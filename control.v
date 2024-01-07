module control(
		input  wire	[5:0]	opcode,
		output reg			branch_eq, branch_ne,
		output reg [3:0]	aluctl,
		output reg			memread, memwrite, memtoreg,
		output reg			regdst, regwrite, alusrc,
		output reg			jump);

	always @(*) begin
		/* defaults */
		aluop[1:0]	<= 2'b10;
		alusrc		<= 1'b0;
		branch_eq	<= 1'b0;
		branch_ne	<= 1'b0;
		memread		<= 1'b0;
		memtoreg	<= 1'b0;
		memwrite	<= 1'b0;
		regdst		<= 1'b1;
		regwrite	<= 1'b1;
		jump		<= 1'b0;

		case (opcode)
			6'b000011: begin	/* lw */
				memread  <= 1'b1;
				regdst   <= 1'b0;
				memtoreg <= 1'b1;
				alusrc   <= 1'b1;
			end
			6'b001000: begin	/* addi */
				regdst   <= 1'b0;
				alusrc   <= 1'b1;
			end
			6'b011000: begin	/* subi */
				regdst   <= 1'b0;
				alusrc   <= 1'b1;
			end
			6'b110100: begin	/* beq */
				branch_eq <= 1'b1;
				regwrite  <= 1'b0;
			end
			6'b001011: begin	/* sw */
				memwrite <= 1'b1;
				alusrc   <= 1'b1;
				regwrite <= 1'b0;
			end
			6'b110101: begin	/* bne */
				branch_ne <= 1'b1;
				regwrite  <= 1'b0;
			end
			6'b100010: begin	/* add */
			end
			6'b000010: begin	/* jump */
				jump <= 1'b1;
			end
		endcase
	end
	
		always @(*) begin
    case(opcode[5:4])
			2'd0: aluctl <= 4'd2;	/* addi */
			2'd1: aluctl <= 4'd6;	/* subi */
			2'd2: aluctl <= funct[3:0];
			2'd3: aluctl <= 4'd2;	/* add */
			default: aluctl = 0;
		endcase
	end
	
endmodule
