`timescale 1ns/1ps

module washing_machine_fsm_tb;

    reg clk;
    reg reset;

    reg start;

    reg [3:0] weight_kg;
    reg [8:0] detergent_g;
    reg [3:0] water_l;

    reg [1:0] mode;
    reg process_done;

    wire alarm;
    wire washing_done;
    wire [5:0] countdown;


    //================================================
    // DUT
    //================================================

    washing_machine_fsm dut (
        .clk(clk),
        .reset(reset),

        .start(start),

        .weight_kg(weight_kg),
        .detergent_g(detergent_g),
        .water_l(water_l),

        .mode(mode),
        .process_done(process_done),

        .alarm(alarm),
        .washing_done(washing_done),
        .countdown(countdown)
    );


    //================================================
    // CLOCK
    //================================================

    always #5 clk = ~clk;


    //================================================
    // TEST
    //================================================

    initial
    begin

        // Initial values
        clk = 0;
        reset = 0;

        start = 0;

        weight_kg = 0;
        detergent_g = 0;
        water_l = 0;

        mode = 0;
        process_done = 0;


        //================================================
        // RESET
        //================================================

        #10;

        reset = 1;
        #10;

        reset = 0;

        $display("======================================");
        $display("WASHING MACHINE TEST START");
        $display("======================================");


        //================================================
        // TEST 1: CLOTH
        //================================================

        $display("TEST 1: Cloth weight = 5 kg");

        weight_kg = 5;
        start = 1;

        #10;

        start = 0;

        $display("State = %d", dut.state);


        //================================================
        // TEST 2: DETERGENT
        //================================================

        $display("TEST 2: Detergent = 150 g");

        detergent_g = 150;
        start = 1;

        #10;

        start = 0;

        $display("State = %d", dut.state);


        //================================================
        // TEST 3: WATER
        //================================================

        $display("TEST 3: Water = 8 L");

        water_l = 8;
        start = 1;

        #10;

        start = 0;

        $display("State = %d", dut.state);


        //================================================
        // TEST 4: NORMAL MODE
        //================================================

        $display("TEST 4: Selecting NORMAL mode");

        mode = 2'b01;

        #10;

        $display("State = %d", dut.state);


        //================================================
        // TEST 5: PROCESS COMPLETE
        //================================================

        $display("TEST 5: Washing process complete");

        process_done = 1;

        #10;

        process_done = 0;

        $display("State = %d", dut.state);


        //================================================
        // TEST 6: CLOTH OVERLOAD
        //================================================

        $display("TEST 6: Cloth weight = 8 kg");

        weight_kg = 8;

        #10;

        if (alarm == 1)
            $display("PASS: Cloth overload alarm generated");
        else
            $display("FAIL: Cloth overload alarm not generated");


        // Correct the weight
        weight_kg = 5;

        #10;


        //================================================
        // TEST 7: DETERGENT OVERLOAD
        //================================================

        $display("TEST 7: Detergent = 250 g");

        // Move to detergent state
        start = 1;

        #10;

        start = 0;

        detergent_g = 250;

        #10;

        if (alarm == 1)
            $display("PASS: Detergent overload alarm generated");
        else
            $display("FAIL: Detergent overload alarm not generated");


        // Correct detergent
        detergent_g = 150;

        #10;


        //================================================
        // TEST 8: WATER OVERLOAD
        //================================================

        $display("TEST 8: Water = 12 L");

        start = 1;

        #10;

        start = 0;

        water_l = 12;

        #10;

        if (alarm == 1)
            $display("PASS: Water overload alarm generated");
        else
            $display("FAIL: Water overload alarm not generated");


        // Correct water
        water_l = 8;

        #10;


        //================================================
        // TEST 9: HARD MODE
        //================================================

        $display("TEST 9: Selecting HARD mode");

        start = 1;

        #10;

        start = 0;

        mode = 2'b10;

        #10;

        $display("State = %d", dut.state);


        //================================================
        // TEST 10: SOFT MODE
        //================================================

        process_done = 1;

        #10;

        process_done = 0;

        // Go through the states again
        weight_kg = 5;
        start = 1;

        #10;

        start = 0;

        detergent_g = 100;
        start = 1;

        #10;

        start = 0;

        water_l = 5;
        start = 1;

        #10;

        start = 0;

        mode = 2'b11;

        #10;

        $display("TEST 10: SOFT mode selected");
        $display("State = %d", dut.state);


        //================================================
        // TEST 11: TIMEOUT
        //================================================

        $display("TEST 11: Testing 60 second timeout");

        /*
         * For simulation we force timer to zero
         * instead of waiting for 60 real seconds.
         */

        force dut.timer = 0;

        #10;

        release dut.timer;

        #10;

        $display("State after timeout = %d", dut.state);


        //================================================
        // END
        //================================================

        $display("======================================");
        $display("TEST COMPLETED");
        $display("======================================");

        #20;

        $finish;

    end


    //================================================
    // WAVEFORM
    //================================================

    initial
    begin
        $dumpfile("washing_machine.vcd");
        $dumpvars(0, washing_machine_fsm_tb);
    end

endmodule