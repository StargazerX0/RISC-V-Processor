`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Interface and implementation can be modified.
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

module Decoder(
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [6:0] Funct7,
    output reg [1:0] PCS,           // 00: Non-control, 01: Conditional branch, 10: JAL, 11: JALR
    output reg RegWrite,            // Register write enable
    output reg MemWrite,            // Memory write enable
    output reg MemtoReg,            // Memory to register enable (for load instructions)
    output reg [1:0] ALUSrcA,       // ALU Source A selector
    output reg ALUSrcB,             // ALU Source B selector
    output reg [2:0] ImmSrc,        // Immediate source selector
    output reg [3:0] ALUControl,    // ALU operation control
    output reg MCycleStart,         // Multi-cycle operation start
    output reg [1:0] MCycleOp,      // Multi-cycle operation type
    output reg MCycleSelect         // Multi-cycle operation selection
); 

    // Combined always block for control signal assignments and multi-cycle logic
    always @ (*) begin
        // ----------------------------
        // Default Assignments
        // ----------------------------
        PCS = 2'b00;               // Default: Non-control (sequential execution)
        MemtoReg = 1'b0;           // Default: No memory to register transfer
        RegWrite = 1'b0;           // Default: No register write
        MemWrite = 1'b0;           // Default: No memory write
        ALUSrcA = 2'b00;           // Default: ALU Source A = Register rs1
        ALUSrcB = 1'b0;            // Default: ALU Source B = Register rs2
        ImmSrc = 3'b000;           // Default: Immediate not used
        ALUControl = 4'b0000;      // Default: ALU operation = ADD
        MCycleStart = 1'b0;        // Default: No multi-cycle operation
        MCycleOp = 2'b00;          // Default: No specific multi-cycle operation
        MCycleSelect = 1'b0;       // Default: Use ALU result, not MCycle result

        // ----------------------------
        // Opcode-Based Control Signal Assignments
        // ----------------------------
        case (Opcode)
            7'h33: begin // R-type (DP Reg)
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b0;        // No memory to register transfer
                RegWrite = 1'b1;        // Enable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b10;        // ALU Source A: Register rs1
                ALUSrcB = 1'b0;         // ALU Source B: Register rs2
                ImmSrc = 3'b000;        // Immediate not used for R-type
                ALUControl = {Funct3, Funct7[5]}; // ALU operation based on Funct3 and Funct7[5]
            end

            7'h13: begin // I-type (DP Imm)
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b0;        // No memory to register transfer
                RegWrite = 1'b1;        // Enable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b10;        // ALU Source A: Register rs1
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b011;        // Immediate source: I-type
                ALUControl[3:1] = Funct3; // ALU operation based on Funct3
                if (Funct3 == 3'h5) begin // SRAI or SRLI based on Funct7[5]
                    ALUControl[0] = Funct7[5];
                end else begin
                    ALUControl[0] = 1'b0; // Default for other I-type instructions
                end 
            end

            7'h03: begin // Load
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b1;        // Memory to register transfer
                RegWrite = 1'b1;        // Enable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b10;        // ALU Source A: Register rs1
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b011;        // Immediate source: I-type
                ALUControl = 4'b0000;   // ALU operation: ADD (calculate address)
            end

            7'h23: begin // Store
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b0;        // Not used for store
                RegWrite = 1'b0;        // Disable register write
                MemWrite = 1'b1;        // Enable memory write
                ALUSrcA = 2'b10;        // ALU Source A: Register rs1
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b110;        // Immediate source: S-type
                ALUControl = 4'b0000;   // ALU operation: ADD (calculate address)
            end
            
            7'h63: begin // Branch
                PCS = 2'b01;            // Conditional branch
                MemtoReg = 1'b0;        // Not used for branch
                RegWrite = 1'b0;        // Disable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b10;        // ALU Source A: Register rs1
                ALUSrcB = 1'b0;         // ALU Source B: Register rs2
                ImmSrc = 3'b111;        // Immediate source: SB-type
                ALUControl = 4'b0001;   // ALU operation: SUB (for comparison)
            end

            7'h67: begin // JALR (Jump and Link Register)
                PCS = 2'b11;            // Unconditional jump
                MemtoReg = 1'b0;        // Not used for jump
                RegWrite = 1'b1;        // Enable register write (link)
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b11;        // ALU Source A: PC
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b011;        // Immediate source: I-type
                ALUControl = 4'b0000;   // ALU operation: ADD (PC + immediate)
            end
            
            7'h6F: begin // JAL (Jump and Link)
                PCS = 2'b10;            // Unconditional jump
                MemtoReg = 1'b0;        // Not used for jump
                RegWrite = 1'b1;        // Enable register write (link)
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b11;        // ALU Source A: PC
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b010;        // Immediate source: UJ-type
                ALUControl = 4'b0000;   // ALU operation: ADD (PC + immediate)
            end

            7'h17: begin // AUIPC
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b0;        // No memory to register transfer
                RegWrite = 1'b1;        // Enable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b11;        // ALU Source A: PC
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b000;        // Immediate source: U-type
                ALUControl = 4'b0000;   // ALU operation: ADD (PC + immediate)
            end

            7'h37: begin // LUI
                PCS = 2'b00;            // Non-control
                MemtoReg = 1'b0;        // No memory to register transfer
                RegWrite = 1'b1;        // Enable register write
                MemWrite = 1'b0;        // Disable memory write
                ALUSrcA = 2'b01;        // ALU Source A: Upper immediate
                ALUSrcB = 1'b1;         // ALU Source B: Immediate
                ImmSrc = 3'b000;        // Immediate source: U-type
                ALUControl = 4'b0000;   // ALU operation: ADD (replace upper bits)
            end

            default: begin // Unknown Opcode
                // Control signals remain at default values set initially
                // No action needed as defaults are already set
            end
        endcase

        // ----------------------------
        // Multi-Cycle Operation Logic
        // ----------------------------
        // Only specific R-type instructions initiate multi-cycle operations
        if (Opcode == 7'h33 && (Funct3 == 3'h2 || Funct3 == 3'h3) && Funct7 == 7'h01) begin
                    MCycleStart = 1'b1;
                    MCycleOp = 2'b01;       // Example: Unsigned Multiply
                    MCycleSelect = 1'b1;    // Select MCycle result
                end
                else if (Opcode == 7'h33 && (Funct3 == 3'h5 || Funct3 == 3'h7) && Funct7 == 7'h01) begin
                    MCycleStart = 1'b1;
                    MCycleOp = 2'b11;       // Example: Unsigned Division
                    MCycleSelect = 1'b1;    // Select MCycle result
                end
                else if (Opcode == 7'h33 && (Funct3 == 3'h4 || Funct3 == 3'h6) && Funct7 == 7'h01) begin
                    MCycleStart = 1'b1;
                    MCycleOp = 2'b10;       // Example: Signed Division
                    MCycleSelect = 1'b1;    // Select MCycle result
                end
                else begin
                    MCycleStart = 1'b0;
                    MCycleOp = 2'b00;
                    MCycleSelect = 1'b0;
                end
    end

endmodule
