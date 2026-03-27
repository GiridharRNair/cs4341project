module splitter2 (
    input wire [1:0] in,
    output wire bit0,
    output wire bit1,
    output wire [1:0] out
);
    assign bit0 = in[0];
    assign bit1 = in[1];
    assign out = {bit1, bit0};
endmodule
