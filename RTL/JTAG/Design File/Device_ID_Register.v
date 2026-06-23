module Device_ID_Register (
    input  wire        TCK,
    input  wire        TRST,
    input  wire        TDI,
    input  wire        Select_IDCODE,
    input  wire        Capture_DR,
    input  wire        Shift_DR,

    output wire        TDO_IDCODE
);

reg [31:0] ID_Reg;

localparam [31:0] CHIP_IDCODE = 32'h14B2_A05F;

always @(posedge TCK or negedge TRST) begin
    if (!TRST)
        ID_Reg <= 32'h0000_0000;
    else if (Select_IDCODE) begin
        if (Capture_DR)
            ID_Reg <= CHIP_IDCODE;
        else if (Shift_DR)
            ID_Reg <= {TDI, ID_Reg[31:1]}; //// Shift right by 1 bit on each TCK
    end
end

assign TDO_IDCODE = ID_Reg[0];

endmodule