/*   in the instruction immediate or register type the 1st 
*    6 bits from MSB correcponds to the opp code the func 
*    means the oppcode
*
*    Here we filtering 4 bits out of those  bit oppcode to 
*    give oppcode to the alu 
*
*     As we are implementing less no of instructions by our ALU 4 bit is sufficient for oppcode
*     remaining 2 bits can be used to control the mux near the Alu input
*/


module alu_control(
		input wire [5:0] funct,
		output reg [3:0] aluctl);

	always @(*) begin
		case(funct[3:0])
			4'd0:  aluctl = 4'd2;	/* add */
			4'd2:  aluctl = 4'd6;	/* sub */
			4'd5:  aluctl = 4'd1;	/* or */
			4'd6:  aluctl = 4'd13;	/* xor */
			4'd7:  aluctl = 4'd12;	/* nor */
			4'd10: aluctl = 4'd7;	/* nand */
			default: aluctl = 4'd0;
		endcase
	end


endmodule

