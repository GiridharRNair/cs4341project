module testbench();
parameter n=4*8;
parameter m=2*n;

reg [3:0] lownum;
reg [3:0] highnum;
reg [7:0] totnum;
reg [7:0] nexnum;
reg [m-1:0] lasnum;
reg test;

initial begin
assign highnum=4'b0000;
assign lownum=4'b1111;
assign test=1'b1;
totnum={highnum,lownum};

nexnum={{4{1'b0}},lownum};

lasnum={{(n/2){1'b0}},{n{test}},{(n/2){1'b0}}};


$display ("Concatenation");

$display("[%b][%b]",highnum,lownum);
$display("[%b]",totnum);
$display("[%b]",nexnum);
$display("[%b]",lasnum);

$finish;

end

endmodule