module TOP_Instruction_Register (
    input TCK,
    input TRST,
    input TDI,
    input Update_IR,
    input Shift_IR,
    input Capture_IR,
    
    output TDO,
    output [3:0]Instr_for_Decoder
);
wire [3:0] Shift_Register_out;

IR_Shift_Register R1 (
    .TCK(TCK),
    .TRST(TRST),
    .TDI(TDI),
    .Shift_IR(Shift_IR),
    .Capture_IR(Capture_IR),
    .Shift_Register_out(Shift_Register_out),
    .TDO_IR(TDO)
);

IR_Hold_Register R2(
    .TCK(TCK),
    .TRST(TRST),
    .Shift_Register_outdata_in(Shift_Register_out),
    .Update_IR(Update_IR),
    .Active_Instruction(Instr_for_Decoder)
);
endmodule