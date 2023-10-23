`ifndef _alu_control
`define _alu_control

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
			4'd10: aluctl = 4'd7;	/* slt */
			default: aluctl = 4'd0;
		endcase
	end


endmodule

`endif
