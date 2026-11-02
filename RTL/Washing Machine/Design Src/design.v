module washing_machine_fsm (
    input clk,
    input reset,

    input start,

    input [3:0] weight_kg,
    input [8:0] detergent_g,
    input [3:0] water_l,

    input [1:0] mode,
    input process_done,

    output reg alarm,
    output reg washing_done,
    output reg [5:0] countdown
);

    //================================================
    // State declaration
    //================================================

    parameter CLOTH     = 3'b000;
    parameter DETERGENT = 3'b001;
    parameter WATER     = 3'b010;
    parameter MODE      = 3'b011;
    parameter OUTPUT    = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [5:0] timer;

    //================================================
    // State register
    //================================================

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= CLOTH;
        else
            state <= next_state;
    end

    //================================================
    // Next-state logic
    //================================================

    always @(*)
    begin

        next_state = state;

        case (state)

            //========================================
            // CLOTH STATE
            //========================================

            CLOTH:
            begin
                if (weight_kg > 7)
                    next_state = CLOTH;

                else if (start)
                    next_state = DETERGENT;

                else if (timer == 0)
                    next_state = CLOTH;
            end

            //========================================
            // DETERGENT STATE
            //========================================

            DETERGENT:
            begin
                if (detergent_g > 200)
                    next_state = DETERGENT;

                else if (start)
                    next_state = WATER;

                else if (timer == 0)
                    next_state = CLOTH;
            end

            //========================================
            // WATER STATE
            //========================================

            WATER:
            begin
                if (water_l > 10)
                    next_state = WATER;

                else if (start)
                    next_state = MODE;

                else if (timer == 0)
                    next_state = CLOTH;
            end

            //========================================
            // MODE SELECTION
            //========================================

            MODE:
            begin
                if ((mode == 2'b01) ||
                    (mode == 2'b10) ||
                    (mode == 2'b11))
                begin
                    next_state = OUTPUT;
                end

                else if (timer == 0)
                    next_state = CLOTH;
            end

            //========================================
            // OUTPUT STATE
            //========================================

            OUTPUT:
            begin
                if (process_done)
                    next_state = CLOTH;
            end

            default:
                next_state = CLOTH;

        endcase
    end

    //================================================
    // 60-second timer
    //================================================

    always @(posedge clk or posedge reset)
    begin

        if (reset)
        begin
            timer <= 6'd60;
        end

        else if (state != next_state)
        begin
            timer <= 6'd60;
        end

        else if (timer > 0)
        begin
            timer <= timer - 1'b1;
        end

    end

    //================================================
    // Countdown output
    //================================================

    always @(*)
    begin
        countdown = timer;
    end

    //================================================
    // Alarm
    //================================================

    always @(*)
    begin

        alarm = 1'b0;

        case (state)

            CLOTH:
            begin
                if (weight_kg > 7)
                    alarm = 1'b1;
            end

            DETERGENT:
            begin
                if (detergent_g > 200)
                    alarm = 1'b1;
            end

            WATER:
            begin
                if (water_l > 10)
                    alarm = 1'b1;
            end

            default:
                alarm = 1'b0;

        endcase
    end

    //================================================
    // Washing completed
    //================================================

    always @(*)
    begin

        if (state == OUTPUT)
            washing_done = 1'b1;
        else
            washing_done = 1'b0;

    end

endmodule