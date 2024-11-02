`timescale 1ns / 1ps

// Forwarding Unit Module
module Forwarding_Unit(
    input [4:0] EX_RS1,        // Source Register 1 in EX stage
    input [4:0] EX_RS2,        // Source Register 2 in EX stage
    input [4:0] MEM_RD,        // Destination Register in MEM stage
    input [4:0] WB_RD,         // Destination Register in WB stage
    input MEM_RegWrite,        // RegWrite signal in MEM stage
    input WB_RegWrite,         // RegWrite signal in WB stage
    output reg [1:0] ForwardA, // Forwarding control for EX_RS1
    output reg [1:0] ForwardB  // Forwarding control for EX_RS2
    );

    always @(*) begin
        // Default forwarding paths (no forwarding)
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // Check for forwarding from MEM stage to EX stage
        if (MEM_RegWrite && (MEM_RD != 0) && (MEM_RD == EX_RS1)) begin
            ForwardA = 2'b10; // Forward from MEM stage
        end
        if (MEM_RegWrite && (MEM_RD != 0) && (MEM_RD == EX_RS2)) begin
            ForwardB = 2'b10; // Forward from MEM stage
        end

        // Check for forwarding from WB stage to EX stage
        if (WB_RegWrite && (WB_RD != 0)) begin
            if ((WB_RD == EX_RS1) && !(MEM_RegWrite && (MEM_RD == EX_RS1))) begin
                ForwardA = 2'b01; // Forward from WB stage
            end
            if ((WB_RD == EX_RS2) && !(MEM_RegWrite && (MEM_RD == EX_RS2))) begin
                ForwardB = 2'b01; // Forward from WB stage
            end
        end
    end
endmodule

