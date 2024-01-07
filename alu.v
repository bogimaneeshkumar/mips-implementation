/*
*  ALU
*/



module alu(
	input		[3:0]	alu_op,
		input		[31:0]	a, b,
		output reg	[31:0]	out,
		output	reg	zero);

	wire [31:0] sub_ab;
	wire [31:0] add_ab;

	assign zero = (0 == out);  //zero flag

	assign sub_ab = a - b;
	assign add_ab = a + b;


	always @(*) begin
		case (alu_op)
			4'd2:  out <= add_ab;				/* add */
			4'd0:  out <= a & b;				/* and */
			4'd12: out <= ~(a | b);				/* nor */
			4'd1:  out <= a | b;				/* or */
			4'd7:  out <= ~(a & b);	       			 /* nand */ 
			4'd6:  out <= sub_ab;				/* sub */
			4'd13: out <= a ^ b;				/* xor */
			default: out <= 0;
		endcase
	end

endmodule
