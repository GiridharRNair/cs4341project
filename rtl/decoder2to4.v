module decoder2to4 (
    input wire [1:0] in,
    output wire [3:0] out
);
    assign out[0] = ~in[1] & ~in[0];
    assign out[1] = ~in[1] &  in[0];
    assign out[2] =  in[1] & ~in[0];
    assign out[3] =  in[1] &  in[0];
endmodule
