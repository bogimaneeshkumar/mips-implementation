/*
 * instruction memory
 *
 */


module im(
		input wire	clk,
		input wire 	[31:0] 	addr,
		output wire [31:0] 	data);

	parameter NMEM = 128;   

	reg [31:0] mem [0:127];  // 32-bit memory with 128 entries

	//actually 2^32 is very big size to systhesis not supported in vivado so currentlt i am decoding(ectracting) only 1st 7 bits of addr 

	assign data = mem[addr[6:0]];  //addr is the PC program counter
	
endmodule
