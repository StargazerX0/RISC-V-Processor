`timescale 1ns / 1ps

// IF/ID Pipeline Register with Enable and Flush
module IF_ID(
    input CLK,
    input RESET,
    input enable,
    input flush,                 // New flush input
    input [31:0] PC_IF,
    input [31:0] Instr_IF,
    output reg [31:0] PC_ID,
    output reg [31:0] Instr_ID
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            PC_ID <= 0;
            Instr_ID <= 0;
        end else if (flush) begin
            PC_ID <= 0;
            Instr_ID <= 32'b0;    // Insert NOP
        end else if (enable) begin
            PC_ID <= PC_IF;
            Instr_ID <= Instr_IF;
        end
    end
endmodule



