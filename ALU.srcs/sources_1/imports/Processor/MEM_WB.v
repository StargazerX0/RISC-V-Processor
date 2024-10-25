`timescale 1ns / 1ps

// MEM/WB Pipeline Register with Enable
module MEM_WB(
    input CLK,
    input RESET,
    input enable,
    input RegWrite_MEM_in,
    input MemtoReg_MEM_in,
    input [31:0] ReadData_in,
    input [31:0] ALUResult_in,
    input [4:0] rd_MEM_in,
    output reg RegWrite_WB,
    output reg MemtoReg_WB,
    output reg [31:0] ReadData_WB,
    output reg [31:0] ALUResult_WB,
    output reg [4:0] rd_WB
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            RegWrite_WB <= 0;
            MemtoReg_WB <= 0;
            ReadData_WB <= 0;
            ALUResult_WB <= 0;
            rd_WB <= 0;
        end else if (enable) begin
            RegWrite_WB <= RegWrite_MEM_in;
            MemtoReg_WB <= MemtoReg_MEM_in;
            ReadData_WB <= ReadData_in;
            ALUResult_WB <= ALUResult_in;
            rd_WB <= rd_MEM_in;
        end
    end
endmodule

