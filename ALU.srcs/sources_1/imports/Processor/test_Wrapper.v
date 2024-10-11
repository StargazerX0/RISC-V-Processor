module test_Wrapper #(
    parameter N_LEDs_OUT = 8,
    parameter N_DIPs     = 16,
    parameter N_PBs      = 3 
)
();

    // Signals for the Unit Under Test (UUT)
    reg  [N_DIPs-1:0] DIP;
    reg  [N_PBs-1:0] PB;
    wire [N_LEDs_OUT-1:0] LED_OUT;
    wire [6:0] LED_PC;
    wire [31:0] SEVENSEGHEX;
    wire [7:0] CONSOLE_OUT;
    reg  CONSOLE_OUT_ready = 1;
    wire CONSOLE_OUT_valid;
    reg  [7:0] CONSOLE_IN = 0;
    reg  CONSOLE_IN_valid = 0;
    wire CONSOLE_IN_ack;
    reg  RESET;
    reg  CLK;

    // Instantiate UUT
    Wrapper dut(
        .DIP(DIP), .PB(PB), .LED_OUT(LED_OUT), .LED_PC(LED_PC),
        .SEVENSEGHEX(SEVENSEGHEX), .CONSOLE_OUT(CONSOLE_OUT),
        .CONSOLE_OUT_ready(CONSOLE_OUT_ready), .CONSOLE_OUT_valid(CONSOLE_OUT_valid),
        .CONSOLE_IN(CONSOLE_IN), .CONSOLE_IN_valid(CONSOLE_IN_valid),
        .CONSOLE_IN_ack(CONSOLE_IN_ack), .RESET(RESET), .CLK(CLK)
    );

    // Clock generation
    always begin
        #5 CLK = ~CLK;
    end

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

    // Optional: Monitor changes in LED_OUT
    always @(LED_OUT) begin
        $display("Time %t: LED changed to %h", $time, LED_OUT);
    end

endmodule
