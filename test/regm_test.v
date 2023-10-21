module regm_test;
reg[4:0] read1, read2, wrreg;
reg[31:0] wrdata;
reg write, clk;
wire [31:0] data1, data2;
integer k;

regm test(write, clk, wrreg, read1, read2, data1, data2, wrdata);
initial clk =0;
always #5 clk = !clk;
 
initial
begin $dumpfile("regm_test.vcd");
 $dumpvars(0, regm_test);
#1 write = 0;
end

initial
begin 
#7
for (k=0; k< 32; k=k+1) begin
	wrreg =k ; wrdata = 10*k; write =1;
	#10 write =0; //even the original circuit input is wire kind but here in the test_bench we are giving those inputs as reg to be continuous untill we change.
//call the delay perfectly such that write is high at every posedge by taking
//into consideration that time period of clock is 10
end
 #20
 for(k=0; k<32; k= k+2) begin
	 read1  = k; read2 = k+1;
	 #5;
	 $display("reg[%2d] = %d, reg[%2d] = %d", read1, data1, read2, data2);
 end
 #2000 $finish;
 end 
 endmodule
