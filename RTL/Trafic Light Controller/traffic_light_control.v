`timescale 1ns / 1ps

module traffic_light_fsm (
    input clk,
    input rst,            // Active-high reset
    output reg [2:0] NS,  // North-South Light {R, Y, G}
    output reg [2:0] EW   // East-West Light {R, Y, G}
);

    // State Encoding
    parameter S0_NS_G = 3'b000;
    parameter S1_NS_Y = 3'b001;
    parameter S2_ALL_R= 3'b010;
    parameter S3_EW_G = 3'b011;
    parameter S4_EW_Y = 3'b100;

    // Output Encoding {Red, Yellow, Green}
    parameter GREEN  = 3'b001;
    parameter YELLOW = 3'b010;
    parameter RED    = 3'b100;

    // Delay Values
    parameter T_GREEN = 20;
    parameter T_YELLOW = 5;
    parameter T_RED   = 2;

    reg [2:0] current_state, next_state;
    reg [4:0] timer; // 5-bit timer to hold max value 20

    // 1. Timer & State Update (Sequential) - Changed to posedge rst
    always @(posedge clk or posedge rst) begin
        if (rst) begin // Active-high condition
            current_state <= S0_NS_G;
            timer <= T_GREEN;
        end else begin
            if (timer == 0) begin
                current_state <= next_state;
                // Load timer based on next state
                case (next_state)
                    S0_NS_G: timer <= T_GREEN;
                    S1_NS_Y: timer <= T_YELLOW;
                    S2_ALL_R: timer <= T_RED;
                    S3_EW_G: timer <= T_GREEN;
                    S4_EW_Y: timer <= T_YELLOW;
                    default: timer <= T_GREEN;
                endcase
            end else begin
                timer <= timer - 1;
            end
        end
    end

    // 2. Next State Logic (Combinational)
    always @(*) begin
        case (current_state)
            S0_NS_G: next_state = S1_NS_Y;
            S1_NS_Y: next_state = S2_ALL_R;
            S2_ALL_R: next_state = S3_EW_G;
            S3_EW_G: next_state = S4_EW_Y;
            S4_EW_Y: next_state = S0_NS_G;
            default: next_state = S0_NS_G;
        endcase
    end

    // 3. Output Logic (Combinational)
    always @(*) begin
        // Default outputs
        NS = RED;
        EW = RED;

        case (current_state)
            S0_NS_G: begin
                NS = GREEN;
                EW = RED;
            end
            S1_NS_Y: begin
                NS = YELLOW;
                EW = RED;
            end
            S2_ALL_R: begin
                NS = RED;
                EW = RED;
            end
            S3_EW_G: begin
                NS = RED;
                EW = GREEN;
            end
            S4_EW_Y: begin
                NS = RED;
                EW = YELLOW;
            end
        endcase
    end

endmodule