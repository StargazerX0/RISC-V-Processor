`timescale 1ns / 1ps

// Hazard Detection Unit Module
module Hazard_Detection_Unit(
    input [4:0] ID_RS1,        // Source Register 1 in ID stage
    input [4:0] ID_RS2,        // Source Register 2 in ID stage
    input EX_MemRead,          // MemRead signal in EX stage
    input EX_MemWrite,         // MemWrite signal in EX stage (for store instructions)
    input [4:0] EX_RD,         // Destination Register in EX stage
    input [1:0] PCSrc_EX,      // PC Source from EX stage (for branches and jumps)
    input ID_MemRead,          // MemRead signal in ID stage (for load instructions)
    output reg Stall,          // Stall signal
    output reg Flush           // Flush signal
    );

    always @(*) begin
        // Default: No stall or flush
        Stall = 1'b0;
        Flush = 1'b0;

        // Load-Use Hazard: If the EX stage is loading a register that the ID stage needs
        if (EX_MemRead && ((EX_RD == ID_RS1) || (EX_RD == ID_RS2))) begin
            Stall = 1'b1; // Stall the pipeline
        end

        // Store-Load Hazard: If the EX stage is storing and the ID stage is loading
        if (EX_MemWrite && ID_MemRead) begin
            Stall = 1'b1; // Stall the pipeline
        end
        // if (EX_MemRead && ((EX_RD == ID_RS1) || (EX_RD == ID_RS2))) begin
        //     Stall = 1'b1; // Stall the pipeline
        // end

        // Control Hazard: If a branch is taken, flush the IF/ID pipeline register
        if (PCSrc_EX != 2'b00) begin
            Flush = 1'b1;
        end
    end
endmodule














