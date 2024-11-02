`timescale 1ns / 1ps

// Hazard Detection Unit Module with Enhanced FSM for Multiple Stall Cycles
module Hazard_Detection_Unit(
    input CLK,
    input RESET,
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

    // Define states using parameters (Standard Verilog)
    parameter IDLE            = 2'b00;
    parameter STALL_LOAD      = 2'b01; // For Load-Use Hazard (1 stall cycle)
    parameter STALL_STORE_1   = 2'b10; // First stall cycle for Store-Load Hazard
    parameter STALL_STORE_2   = 2'b11; // Second stall cycle for Store-Load Hazard

    reg [1:0] current_state, next_state;

    // State Transition on Clock Edge
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next State Logic and Output Generation
    always @(*) begin
        // Default assignments
        Stall = 1'b0;
        Flush = 1'b0;
        next_state = current_state;

        case (current_state)
            IDLE: begin
                // Control Hazard Detection
                if (PCSrc_EX != 2'b00) begin
                    Flush = 1'b1;
                    // Typically, Flush requires one cycle; no state change needed
                end

                // Load-Use Hazard Detection
                if (EX_MemRead && ((EX_RD == ID_RS1) || (EX_RD == ID_RS2))) begin
                    Stall = 1'b1;
                    next_state = STALL_LOAD;
                end
                // Store-Load Hazard Detection
                else if (EX_MemWrite && ID_MemRead) begin
                    Stall = 1'b1;
                    next_state = STALL_STORE_1;
                end
            end

            STALL_LOAD: begin
                // Assert Stall for one cycle
                Stall = 1'b1;
                // After one stall cycle, return to IDLE
                next_state = IDLE;
            end

            STALL_STORE_1: begin
                // Assert Stall for first cycle
                Stall = 1'b1;
                // Transition to second stall cycle
                next_state = STALL_STORE_2;
            end

            STALL_STORE_2: begin
                // Assert Stall for second cycle
                Stall = 1'b1;
                // After two stall cycles, return to IDLE
                next_state = IDLE;
            end

            default: begin
                Stall = 1'b0;
                Flush = 1'b0;
                next_state = IDLE;
            end
        endcase
    end
endmodule
