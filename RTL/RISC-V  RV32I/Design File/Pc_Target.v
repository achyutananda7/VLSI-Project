module Pc_Target (
    input [31:0] PC,ImmExt,
    output [31:0] Pc_Target
);
assign Pc_Target = PC + ImmExt;
endmodule