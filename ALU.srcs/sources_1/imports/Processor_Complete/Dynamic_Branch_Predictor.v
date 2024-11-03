module Dynamic_Branch_Predictor(
    input wire CLK,                   // Clock signal
    input wire RESET,                 // Reset signal to initialize the predictor
    input wire branch_enable,       // Control signal to update predictor only on branch instructions
    input wire branch_taken,          // Actual outcome of the branch (1 if taken, 0 if not taken)
    output reg prediction             // Prediction output (1 if predicted taken, 0 if predicted not taken)
);

    // Define the states
    parameter STRONGLY_NOT_TAKEN = 2'b00;
    parameter WEAKLY_NOT_TAKEN   = 2'b01;
    parameter WEAKLY_TAKEN       = 2'b10;
    parameter STRONGLY_TAKEN     = 2'b11;

    reg [1:0] state, next_state;
    
    // Prediction logic based on current state
    always @(*) begin
        case (state)
            STRONGLY_NOT_TAKEN: prediction = 1'b0;  // Predict not taken
            WEAKLY_NOT_TAKEN:   prediction = 1'b0;  // Predict not taken
            WEAKLY_TAKEN:       prediction = 1'b1;  // Predict taken
            STRONGLY_TAKEN:     prediction = 1'b1;  // Predict taken
            default:            prediction = 1'b0;
        endcase
    end

    // State transition logic
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            state <= STRONGLY_TAKEN;
            next_state <= STRONGLY_TAKEN;
        end else if (branch_enable) begin
            // Only update the state if branch_enable is high
            case (state)
                STRONGLY_NOT_TAKEN: begin
                    if (branch_taken)
                        next_state <= WEAKLY_NOT_TAKEN;  // Move to weakly not taken
                    else
                        next_state <= STRONGLY_NOT_TAKEN; // Stay strongly not taken
                end
                WEAKLY_NOT_TAKEN: begin
                    if (branch_taken)
                        next_state <= WEAKLY_TAKEN;       // Move to weakly taken
                    else
                        next_state <= STRONGLY_NOT_TAKEN; // Move to strongly not taken
                end
                WEAKLY_TAKEN: begin
                    if (branch_taken)
                        next_state <= STRONGLY_TAKEN;     // Move to strongly taken
                    else
                        next_state <= WEAKLY_NOT_TAKEN;   // Move to weakly not taken
                end
                STRONGLY_TAKEN: begin
                    if (branch_taken)
                        next_state <= STRONGLY_TAKEN;     // Stay strongly taken
                    else
                        next_state <= WEAKLY_TAKEN;       // Move to weakly taken
                end
                default: begin
                    next_state <= STRONGLY_NOT_TAKEN;
                end
            endcase
        end
        // Update the current state
        state <= next_state;
        
    end

endmodule
