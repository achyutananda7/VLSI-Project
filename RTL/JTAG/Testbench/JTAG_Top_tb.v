`timescale 1ns / 1ps

module JTAG_Top_tb;

    // =========================================================================
    // 1. Testbench Signals
    // =========================================================================
    reg TCK;
    reg TRST;
    reg TMS;
    reg TDI;
    reg Ext_Pin_A;
    reg Ext_Pin_B;

    wire TDO;
    wire Ext_Pin_Y;

    // Expected Constants for Verification
    localparam [3:0]  OP_IDCODE = 4'b0001;
    localparam [3:0]  OP_EXTEST = 4'b0010;
    localparam [3:0]  OP_BYPASS = 4'b1111;
    localparam [31:0] EXP_IDCODE = 32'h14B2_A05F;

    // =========================================================================
    // 2. Device Under Test (DUT) Instantiation
    // =========================================================================
    JTAG_Top uut (
        .TCK(TCK),
        .TRST(TRST),
        .TMS(TMS),
        .TDI(TDI),
        .TDO(TDO),
        .Ext_Pin_A(Ext_Pin_A),
        .Ext_Pin_B(Ext_Pin_B),
        .Ext_Pin_Y(Ext_Pin_Y)
    );

    // =========================================================================
    // 3. Clock Generation (TCK)
    // =========================================================================
    // Initial block ensures TCK isn't an unknown 'x' state at startup
    initial TCK = 0;
    always #10 TCK = ~TCK; // 50MHz Test Clock

    // =========================================================================
    // 4. Helper Tasks for TAP Controller Navigation
    // =========================================================================
    
    // Sends a single bit through TMS and waits for a clock cycle
    task send_tms(input bit_val);
        begin
            TMS = bit_val;
            @(posedge TCK);
            #2; // Small delay after edge to let registers settle (simulate hold time)
        end
    endtask

    // Resets the JTAG TAP Controller using the asynchronous TRST pin
    task reset_jtag;
        begin
            TRST = 0;
            TMS = 1;
            TDI = 0;
            Ext_Pin_A = 0;
            Ext_Pin_B = 0;
            #25;
            TRST = 1; // Release reset (State is Test-Logic-Reset)
            
            // FIX: We MUST drive TMS=0 to escape Reset and enter Run-Test-Idle!
            send_tms(0); 
        end
    endtask

    // Navigates TAP FSM from Run-Test-Idle to Shift-IR state
    task goto_shift_ir;
        begin
            send_tms(1); // Move to Select-DR-Scan
            send_tms(1); // Move to Select-IR-Scan
            send_tms(0); // Move to Capture-IR
            send_tms(0); // Move to Shift-IR
        end
    endtask

    // Navigates TAP FSM from Run-Test-Idle to Shift-DR state
    task goto_shift_dr;
        begin
            send_tms(1); // Move to Select-DR-Scan
            send_tms(0); // Move to Capture-DR
            send_tms(0); // Move to Shift-DR
        end
    endtask

    // Shifts an arbitrary 4-bit instruction opcode into the Instruction Register
    task shift_instruction(input [3:0] opcode);
        integer i;
        begin
            goto_shift_ir; // Puts us in Shift-IR state
            
            for (i = 0; i < 4; i = i + 1) begin
                TDI = opcode[i];
                // On the final bit, we must raise TMS to exit Shift-IR per standard rules
                if (i == 3) begin
                    send_tms(1); // State becomes Exit1-IR
                end else begin
                    send_tms(0); // State stays Shift-IR
                end
            end
            
            // Safely exit the instruction update cycle and return to Idle
            send_tms(1); // Move from Exit1-IR to Update-IR
            send_tms(0); // Return to Run-Test-Idle
        end
    endtask

    // =========================================================================
    // 5. Main Simulation Test Vectors
    // =========================================================================
    reg [31:0] captured_id;
    integer j;

    initial begin
        $display("==================================================");
        $display("Starting JTAG Full Architecture Simulation Vector");
        $display("==================================================");
        
        reset_jtag; // Ends in Run-Test-Idle state

        // ---------------------------------------------------------------------
        // TEST PHASE 1: Verify IDCODE Operation
        // ---------------------------------------------------------------------
        $display("\n[Phase 1] Shifting IDCODE Instruction (4'b0001)...");
        shift_instruction(OP_IDCODE);

        $display("[Phase 1] Reading 32-bit Device Identification Register...");
        goto_shift_dr; // Move to Shift-DR
        
        for (j = 0; j < 32; j = j + 1) begin
            captured_id[j] = TDO; // Read the current bit on the TDO wire
            
            if (j == 31) begin
                send_tms(1); // Shift final bit and jump to Exit1-DR
            end else begin
                send_tms(0); // Shift bit and stay in Shift-DR
            end
        end
        
        // Cleanly exit back to Idle
        send_tms(1); // Exit1-DR -> Update-DR
        send_tms(0); // Update-DR -> Run-Test-Idle

        $display("[Phase 1] Expected ID: 0x%h | Read ID: 0x%h", EXP_IDCODE, captured_id);
        if (captured_id === EXP_IDCODE) begin
            $display(">>> SUCCESS: IDCODE Verified Correctly! <<<");
        end else begin
            $display(">>> ERROR: IDCODE Mismatch! <<<");
        end

        // ---------------------------------------------------------------------
        // TEST PHASE 2: Verify BYPASS Operation (1-Bit Shortcut)
        // ---------------------------------------------------------------------
        $display("\n[Phase 2] Shifting BYPASS Instruction (4'b1111)...");
        shift_instruction(OP_BYPASS);

        $display("[Phase 2] Testing Bypass 1-clock-cycle delay data line...");
        goto_shift_dr; // Move to Shift-DR
        
        // Push a '1' into the Bypass Register
        TDI = 1'b1; 
        send_tms(0); // Shift '1' in, stay in Shift-DR
        
        // Check TDO immediately after the single clock shift
        if (TDO === 1'b1) begin
            $display(">>> SUCCESS: Bypass Shift Delay Verified! <<<");
        end else begin
            $display(">>> ERROR: Bypass Data Flow Error! <<<");
        end
        
        // Push a '0' to clear it and exit Shift-DR simultaneously
        TDI = 1'b0; 
        send_tms(1); // Shift '0' in, jump to Exit1-DR
        
        send_tms(1); // Exit1-DR -> Update-DR
        send_tms(0); // Update-DR -> Run-Test-Idle

        // ---------------------------------------------------------------------
        // TEST PHASE 3: Verify EXTEST (Boundary Scan Register Control)
        // ---------------------------------------------------------------------
        $display("\n[Phase 3] Shifting EXTEST Instruction (4'b0010)...");
        shift_instruction(OP_EXTEST);

        $display("[Phase 3] Injecting test stimuli into core logic via BSR chain...");
        goto_shift_dr; // Move to Shift-DR
        
        // BSR chain: TDI -> BSC_A -> BSC_B -> BSC_Y -> TDO
        // We want to inject A = 1 and B = 1 into the core logic.
        // It requires 3 shifts to populate the 3 cells.
        
        TDI = 1'b0; send_tms(0); // Shift 1: Bit lands in Cell Y
        TDI = 1'b1; send_tms(0); // Shift 2: Bit lands in Cell B (Injecting '1')
        TDI = 1'b1; send_tms(1); // Shift 3: Bit lands in Cell A (Injecting '1') AND moves to Exit1-DR
        
        // Move to Update-DR to lock the shifted values into the core logic inputs
        send_tms(1); // Exit1-DR -> Update-DR
        
        #5; // Give the internal Core Logic (AND gate) a moment to evaluate 1 & 1
        
        send_tms(0); // Update-DR -> Run-Test-Idle
        
        // Now, we need to capture the output calculated by the core logic
        goto_shift_dr; // Moves back through Capture-DR. BSC_Y snapshots the core output!
        
        #5; 
        // We are now back in Shift-DR. TDO is directly streaming BSC_Y's captured data.
        if (TDO === 1'b1) begin
            $display(">>> SUCCESS: Boundary Scan Cell Interception & Compute Verified! <<<");
        end else begin
            $display(">>> ERROR: Boundary Scan Compute Mismatch! <<<");
        end

        // Clean exit
        send_tms(1); // Shift-DR -> Exit1-DR
        send_tms(1); // Exit1-DR -> Update-DR
        send_tms(0); // Update-DR -> Run-Test-Idle

        $display("\n==================================================");
        $display("Simulation Complete.");
        $display("==================================================");
        $finish;
    end

endmodule