/*
 * Data Memory.
 *
 * 32-bit data with a 7 bit address (128 entries).
 *
 * The read and write operations .
 *
 */
module dm(
		input wire			clk,
		input wire	[6:0]	addr,
		input wire			rd, wr,
		input wire 	[31:0]	wdata,
		output wire	[31:0]	rdata);

	reg [31:0] mem [0:127];  // 32-bit memory with 128 entries

	 always @(posedge clk) begin
        if (wr) begin
            mem[addr] <= wdata;
        end
        if (rd) begin
            rdata <= mem[addr];
        end
    end
endmodule

