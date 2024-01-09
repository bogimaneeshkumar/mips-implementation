/*
 * MIPS CPU.
 * with 5 stage pipelined
 *
 * all the Structural , Data , Control Hazards are resolved
 */
module cpu(
		input wire clk);

	parameter NMEM = 20;  // number in instruction memory

	wire regwrite_s5;
	wire [4:0] wrreg_s5;
	wire [31:0]	wrdata_s5;
	reg stall_s1_s2;

	/*  flush control to flush the 1st 3 stages of pipeline in case of 
	  jump or branch instrustions to prevent from hazards */
	reg flush_s1, flush_s2, flush_s3;
	always @(*) begin
		flush_s1 <= 1'b0;
		flush_s2 <= 1'b0;
		flush_s3 <= 1'b0;
		if (pcsrc | jump_s4) begin
			flush_s1 <= 1'b1;
			flush_s2 <= 1'b1;
			flush_s3 <= 1'b1;
		end
	end
	

	// stage 1, IF (fetch)

	reg  [31:0] pc;
	initial begin
		pc <= 32'd0;
	end
	// pass PC + 4 to stage 2
	wire [31:0] pc4_s2;
	regr #(.N(32)) regr_pc4_s2(.clk(clk),
						.hold(stall_s1_s2), .clear(flush_s1),
						.in(pc4), .out(pc4_s2));

	// instruction memory and pass instruction from stage 1 to 2
	wire [31:0] inst;
	wire [31:0] inst_s2;
	im #(.NMEM(NMEM), .IM_DATA(IM_DATA))
		im1(.clk(clk), .addr(pc), .data(inst));
	regr #(.N(32)) regr_im_s2(.clk(clk),
						.hold(stall_s1_s2), .clear(flush_s1),
						.in(inst), .out(inst_s2));


	wire [31:0] pc4;  /* PC + 4 as mips is  32bit instruction we need to increment 4 time 
	                   for byte addressable if word addressable then increment by 1 is enough */
	assign pc4 = pc + 4;

	always @(posedge clk) begin
		if (stall_s1_s2) 
			pc <= pc;  //if inst is in process then do not increment pc of that respective inst
		else if (pcsrc == 1'b1)
			pc <= baddr_s4;  //branch address
		else if (jump_s4 == 1'b1)
			pc <= jaddr_s4;  //jump address
		else
			pc <= pc4;
	end

	

	// {{{ stage 2, ID (decode)

	// decode instruction
	wire [5:0]  opcode;
	wire [4:0]  rs;
	wire [4:0]  rt;
	wire [4:0]  rd;
	wire [15:0] imm;
	wire [31:0] jaddr_s2;
	wire [31:0] seimm;  // sign extended immediate
	//
	assign opcode   = inst_s2[31:26];
	assign rs       = inst_s2[25:21];
	assign rt       = inst_s2[20:16];
	assign rd       = inst_s2[15:11];
	assign imm      = inst_s2[15:0];
	assign jaddr_s2 = {pc[31:28], inst_s2[25:0], {2{1'b0}}};
	assign seimm 	= {{16{inst_s2[15]}}, inst_s2[15:0]};

	// register memory
	wire [31:0] data1, data2;
	regm regm1(.clk(clk), .read1(rs), .read2(rt),
			.data1(data1), .data2(data2),
			.regwrite(regwrite_s5), .wrreg(wrreg_s5),
			.wrdata(wrdata_s5));

	// pass rs to stage 3 (for forwarding)
	wire [4:0] rs_s3;
	regr #(.N(5)) regr_s2_rs(.clk(clk), .clear(1'b0), .hold(stall_s1_s2),
				.in(rs), .out(rs_s3));

	// transfer register data to stage 3
	wire [31:0]	data1_s3, data2_s3;
	regr #(.N(64)) reg_s2_mem(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
				.in({data1, data2}),
				.out({data1_s3, data2_s3}));

	// transfer seimm, rt, and rd to stage 3
	wire [31:0] seimm_s3;
	wire [4:0] 	rt_s3;
	wire [4:0] 	rd_s3;
	regr #(.N(32)) reg_s2_seimm(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
						.in(seimm), .out(seimm_s3));
	regr #(.N(10)) reg_s2_rt_rd(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
						.in({rt, rd}), .out({rt_s3, rd_s3}));

	// control (opcode -> ...)
	wire		regdst;
	wire		branch_eq_s2;
	wire		branch_ne_s2;
	wire		memread;
	wire		memwrite;
	wire		memtoreg;
	wire [3:0]	aluctl;
	wire		regwrite;
	wire		alusrc;
	wire		jump_s2;
	//
	control ctl1(.opcode(opcode), .regdst(regdst),
				.branch_eq(branch_eq_s2), .branch_ne(branch_ne_s2),
				.memread(memread),
		     .memtoreg(memtoreg), .aluctl(aluctl),
				.memwrite(memwrite), .alusrc(alusrc),
				.regwrite(regwrite), .jump(jump_s2));

	// shift left, seimm
	wire [31:0] seimm_sl2;
	assign seimm_sl2 = {seimm[29:0], 2'b0};  // shift left 2 bits
	// branch address
	wire [31:0] baddr_s2;
	assign baddr_s2 = pc4_s2 + seimm_sl2;

	// transfer the control signals to stage 3
	wire		regdst_s3;
	wire		memread_s3;
	wire		memwrite_s3;
	wire		memtoreg_s3;
	wire [3:0]	aluctl_s3;
	wire		regwrite_s3;
	wire		alusrc_s3;
	// A bubble is inserted by setting all the control signals
	// to zero (stall_s1_s2).
	regr #(.N(8)) reg_s2_control(.clk(clk), .clear(stall_s1_s2), .hold(1'b0),
			.in({regdst, memread, memwrite,
					memtoreg, aluctl, regwrite, alusrc}),
			.out({regdst_s3, memread_s3, memwrite_s3,
					memtoreg_s3, aluctl_s3, regwrite_s3, alusrc_s3}));

	wire branch_eq_s3, branch_ne_s3;
	regr #(.N(2)) branch_s2_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in({branch_eq_s2, branch_ne_s2}),
				.out({branch_eq_s3, branch_ne_s3}));

	wire [31:0] baddr_s3;
	regr #(.N(32)) baddr_s2_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in(baddr_s2), .out(baddr_s3));

	wire jump_s3;
	regr #(.N(1)) reg_jump_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in(jump_s2),
				.out(jump_s3));

	wire [31:0] jaddr_s3;
	regr #(.N(32)) reg_jaddr_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in(jaddr_s2), .out(jaddr_s3));
	// }}}

	// {{{ stage 3, EX (execute)

	// pass through some control signals to stage 4
	wire regwrite_s4;
	wire memtoreg_s4;
	wire memread_s4;
	wire memwrite_s4;
	regr #(.N(4)) reg_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in({regwrite_s3, memtoreg_s3, memread_s3,
						memwrite_s3}),
				.out({regwrite_s4, memtoreg_s4, memread_s4,
						memwrite_s4}));

	// second ALU input can come from an immediate value or data
	wire [31:0] alusrc_data2;
	assign alusrc_data2 = (alusrc_s3) ? seimm_s3 : fw_data2_s3;
	
	// ALU
	wire [31:0]	alurslt;
	wire zero_s3;
	alu alu1(.ctl(aluctl), .a(data1_s3), .b(alusrc_data2), .out(alurslt),
									.zero(zero_s3));
	wire zero_s4;
	regr #(.N(1)) reg_zero_s3_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
					.in(zero_s3), .out(zero_s4));

	// pass ALU result and zero to stage 4
	wire [31:0]	alurslt_s4;
	regr #(.N(32)) reg_alurslt(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in({alurslt}),
				.out({alurslt_s4}));

	// pass data2 to stage 4
	wire [31:0] data2_s4;
	
	regr #(.N(32)) reg_data2_s3(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(data2_s3), .out(data2_s4));

	// write register
	wire [4:0]	wrreg;
	wire [4:0]	wrreg_s4;
	assign wrreg = (regdst_s3) ? rd_s3 : rt_s3;
	// pass to stage 4
	regr #(.N(5)) reg_wrreg(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(wrreg), .out(wrreg_s4));

	wire branch_eq_s4, branch_ne_s4;
	regr #(.N(2)) branch_s3_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in({branch_eq_s3, branch_ne_s3}),
				.out({branch_eq_s4, branch_ne_s4}));

	wire [31:0] baddr_s4;
	regr #(.N(32)) baddr_s3_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(baddr_s3), .out(baddr_s4));

	wire jump_s4;
	regr #(.N(1)) reg_jump_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(jump_s3),
				.out(jump_s4));

	wire [31:0] jaddr_s4;
	regr #(.N(32)) reg_jaddr_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(jaddr_s3), .out(jaddr_s4));
	// }}}

	// {{{ stage 4, MEM (memory)

	// pass regwrite and memtoreg to stage 5
	wire memtoreg_s5;
	regr #(.N(2)) reg_regwrite_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in({regwrite_s4, memtoreg_s4}),
				.out({regwrite_s5, memtoreg_s5}));

	// data memory
	wire [31:0] rdata;
	dm dm1(.clk(clk), .addr(alurslt_s4), .rd(memread_s4), .wr(memwrite_s4),
			.wdata(data2_s4), .rdata(rdata));
	// pass read data to stage 5
	wire [31:0] rdata_s5;
	regr #(.N(32)) reg_rdata_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(rdata),
				.out(rdata_s5));

	// pass alurslt to stage 5
	wire [31:0] alurslt_s5;
	regr #(.N(32)) reg_alurslt_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(alurslt_s4),
				.out(alurslt_s5));

	// pass wrreg to stage 5
	regr #(.N(5)) reg_wrreg_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(wrreg_s4),
				.out(wrreg_s5));

	// branch
	reg pcsrc;
	always @(*) begin
		case (1'b1)
			branch_eq_s4: pcsrc <= zero_s4;
			branch_ne_s4: pcsrc <= ~(zero_s4);
			default: pcsrc <= 1'b0;
		endcase
	end
	// }}}
			
	// {{{ stage 5, WB (write back)

	assign wrdata_s5 = (memtoreg_s5 == 1'b1) ? rdata_s5 : alurslt_s5;

	// }}}
	
	// load use data hazard detection, signal stall
	
	/* If an operation in stage 5 (WB) write the value to the register
	 * and the operation in stage 3 (EX) depends on this value,
	 * a stall must be performed.  
  	 *
	 *   ADD R1, R2, R5  ;
  	 *   Sub R5, R1, R3 ;
	 */
	always @(*) begin
		if ((rt == rt_s3) || (rs == rt_s3) ) begin
			stall_s1_s2 <= 1'b1;  // perform a stall
		end else
			stall_s1_s2 <= 1'b0;  // no stall
	end


endmodule

