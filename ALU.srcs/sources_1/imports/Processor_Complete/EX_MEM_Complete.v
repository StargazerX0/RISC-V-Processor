`timescale 1ns / 1ps

// EX/MEM Pipeline Register
module EX_MEM_Complete(
    input CLK,
    input RESET,
    input RegWrite_EX,
    input MemtoReg_EX,
    input [31:0] ALUResult_EX,
    input [31:0] RD2_EX,
    input [4:0] rd_EX,
    input MemWrite_EX,            // Add MemWrite_EX
    output reg RegWrite_MEM,
    output reg MemtoReg_MEM,
    output reg [31:0] ALUResult_MEM,
    output reg [31:0] RD2_MEM,
    output reg [4:0] rd_MEM,
    output reg MemWrite_MEM        // Add MemWrite_MEM
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            RegWrite_MEM <= 0;
            MemtoReg_MEM <= 0;
            ALUResult_MEM <= 0;
            RD2_MEM <= 0;
            rd_MEM <= 0;
            MemWrite_MEM <= 0;     // Initialize MemWrite_MEM
        end else begin
            RegWrite_MEM <= RegWrite_EX;
            MemtoReg_MEM <= MemtoReg_EX;
            ALUResult_MEM <= ALUResult_EX;
            RD2_MEM <= RD2_EX;
            rd_MEM <= rd_EX;
            MemWrite_MEM <= MemWrite_EX; // Pass through MemWrite_EX
        end
    end
endmodule

