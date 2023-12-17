/*
 * register memory bank
 *
 * A 32-bit register memory bank.  with two read ports and one write port
 *
 *The register at address 0, the value read is always zero.
 */

module regm (
    input wire clk,
    input wire [4:0] read1, read2,
    output wire [31:0] data1, data2,
    input wire regwrite,
    input wire [4:0] wrreg,
    input wire [31:0] wrdata
);

    reg [31:0] mem [0:31]; // 32-bit memory with 32 entries

    always @(*) begin
        if (read1 == 5'd0)
            data1 = 32'd0;
	    else if (read1 == wrreg && regwrite)   //If the register being read is the same as that being written,value being written will be available immediately without a one cycle delay.
            data1 = wrdata;
        else
            data1 = mem[read1];

        if (read2 == 5'd0)
            data2 = 32'd0;
	    else if (read2 == wrreg && regwrite)  //If the register being read is the same as that being written, the value being written will be available immediately without a one cycle delay.
            data2 = wrdata;
        else
            data2 = mem[read2];
    end

    always @(posedge clk) begin
        if (regwrite && wrreg != 5'd0)
            mem[wrreg] <= wrdata; // write a non-zero register
    end

endmodule
