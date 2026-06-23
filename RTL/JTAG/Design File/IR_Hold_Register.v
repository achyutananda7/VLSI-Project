module IR_Hold_Register (
    input TCK,
    input TRST,
    input [3:0] Shift_Register_outdata_in,
    input Update_IR,

    output reg [3:0] Active_Instruction // The Actual comand line to the chip
);

parameter [3:0] Inst_Bypass = 4'b1111;

always @ (negedge TCK or negedge TRST) begin
    if(!TRST) begin
        Active_Instruction <= Inst_Bypass; // Start in safe bypass mode
    end
    else if (Update_IR) begin
        Active_Instruction <= Shift_Register_outdata_in;
    end
end
endmodule