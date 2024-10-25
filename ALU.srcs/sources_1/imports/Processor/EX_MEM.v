`timescale 1ns / 1ps

// EX/MEM Pipeline Register with Enable and MemWrite
module EX_MEM(
    input CLK,
    input RESET,
    input enable,
    input RegWrite_EX_in,
    input MemtoReg_EX_in,
    input MemWrite_EX_in,      // Added MemWrite_EX_in
    input [31:0] ALUResult_in,
    input [31:0] RD2_EX_in,
    input [4:0] rd_EX_in,
    output reg RegWrite_MEM,
    output reg MemtoReg_MEM,
    output reg MemWrite_MEM,    // Added MemWrite_MEM
    output reg [31:0] ALUResult_MEM,
    output reg [31:0] RD2_MEM,
    output reg [4:0] rd_MEM
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            RegWrite_MEM <= 0;
            MemtoReg_MEM <= 0;
            MemWrite_MEM <= 0;    // Initialize MemWrite_MEM
            ALUResult_MEM <= 0;
            RD2_MEM <= 0;
            rd_MEM <= 0;
        end else if (enable) begin
            RegWrite_MEM <= RegWrite_EX_in;
            MemtoReg_MEM <= MemtoReg_EX_in;
            MemWrite_MEM <= MemWrite_EX_in;  // Assign MemWrite_MEM
            ALUResult_MEM <= ALUResult_in;
            RD2_MEM <= RD2_EX_in;
            rd_MEM <= rd_EX_in;
        end
    end
endmodule
