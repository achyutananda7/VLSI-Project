module Boundary_Scan_Register (
    input wire TCK,
    input wire TRST,
    
    // Physical External Chip Pins (Connected to the PCB board)
    input wire Ext_Pin_A,
    input wire Ext_Pin_B,
    output wire Ext_Pin_Y,
    
    // JTAG Serial Chain Pins
    input wire TDI,
    output wire TDO_BSR,
    
    // Control Flags (From TAP Controller & Instruction Decoder)
    input wire Capture_DR,
    input wire Shift_DR,
    input wire Update_DR,
    input wire Select_BSR       // Connects directly to the "Mode" pin of all cells
);

    // Internal wires connecting the core logic to the boundary cells
    wire core_A, core_B, core_Y;
    
    // Internal serial wires chaining the boundary cells together
    wire bsc1_to_bsc2;
    wire bsc2_to_bsc3;

    // ------------------------------------------------------------------------
    // Cell 1: Wrapped around Input Pin A
    // ------------------------------------------------------------------------
    Boundary_Scan_Cell BSC_A (
        .TCK(TCK),
        .TRST(TRST),
        .System_In(Ext_Pin_A),   // Reads from the outside physical pin
        .System_Out(core_A),     // Drives the internal core logic input
        .Shift_In(TDI),          // First cell in the chain connects to TDI
        .Shift_Out(bsc1_to_bsc2),// Passes serial data to the next cell
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .Update_DR(Update_DR),
        .Mode(Select_BSR)
    );

    // ------------------------------------------------------------------------
    // Cell 2: Wrapped around Input Pin B
    // ------------------------------------------------------------------------
    Boundary_Scan_Cell BSC_B (
        .TCK(TCK),
        .TRST(TRST),
        .System_In(Ext_Pin_B),   // Reads from the outside physical pin
        .System_Out(core_B),     // Drives the internal core logic input
        .Shift_In(bsc1_to_bsc2), // Reads serial data from Cell 1
        .Shift_Out(bsc2_to_bsc3),// Passes serial data to the next cell
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .Update_DR(Update_DR),
        .Mode(Select_BSR)
    );

    // ------------------------------------------------------------------------
    // Instantiate the Core Logic inside the boundary cage
    // ------------------------------------------------------------------------
    Core_Logic chip_brain (
        .A(core_A),
        .B(core_B),
        .Y(core_Y)
    );

    // ------------------------------------------------------------------------
    // Cell 3: Wrapped around Output Pin Y
    // ------------------------------------------------------------------------
    Boundary_Scan_Cell BSC_Y (
        .TCK(TCK),
        .TRST(TRST),
        .System_In(core_Y),      // Reads the results computed by the Core Logic
        .System_Out(Ext_Pin_Y),  // Drives the physical external output pin
        .Shift_In(bsc2_to_bsc3), // Reads serial data from Cell 2
        .Shift_Out(TDO_BSR),     // Last cell outputs directly to the JTAG TDO path
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .Update_DR(Update_DR),
        .Mode(Select_BSR)
    );

endmodule