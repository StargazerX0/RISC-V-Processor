`timescale 1ns / 1ps

// Hazard Detection Unit Module with FSM and CLEAR_STALL State
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
    input branch_enableE,
    input branch_taken,
    input prediction,
    output reg Stall,          // Stall signal
    input FlushED,
    output reg FlushE,           // Flush signal
    output reg FlushD
    );

// Define states using parameters (Standard Verilog)
parameter IDLE          = 3'b000;
parameter STALL_LOAD    = 3'b001; // For Load-Use Hazard (1 stall cycle)
parameter STALL_STORE_1 = 3'b010; // First stall cycle for Store-Load Hazard
parameter STALL_STORE_2 = 3'b011; // Second stall cycle for Store-Load Hazard
parameter CLEAR_STALL   = 3'b100; // Clear Stall

reg [2:0] current_state, next_state;

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
    FlushE = 1'b0;
    FlushD = 1'b0;
    next_state = current_state;
    
    case (current_state)
        IDLE: begin
            // Control Hazard Detection
            if (branch_enableE) begin
                if (branch_taken) begin
                    FlushE = 1'b1;
                end
                if (!FlushED && ((!branch_taken && prediction) || (branch_taken && !prediction))) begin
                    FlushD = 1'b1;
                end
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
            // Transition to CLEAR_STALL after one stall cycle
            next_state = CLEAR_STALL;
        end

        STALL_STORE_1: begin
            // Assert Stall for first cycle of Store-Load Hazard
            Stall = 1'b1;
            // Transition to STALL_STORE_2 for second stall cycle
            next_state = STALL_STORE_2;
        end

        STALL_STORE_2: begin
            // Assert Stall for second cycle of Store-Load Hazard
            Stall = 1'b1;
            // Transition to CLEAR_STALL after two stall cycles
            next_state = CLEAR_STALL;
        end

        CLEAR_STALL: begin
            // Deassert Stall
            Stall = 1'b0;
            // Transition back to IDLE
            next_state = IDLE;
        end

        default: begin
            Stall = 1'b0;
            next_state = IDLE;
        end
    endcase
end

endmodule
