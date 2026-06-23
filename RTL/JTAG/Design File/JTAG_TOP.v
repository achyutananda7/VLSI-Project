module JTAG_Top (
    // Physical JTAG Pins
    input wire TCK,
    input wire TRST,
    input wire TMS,
    input wire TDI,
    output wire TDO,

    // Physical Chip System Pins (Connected to the Application Board)
    input wire Ext_Pin_A,
    input wire Ext_Pin_B,
    output wire Ext_Pin_Y
);

    // =========================================================================
    // 1. Internal Interconnect Wires
    // =========================================================================
    
    // Control Wires: TAP Controller -> Registers
    wire Capture_DR, Shift_DR, Update_DR;
    wire Capture_IR, Shift_IR, Update_IR;

    // Bus Wires: Instruction Register -> Instruction Decoder
    wire [3:0] Instr_for_Decoder;

    // Selection Wires: Instruction Decoder -> Data Registers
    wire Select_Bypass;
    wire Select_IDCODE;
    wire Select_BSR;

    // Serial Exit Wires: Submodules -> Multiplexer Trees
    wire TDO_IR;
    wire TDO_Bypass;
    wire TDO_IDCODE;
    wire TDO_BSR;
    
    reg TDO_DR; // Holds the chosen output from the active Data Register

    // =========================================================================
    // 2. Submodule Instantiations
    // =========================================================================

    // A. The State Director
    TAP_Controller TAP_Ctrl_Inst (
        .TMS(TMS),
        .TCK(TCK),
        .TRST(TRST),
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .Update_DR(Update_DR),
        .Capture_IR(Capture_IR),
        .Shift_IR(Shift_IR),
        .Update_IR(Update_IR)
    );

    // B. The Command Holder
    TOP_Instruction_Register IR_Inst (
        .TCK(TCK),
        .TRST(TRST),
        .TDI(TDI),
        .Capture_IR(Capture_IR),
        .Shift_IR(Shift_IR),
        .Update_IR(Update_IR),
        .TDO(TDO_IR),
        .Instr_for_Decoder(Instr_for_Decoder)
    );

    // C. The Command Translator
    Instruction_Decoder Decoder_Inst (
        .Instr_for_Decoder(Instr_for_Decoder),
        .Select_Bypass(Select_Bypass),
        .Select_IDCODE(Select_IDCODE),
        .Select_BSR(Select_BSR)
    );

    // D. Data Register Lane 1: Bypass (1-bit)
    Bypass_Register Bypass_Reg_Inst (
        .TCK(TCK),
        .TRST(TRST),
        .TDI(TDI),
        .Select_Bypass(Select_Bypass),
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .TDO_Bypass(TDO_Bypass)
    );

    // E. Data Register Lane 2: Device ID (32-bit)
    Device_ID_Register Device_ID_Reg_Inst (
        .TCK(TCK),
        .TRST(TRST),
        .TDI(TDI),
        .Select_IDCODE(Select_IDCODE),
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .TDO_IDCODE(TDO_IDCODE)
    );

    // F. Data Register Lane 3: Boundary Scan Chain (Wrapping Core Logic)
    Boundary_Scan_Register BSR_Chain_Inst (
        .TCK(TCK),
        .TRST(TRST),
        .Ext_Pin_A(Ext_Pin_A),
        .Ext_Pin_B(Ext_Pin_B),
        .Ext_Pin_Y(Ext_Pin_Y),
        .TDI(TDI),
        .TDO_BSR(TDO_BSR),
        .Capture_DR(Capture_DR),
        .Shift_DR(Shift_DR),
        .Update_DR(Update_DR),
        .Select_BSR(Select_BSR)
    );

    // =========================================================================
    // 3. Multiplexer Steering Blocks
    // =========================================================================

    // The Orange Multiplexer Stage: Gathers Data Registers
    always @(*) begin
        if (Select_IDCODE) begin
            TDO_DR = TDO_IDCODE;
        end
        else if (Select_BSR) begin
            TDO_DR = TDO_BSR;
        end
        else begin
            TDO_DR = TDO_Bypass; // Default safety net
        end
    end

    // The Green Multiplexer Stage: Selects final path to physical exit pin
    // If Shift_IR is active, stream out the IR data. Otherwise, stream out DR data.
    assign TDO = (Shift_IR) ? TDO_IR : TDO_DR;

endmodule