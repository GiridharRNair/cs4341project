module reg_n #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] q
);
    wire [WIDTH-1:0] d_sel;
    genvar i;

    assign d_sel = en ? d : q;

    // STRUCTURAL: The 'generate...for' loop executes at ELABORATION TIME (compile-time),
    // not simulation time. It unrolls into separate dff_async instantiations (one per bit).
    // This is parametric component instantiation, not algorithmic programming.
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_dff
            dff_async u_dff (
                .clk(clk),
                .reset(reset),
                .d(d_sel[i]),
                .q(q[i])
            );
        end
    endgenerate
endmodule
