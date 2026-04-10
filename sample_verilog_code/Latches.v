module DFlipFlop(clk,d,q,qnot);
input clk,d;
output q,qnot;

wire clk,d;
reg q, qnot;

reg a1,a2,a3,a4;
reg b1,b2;

always@(*)
begin
a1=~(a2&a4);
a2=~(a1&clk);
a3=~(clk&a2&a4);
a4=~(a3&d);
b1=~(a2&b2);
b2=~(a3&b1);
q=b1;
qnot=b2;
end

endmodule

 
module testbench();
wire q,qnot;
reg clk,d;

 
DFlipFlop egg(clk,d,q,qnot); 

initial
begin

$display(" | | |q");
$display("c| | |n");
$display("l| | |o");
$display("k|d|q|t");
$display("--------");

	
clk=0;d=0;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=0;#10;;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=0;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=0;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=0;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=0;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=1;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=1;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=1;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=1;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=0;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=0;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");

clk=0;d=0;#10;
$display("curr %b|%b|%b|%b",clk,d,q,qnot);
clk=1;d=0;#10;
$display("next %b|%b|%b|%b",clk,d,q,qnot);
$display("--------");


end


endmodule
 