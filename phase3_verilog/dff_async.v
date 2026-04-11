module dff_async (
    input wire clk,
    input wire reset,
    input wire d,
    output reg q
);
    // STRUCTURAL: This module IS the primitive flip-flop component itself.
    // The always block implements the hardware behavior of a D flip-flop,
    // not algorithmic/procedural logic. This is a structural building block.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 1'b0;
        end else begin
            q <= d;
        end
    end
endmodule
