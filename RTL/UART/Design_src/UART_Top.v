module UART_Top (
    input clk,rst,
    // Physical Pins For Tx
    input Tx_En,
    input [7:0] Tx_Data_in,
    output Busy,
    // Physical Pins For Rx
    input Rx_En,
    output [7:0] Rx_Data_Out,
    output parity_error,
    output Data_valid

);
wire w_tick;
wire Tx_pin;

baud_generator bud(
    .clk(clk),
    .rst(rst),
    .tick(w_tick)
);

URT_Tx Tx(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .Tx_En(Tx_En),
    .Data_in(Tx_Data_in),
    .Data_out(Tx_pin), // Connect Direct to the fpga pin
    .Busy(Busy)
);

UART_Rx Rx (
    .clk(clk),
    .rst(rst),
    .Rx_En(Rx_En),
    .tick(w_tick),
    .Rx_Data_in(Tx_pin),
    .Data_valid(Data_valid),
    .parity_error(parity_error),
    .Rx_Data(Rx_Data_Out)
);

    
endmodule