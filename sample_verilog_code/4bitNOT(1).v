//=================================================================
//
// FourBitNOT
//
// Inputs
// inputA, a 4-bit integer
//
// Output
// outputC, a 4-bit integer
//
//==================================================================

module FourBitNOT(inputA,outputC);
parameter k=4;
input  [k-1:0] inputA;
output [k-1:0] outputC;
wire   [k-1:0] inputA;
reg    [k-1:0] outputC;
reg    [k-1:0] result;

always@(*)
begin
	result=~(inputA);
	outputC=result;
end
 
endmodule

/*
//============================================
module testbench();

reg [3:0] a;
wire [3:0] c;

FourBitNOT fbn(a,c);

initial begin
a=4'b1111;
#10;
$display("%b|%b",a,c);
$finish;

end


endmodule
 */