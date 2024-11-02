`timescale 1ns / 1ps

// ID/EX Pipeline Register with Enable and Flush
module ID_EX_Complete(
    input CLK,
    input RESET,
    input enable,
    input flush,                 // Flush input to insert NOP
    // Control signals
    input RegWrite_in,
    input MemtoReg_in,
    input [1:0] ALUSrcA_in,
    input ALUSrcB_in,
    input [3:0] ALUControl_in,
    input MCycleStart_in,
    input [1:0] MCycleOp_in,
    input MCycleSelect_in,
    input [2:0] ImmSrc_in,
    input [1:0] PCS_in,
    input [2:0] Funct3_in,
    input MemWrite_in,           // Add MemWrite_in
    // Data signals
    input [31:0] RD1_in,
    input [31:0] RD2_in,
    input [31:0] ExtImm_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input [31:0] PC_in,
    // Outputs
    output reg RegWrite_EX,
    output reg MemtoReg_EX,
    output reg [1:0] ALUSrcA_EX,
    output reg ALUSrcB_EX,
    output reg [3:0] ALUControl_EX,
    output reg MCycleStart_EX,
    output reg [1:0] MCycleOp_EX,
    output reg MCycleSelect_EX,
    output reg [2:0] ImmSrc_EX,
    output reg [1:0] PCS_EX,      // Pass PCS to EX stage
    output reg [2:0] Funct3_EX,   // Pass Funct3 to EX stage
    output reg [31:0] RD1_EX,
    output reg [31:0] RD2_EX,
    output reg [31:0] ExtImm_EX,
    output reg [4:0] rs1_EX,
    output reg [4:0] rs2_EX,
    output reg [4:0] rd_EX,
    output reg [31:0] PC_EX,
    output reg MemWrite_EX        // Add MemWrite_EX
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            // Initialize all outputs to 0
            RegWrite_EX <= 0;
            MemtoReg_EX <= 0;
            ALUSrcA_EX <= 0;
            ALUSrcB_EX <= 0;
            ALUControl_EX <= 0;
            MCycleStart_EX <= 0;
            MCycleOp_EX <= 2'b00;
            MCycleSelect_EX <= 0;
            ImmSrc_EX <= 0;
            PCS_EX <= 0;
            Funct3_EX <= 0;
            RD1_EX <= 0;
            RD2_EX <= 0;
            ExtImm_EX <= 0;
            rs1_EX <= 0;
            rs2_EX <= 0;
            rd_EX <= 0;
            PC_EX <= 0;
            MemWrite_EX <= 0;
        end else if (flush) begin
            // Insert NOP by clearing control signals and data
            RegWrite_EX <= 0;
            MemtoReg_EX <= 0;
            ALUSrcA_EX <= 0;
            ALUSrcB_EX <= 0;
            ALUControl_EX <= 4'b0000;
            MCycleStart_EX <= 0;
            MCycleOp_EX <= 2'b00;
            MCycleSelect_EX <= 0;
            ImmSrc_EX <= 0;
            PCS_EX <= 0;
            Funct3_EX <= 0;
            RD1_EX <= 0;
            RD2_EX <= 0;
            ExtImm_EX <= 0;
            rs1_EX <= 0;
            rs2_EX <= 0;
            rd_EX <= 0;
            PC_EX <= 0;
            MemWrite_EX <= 0;
        end else if (enable) begin
            // Normal operation: pass through control and data signals
            RegWrite_EX <= RegWrite_in;
            MemtoReg_EX <= MemtoReg_in;
            ALUSrcA_EX <= ALUSrcA_in;
            ALUSrcB_EX <= ALUSrcB_in;
            ALUControl_EX <= ALUControl_in;
            MCycleStart_EX <= MCycleStart_in;
            MCycleOp_EX <= MCycleOp_in;
            MCycleSelect_EX <= MCycleSelect_in;
            ImmSrc_EX <= ImmSrc_in;
            PCS_EX <= PCS_in;
            Funct3_EX <= Funct3_in;
            RD1_EX <= RD1_in;
            RD2_EX <= RD2_in;
            ExtImm_EX <= ExtImm_in;
            rs1_EX <= rs1_in;
            rs2_EX <= rs2_in;
            rd_EX <= rd_in;
            PC_EX <= PC_in;
            MemWrite_EX <= MemWrite_in;  // Pass through MemWrite_in
        end
    end
endmodule


