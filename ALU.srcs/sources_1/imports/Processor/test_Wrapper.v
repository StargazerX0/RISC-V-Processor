`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
--	(c) Thao Nguyen and Rajesh Panicker
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
module test_Wrapper #(
	   parameter N_LEDs_OUT	= 8,					
	   parameter N_DIPs		= 16,
	   parameter N_PBs		= 3 
	)
	(
	);
	
	// Signals for the Unit Under Test (UUT)
	reg  [N_DIPs-1:0] DIP = 0;		
	reg  [N_PBs-1:0] PB = 0;			
	wire [N_LEDs_OUT-1:0] LED_OUT;
	wire [6:0] LED_PC;			
	wire [31:0] SEVENSEGHEX;	
	wire [7:0] CONSOLE_OUT;
	reg  CONSOLE_OUT_ready = 0;
	wire CONSOLE_OUT_valid;
	reg  [7:0] CONSOLE_IN = 0;
	reg  CONSOLE_IN_valid = 0;
	wire CONSOLE_IN_ack;
	reg  RESET = 0;					
	reg  CLK = 0;				
	
	// Instantiate UUT
	Wrapper dut(DIP, PB, LED_OUT, LED_PC, SEVENSEGHEX, CONSOLE_OUT, CONSOLE_OUT_ready, CONSOLE_OUT_valid, CONSOLE_IN, CONSOLE_IN_valid, CONSOLE_IN_ack, RESET, CLK) ;
	
	// Note: This testbench is for the Hello World program. Other assembly programs require appropriate modifications.
	// Run for about 6 us. Set CONSOLE_OUT radix to ASCII to see the printed messages.
	// STIMULI
    // Test stimulus
    initial begin
        // Initialize
        CLK = 0;
        RESET = 1;
        DIP = 16'h0012;  // Set an initial value for DIP switches
        PB = 3'b000;

        // Release reset
        #20 RESET = 0;

        // Wait for program to execute (adjust this delay as needed)
        #10000;

        // Check LED output
        $display("DIP input: %h", DIP);
        $display("LED output: %h", LED_OUT);
        $display("Expected LED output: %h", (DIP >> 3) & 8'hFF);  // Expected result of arithmetic right shift by 3

        // Continue running for a bit to ensure no further changes
        #2000;

        // End simulation
        $finish;
    end
	
	// GENERATE CLOCK       
    always          
    begin
       #5 CLK = ~CLK ; // invert clk every 5 time units 
    end
    
endmodule