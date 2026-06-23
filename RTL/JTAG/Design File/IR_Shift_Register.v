module IR_Shift_Register (
    input TCK,
    input TRST,
    input TDI,
    input Shift_IR,
    input Capture_IR,

    output reg [3:0] Shift_Register_out, // 4-bit parallel output to the hold register
    output  TDO_IR  // 1-bit serial output passing through
);

parameter [3:0] Status_Pattern = 4'b0101;

always @ (posedge TCK or negedge TRST ) begin
    if(!TRST) begin
        Shift_Register_out <= 4'b0000;
    end
    else begin
        if (Capture_IR) begin
            Shift_Register_out <= Status_Pattern; // Parallel load Status
        end
        else if (Shift_IR) begin
            Shift_Register_out <= {TDI, Shift_Register_out[3:1]}; // Serial Shift right
        end
        
    end
end

// TDO always see the last bit of our shift chain
assign TDO_IR =  Shift_Register_out[0];
endmodule