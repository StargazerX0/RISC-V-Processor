`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 16:55:23
// Design Name: 
// Module Name: test_MCycle
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

module test_MCycle();

    // DECLARE INPUT SIGNALS
    reg CLK = 0;
    reg RESET = 0;
    reg Start = 0;
    reg [1:0] MCycleOp = 0;
    reg [3:0] Operand1 = 0;
    reg [3:0] Operand2 = 0;

    // DECLARE OUTPUT SIGNALS
    wire [3:0] Result1;
    wire [3:0] Result2;
    wire Busy;
    
    // INSTANTIATE DEVICE/UNIT UNDER TEST (DUT/UUT)
    MCycle dut(CLK, RESET, Start, MCycleOp, Operand1, Operand2, Result1, Result2, Busy);
    
    // STIMULI
    initial begin
        $display("Test started");
        
       // Test 1: Signed Multiplication
       #10;    
       MCycleOp = 2'b00;
       Operand1 = 4'b1111; // -1
       Operand2 = 4'b0010; // -2
       Start = 1'b1;
       $display("Test 1: Signed Multiply - Operands: %d, %d", $signed(Operand1), $signed(Operand2));

       wait(Busy);
       wait(~Busy);
       $display("Test 1 Result: %d", $signed({Result2, Result1}));

       // Test 2: Unsigned Multiplication
       MCycleOp = 2'b01;
       Operand1 = 4'b1111; // 15
       Operand2 = 4'b0011; // 3
       $display("Test 2: Unsigned Multiply - Operands: %d, %d", Operand1, Operand2);
        
       wait(Busy); 
       wait(~Busy);
       $display("Test 2 Result: %d", {Result2, Result1});

        // Test 3: Signed Division
        MCycleOp = 2'b10;
        Operand1 = 4'b0110; // 6
        Operand2 = 4'b1110; // -2
        $display("Test 3: Signed Divide - Operands: %d, %d", $signed(Operand1), $signed(Operand2));

        wait(Busy); 
        wait(~Busy); 
        $display("Test 3 Quotient: %d, Remainder: %d", $signed(Result1), $signed(Result2));


        // Test 4: Unsigned Division
        MCycleOp = 2'b11;
        Operand1 = 4'b0101; // 5
        Operand2 = 4'b0001; // 2
        $display("Test 4: Unsigned Divide - Operands: %d, %d", Operand1, Operand2);

        wait(Busy); 
        wait(~Busy); 
        $display("Test 4 Quotient: %d, Remainder: %d", Result1, Result2);


        Start = 1'b0;
        $display("Test completed");
    end
     
    // GENERATE CLOCK       
    always begin 
        #5 CLK = ~CLK; 
    end
    
endmodule

















