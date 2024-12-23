`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 10:59:44
// Design Name: 
// Module Name: MCycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/* 
----------------------------------------------------------------------------------
--	(c) Shahzor Ahmad, Rajesh C Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module MCycle

    #(parameter width = 32) // Keep this at 4 to verify your algorithms with 4 bit numbers (easier). When using MCycle as a component in ARM, generic map it to 32.
    (
        input CLK,
        input RESET, // Connect this to the reset of the ARM processor.
        input Start, // Multi-cycle Enable. The control unit should assert this when an instruction with a multi-cycle operation is detected.
        input [1:0] MCycleOp, // Multi-cycle Operation. "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division. Generated by Control unit
        input [width-1:0] Operand1, // Multiplicand / Dividend
        input [width-1:0] Operand2, // Multiplier / Divisor
        output reg [width-1:0] Result1, // LSW of Product / Quotient
        output reg [width-1:0] Result2, // MSW of Product / Remainder
        output reg Busy // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
    );
    
// use the Busy signal to reset WE_PC to 0 in ARM.v (aka "freeze" PC). The two signals are complements of each other
// since the IDLE_PROCESS is combinational, instantaneously asserts Busy once Start is asserted
  
    parameter IDLE = 1'b0 ;  // will cause a warning which is ok to ignore - [Synth 8-2507] parameter declaration becomes local in MCycle with formal parameter declaration list...

    parameter COMPUTING = 1'b1 ; // this line will also cause the above warning
    reg state = IDLE ;
    reg n_state = IDLE ;
   
    reg done ;
    reg [7:0] count = 0 ; // assuming no computation takes more than 256 cycles.
    reg [2*width-1:0] temp_sum = 0 ;
    reg [2*width-1:0] shifted_op1 = 0 ;
    reg [2*width-1:0] shifted_op2 = 0 ;
         
    parameter half_width = width/2; // also will cause the above warning
   
    always@( state, done, Start, RESET ) begin : IDLE_PROCESS  
		// Note : This block uses non-blocking assignments to get around an unpredictable Verilog simulation behaviour.
        // default outputs
        Busy <= 1'b0 ;
        n_state <= IDLE ;
        
        // reset
        if(~RESET)
            case(state)
                IDLE: begin
                    if(Start) begin // note: a mealy machine, since output depends on current state (IDLE) & input (Start)
                        n_state <= COMPUTING ;
                        Busy <= 1'b1 ;
                    end
                end
                COMPUTING: begin
                    if(~done) begin
                        n_state <= COMPUTING ;
                        Busy <= 1'b1 ;
                    end
                end        
            endcase    
    end


    always@( posedge CLK ) begin : STATE_UPDATE_PROCESS // state updating
        state <= n_state ;    
    end
    
    reg op1_sign = 0;
    reg op2_sign = 0;

    wire [half_width-1:0] op1_msb;
    assign op1_msb = Operand1[width-1:half_width];
    wire [half_width-1:0] op1_lsb;
    assign op1_lsb = Operand1[half_width-1:0];
    
    wire [half_width-1:0] op2_msb;
    assign op2_msb = Operand2[width-1:half_width];
    wire [half_width-1:0] op2_lsb;
    assign op2_lsb = Operand2[half_width-1:0];
    
    reg [width-1:0] shifted_op1_msb = 0;
    reg [width-1:0] shifted_op1_lsb = 0;
    reg [width-1:0] shifted_op2_msb = 0;
    reg [width-1:0] shifted_op2_lsb = 0;
    reg [width-1:0] temp_sum_msb = 0;
    reg [width-1:0] temp_sum_lsb = 0;
    
    wire [width-1:0] sum_op1;
    assign sum_op1 = op1_msb + op1_lsb;
    wire [width-1:0] sum_op2;
    assign sum_op2 = op2_msb + op2_lsb;
    
    reg [width-1:0] temp_sum_sum_op = 0;
    reg [width-1:0] shifted_sum_op1 = 0;
    reg [width-1:0] shifted_sum_op2 = 0;
    
    reg [width-1:0] Z1 = 0;
    reg [2*width-1:0] result = 0;

    
    always@( posedge CLK ) begin : COMPUTING_PROCESS // process which does the actual computation
        // n_state == COMPUTING and state == IDLE implies we are just transitioning into COMPUTING
        if( RESET | (n_state == COMPUTING & state == IDLE) ) begin // 2nd condition is true during the very 1st clock cycle of the multiplication
            count = 0 ;
            temp_sum = 0 ;
            temp_sum_msb = 0;
            temp_sum_lsb = 0;
            temp_sum_sum_op = 0;

            if (~MCycleOp[0]) begin // Signed operation, simple trick to convert
                // Store signs and convert to positive
                op1_sign = Operand1[width-1];
                op2_sign = Operand2[width-1];
                
                if (op1_sign) begin
                    shifted_op1 = {{width{1'b0}}, (~Operand1 + 1'b1)};
                    shifted_op1_msb = {{half_width{1'b0}}, (~op1_msb)};
                    shifted_op1_lsb = {{half_width{1'b0}}, (~op1_lsb) + 1'b1};
                end
                else begin
                    shifted_op1 = {{width{1'b0}}, Operand1};
                    shifted_op1_msb = {{half_width{1'b0}}, (op1_msb)};
                    shifted_op1_lsb = {{half_width{1'b0}}, (op1_lsb)};
                end
                
                if (op2_sign) begin
                    shifted_op2 = {{width{1'b0}}, (~Operand2 + 1'b1)};
                    shifted_op2_msb = {{half_width{1'b0}}, (~op2_msb)};
                    shifted_op2_lsb = {{half_width{1'b0}}, (~op2_lsb) + 1'b1};
                end
                else begin
                    shifted_op2 = {{width{1'b0}}, Operand2};
                    shifted_op2_msb = {{half_width{1'b0}}, (op2_msb)};
                    shifted_op2_lsb = {{half_width{1'b0}}, (op2_lsb)};
                end
                shifted_sum_op1 = shifted_op1_msb + shifted_op1_lsb;
                shifted_sum_op2 =  shifted_op2_msb +  shifted_op2_lsb; 
            end else begin // Unsigned operation
                op1_sign = 1'b0;
                op2_sign = 1'b0;
                shifted_op1 = {{width{1'b0}}, Operand1};
                shifted_op2 = {{width{1'b0}}, Operand2};
                
                shifted_op1_msb = {{half_width{1'b0}}, (Operand1[width-1:half_width])};
                shifted_op1_lsb = {{half_width{1'b0}}, (Operand1[half_width-1:0])};
                shifted_sum_op1 = sum_op1;
                
                shifted_op2_msb = {{half_width{1'b0}}, (Operand2[width-1:half_width])};
                shifted_op2_lsb = {{half_width{1'b0}}, (Operand2[half_width-1:0])};
                shifted_sum_op2 = sum_op2;
            end

        end ;

        done <= 1'b0 ;   
        
        if( ~MCycleOp[1] ) begin // Multiply
            // if( ~MCycleOp[0] ), takes 2*'width' cycles to execute, returns signed(Operand1)*signed(Operand2)
            // if( MCycleOp[0] ), takes 'width' cycles to execute, returns unsigned(Operand1)*unsigned(Operand2)        
//            if( shifted_op2[0] ) // add only if b0 = 1
//                temp_sum = temp_sum + shifted_op1 ; // partial product for multiplication
            
//            shifted_op2 = {1'b0, shifted_op2[2*width-1 : 1]} ;
//            shifted_op1 = {shifted_op1[2*width-2 : 0], 1'b0} ;
            
            if (shifted_op2_msb[0])
                temp_sum_msb = temp_sum_msb + shifted_op1_msb;
                
            if (shifted_op2_lsb[0])
                temp_sum_lsb = temp_sum_lsb + shifted_op1_lsb;
            
            if (shifted_sum_op2[0])
                temp_sum_sum_op = temp_sum_sum_op + shifted_sum_op1;
            
            shifted_op2_msb = {1'b0, shifted_op2_msb[width-1 : 1]};
            shifted_op2_lsb = {1'b0, shifted_op2_lsb[width-1 : 1]};
            shifted_sum_op2 = {1'b0, shifted_sum_op2[width-1 : 1]};
            shifted_op1_msb = {shifted_op1_msb[width-2 : 0], 1'b0};
            shifted_op1_lsb = {shifted_op1_lsb[width-2 : 0], 1'b0};
            shifted_sum_op1 = {shifted_sum_op1[width-2 : 0], 1'b0};     
                
//        if (count == 2*width-1) begin
//            done <= 1'b1;
//            // Negate result if signs are different (only for signed multiplication)
//            if (~MCycleOp[0] && (op1_sign ^ op2_sign))
//                temp_sum = ~temp_sum + 1'b1; // 2's complement negation
//        end
        
        if (count == half_width) begin
            done <= 1'b1;
            
            Z1 = temp_sum_sum_op - temp_sum_msb - temp_sum_lsb;
            temp_sum = (temp_sum_msb << width) + (Z1 << half_width) + temp_sum_lsb;
            
            if (~MCycleOp[0] && (op1_sign ^ op2_sign))
                temp_sum = ~temp_sum + 1'b1; // 2's complement negation
        end
               
            count = count + 1;    
        end    
        else begin //  Divide
            if (RESET | (n_state == COMPUTING & state == IDLE)) begin
                // Initialize for division
                shifted_op2 = {1'b0, shifted_op2[width - 1: 0], {(width- 1){1'b0}}};
            end
            

            if(shifted_op1 >= shifted_op2) begin
                shifted_op1 = shifted_op1 - shifted_op2;
                temp_sum = {temp_sum[2*width-2:0], 1'b1};
            end else begin
                temp_sum = {temp_sum[2*width-2:0], 1'b0};
            end 

            shifted_op2 = {1'b0, shifted_op2[2*width-1:1]}; // Shift divisor right

            if(count == width - 1) begin
                done <= 1'b1;
                if (~MCycleOp[0]) begin // Only for signed division
                    // Adjust quotient
                    if (op1_sign ^ op2_sign)
                        temp_sum[width-1:0] = ~temp_sum[width-1:0] + 1'b1;
                    
                    // Adjust remainder
                    if (op1_sign)
                        shifted_op1[width-1:0] = ~shifted_op1[width-1:0] + 1'b1;
                    
                end
            end

            count = count + 1;
               
        end

        if( ~MCycleOp[1] ) begin 
            Result2 <= temp_sum[2*width-1 : width];
            Result1 <= temp_sum[width-1 : 0];
        end
        else begin
            Result2 <= shifted_op1[width-1:0]; // Remainder
            Result1 <= temp_sum[width-1 : 0];  // Quotient
        end
    end
   
endmodule
















