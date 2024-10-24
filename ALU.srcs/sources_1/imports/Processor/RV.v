`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: RV
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified unless you modify Wrapper.v/vhd too. 
                        The implementation can be modified.
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate anyone's intellectual property.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh<dot>panicker<at>ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file as well as any files derived from this.
----------------------------------------------------------------------------------
*/

// Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
// A 2-1 multiplexing can be done easily using an assign with a ternary operator
// For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT use nested ternary assignment operator as it hampers the readability of your code.

module RV(
    input CLK,
    input RESET,
    //input Interrupt,  
    input [31:0] Instr,
    input [31:0] ReadData_in,  // v2: Renamed to support lb/lbu/lh/lhu
    output MemRead,
    output [3:0] MemWrite_out,  // v2: Changed to support sb/sh
    output [31:0] PC,
    output [31:0] FinalALUResult,
    output [31:0] WriteData_out  // v2: Renamed to support sb/sh
    );
    
    // RV Signals
    wire [2:0] SizeSel;
    wire [31:0] ReadData;
    wire [31:0] WriteData;
    wire MemWrite;

    // RegFile signals
    wire WE;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] WD;
    wire [31:0] R15;
    wire [31:0] RD1;
    wire [31:0] RD2;
     
    // Extend Module signals
    wire [2:0] ImmSrc;
    wire [24:0] InstrImm;
    wire [31:0] ExtImm;
    
    // Decoder signals
    wire [6:0] Opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [1:0] PCS;
    wire RegWrite;
    wire MemtoReg;
    wire [1:0] ALUSrcA;
    wire ALUSrcB;
    wire [3:0] ALUControl;

    // PC_Logic signals
    wire [1:0] PCSrc;

    // ALU signals
    wire [31:0] Src_A;
    wire [31:0] Src_B;
    wire [31:0] ALUResult;
    wire [2:0] ALUFlags;

    // ProgramCounter signals
    wire WE_PC;
    wire [31:0] PC_IN;
    
    // Other internal signals here
    wire [31:0] PC_Offset;
    wire [31:0] Result;
    
    wire MCycleStart;
    wire [1:0] MCycleOp;
    wire [31:0] MCycle_Result1; // LSW of Product / Quotient
    wire [31:0] MCycle_Result2; // MSW of Product / Remainder
    wire Busy;
    wire MCycleSelect;
    
    assign MemRead = MemtoReg; // This is needed for the proper functionality of some devices such as UART CONSOLE
    assign WE_PC = ~Busy; // For multi-cycle operations (Multiplication, Division) or Pipelining with hazard hardware.
    
    // v2: Added to support lb/lbu/lh/lhu/sb/sh
    assign ReadData = ReadData_in;  
    assign WriteData_out = WriteData;  
    assign MemWrite_out = {4{MemWrite}}; 
    assign SizeSel = 3'b010;  

    // instruction parsing
    assign Opcode = Instr[6:0];
    assign Funct3 = Instr[14:12];
    assign Funct7 = Instr[31:25];
    assign rs1 = Instr[19:15];
    assign rs2 = Instr[24:20];
    assign rd = Instr[11:7];
    assign InstrImm = Instr[31:7];

    // ALU Connection
    assign Src_A = (ALUSrcA[0] == 1'b0) ? RD1 :
                   (ALUSrcA[1] == 1'b0) ? 32'b0 :
                   (ALUSrcA == 2'b11) ? PC :
                   32'bx;

    assign Src_B = ALUSrcB ? ExtImm : RD2;

    // PC Update Logic
    assign PC_Offset = ExtImm;
    assign PC_IN = (PCSrc == 2'b00) ? PC + 4 :
                   (PCSrc == 2'b01) ? PC + ExtImm :
                   (PCSrc == 2'b10) ? {ALUResult[31:1], 1'b0} :
                   (PCSrc == 2'b11) ? {ALUResult[31:1], 1'b0} :
                   PC + 4;

    // WriteData for memory operations
    assign WriteData = RD2;

    // result selection
    assign Result = MemtoReg ? ReadData : MCycleSelect ? MCycle_Result1 : ALUResult;
    assign WD = Result;
    assign WE = RegWrite;
    
    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE,
                    rs1,
                    rs2,
                    rd,
                    WD,
                    RD1,
                    RD2     
                );
                
    // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Opcode,
                    Funct3,
                    Funct7,
                    PCS,
                    RegWrite,
                    MemWrite,
                    MemtoReg,
                    ALUSrcA,
                    ALUSrcB,
                    ImmSrc,
                    ALUControl,
                    MCycleStart,
                    MCycleOp,
                    MCycleSelect
                );
                
    // Instantiate PC_Logic
    PC_Logic PC_Logic1(
                    PCS,
                    Funct3,
                    ALUFlags,
                    PCSrc
    );
                
    // Instantiate ALU        
    ALU ALU1(
                    Src_A,
                    Src_B,
                    ALUControl,
                    ALUResult,
                    ALUFlags
                );                
    
    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(
                    CLK,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    PC  
                ); 

    // Instantiate MCycle
    MCycle MCycle1(
                    CLK,
                    RESET,
                    MCycleStart,
                    MCycleOp,
                    Src_A,
                    Src_B,
                    MCycle_Result1,
                    MCycle_Result2,
                    Busy
                );
    
    assign FinalALUResult = MCycleSelect ? MCycle_Result1 : ALUResult;

endmodule
