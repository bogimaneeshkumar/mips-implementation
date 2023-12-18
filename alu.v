/*
*  ALU
*/

module alu(
	input		[5:0]	opp_code,
		input		[31:0]	a, b,
		output reg	[31:0]	out,
		output	reg	zero);

	wire [31:0] sub_ab;
	wire [31:0] add_ab;

	assign zero = (0 == out);  //zero flag

	assign sub_ab = a - b;
	assign add_ab = a + b;


	always @(*) begin
		case (opp_code)
			6'd2:  out <= add_ab;				/* add */
			6'd0:  out <= a & b;				/* and */
			6'd12: out <= ~(a | b);				/* nor */
			6'd1:  out <= a | b;				/* or */
			6'd7:  out <= ~(a & b);	       			 /* nand */ 
			6'd6:  out <= sub_ab;				/* sub */
			6'd13: out <= a ^ b;				/* xor */
			default: out <= 0;
		endcase
	end

endmodule

