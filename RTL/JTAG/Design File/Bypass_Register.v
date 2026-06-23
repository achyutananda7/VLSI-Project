module Bypass_Register (
    input TCK,
    input TRST,
    input TDI,
    input Select_Bypass,
    input Capture_DR,
    input Shift_DR,

    output TDO_Bypass
);
reg Bypass_Reg;
always @ (posedge TCK or negedge TRST) begin
    if(!TRST) begin
        Bypass_Reg <= 1'b0;
    end
    else begin
        if (Select_Bypass)begin
            if(Capture_DR) begin
                Bypass_Reg <= 1'b0; // IEEE standard mandates capturing a 0
            end
            else if (Shift_DR) begin
                Bypass_Reg <= TDI;//Shift data: TDI passes through on next clock
            end
        end
    end
   
end
assign TDO_Bypass = Bypass_Reg;

endmodule