module twos_complement_n #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);
    assign out = ~in + {{(WIDTH-1){1'b0}}, 1'b1};
endmodule
