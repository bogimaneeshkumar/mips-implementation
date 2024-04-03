/*
 * instruction memory
 *
 */


module im #( 	parameter NMEM = 32, IM_DATA=128;  )   (	input wire	clk,
		input wire 	[31:0] 	addr,
		output wire [31:0] 	data);

	reg [NMEM-1:0] mem [0:IM_DATA-1];  // 32-bit memory with 128 entries

	assign data = mem[addr];  //addr is the PC program counter
	
endmodule
