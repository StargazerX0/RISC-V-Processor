`timescale 1ns / 1ps

// Main Pipelined RISC-V Processor with MCycle Integration
module Pipelined_RV(
    input CLK,
    input RESET,
    //input Interrupt,  
    input [31:0] Instr,           // Instruction input for the current PC
    input [31:0] ReadData_in,     // Data read from memory (e.g., load instructions)
    output MemRead,               // Memory read enable signal
    output [3:0] MemWrite_out,    // Memory write enable signal (supports sb/sh)
    output [31:0] PC,             // Current Program Counter value
    output [31:0] FinalALUResult, // Final ALU result after pipeline
    output [31:0] WriteData_out   // Data to write to memory (e.g., store instructions)
    );

// ---------------------------------
// Pipeline Stage Wires
// ---------------------------------

// IF Stage
wire [31:0] PC_IF;
wire [31:0] Instr_IF;

// IF/ID Pipeline Register
wire [31:0] PC_ID;
wire [31:0] Instr_ID;

// ID Stage
wire [31:0] RD1_ID;
wire [31:0] RD2_ID;
wire [31:0] ExtImm_ID;
wire [4:0] rs1_ID;
wire [4:0] rs2_ID;
wire [4:0] rd_ID;

// Control Signals ID Stage
wire RegWrite_ID;
wire MemtoReg_ID;
wire [1:0] ALUSrcA_ID;
wire ALUSrcB_ID;
wire [3:0] ALUControl_ID;
wire MCycleStart_ID;
wire [1:0] MCycleOp_ID;
wire MCycleSelect_ID;
wire [2:0] ImmSrc_ID;

// ID/EX Pipeline Register
wire [31:0] RD1_EX;
wire [31:0] RD2_EX;
wire [31:0] ExtImm_EX;
wire [4:0] rs1_EX;
wire [4:0] rs2_EX;
wire [4:0] rd_EX;
wire [31:0] PC_EX;
wire RegWrite_EX;
wire MemtoReg_EX;
wire [1:0] ALUSrcA_EX;
wire ALUSrcB_EX;
wire [3:0] ALUControl_EX;
wire MCycleStart_EX;
wire [1:0] MCycleOp_EX;
wire MCycleSelect_EX;
wire [2:0] ImmSrc_EX;
wire [1:0] PCS_EX;
wire [2:0] Funct3_EX; // Added Funct3_EX

// EX Stage
wire [31:0] Src_A_EX;
wire [31:0] Src_B_EX;
wire [31:0] ALUResult_EX;
wire [2:0] ALUFlags_EX;

// EX/MEM Pipeline Register
wire [31:0] ALUResult_MEM;
wire [31:0] RD2_MEM;
wire [4:0] rd_MEM;
wire RegWrite_MEM;
wire MemtoReg_MEM;
wire MemWrite_MEM;  // Declared MemWrite_MEM

// MEM Stage
wire [31:0] ReadData_MEM;

// MEM/WB Pipeline Register
wire [31:0] ReadData_WB;
wire [31:0] ALUResult_WB;
wire [4:0] rd_WB;
wire RegWrite_WB;
wire MemtoReg_WB;

// Write Back Stage
wire [31:0] WD_WB;

// Final ALU Result
wire [31:0] ALUResult_WB_Final;

// Additional Wires
wire [24:0] InstrImm_ID; // Declared InstrImm_ID
//wire [2:0] Funct3_EX;

// ---------------------------------
// Control and Stall Signals
// ---------------------------------

wire Busy;       // From MCycle module indicating multi-cycle operation
wire stall;      // Stall signal based on Busy

// Generate Stall Signal
assign stall = Busy;

// ---------------------------------
// Program Counter Logic
// ---------------------------------

// Instruction Parsing
wire [6:0] Opcode_ID;
wire [2:0] Funct3_ID;
wire [6:0] Funct7_ID;
wire [1:0] PCS_ID;

// Removed duplicate declaration of PCS_EX

wire [1:0] PCSrc_EX;

// Instantiate PC_Logic
PC_Logic PC_Logic1(
    .PCS(PCS_EX),
    .Funct3(Funct3_EX),       // Changed from Funct3_ID to Funct3_EX
    .ALUFlags(ALUFlags_EX),
    .PCSrc(PCSrc_EX)
);

// PC_IN should use ALUResult_EX instead of FinalALUResult
wire [31:0] PC_IN;
assign PC_IN = (PCSrc_EX == 2'b00) ? PC_IF + 4 :
               (PCSrc_EX == 2'b01) ? PC_IF + ExtImm_EX - 8:
               (PCSrc_EX == 2'b10) ? {ALUResult_EX[31:1], 1'b0} - 8:
               (PCSrc_EX == 2'b11) ? RD1_EX + ExtImm_EX:
               PC_IF + 4; // Default case

// PC Update Logic with Stall
ProgramCounter PC1(
    .CLK(CLK),
    .RESET(RESET),
    .WE_PC(~stall),    // Disable PC update when stalled
    .PC_IN(PC_IN),
    .PC(PC_IF)         // Corrected port connection from 'PC_OUT' to 'PC'
);

// Instruction Memory Fetch
// Instr_IF is directly assigned from the Instr input
assign Instr_IF = Instr;

// ---------------------------------
// IF/ID Pipeline Register
// ---------------------------------

IF_ID IF_ID1(
    .CLK(CLK),
    .RESET(RESET),
    .enable(~stall),  // Disable IF/ID update when stalled
    .PC_IF(PC_IF),
    .Instr_IF(Instr_IF),
    .PC_ID(PC_ID),
    .Instr_ID(Instr_ID)
);

// ---------------------------------
// ID Stage
// ---------------------------------

assign Opcode_ID = Instr_ID[6:0];
assign Funct3_ID = Instr_ID[14:12];
assign Funct7_ID = Instr_ID[31:25];
assign rs1_ID = Instr_ID[19:15];
assign rs2_ID = Instr_ID[24:20];
assign rd_ID = Instr_ID[11:7];
assign InstrImm_ID = Instr_ID[31:7]; // Now declared

// Instantiate RegFile
RegFile RegFile1( 
    .CLK(CLK),
    .WE(RegWrite_WB),
    .rs1(rs1_ID),
    .rs2(rs2_ID),
    .rd(rd_WB),        // From MEM/WB stage
    .WD(WD_WB),
    .RD1(RD1_ID),
    .RD2(RD2_ID)     
);

// Instantiate Extend Module
Extend Extend1(
    .ImmSrc(ImmSrc_ID),
    .InstrImm(InstrImm_ID),
    .ExtImm(ExtImm_ID)
);

// Instantiate Decoder
Decoder Decoder1(
    .Opcode(Opcode_ID),
    .Funct3(Funct3_ID),
    .Funct7(Funct7_ID),
    .PCS(PCS_ID),
    .RegWrite(RegWrite_ID),
    .MemWrite(MemWrite_ID),
    .MemtoReg(MemtoReg_ID),
    .ALUSrcA(ALUSrcA_ID),
    .ALUSrcB(ALUSrcB_ID),
    .ImmSrc(ImmSrc_ID),
    .ALUControl(ALUControl_ID),
    .MCycleStart(MCycleStart_ID),
    .MCycleOp(MCycleOp_ID),
    .MCycleSelect(MCycleSelect_ID)
);

// ---------------------------------
// ID/EX Pipeline Register
// ---------------------------------

ID_EX ID_EX1(
    .CLK(CLK),
    .RESET(RESET),
    .enable(~stall),  // Disable ID/EX update when stalled
    // Control signals
    .RegWrite_in(RegWrite_ID),
    .MemtoReg_in(MemtoReg_ID),
    .ALUSrcA_in(ALUSrcA_ID),
    .ALUSrcB_in(ALUSrcB_ID),
    .ALUControl_in(ALUControl_ID),
    .MCycleStart_in(MCycleStart_ID),
    .MCycleOp_in(MCycleOp_ID),
    .MCycleSelect_in(MCycleSelect_ID),
    .ImmSrc_in(ImmSrc_ID),
    .PCS_in(PCS_ID),         // Pass PCS from Decoder
    .Funct3_in(Funct3_ID),   // Pass Funct3 from ID stage
    // Data signals
    .RD1_in(RD1_ID),
    .RD2_in(RD2_ID),
    .ExtImm_in(ExtImm_ID),
    .rs1_in(rs1_ID),
    .rs2_in(rs2_ID),
    .rd_in(rd_ID),
    .PC_in(PC_ID),            // Pass PC from IF/ID to ID/EX
    // Outputs
    .RegWrite_EX(RegWrite_EX),
    .MemtoReg_EX(MemtoReg_EX),
    .ALUSrcA_EX(ALUSrcA_EX),
    .ALUSrcB_EX(ALUSrcB_EX),
    .ALUControl_EX(ALUControl_EX),
    .MCycleStart_EX(MCycleStart_EX),
    .MCycleOp_EX(MCycleOp_EX),
    .MCycleSelect_EX(MCycleSelect_EX),
    .ImmSrc_EX(ImmSrc_EX),
    .PCS_EX(PCS_EX),          // Output PCS to EX stage
    .Funct3_EX(Funct3_EX),    // Output Funct3_EX
    .RD1_EX(RD1_EX),
    .RD2_EX(RD2_EX),
    .ExtImm_EX(ExtImm_EX),
    .rs1_EX(rs1_EX),
    .rs2_EX(rs2_EX),
    .rd_EX(rd_EX),
    .PC_EX(PC_EX)
);

// ---------------------------------
// EX Stage
// ---------------------------------

// ALU Source A Selection
assign Src_A_EX = (ALUSrcA_EX[0] == 1'b0) ? RD1_EX :
                  (ALUSrcA_EX[1] == 1'b0) ? 32'b0 :
                  (ALUSrcA_EX == 2'b11) ? PC_EX :
                  32'bx;

// ALU Source B Selection
assign Src_B_EX = ALUSrcB_EX ? ExtImm_EX : RD2_EX;

// Instantiate ALU        
wire [31:0] ALUResult_EX_internal;

ALU ALU1(
    .Src_A(Src_A_EX),
    .Src_B(Src_B_EX),
    .ALUControl(ALUControl_EX),
    .ALUResult(ALUResult_EX_internal),
    .ALUFlags(ALUFlags_EX)
);                

// Instantiate MCycle
wire [31:0] MCycle_Result1;
wire [31:0] MCycle_Result2;

MCycle MCycle1(
    .CLK(CLK),
    .RESET(RESET),
    .Start(MCycleStart_EX),
    .MCycleOp(MCycleOp_EX),
    .Operand1(RD1_EX),
    .Operand2(RD2_EX),
    .Result1(MCycle_Result1), // LSW of Product / Quotient
    .Result2(MCycle_Result2), // MSW of Product / Remainder
    .Busy(Busy)
);

// Final ALU Result considering MCycle
//assign ALUResult_EX = MCycleSelect_EX ? MCycle_Result1 : ALUResult_EX_internal;

// 3'h0 -> mul, 3'h1 -> mulh, 3'h2 -> mulsu, 3'h3 -> mulu
// 3'h4 -> div, 4'h5 -> divu
// 3'h6 -> rem, 4'h7 -> remu

assign ALUResult_EX = ~MCycleSelect_EX ? ALUResult_EX_internal : 
                        ((Funct3_EX == 3'h0 || Funct3_EX == 3'h4 || 
                          Funct3_EX == 3'h5) ? MCycle_Result1 : 
                         (Funct3_EX == 3'h1 || Funct3_EX == 3'h3 || 
                          Funct3_EX == 3'h6 || Funct3_EX == 3'h7) ? 
                          MCycle_Result2 : 32'bx);    

// ---------------------------------
// EX/MEM Pipeline Register
// ---------------------------------

EX_MEM EX_MEM1(
    .CLK(CLK),
    .RESET(RESET),
    .enable(~stall),          // Disable EX/MEM update when stalled
    .RegWrite_EX_in(RegWrite_EX),
    .MemtoReg_EX_in(MemtoReg_EX),
    .MemWrite_EX_in(MemWrite_EX),  // Changed from MemWrite_ID to MemWrite_EX
    .ALUResult_in(ALUResult_EX),
    .RD2_EX_in(RD2_EX),
    .rd_EX_in(rd_EX),
    .RegWrite_MEM(RegWrite_MEM),
    .MemtoReg_MEM(MemtoReg_MEM),
    .MemWrite_MEM(MemWrite_MEM),    // Receive MemWrite_MEM from EX_MEM
    .ALUResult_MEM(ALUResult_MEM),
    .RD2_MEM(RD2_MEM),
    .rd_MEM(rd_MEM)
);

// ---------------------------------
// MEM Stage
// ---------------------------------

// Memory operations
// For demonstration, connecting ReadData_MEM directly
// In practice, instantiate a memory module here
assign ReadData_MEM = ReadData_in;

// Control Signals for Memory
assign MemRead = MemtoReg_MEM;                // Proper functionality for devices like UART CONSOLE
assign MemWrite_out = {4{MemWrite_MEM}};      // Support sb/sh by replicating MemWrite_MEM
assign WriteData_out = RD2_MEM;               // Data to write to memory

// ---------------------------------
// MEM/WB Pipeline Register
// ---------------------------------

MEM_WB MEM_WB1(
    .CLK(CLK),
    .RESET(RESET),
    .enable(~stall),                          // Disable MEM/WB update when stalled
    .RegWrite_MEM_in(RegWrite_MEM),
    .MemtoReg_MEM_in(MemtoReg_MEM),
    .ReadData_in(ReadData_MEM),
    .ALUResult_in(ALUResult_MEM),
    .rd_MEM_in(rd_MEM),
    .RegWrite_WB(RegWrite_WB),
    .MemtoReg_WB(MemtoReg_WB),
    .ReadData_WB(ReadData_WB),
    .ALUResult_WB(ALUResult_WB),
    .rd_WB(rd_WB)
);

// ---------------------------------
// Write Back Stage
// ---------------------------------

// Write Back Data Selection
assign WD_WB = MemtoReg_WB ? ReadData_WB : ALUResult_WB;

// Removed unused assignments
// assign WD_ID = WD_WB;
// assign WE_ID = RegWrite_WB;

// Final ALU Result Output
assign FinalALUResult = ALUResult_WB;

// PC Output
assign PC = PC_IF;

endmodule
