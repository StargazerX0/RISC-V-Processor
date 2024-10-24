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
    wire [7:0] UART_TX;
    reg  UART_TX_ready = 1;
    wire UART_TX_valid;
    reg  [7:0] UART_RX = 0;
    reg  UART_RX_valid = 0;
    wire UART_RX_ack;
    reg  RESET;
    reg  CLK;

    // Instantiate UUT
    Wrapper dut(
        .DIP(DIP), .PB(PB), .LED_OUT(LED_OUT), .LED_PC(LED_PC),
        .SEVENSEGHEX(SEVENSEGHEX), .UART_TX(UART_TX),
        .UART_TX_ready(UART_TX_ready), .UART_TX_valid(UART_TX_valid),
        .UART_RX(UART_RX), .UART_RX_valid(UART_RX_valid),
        .UART_RX_ack(UART_RX_ack), .RESET(RESET), .CLK(CLK)
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
