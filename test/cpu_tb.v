/*
 * NAME
 *
 * cpu_tb.v - generic cpu test bench
 *
 * DESCRIPTION
 *
 * 
 *   ./t0001-no_hazard > t0001-no_hazard.out
 */

`include "cpu.v"

module cpu_tb;

	integer i = 0;

	reg			clk;

	cpu #(.NMEM(`NUM_IM_DATA), .IM_DATA(`IM_DATA_FILE))
			mips1(.clk(clk));

	always begin
		clk <= ~clk;
		#5;
	end

	initial begin
		$dumpfile(`DUMP_FILE);
		$dumpvars(0, cpu_tb);

		clk <= 1'b0;

		/* cpu will $display output when `DEBUG_CPU_STAGES is on */

		// Run all the lines, plus 5 extra to finish off the pipeline.
		for (i = 0; i < `NUM_IM_DATA + 5; i = i + 1) begin
			@(posedge clk);
		end

		$finish;
	end
endmodule

