module Boundary_Scan_Cell (
    input wire TCK,
    input wire TRST,
    
    // System Data Path
    input wire System_In,
    output wire System_Out,
    
    // JTAG Serial Chain Path
    input wire Shift_In,
    output wire Shift_Out,
    
    // Control Signals
    input wire Capture_DR,
    input wire Shift_DR,
    input wire Update_DR,
    input wire Mode             // From Instruction Decoder (1 = Test Mode, 0 = Normal Mode)
);

    reg shift_reg;  // The capture/shift flip-flop
    reg update_reg; // The hold/update register

    // --------------------------------------------------------
    // 1. Shift and Capture Stage (Rising Edge)
    // --------------------------------------------------------
    always @(posedge TCK or negedge TRST) begin
        if (!TRST) begin
            shift_reg <= 1'b0;
        end
        else begin
            if (Capture_DR) begin
                shift_reg <= System_In; // Snapshot the live pin/core signal
            end
            else if (Shift_DR) begin
                shift_reg <= Shift_In;   // Slide data right through the chain
            end
        end
    end

    // --------------------------------------------------------
    // 2. Update Stage (Falling Edge for Safety)
    // --------------------------------------------------------
    always @(negedge TCK or negedge TRST) begin
        if (!TRST) begin
            update_reg <= 1'b0;
        end
        else if (Update_DR) begin
            update_reg <= shift_reg; // Freeze the shifted-in test bit
        end
    end

    // --------------------------------------------------------
    // 3. Output Multiplexing Logic
    // --------------------------------------------------------
    // Connect the serial exit door to the next cell
    assign Shift_Out = shift_reg;

    // The Mode switch: 0 = Normal bypass, 1 = Inject test data
    assign System_Out = (Mode) ? update_reg : System_In;

endmodule