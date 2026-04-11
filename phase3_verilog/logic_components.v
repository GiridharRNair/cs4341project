module or2 (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a | b;
endmodule

module or4 (
    input wire a,
    input wire b,
    input wire c,
    input wire d,
    output wire y
);
    assign y = a | b | c | d;
endmodule

module xor2 (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a ^ b;
endmodule

module demux1to4 (
    input wire in,
    input wire [1:0] sel,
    output wire [3:0] out
);
    assign out[0] = in & ~sel[1] & ~sel[0];
    assign out[1] = in & ~sel[1] &  sel[0];
    assign out[2] = in &  sel[1] & ~sel[0];
    assign out[3] = in &  sel[1] &  sel[0];
endmodule