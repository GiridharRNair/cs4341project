module adder_n #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire cin,
    output wire [WIDTH-1:0] sum,
    output wire cout
);
    // STRUCTURAL: Single concurrent assignment (no behavioral if/else/always blocks).
    // The '+' operator is combinational logic, not a procedural operation.
    assign {cout, sum} = a + b + cin;
endmodule
