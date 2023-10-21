/*
 * regm - register memory
 *
 * A 32-bit register memory.  Two registers can be read at once. The
 * variables `read1` and `read2` specify which registers to read.  The
 * output is placed in `data1` and `data2` and at same time one register can
 * be write with wrdata to register specified by wrreg
 *
 */

`ifndef _regm
`define _regm

`ifndef DEBUG_CPU_REG
`define DEBUG_CPU_REG 0
`endif

module regm( write, clk, wrreg, read1, read2, data1, data2, wrdata);

		input   write, clk;
                input   [4:0] wrreg, read1, read2;
                output  [31:0]  data1, data2;
                input   [31:0]  wrdata;

	reg [31:0] mem [0:31];  // 32-bit memory regfile 



	assign data1 = mem[read1];
	assign data2 = mem[read2];

	always @(posedge clk) begin
		if (write ) begin
			mem[wrreg] <= wrdata;
		end
	end
endmodule

`endif
