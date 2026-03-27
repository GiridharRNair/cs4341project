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
