module FourBitMul(inputA,inputB,result);
parameter k=4;

input [k-1:0]inputA;
input [k-1:0]inputB;
wire [k-1:0] inputA;
wire [k-1:0] inputB;

output [((k)*2-1):0]result;
reg    [((k)*2-1):0] result;

//This module is behavioral, which means I can use if statements and built-in math operations.

always@(*)
begin
 
result=8'b00000000;
   result=inputA*inputB;//behavioral multiplier
   
 end

endmodule

/*
//============================================
module testbench();

reg [3:0] a,b;
wire [7:0] c;
 

FourBitMul fbm(a,b,c);

initial begin

a=4'b1010;
b=4'b1010;
#10;
$display("%b|%b|%b ",a,b,c );

a=4'b1010;
b=4'b0010;
#10;
$display("%b|%b|%b ",a,b,c );
$finish;

end


endmodule
 */