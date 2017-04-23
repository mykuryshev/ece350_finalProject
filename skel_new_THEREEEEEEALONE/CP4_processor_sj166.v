module CP4_processor_sj166(clock, reset, dmem_data_in, dmem_address, memory_out, vga_address, vga_out,
									vga_clock, timer_out, key_press_ind, key_press_data, reg28_data, reg29_data);

	input clock, reset;
	
	output 	[31:0] 	dmem_data_in;
	output	[11:0]	dmem_address;
	
	
/////FETCH STAGE: PC, IMEM, F/D register//////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire[31:0] PC_in, PC_incr, FD_in, PC_FD;
	wire[31:0] PC_out;
	wire[31:0] F_D_out; 
	wire[11:0] imem_in;
	wire[31:0] imem_out;
	wire flush;
	wire pc_enable;
	
	register PC(.clk(~clock), .data_in(PC_in), .write_enable(pc_enable), .data_out(PC_out), .ctrl_reset(reset));
	assign imem_in = PC_out[11:0]; //imem read address = bottom 12 bits of PC 
	
	imem myimem(	.address 	(imem_in),
					.clken		(1'b1),
					.clock		(~clock), 
					.q			(imem_out)
	);
	
	wire lw_D = ~F_D_out[31] && F_D_out[30] && ~|F_D_out[29:27]; //01000
	assign pc_enable = ~lw_D;
	
	assign FD_in = flush || lw_D ? 32'h00000000 : imem_out;
	
	register F_D(.clk(clock), .data_in(FD_in), .write_enable(1'b1), .data_out(F_D_out), .ctrl_reset(reset));
	register PC_F(.clk(clock), .data_in(PC_out), .write_enable(1'b1), .data_out(PC_FD), .ctrl_reset(reset));
	
	adder_32 PC_adder(.A(PC_out), .B(32'h00000001), .Cin(1'b0), .Sums(PC_incr));
	
	
	
/////DECODE STAGE: REGFILE AND D/X////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire[4:0] rs_addr, rt_addr, regfile_readinput_B, regfile_readinput_A;
	wire[4:0] regfile_write_addr;
	wire regfile_write_enable, rs_write;
	wire branch_indicator, sw_indicator, jr_indicator, bex_indicator, blt_indicator, bne_indicator, sw_VGAind;
	wire[31:0] regread_A, regread_B;
   wire[31:0]	rd_writedata, rs_writeData;
	wire[4:0] rstatus_addr = 5'b11110; //rstatus = 30
	wire[4:0] regA_actual, regB_actual; //Indicates the ACTUAL register locations read for A and B
	
	output timer_out;
	timer processor_timer(clock, reset, timer_out);
	
	input key_press_ind;
	input[7:0] key_press_data;
	wire[31:0] regfile_key_data;
	assign regfile_key_data[31:8] = 24'h000000;
	assign regfile_key_data[7:0] = key_press_data;

	output[31:0] reg28_data, reg29_data;
	
	//A = rs or rstatus if it's a bex, B = rt, or rd if it's a branch or a sw or a jr
	regfile_mod reg_file(.clock(~clock), .ctrl_writeEnable(regfile_write_enable), .ctrl_reset(reset), .ctrl_writeReg(regfile_write_addr), 
						  .ctrl_readRegA(regfile_readinput_A[4:0]), .ctrl_readRegB(regfile_readinput_B[4:0]), .data_writeReg(rd_writedata[31:0]),
						  .rs_write(rs_write), .rs_writeData(rs_writeData), 
						  .data_readRegA(regread_A[31:0]), .data_readRegB(regread_B[31:0]), .timer_state(timer_out), 
						  .key_pressed_indicator(key_press_ind), .key_pressed_data(regfile_key_data), .reg28_data(reg28_data), .reg29_data(reg29_data));
	
	//Current instruction is branch instruction if opcode = 00010 or 00110
	assign bne_indicator = (~|F_D_out[31:29] && F_D_out[28] && ~F_D_out[27]); 
	assign blt_indicator = (~|F_D_out[31:30] && &F_D_out[29:28] && ~F_D_out[27]);
	assign branch_indicator = blt_indicator || bne_indicator;
	
	//Current instruction is sw if opcode = 00111
	assign sw_indicator = ~|F_D_out[31:30] && &F_D_out[29:27];
	
	//Current instruction is jr if opcode = 00100
	assign jr_indicator = (~|F_D_out[31:30] && F_D_out[29] && ~|F_D_out[28:27]);
	
	//Current instruction is bex if opcode = 10110
	assign bex_indicator = F_D_out[31] && ~F_D_out[30] && &F_D_out[29:28] && ~F_D_out[27];
	
	//01111
	assign sw_VGAind = ~F_D_out[31] && &F_D_out[30:27];
	
	
	//If current instr is a bex, then the reg A that we read from will be rstatus, instead of rs
	generate
	
	for(i = 0; i < 5; i = i+1) begin: loop1
		//a: rs
		//b: rstatus
		//ctrl: bex indicator
		mux_21 temp(.a(F_D_out[i+17]), .b(rstatus_addr[i]), .ctrl(bex_indicator), .out(regfile_readinput_A[i]));
	end
	endgenerate
	
	assign regA_actual = bex_indicator ? rstatus_addr : F_D_out[21:17];
	assign regB_actual = branch_indicator || sw_indicator || sw_VGAind || jr_indicator ? F_D_out[26:22] : F_D_out[16:12];
	
	// If current instr is a branch or jr or sw, then the reg B that we read from regile will be rd, not rt. 
	genvar i; 
	generate
	
	for(i = 0; i < 5; i = i+1) begin: loop2
		//a: rt
		//b: rd
		//ctrl: branch indicator OR sw indicator OR jr indicator
		mux_21 temp(.a(F_D_out[i+12]), .b(F_D_out[i+22]), .ctrl(branch_indicator || sw_indicator || sw_VGAind || jr_indicator), .out(regfile_readinput_B[i]));
	end
	endgenerate
	
	
	//_x denotes that these are the values for X stage
	wire[4:0] alu1_x, sh_x, rd_addr_x, addrA_x, addrB_x;
	wire[31:0] pc_x,  regA_x, regB_x, imdt_x, tgt_x;
	wire [4:0] op_x;
	
	DX d_x(.op(F_D_out[31:27]), .pc(PC_FD), .alu(F_D_out[6:2]), .sh(F_D_out[11:7]), .a(regread_A[31:0]), .b(regread_B[31:0]), .flush(flush), 
			 .imdt(F_D_out[16:0]), .t(F_D_out[26:0]), .rd_addr(F_D_out[26:22]), .clock(clock), .addrA(regA_actual), .addrB(regB_actual), 
			 .DX_reset(reset), .opcode(op_x[4:0]), .PCplusone(pc_x[31:0]), .ALUopcode(alu1_x[4:0]), .shamt(sh_x[4:0]), .regA(regA_x[31:0]), 
			 .regB(regB_x[31:0]), .immediate(imdt_x[31:0]), .target(tgt_x[31:0]), .rd_address(rd_addr_x[4:0]), .addressA(addrA_x), .addressB(addrB_x));
	
	
	
//////EXECUTE STAGE: ALUs, branch logic /////////////////////////////////////////////////////////////////////////////////////////////////////

	wire br_x, jr_x, j_x, jal_x, bne_x, blt_x, bex_x, r_type_x, lw_x, sw_x, addi_x, swVGA_x;
	
	//Current instruction is branch instruction if opcode = 00010 or 00110
	assign bne_x = (~|op_x[4:2] && op_x[1] && ~op_x[0]); 
	assign blt_x = (~|op_x[4:3] && &op_x[2:1] && ~op_x[0]);
	assign br_x = blt_x || bne_x;
	
	//Current instruction is jr if opcode = 00100
	assign jr_x = ~|op_x[4:3] && op_x[2] && ~|op_x[1:0];
	
	//Current instruction is bex if opcode = 10110
	assign bex_x = op_x[4] && ~op_x[3] && &op_x[2:1] && ~op_x[0];
	
	//Current instruction is j indicator if opcode = 00001
	assign j_x = ~|op_x[4:1] && op_x[0];
	
	//Current instruction is jal if opcode = 00011
	assign jal_x = ~|op_x[4:2] && &op_x[1:0];
	
	//00000
	assign r_type_x = ~|op_x[4:0];
	
	//01000
	assign lw_x = ~op_x[4] && op_x[3] && ~|op_x[2:0];
	
	//00111
	assign sw_x = ~|op_x[4:3] && &op_x[2:0];
	
	//00101
	assign addi_x = ~|op_x[4:3] && op_x[2] && ~op_x[1] && op_x[0];
	
	//01111
	assign swVGA_x = ~op_x[4] && &op_x[3:0];
	
	//Alu 2
	wire[31:0] branch_target;
	ALU ALU2(.data_operandA(pc_x[31:0]), .data_operandB(imdt_x[31:0]), .ctrl_ALUopcode(5'b00000), 
				.ctrl_shiftamt(5'b00000), .data_result(branch_target[31:0]));
				
	
		
	wire[31:0] alu_inA, alu_inB, alu1_int1, alu1_int2; //Pick register if it's an r-type or a branch, pick imdt otherwise; int1, int2 = intermediates for input B
	
	//MUX to select ALU1 intermediate input
	generate
	for(i = 0; i < 32; i = i+1) begin: loop3
		//a: imdt
		//b: registerb
		//ctrl: r_type_x OR branch
		mux_21 temp(.a(imdt_x[i]), .b(regB_x[i]), .ctrl(br_x || r_type_x), .out(alu1_int1[i]));
	end
	endgenerate
	
	//If bex, alu1 input B = 0's
	assign alu1_int2[31:0] = bex_x ? 32'h00000000 : alu1_int1[31:0];
	
	
	wire A_usesReg = r_type_x || addi_x || sw_x || lw_x || bex_x || blt_x || bne_x || swVGA_x;
	wire B_usesReg = r_type_x || bne_x || blt_x;
	
	//MX BYPASSING
	wire setxW_bypassA, setxW_bypassB;
	assign setxW_bypassA = rs_write && (bex_x || (A_usesReg && addrA_x == 5'b11110));
	assign setxW_bypassB = rs_write && (B_usesReg && addrB_x == 5'b11110);
	
	
	wire[4:0] aX_M = addrA_x ~^ M_addr; //aX_M = bitwise XNOR of register A in X stage with write destination for M stage
	wire[4:0] bX_M = addrB_x ~^ M_addr; //bX_M = bitwise XNOR of register B in X stage with write destination for M stage
	
	wire mxbypass_A, mxbypass_B;
	assign mxbypass_A = A_usesReg && M_writes && &aX_M[4:0] && |addrA_x[4:0];
	assign mxbypass_B = B_usesReg && M_writes && &bX_M[4:0] && |addrB_x[4:0];
	
	//WX BYPASSING
	wire wxbypass_A, wxbypass_B;
	wire[4:0] aX_W = addrA_x ~^ regfile_write_addr;
	wire[4:0] bX_W = addrB_x ~^ regfile_write_addr;
	
	assign wxbypass_A = A_usesReg && regfile_write_enable && &aX_W[4:0] && |addrA_x[4:0]; //No bypass if using $0
	assign wxbypass_B = B_usesReg && regfile_write_enable && &bX_W[4:0] && |addrB_x[4:0];
	
	
	//PICKING BW MX AND WX BYPASSES
	wire[31:0] a_bypassed = mxbypass_A ? M_data : rd_writedata;
	wire[31:0] a_byp_setx = setxW_bypassA ? rs_writeData : a_bypassed;
	assign alu_inA = wxbypass_A || mxbypass_A || setxW_bypassA ? a_byp_setx : regA_x;
	
	wire[31:0] b_bypassed = mxbypass_B ? M_data : rd_writedata;
	wire[31:0] b_byp_setx = setxW_bypassB ? rs_writeData : b_bypassed;
	assign alu_inB = wxbypass_B || mxbypass_B || setxW_bypassB ? b_byp_setx : alu1_int2;
	
	
	//ALU1 opcode: If it's an R-type, use the ALU opcode from FD. If not, default to 0 (addition). Then, if it's a branch or bex, pick subtraction. 
	wire[4:0] intermediate_opcode;
	wire[4:0] alu1_opcode;
	assign intermediate_opcode = r_type_x ? alu1_x[4:0] : 5'b00000;
	assign alu1_opcode = br_x || bex_x ? 5'b00001 : intermediate_opcode;
	
	wire[31:0] alu1_out;
	wire alu1_LT, alu1_NEQ, alu1_OF;
	
	//ALU 1
	ALU ALU1(.data_operandA(alu_inA), .data_operandB(alu_inB), .ctrl_ALUopcode(alu1_opcode), 
				.ctrl_shiftamt(sh_x[4:0]), .data_result(alu1_out), .isNotEqual(alu1_NEQ), .isLessThan(alu1_LT), .overflow(alu1_OF));
	
	
	

	
	
	
	//Setting up multdiv							 
	wire[31:0] multdiv_result, multdiv_addr_out;
	wire multdiv_ready;
	
	wire[31:0] multdiv_addr_in, multdiv_A, multdiv_B;
	wire multdiv_exception, x_mult, x_div, multdiv_reset;
	wire[4:0] multdiv_writeAddr;
	
	assign multdiv_addr_in[4:0] = rd_addr_x;
		
	register multdiv_addr(clock, multdiv_addr_in, x_mult || x_div, multdiv_addr_out, reset);
	register mdA(~clock, alu_inA, x_mult || x_div, multdiv_A, reset);
	register mdB(~clock, alu_inB, x_mult || x_div, multdiv_B, reset);
	
	assign x_mult = ~|alu1_opcode[4:3] && &alu1_opcode[2:1] && ~alu1_opcode[0]; //mult if alu1_x = 00110
	assign x_div = ~|alu1_opcode[4:3] && &alu1_opcode[2:0]; //div if 00111
	
	multdiv mult_div(multdiv_A, multdiv_B, x_mult, x_div, clock, multdiv_result, multdiv_exception, 
						  multdiv_ready, multdiv_reset);
	
	wire[5:0] counter_outputs;
	counter33 multdiv_counter(.clock(clock), .reset(x_mult || x_div), .out(counter_outputs));
	
	//Reset multdiv when counter = 0
	assign multdiv_reset = ~|counter_outputs[5:0];
	
	
	
	
	
	
	
	
	
	
	//X Stage Control 
	
	wire take_blt = blt_x && ~alu1_LT && |alu1_out[31:0];
	wire take_bne = bne_x && ~|alu1_out[31:0]; //BEQ
	wire take_branch = take_blt || take_bne;
	
	wire take_bex = bex_x && alu1_NEQ;
	wire take_target = j_x || jal_x || take_bex;
	
	wire take_rd = jr_x;
	
	
	//PC_alt will be one of {Branch Target, Target, or RD} .... PC will either be PC_alt or PC_Incr; if take_alt is true, PC will be PC_alt 
	wire [31:0] PC_alt; 
	wire take_alt = take_branch || take_target || take_rd;
	
	assign flush = take_alt;
	
	//MUX: alt_int = branch target or immediate target
	wire[31:0] alt_int;
	generate
	
	for(i = 0; i < 32; i = i+1) begin: loop4
		//a: branch target
		//b: target
		//ctrl: take_target
		mux_21 temp(.a(branch_target[i]), .b(tgt_x[i]), .ctrl(take_target), .out(alt_int[i]));
	end
	endgenerate

	wire[31:0] jr_reg, jr_reg_wxbypassed, jr_reg_bypassed;
	
	assign jr_reg_wxbypassed = rs_write ? rs_writeData : rd_writedata;
	assign jr_reg_bypassed = M_writes && &bX_M[4:0] && |addrB_x[4:0] ? M_data : jr_reg_wxbypassed;
	
	assign jr_reg = (M_writes && &bX_M[4:0]) || (regfile_write_enable && &bX_W[4:0]) || (rs_write && (addrB_x == 5'b11110)) ? jr_reg_bypassed : regB_x;
		
	//MUX 2: Final value of PC_alt
	generate
	
	for(i = 0; i < 32; i = i+1) begin: loop5
		//a: branch target or target
		//b: rd
		//ctrl: take_rd (same as jr_x)
		mux_21 temp(.a(alt_int[i]), .b(jr_reg[i]), .ctrl(take_rd), .out(PC_alt[i]));
	end
	endgenerate
	
	//MUX 3: PC = PC_Alt or PC_Incr
	generate
	for(i = 0; i < 32; i = i+1) begin: loop6
		//a: PC+1
		//b: PC alt
		//ctrl: take_alt
		mux_21 temp(.a(PC_incr[i]), .b(PC_alt[i]), .ctrl(take_alt), .out(PC_in[i]));
	end
	endgenerate
	

	wire[31:0] alu1out_M, target_M, regB_M, pc_M;
	wire[4:0] opcode_M, rd_addr_M, aluop_M;
	wire overflow_M;
	
	XM x_m(.op(op_x), .rd(rd_addr_x), .regb(jr_reg), .alu(alu1_out), .tgt(tgt_x), .clock(clock), .reset(reset), .of(alu1_OF), .aluop(alu1_opcode), .pc(pc_x),
			 .overflow(overflow_M), .opcode(opcode_M), .rd_addr(rd_addr_M), .regB_data(regB_M), .aluout(alu1out_M), .target(target_M), .alu_opcode(aluop_M), .pc_out(pc_M));

	

	
	
	////// M STAGE: Memory reads and writes /////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign dmem_address = alu1out_M[11:0];
	assign dmem_data_in = regB_M[31:0];
	wire[31:0] dmem_out;
	wire sw_M;
	assign sw_M = ~|opcode_M[4:3] && &opcode_M[2:0];

	
	dmem mydmem(.address	(dmem_address), .clock(~clock), .data(dmem_data_in), .wren(sw_M), .q	(dmem_out)); 
	
	input[18:0] vga_address;
	output[7:0] vga_out;
	
	//SW_VGA CODE = 01111
	wire sw_VGA;
	assign sw_VGA = ~opcode_M[4] && &opcode_M[3:0];
	
	//LW_VGA CODE = 11000
	wire lw_VGA;
	assign lw_VGA = &opcode_M[4:3] && ~|opcode_M[2:0];
	
	input vga_clock;
	
	wire[31:0] vga_outputA;
	assign vga_outputA[31:8] = 24'h000000;
	
	//VGAMEM Usage:
	//Write port A: Allows processor to store to vgamem
	//Read port A: Allows processor to load from vgamem
	
	//Write port B: Disabled
	//Read port B: Allows vga controller to read from vgamem
	
	vgamem_new myvgamem(.address_a(alu1out_M[18:0]), .address_b(vga_address), .inclock(~clock), .data_a(dmem_data_in[7:0]), .data_b(dmem_data_in[7:0]),
						 .wren_a(sw_VGA), .wren_b(1'b0),  .q_a(vga_outputA[7:0]), .q_b(vga_out), .outclock(~clock));
	
	
	output[31:0] memory_out;
	assign memory_out = lw_VGA ? vga_outputA : dmem_out;

	wire[31:0] target_W, data_W, pc_W;
	wire[4:0] rd_addr_W, aluop_W;
	wire overflow_W;
	wire[4:0] opcode_W;
	wire[31:0] aluout_W;
	
	//data, alu, op, rd, tgt, of, clock, reset, data_out, alu_out, opcode, rd_addr, target, overflow
	MW M_W(.data(memory_out), .alu(alu1out_M), .op(opcode_M), .rd(rd_addr_M), .tgt(target_M), .of(overflow_M), .clock(clock), .reset(reset), .aluop(aluop_M), .pc(pc_M),
			 .data_out(data_W), .alu_out(aluout_W), .opcode(opcode_W), .rd_addr(rd_addr_W), .target(target_W), .overflow(overflow_W),
			 .pc_out(pc_W), .alu_opcode(aluop_W));
			 
			 
	//Control signals and data used for MX bypasses
	
	wire rtype_M, addi_M, setx_M, jal_M;
	
	//00000
	assign rtype_M = ~|opcode_M[4:0];
	
	//00101
	assign addi_M = ~|opcode_M[4:3] && opcode_M[2] && ~opcode_M[1] && opcode_M[0];
	
	//00011
	assign jal_M = ~|opcode_M[4:2] && &opcode_M[1:0];
	
	//10101
	assign setx_M = opcode_M[4] && ~opcode_M[3] && opcode_M[2] && ~opcode_M[1] && opcode_M[0];
	
	wire M_writes;
	wire[4:0] M_addr, M_addr_int;
	wire[31:0] M_data;
	wire[31:0] M_data_int;
	
	assign M_writes = rtype_M || addi_M || setx_M || jal_M;
	
	//rd if addi or rtype, otherwise assume it's a setx and use $30...then check if it's a jal
	assign M_addr_int = addi_M || rtype_M ? rd_addr_M : 5'b11110;
	assign M_addr = jal_M ? 5'b11111 : M_addr_int;
	
	assign M_data_int = rtype_M || addi_M ? alu1out_M : target_M;
	assign M_data = jal_M ? pc_M : M_data_int;
	
	//////// W stage: Writing back to regfile ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	//	wire regfile_write_enable, rs_write;
	//rd_writedata, rs_writeData
	//regfile_write_addr
	
	wire rtype_W = ~|opcode_W[4:0];
	
	wire add_W = rtype_W && ~|aluop_W[4:0]; //00000
	wire sub_W = rtype_W && (~|aluop_W[4:1] && aluop_W[0]); //00001
	wire mult_W = rtype_W && (~|aluop_W[4:3] && &aluop_W[2:1] && ~aluop_W[0]); //00110
	wire div_W = rtype_W && (~|aluop_W[4:3] && &aluop_W[2:0]); //00111
	
	wire rtype_regular = rtype_W && ~mult_W && ~div_W; //"regular" rtype = not mult or div
	
	wire addi_W = ~|opcode_W[4:3] && opcode_W[2] && ~opcode_W[1] && opcode_W[0]; //00101
	wire lw_W = ~opcode_W[4] && opcode_W[3] && ~|opcode_W[2:0]; //01000
	wire lw_VGA_W = &opcode_W[4:3] && ~|opcode_W[2:0];
	wire itype_W = addi_W || lw_W || lw_VGA_W;
	
	wire setx_W;
	assign setx_W = opcode_W[4] && ~opcode_W[3] && opcode_W[2] && ~opcode_W[1] && opcode_W[0];//10101
	
	wire jal_W = ~|opcode_W[4:2] && &opcode_W[1:0]; //00011
	
	//Do a register file write for regular rtypes, itypes, jal, and whenever multdiv is ready
	assign regfile_write_enable = rtype_regular || itype_W || jal_W || multdiv_ready; 
	
	//Write to rstatus for: add, subtract, mult, div, addi, setx	
	wire overflow_condition = ((add_W || sub_W || addi_W) && overflow_W) || (multdiv_ready && multdiv_exception);
	assign rs_write = overflow_condition || setx_W;
	
	// rd_addr for r-type, lw, addi; $31 for jal.
	wire[4:0] regfile_write_addr_int = (rtype_W || lw_W || addi_W || lw_VGA_W) ? rd_addr_W : 5'b11111; 	
	assign regfile_write_addr = multdiv_ready ? multdiv_addr_out[4:0] : regfile_write_addr_int;
	
	//Overflow code: 1 for add, 2 for addi, 3 for sub, 4 for mult, 5 for div: WONT WORK FOR MULT DIV 
	wire[31:0] overflow_code;
	assign overflow_code[0] = add_W || sub_W || div_W;
	assign overflow_code[1] = addi_W || sub_W;
	assign overflow_code[2] = mult_W || div_W;
	
	//target for setx, overflow code otherwise
	assign rs_writeData = setx_W ? target_W : overflow_code;
	
	//rd_writeData: aluout for r-type regular, addi. data_out for lw. PC+1 for jal. multdiv out for multdiv. 
	wire[31:0] int_data1, int_data2;
	assign int_data1 = (rtype_W || addi_W) ? aluout_W : data_W;
	assign int_data2 = multdiv_ready ? multdiv_result : int_data1;
	
	assign rd_writedata = jal_W ? pc_W : int_data2;
	
	//TODO: 
	//Fix multdiv overflow codes; Right now, div_W and mult_W get triggered with the m/d instr reaches W stage...not when m/d result is actually ready
	
	
endmodule



module register(clk, data_in, write_enable, data_out, ctrl_reset);

	input clk, write_enable, ctrl_reset;
	input [31:0] data_in;
	output [31:0] data_out;
	
	assign async_ctrl = 1;
	
	genvar i; 
	generate
	for(i = 0; i < 32; i = i+1) begin: loop1
		dffe dffe_temp(.d(data_in[i]), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(write_enable), .q(data_out[i]));
	end
	endgenerate
	
endmodule

module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, 
								 data_result, data_exception, data_resultRDY, reset);

input [31:0] data_operandA, data_operandB;
input ctrl_MULT, ctrl_DIV, clock, reset;

output [31:0] data_result;
output data_exception, data_resultRDY;

wire[31:0] mult_out, div_out;
wire mult_exception, div_exception, mult_ready, div_ready;

div divider(.dividend(data_operandA), .divisor(data_operandB), .div_ctrl(ctrl_DIV), .clock(clock), 
				.data_ready(div_ready), .div_exception(div_exception), .quotient(div_out), .reset(reset));
				
mult multiplier(.data_A(data_operandA), .data_B(data_operandB), .mult_ctrl(ctrl_MULT), .clock(clock), 
					 .data_ready(mult_ready), .overflow(mult_exception), .product(mult_out), .reset(reset));

wire control_asserted, control_select;
or o1(control_asserted, ctrl_MULT, ctrl_DIV);
 
//The output of this signals whether it's a multiplication
dffe op_control(.d(ctrl_MULT), .clk(clock), .clrn(1'b1), .prn(1'b1), .ena(control_asserted), .q(control_select));


genvar i; 
	generate
	for(i = 0; i < 32; i = i+1) begin: loop1
		mux_21 mux_temp(.ctrl(control_select), .b(mult_out[i]), .a(div_out[i]), .out(data_result[i]));
	end
endgenerate
	
mux_21 mux1(.ctrl(control_select), .b(mult_ready), .a(div_ready), .out(data_resultRDY));
mux_21 mux2(.ctrl(control_select), .b(mult_exception), .a(div_exception), .out(data_exception));


endmodule



module counter16 (clock, reset, out);

input clock, reset;
output [4:0] out;
reg [4:0] next;

dff dff0(.d(next[0]), .clk(clock), .q(out[0]), .clrn(1'b1));
dff dff1(.d(next[1]), .clk(clock), .q(out[1]), .clrn(1'b1));
dff dff2(.d(next[2]), .clk(clock), .q(out[2]), .clrn(1'b1));
dff dff3(.d(next[3]), .clk(clock), .q(out[3]), .clrn(1'b1));
dff dff4(.d(next[4]), .clk(clock), .q(out[4]), .clrn(1'b1));


always@(*) begin

casex({reset, out})
6'b1xxxxx: next = 0;
6'd0: next = 1;
6'd1: next = 2;
6'd2: next = 3;
6'd3: next = 4;
6'd4: next = 5;
6'd5: next = 6;
6'd6: next = 7;
6'd7: next = 8;
6'd8: next = 9;
6'd9: next = 10;
6'd10: next = 11;
6'd11: next = 12;
6'd12: next = 13;
6'd13: next = 14;
6'd14: next = 15;
6'd15: next = 16;
6'd16: next = 16;

default: next = 0;

endcase
end
endmodule

module counter32 (clock, reset, out);

input clock, reset;
output [5:0] out;
reg [5:0] next;

dff dff0(.d(next[0]), .clk(clock), .q(out[0]), .clrn(1'b1));
dff dff1(.d(next[1]), .clk(clock), .q(out[1]), .clrn(1'b1));
dff dff2(.d(next[2]), .clk(clock), .q(out[2]), .clrn(1'b1));
dff dff3(.d(next[3]), .clk(clock), .q(out[3]), .clrn(1'b1));
dff dff4(.d(next[4]), .clk(clock), .q(out[4]), .clrn(1'b1));
dff dff5(.d(next[5]), .clk(clock), .q(out[5]), .clrn(1'b1));


always@(*) begin

casex({reset, out})
7'b1xxxxxx: next = 0;
7'd0: next = 1;
7'd1: next = 2;
7'd2: next = 3;
7'd3: next = 4;
7'd4: next = 5;
7'd5: next = 6;
7'd6: next = 7;
7'd7: next = 8;
7'd8: next = 9;
7'd9: next = 10;
7'd10: next = 11;
7'd11: next = 12;
7'd12: next = 13;
7'd13: next = 14;
7'd14: next = 15;
7'd15: next = 16;
7'd16: next = 17;
7'd17: next = 18;
7'd18: next = 19;
7'd19: next = 20;
7'd20: next = 21;
7'd21: next = 22;
7'd22: next = 23;
7'd23: next = 24;
7'd24: next = 25;
7'd25: next = 26;
7'd26: next = 27;
7'd27: next = 28;
7'd28: next = 29;
7'd29: next = 30;
7'd30: next = 31;
7'd31: next = 32;
7'd32: next = 32;

default: next = 0;

endcase
end
endmodule


module div(dividend, divisor, quotient, div_ctrl, div_exception, clock, data_ready, reset);
//A = dividend, B = divisor

input[31:0] dividend, divisor;
input div_ctrl, clock, reset;

output[31:0] quotient;
output div_exception, data_ready;
wire divisor_0;

assign divisor_0 = ~|divisor[31:0];

wire fsm_done;

wire Trigger; //Trigger is the wire that signals that divisor < = remainder, so we do stuff in this cycle

//Counter and shift amount
wire[5:0] counter_state;
counter32 counter(.clock(clock), .reset(div_ctrl || reset), .out(counter_state));

//fsm done: counter = 32
and fsm_and(fsm_done, counter_state[5], ~counter_state[4], ~counter_state[3], ~counter_state[2], ~counter_state[1], ~counter_state[0]);

and exception(div_exception, divisor_0, fsm_done);

wire[4:0] shift_amt;
assign shift_amt = ~counter_state[4:0];

wire done; 
assign done = counter_state[5];

//remainder block
wire[31:0] rem_block_in, rem_block_out;
wire rem_block_enable;
register remainder_reg(.clk(clock), .data_in(rem_block_in), .write_enable(rem_block_enable), .data_out(rem_block_out), .ctrl_reset(1'b0));

or or1(rem_block_enable, Trigger, div_ctrl); //Write to remainder at beginning or when Trigger occurs


//sign resolved divisor
//sign resolved dividend

wire[31:0] resolved_divisor, resolved_dividend;
wire [4:0] divisor_opcode, dividend_opcode;

assign divisor_opcode[4:1] = 4'b0000;
assign dividend_opcode[4:1] = 4'b0000;
assign divisor_opcode[0] = divisor[31];
assign dividend_opcode[0] = dividend[31];
wire[31:0] zeros = 32'h00000000;

ALU divisor_ALU(.data_operandA(zeros), .data_operandB(divisor), .ctrl_ALUopcode(divisor_opcode), .ctrl_shiftamt(5'b00000), 
					 .data_result(resolved_divisor));
					 
ALU dividend_ALU(.data_operandA(zeros), .data_operandB(dividend), .ctrl_ALUopcode(dividend_opcode), .ctrl_shiftamt(5'b00000), 
					 .data_result(resolved_dividend));
					 
//ALU1
wire[31:0] ALU1_remainder, ALU1_output;
wire ALU_LT, ALU_equal, isEqual;

assign isEqual = ~|ALU1_output[31:0];
ALU ALU1(.data_operandA(resolved_divisor), .data_operandB(ALU1_remainder), .ctrl_ALUopcode(5'b00001), .ctrl_shiftamt(5'b00000), 
			 .isNotEqual(ALU_equal), .isLessThan(ALU_LT), .data_result(ALU1_output));

or or2(Trigger, isEqual, ALU_LT); 

//Shifter for remainder
SRA remainder_shifter(.data(rem_block_out), .ctrl(shift_amt), .out(ALU1_remainder));


//ALU2
wire[31:0] shifted_divisor, subtracted_remainder;
ALU ALU2(.data_operandA(rem_block_out), .data_operandB(shifted_divisor), .ctrl_ALUopcode(5'b00001), .ctrl_shiftamt(5'b00000),
			.data_result(subtracted_remainder));
			
//Shifter for divisor
SL divisor_shifter(.data(resolved_divisor), .ctrl(shift_amt), .out(shifted_divisor));

//Inputs to remainder block
genvar i; 
generate
	for(i = 0; i < 32; i = i+1) begin: loop1
		mux_21 mux_temp(.ctrl(div_ctrl), .b(resolved_dividend[i]), .a(subtracted_remainder[i]), .out(rem_block_in[i]));
	end
endgenerate

wire[31:0] intermediate_quotient;

//module reg_32_writable(clk, data_in, write_enable, data_out, ctrl_reset, write_address);
reg_32_writable quotient_block(.clk(clock), .data_in(32'hFFFFFFFF), .write_enable(Trigger),
								 .ctrl_reset(div_ctrl), .write_address(shift_amt), .data_out(intermediate_quotient));

or or3(data_ready, div_exception, done);

//sign resolved quotient		 
wire[4:0] quotient_opcode;
assign quotient_opcode[4:1] = 4'b0000;
xor operand_signs(quotient_opcode[0], dividend[31], divisor[31]);

ALU quotient_ALU(.data_operandA(zeros), .data_operandB(intermediate_quotient), .ctrl_ALUopcode(quotient_opcode), 
					  .ctrl_shiftamt(5'b00000), .data_result(quotient));
								 
endmodule

module mult(data_A, data_B, product, mult_ctrl, clock, data_ready, overflow, sign_overflow, top_product, maxneg_overflow, reset);

input [31:0] data_A, data_B;
input mult_ctrl, clock, reset;

output [31:0] product;
output data_ready, overflow;

//Set up FSM
wire[4:0] FSM_STATE;
counter16 FSM(.clock(clock), .reset(mult_ctrl || reset), .out(FSM_STATE));

//Initialize ALUOPCODE
wire[4:0] ALU_opcode;
assign ALU_opcode[4:1] = 4'b0000;

//Create preslicer with data_B as input
wire[15:0] shifts, adds, subtracts;
preslicer slicer(.shifts(shifts), .adds(adds), .subtracts(subtracts), .data_in(data_B));

//initialize LSB of ALUOPCODE using subtract_bit
//initialize do_nothing signal using add and subtract bits
wire add_bit, subtract_bit, do_nothing;
reg_16 add_ctrl(.clk(clock), .data_in(adds), .write_enable(mult_ctrl), .data_out(add_bit), .ctrl_reset(1'b0), .read_address(FSM_STATE));
reg_16 subtract_ctrl(.clk(clock), .data_in(subtracts), .write_enable(mult_ctrl), .data_out(subtract_bit), .ctrl_reset(1'b0), .read_address(FSM_STATE));
assign ALU_opcode[0] = subtract_bit;
and and1(do_nothing, ~add_bit, ~subtract_bit);

//Setup shift_bit
wire shift_bit;
reg_16 shift_ctrl(.clk(clock), .data_in(shifts), .write_enable(mult_ctrl), .data_out(shift_bit), .ctrl_reset(1'b0), .read_address(FSM_STATE));


//Setup ALU and wires going in/out
wire[31:0] shifted_multiplicand;
wire[63:0] full_ALU_out, full_product, reg_in;

assign product[31:0] = full_product[31:0];
assign full_ALU_out[31:0] = full_product[31:0];

genvar i; 
generate
	for(i = 0; i < 64; i = i+1) begin: loop1
		mux_21 mux_temp(.ctrl(do_nothing), .b(full_product[i]), .a(full_ALU_out[i]), .out(reg_in[i]));
	end
endgenerate

ALU alu(.data_operandA(full_product[63:32]), .data_operandB(shifted_multiplicand), .ctrl_ALUopcode(ALU_opcode), .ctrl_shiftamt(5'b00000), 
							  .data_result(full_ALU_out[63:32]));

//Setup shifters for ALU inputs and outputs
SLL_1_ctrl multiplicand_shifter(.data(data_A), .ctrl(shift_bit), .out(shifted_multiplicand));							  

//initialize DONE wire: done is true when fsmstate = 16 = 10000
wire fsm_done;
and and2(fsm_done, FSM_STATE[4], ~FSM_STATE[3], ~FSM_STATE[3], ~FSM_STATE[1], ~FSM_STATE[0]);

//Setup product register
shiftregister product_register(.clk(clock), .data_in(reg_in), .data_out(full_product), .ctrl_reset(mult_ctrl), .write_enable(~fsm_done));

//Setup check to see if we have overflow by checking upper 32 bits of product register
wire product_upper_OR;
or p_or(product_upper_OR, full_product[63:32]);

or ready_or(data_ready, overflow, fsm_done);

output[31:0] top_product;
assign top_product = full_product[63:32];

wire A0, B0, either_op_0;
assign A0 = ~|data_A[31:0];
assign B0 = ~|data_B[31:0];
or op0(either_op_0, A0, B0);


//Case 1: top product is not all the same, or it's different from sign of actual product
wire top_prod_all_zeros = ~|top_product[31:0];
wire top_prod_all_ones = &top_product[31:0];

wire all_ones, all_zeros;
and andones(all_ones, top_prod_all_ones, product[31]);
and andzeros(all_zeros, top_prod_all_zeros, ~product[31]);
 
output sign_overflow;
nor s_o_nor(sign_overflow, all_ones, all_zeros);


//Case 2: multiplying maxneg by maxneg

wire amaxneg, bmaxneg;
assign amaxneg = data_A[31] & (~|data_A[30:0]);
assign bmaxneg = data_B[31] & (~|data_B[30:0]);

output maxneg_overflow;
and maxneg(maxneg_overflow, amaxneg, bmaxneg);

wire both_cases;
or both(both_cases, sign_overflow, maxneg_overflow);

and final(overflow, both_cases, ~either_op_0, fsm_done);


endmodule

module preslicer(data_in, shifts, adds, subtracts);

input [31:0] data_in;
output [15:0] shifts, adds, subtracts;

wire [32:0] all_inputs;
assign all_inputs[0] = 1'b0; //Adding implicit 0
assign all_inputs[32:1] = data_in[31:0];

genvar i;
generate

for (i = 0; i < 16; i = i+1) begin: loop1
	
	//SHIFTS
	wire w1, w2;
	and and1(w1, all_inputs[i*2+2], ~all_inputs[i*2+1], ~all_inputs[i*2]);
	and and2(w2, ~all_inputs[i*2+2], all_inputs[i*2+1], all_inputs[i*2]);
	or or1(shifts[i], w1, w2);
	
	//ADDS
	wire w3, w4, w5;
	and and3(w3, ~all_inputs[i*2+2], all_inputs[i*2+1], ~all_inputs[i*2]);
	and and4(w4, ~all_inputs[i*2+2], ~all_inputs[i*2+1], all_inputs[i*2]);
	and and5(w5, ~all_inputs[i*2+2], all_inputs[i*2+1], all_inputs[i*2]);
	or or2(adds[i], w3, w4, w5);
	
	//SUBTRACTS
	wire w6, w7, w8;
	and and6(w6, all_inputs[i*2+2], ~all_inputs[i*2+1], ~all_inputs[i*2]);
	and and7(w7, all_inputs[i*2+2], all_inputs[i*2+1], ~all_inputs[i*2]);
	and and8(w8, all_inputs[i*2+2], ~all_inputs[i*2+1], all_inputs[i*2]);
	or or3(subtracts[i], w6, w7, w8);

end
endgenerate



endmodule

module reg_16(clk, data_in, write_enable, data_out, ctrl_reset, read_address);
//This is a register where we can specify the address of the DFF being read

	input clk, write_enable, ctrl_reset;
	input [15:0] data_in;
	input [3:0] read_address;
	
	output data_out;
	
	wire [15:0] stored_values;
	wire [4:0] decoder_input;
	
	//Using a 5:32 decoder, we give it a 0 in the MSB
	assign decoder_input[4] = 1'b0;
	assign decoder_input[3:0] = read_address[3:0];
	
	assign async_ctrl = 1;
	
	genvar i; 
	generate
	for(i = 0; i < 16; i = i+1) begin: loop1
		dffe dffe_temp(.d(data_in[i]), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(write_enable), .q(stored_values[i]));
	end
	endgenerate
	
	wire[31:0] decoder_out;
	decoder decode(.in(decoder_input), .out(decoder_out));
	
	generate
	for(i = 0; i < 16; i = i + 1) begin: loop2
		tristate temp(.in(stored_values[i]), .oe(decoder_out[i]), .out(data_out));
	end
	endgenerate
	
	
endmodule



module reg_32_writable(clk, data_in, write_enable, data_out, ctrl_reset, write_address);
//This is a register where we can specify the address of the DFF being written

	input clk, write_enable, ctrl_reset;
	input [31:0] data_in;
	input [4:0] write_address;
	
	output[31:0] data_out;
	
	assign async_ctrl = 1;
	
	wire[31:0] decoder_out, enables;
	decoder decode(.in(write_address), .out(decoder_out));

	
	
	genvar i; 
	generate
	for(i = 0; i < 32; i = i+1) begin: loop1
	
		and and1(enables[i], write_enable, decoder_out[i]);
		
		dffe dffe_temp(.d(data_in[i]), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(enables[i]), .q(data_out[i]));
	end
	endgenerate
	
	
endmodule


module shiftregister(clk, data_in, write_enable, data_out, ctrl_reset);

	input clk, write_enable, ctrl_reset;
	input [63:0] data_in;
	output [63:0] data_out;
	
	assign async_ctrl = 1;
	
	genvar i; 
	generate
	for(i = 0; i < 62; i = i+1) begin: loop1
		dffe dffe_temp(.d(data_in[i+2]), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(write_enable), .q(data_out[i]));
	end
	endgenerate
	
	
	//2 bits of sign extension
	
	wire bit_62;
	wire bit_63;
	
	assign bit_62 = data_in[63] ? 1'b1 : 1'b0;
	assign bit_63 = data_in[63] ? 1'b1 : 1'b0;

	dffe dffe_1(.d(bit_62), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(write_enable), .q(data_out[62]));
		
	dffe dffe_2(.d(bit_63), .clk(clk), .clrn(~ctrl_reset), .prn(async_ctrl),
		.ena(write_enable), .q(data_out[63]));
	
endmodule



//This module: 
//Is like a register that holds 64 bits, except: 
//It'll right-shift any input by 2


module SLL_1_ctrl(data, out, ctrl, overflow);

input [31:0] data;
input ctrl;
output [31:0] out;
output overflow;

and and1(overflow, ctrl, data[31]);

assign out[0] = ctrl ? 1'b0 : data[0];
assign out[31:1] = ctrl? data[30:0] : data[31:1];

endmodule

module tristate(in, oe, out);
	input in, oe;
	output out;
	
	assign out = oe? in : 1'bz;
	
endmodule


module XM(op, rd, regb, alu, aluop, pc, tgt, of, clock, reset, opcode, rd_addr, regB_data, aluout, target, overflow, alu_opcode, pc_out);

input[4:0] op, rd, aluop;
input[31:0] regb, alu, tgt, pc;
input clock, reset, of;

output[4:0] opcode, rd_addr, alu_opcode;
output[31:0] regB_data, aluout, target, pc_out;
output overflow;

register regB(.clk(clock), .data_in(regb), .write_enable(1'b1), .data_out(regB_data), .ctrl_reset(reset));
register alureg(.clk(clock), .data_in(alu), .write_enable(1'b1), .data_out(aluout), .ctrl_reset(reset));
register tgtreg(.clk(clock), .data_in(tgt), .write_enable(1'b1), .data_out(target), .ctrl_reset(reset));

wire[31:0] misc_in, misc_out;
assign misc_in[4:0] = op;
assign misc_in[9:5] = rd;
assign misc_in[10] = of;
assign misc_in[15:11] = aluop;

register misc(.clk(clock), .data_in(misc_in), .write_enable(1'b1), .data_out(misc_out), .ctrl_reset(reset));
register PC(.clk(clock), .data_in(pc), .write_enable(1'b1), .data_out(pc_out), .ctrl_reset(reset));

assign opcode = misc_out[4:0];
assign rd_addr = misc_out[9:5];
assign overflow = misc_out[10];
assign alu_opcode = misc_out[15:11];

endmodule

//Modified version of regfile: Has an extra write port for $rstatus (30) and keeps $r0 fixed at 0

module regfile_mod(
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, 
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA,
	data_readRegB, rs_write, rs_writeData, timer_state,
	key_pressed_indicator, key_pressed_data, reg28_data, reg29_data);
	
	input clock, ctrl_writeEnable, ctrl_reset, timer_state, key_pressed_indicator, rs_write;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input[31:0] data_writeReg, rs_writeData;
	input[31:0] key_pressed_data;	
		
	output[31:0] data_readRegA, data_readRegB, reg28_data, reg29_data;
	
	wire [31:0] write_select_bits; //Input to the AND gates for write enable
	decoder write_decoder(ctrl_writeReg, write_select_bits);
	
	wire[31:0] read_select_bitsA; //RS1 address
	decoder read_decoderA(ctrl_readRegA, read_select_bitsA);
	
	wire[31:0] read_select_bitsB; //RS2 address
	decoder read_decoderB(ctrl_readRegB, read_select_bitsB);
	
	wire[31:0] register_write_enable_bits; //The actual bit that gets sent to the register
	
	wire[1023:0] Reg_data; //Output from the registers
	
	
	//Create write enables for registers 0 - 29
	genvar i; 
	generate
	for(i = 1; i < 28; i = i+1) begin: loop1
		and and_temp(register_write_enable_bits[i], ctrl_writeEnable, write_select_bits[i]);
	end
	endgenerate
	
	//Starts at 1 because register 0 is fixed to 0; ends at 28 because register 29 is reserved for a timer output
	generate
	for(i = 1; i < 28; i = i+1) begin: loop2
		register reg_temp(clock, data_writeReg, register_write_enable_bits[i], Reg_data[32*i+31:32*i], ctrl_reset);
		end
	endgenerate
	
	//Register 0 is fixed at 0!
	assign Reg_data[31:0] = 32'h00000000;
	
	
	//Register 28 has 2 sets of write data: keyboard stuff and regular stuff - prioritizing keyboard input
	assign register_write_enable_bits[28] = key_pressed_indicator || (write_select_bits[28] && ctrl_writeEnable);
	wire[31:0] reg28_writeData;
	assign reg28_writeData = key_pressed_indicator ? key_pressed_data : data_writeReg;
	register reg_28(clock, reg28_writeData, register_write_enable_bits[28], Reg_data[927:896], ctrl_reset);
	assign reg28_data = Reg_data[927:896];

	//Register 29
	assign register_write_enable_bits[29] = (write_select_bits[29] && ctrl_writeEnable);
	register reg_29(clock, data_writeReg, register_write_enable_bits[29], Reg_data[959:928], ctrl_reset);
	assign reg29_data = Reg_data[959:928];
	
	//Register 30: Can write to $rstatus using regular write address or using rs_write (don't need writeenable for the latter); 
	assign register_write_enable_bits[30] = rs_write || (write_select_bits[30] && ctrl_writeEnable);
	
	//Write data to $rstatus: If rs_write is enabled, we select rs_writeData; otherwise, we select the regular write data
	wire[31:0] rstatus_dataIn;
	assign rstatus_dataIn = rs_write ? rs_writeData[31:0] : data_writeReg[31:0];
	
	register reg_status(clock, rstatus_dataIn, register_write_enable_bits[30], Reg_data[991:960], ctrl_reset);
	
	
	//Register 31: just like 0-29
	assign register_write_enable_bits[31] = ctrl_writeEnable && write_select_bits[31];
	register reg_31(clock, data_writeReg, register_write_enable_bits[31], Reg_data[1023:992], ctrl_reset);
	
	
	generate
	for(i = 0; i < 1024; i = i+1) begin: loop3
		tristate tri_temp(Reg_data[i], read_select_bitsA[i/32], data_readRegA[i%32]);
		end
	endgenerate
	
	generate
	for(i = 0; i < 1024; i = i+1) begin: loop4
		tristate tri_temp(Reg_data[i], read_select_bitsB[i/32], data_readRegB[i%32]);
		end
	endgenerate
	
endmodule



module MW(data, alu, aluop, op, rd, pc, tgt, of, clock, reset, data_out, alu_out, opcode, rd_addr, target, overflow, alu_opcode, pc_out);

input[31:0] data, alu, tgt, pc;
input[4:0] op, rd, aluop;
input of, clock, reset;

output[4:0] opcode, rd_addr, alu_opcode;
output[31:0] data_out, alu_out, target, pc_out;
output overflow;

register regData(.clk(clock), .data_in(data), .write_enable(1'b1), .data_out(data_out), .ctrl_reset(reset));
register alureg(.clk(clock), .data_in(alu), .write_enable(1'b1), .data_out(alu_out), .ctrl_reset(reset));
register tgtreg(.clk(clock), .data_in(tgt), .write_enable(1'b1), .data_out(target), .ctrl_reset(reset));

wire[31:0] misc_in, misc_out;
assign misc_in[4:0] = op;
assign misc_in[9:5] = rd;
assign misc_in[10] = of;
assign misc_in[15:11] = aluop;

register misc(.clk(clock), .data_in(misc_in), .write_enable(1'b1), .data_out(misc_out), .ctrl_reset(reset));
register PC(.clk(clock), .data_in(pc), .write_enable(1'b1), .data_out(pc_out), .ctrl_reset(reset));

assign opcode = misc_out[4:0];
assign rd_addr = misc_out[9:5];
assign overflow = misc_out[10];
assign alu_opcode = misc_out[15:11];

endmodule


module mux_21(a, b, ctrl, out);
input a, b, ctrl;
output out;

assign out = ctrl ? b : a;

endmodule


module DX(op, pc, alu, sh, a, b, imdt, t, rd_addr, clock, DX_reset, addrA, addrB,
			 opcode, PCplusone, ALUopcode, shamt, regA, regB, immediate, target, rd_address, flush, addressA, addressB);

input [4:0] op, alu, sh, rd_addr, addrA, addrB; //op = opcode, alu = aluopcode, sh = shamt, rd_addr = rd address
input [31:0] a, b, pc; //a = reg a contents, b = reg b contents, pc = PC+1 for the instruction being stored in DX
input [16:0] imdt;
input[26:0] t;
input clock, DX_reset, flush; //j = jr indicator, bex = bex indicator

output [4:0] opcode, ALUopcode, shamt, rd_address, addressA, addressB;
output [31:0] regA, regB, PCplusone;
output [31:0] immediate;
output [31:0] target;

wire[31:0] A_in, B_in, I_in, T_in, misc_in;
wire[31:0] zeros = 32'h00000000;

register A(.clk(clock), .data_in(A_in), .write_enable(1'b1), .data_out(regA), .ctrl_reset(DX_reset));
register B(.clk(clock), .data_in(B_in), .write_enable(1'b1), .data_out(regB), .ctrl_reset(DX_reset));

//Sign extending the immediate
wire[31:0] sx_imdt;
assign sx_imdt[16:0] = imdt[16:0];
assign sx_imdt[31:17] = imdt[16] ? 15'b111111111111111 : 15'b00000000000000000;
register I(.clk(clock), .data_in(I_in), .write_enable(1'b1), .data_out(immediate), .ctrl_reset(DX_reset));

//Target is always positive; we sign extend target with 0's
wire [31:0] sx_tgt;
assign sx_tgt[26:0] = t[26:0];
assign sx_tgt[31:27] = 5'b00000;
register T(.clk(clock), .data_in(T_in), .write_enable(1'b1), .data_out(target), .ctrl_reset(DX_reset));

register P(.clk(clock), .data_in(pc), .write_enable(1'b1), .data_out(PCplusone), .ctrl_reset(DX_reset));

wire[31:0] misc_wires;
wire[31:0] misc_outputs;

assign misc_wires[4:0] = op;
assign misc_wires[9:5] = alu;
assign misc_wires[14:10] = sh;
assign misc_wires[19:15] = rd_addr;
assign misc_wires[24:20] = addrA;
assign misc_wires[29:25] = addrB;

register misc(.clk(clock), .data_in(misc_in), .write_enable(1'b1), .data_out(misc_outputs), .ctrl_reset(DX_reset));

assign opcode = misc_outputs[4:0];
assign ALUopcode = misc_outputs[9:5];
assign shamt = misc_outputs[14:10];
assign rd_address = misc_outputs[19:15];
assign addressA = misc_outputs[24:20];
assign addressB = misc_outputs[29:25];


assign A_in = flush ? zeros : a;
assign B_in = flush ? zeros: b;
assign I_in = flush ? zeros: sx_imdt;
assign T_in = flush ? zeros : sx_tgt;
assign misc_in = flush ? zeros : misc_wires;

endmodule


module decoder(in, out);

	input [4:0] in;
	output [31:0] out; 

//32 and gates
//Complemented first
//input 0 alternates
//input 1 in groups of 2
//input 2 in groups of 4
//input 3 in groups of 8
//input 4 in groups of 16

	and and1(out[0], ~in[0], ~in[1], ~in[2], ~in[3], ~in[4]);
	and and2(out[1], in[0], ~in[1], ~in[2], ~in[3], ~in[4]);
	and and3(out[2], ~in[0], in[1], ~in[2], ~in[3], ~in[4]);
	and and4(out[3], in[0], in[1], ~in[2], ~in[3], ~in[4]);
	
	and and5(out[4], ~in[0], ~in[1], in[2], ~in[3], ~in[4]);
	and and6(out[5], in[0], ~in[1], in[2], ~in[3], ~in[4]);
	and and7(out[6], ~in[0], in[1], in[2], ~in[3], ~in[4]);
	and and8(out[7], in[0], in[1], in[2], ~in[3], ~in[4]);
	
	and and9(out[8], ~in[0], ~in[1], ~in[2], in[3], ~in[4]);
	and and10(out[9], in[0], ~in[1], ~in[2], in[3], ~in[4]);
	and and11(out[10], ~in[0], in[1], ~in[2], in[3], ~in[4]);
	and and12(out[11], in[0], in[1], ~in[2], in[3], ~in[4]);
	
	and and13(out[12], ~in[0], ~in[1], in[2], in[3], ~in[4]);
	and and14(out[13], in[0], ~in[1], in[2], in[3], ~in[4]);
	and and15(out[14], ~in[0], in[1], in[2], in[3], ~in[4]);
	and and16(out[15], in[0], in[1], in[2], in[3], ~in[4]);
	
	and and17(out[16], ~in[0], ~in[1], ~in[2], ~in[3], in[4]);
	and and18(out[17], in[0], ~in[1], ~in[2], ~in[3], in[4]);
	and and19(out[18], ~in[0], in[1], ~in[2], ~in[3], in[4]);
	and and20(out[19], in[0], in[1], ~in[2], ~in[3], in[4]);
	
	and and21(out[20], ~in[0], ~in[1], in[2], ~in[3], in[4]);
	and and22(out[21], in[0], ~in[1], in[2], ~in[3], in[4]);
	and and23(out[22], ~in[0], in[1], in[2], ~in[3], in[4]);
	and and24(out[23], in[0], in[1], in[2], ~in[3], in[4]);
	
	and and25(out[24], ~in[0], ~in[1], ~in[2], in[3], in[4]);
	and and26(out[25], in[0], ~in[1], ~in[2], in[3], in[4]);
	and and27(out[26], ~in[0], in[1], ~in[2], in[3], in[4]);
	and and28(out[27], in[0], in[1], ~in[2], in[3], in[4]);
	
	and and29(out[28], ~in[0], ~in[1], in[2], in[3], in[4]);
	and and30(out[29], in[0], ~in[1], in[2], in[3], in[4]);
	and and31(out[30], ~in[0], in[1], in[2], in[3], in[4]);
	and and32(out[31], in[0], in[1], in[2], in[3], in[4]);

endmodule


module ALU(data_operandA, data_operandB, ctrl_ALUopcode,
							ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
							
		input [31:0] data_operandA, data_operandB;
		input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
		
		output [31:0] data_result;
		output isNotEqual, isLessThan, overflow;
		
		//Intermediate wires; B_Out = output of MUX for input B, shift_out = output of MUX for LS and RS outputs
		//and_or_out = output of MUX for and and or outputs, adder_final_out = and_or_out MUXed with adder sum
		wire[31:0] SLOut, SROut, Sum, OR, AND, B_Out, shift_out, and_or_out, everything_but_sum;
		wire subtract_ctrl;
		
		SL left_shifter(.data(data_operandA), .ctrl(ctrl_shiftamt), .out(SLOut)); 
		SRA right_shifter(.data(data_operandA), .ctrl(ctrl_shiftamt), .out(SROut));
	
		//subtract_ctrl is 1 iff the lower 2 bits of ctrl_ALUopcode are 01
		and and1(subtract_ctrl, ~ctrl_ALUopcode[1], ctrl_ALUopcode[0]);
		
		genvar i;
		generate
		//MUX will output ~B is ctrl bit is high
		for(i = 0; i < 32; i=i+1) begin: loop1
			mux_21 temp(.a(data_operandB[i]), .b(~data_operandB[i]), .ctrl(subtract_ctrl), .out(B_Out[i]));
		end
		
		endgenerate
		
		adder_32 adder(.A(data_operandA), .B(B_Out), .Cin(subtract_ctrl), .Props(OR), .Gens(AND), .Sums(Sum));
		
		//s is true if we're going to output sum as our final result
		wire sum_ctrl;
		and sum_ctrl_and(sum_ctrl, ~ctrl_ALUopcode[2], ~ctrl_ALUopcode[1]);
		
		generate
		for(i = 0; i < 32; i=i+1) begin: loop2
			mux_21 temp(.a(SLOut[i]), .b(SROut[i]), .ctrl(ctrl_ALUopcode[0]), .out(shift_out[i]));
			mux_21 temp2(.a(AND[i]), .b(OR[i]), .ctrl(ctrl_ALUopcode[0]), .out(and_or_out[i]));
			mux_21 temp3(.a(and_or_out[i]), .b(shift_out[i]), .ctrl(ctrl_ALUopcode[2]), .out(everything_but_sum[i]));
			mux_21 temp4(.a(everything_but_sum[i]), .b(Sum[i]), .ctrl(sum_ctrl), .out(data_result[i]));
			
			//mux_21 temp3(.a(Sum[i]), .b(and_or_out[i]), .ctrl(ctrl_ALUopcode[1]), .out(adder_final_out[i]));
			//mux_21 temp4(.a(adder_final_out[i]), .b(shift_out[i]), .ctrl(ctrl_ALUopcode[2]), .out(data_result[i]));
		end
		
		endgenerate
		
		//ISNOTEQUAL: true if ANY bit of Sum is 1
		wire w1, w2, w3, w4;
		or or1(w1, Sum[7:0]);
		or or2(w2, Sum[15:8]);
		or or3(w3, Sum[23:16]);
		or or4(w4, Sum[31:24]);
		or or5(isNotEqual, w1, w2, w4, w4);
		
		//isLessThan: True if adder result is negative (for subtraction)
		//If you have overflow, we negate the adder result
		mux_21 ltmux(.a(Sum[31]), .b(~Sum[31]), .ctrl(overflow), .out(isLessThan));
		
		//Overflow
		wire w5, w6, w7, w8, w9, w10;
		and and2(w5, ~data_operandA[31], ~data_operandB[31], Sum[31]);
		and and3(w6, data_operandA[31], data_operandB[31], ~Sum[31]);
		or or6(w7, w5, w6);
		
		and and4(w8, data_operandA[31], ~data_operandB[31], ~Sum[31]);
		and and5(w9, ~data_operandA[31], data_operandB[31], Sum[31]);
		or or7(w10, w8, w9);
		
		mux_21 overflowmux(.a(w7), .b(w10), .ctrl(subtract_ctrl), .out(overflow));
		
							
endmodule

module adder_32(A, B, Cin, Props, Gens, Sums);

	input [31:0] A, B;
	input Cin;
	output [31:0] Props, Gens, Sums;
	
	//block_carries[i] = carry IN to the ith 8-bit adder block
	//block_gens[i] = gen function for the ith block, same idea for block_props
	wire[3:0] block_carries, block_gens, block_props;
	
	assign block_carries[0] = Cin;
	
	genvar i;
	generate
	
	for(i = 0; i < 4; i=i+1) begin: loop1
		adder_block_8bit add_temp(.A(A[i*8+7:i*8]), .B(B[i*8+7:i*8]), .Cin(block_carries[i]), 
										.sums(Sums[i*8+7:i*8]), .PROP(block_props[i]), .GEN(block_gens[i]), 
										.prop(Props[i*8+7:i*8]), .gen(Gens[i*8+7:i*8]));
	end
	
	endgenerate
	
	//BLOCK CARRY 1
	wire w1;
	and and1(w1, block_props[0], block_carries[0]);
	or or1(block_carries[1], w1, block_gens[0]);
	
	//BLOCK CARRY 2
	wire w2, w3;
	and and2(w2, block_props[1], block_props[0], block_carries[0]);
	and and3(w3, block_props[1], block_gens[0]);
	or or2(block_carries[2], block_gens[1], w2, w3);
	
	//BLOCK CARRY 3
	wire w4, w5, w6;
	and and4(w4, block_props[2], block_props[1], block_props[0], block_carries[0]);
	and and5(w5, block_props[2], block_props[1], block_gens[0]);
	and and6(w6, block_props[2], block_gens[1]);
	or or3(block_carries[3], block_gens[2], w4, w5, w6); 

endmodule

module adder_block_8bit(A,B,Cin,sums, PROP, GEN, prop, gen);

	input [7:0] A, B;
	input Cin;
	output [7:0] sums, prop, gen;
	output PROP, GEN;
	
	//carries[i] = carry IN to ith block
	wire[7:0] carries;
	
	//Initialize C0 
	assign carries[0] = Cin;
	
	genvar i;
	generate
	
	for(i = 0; i < 8; i=i+1) begin: loop1
		full_adder add_temp(.a(A[i]), .b(B[i]), .cin(carries[i]), .p(prop[i]), .g(gen[i]), .sum(sums[i]));
	end
	
	endgenerate
	
	
	//CARRY 1
	wire w1;
	and and1(w1, prop[0], carries[0]);
	or or1(carries[1], w1, gen[0]);
	
	
	//CARRY 2
	wire w2, w3;
	and and2(w2, carries[0], prop[0], prop[1]);
	and and3(w3, prop[1], gen[0]);
	or or2(carries[2], gen[1], w2, w3); 
	
	//CARRY 3
	wire w4, w5, w6;
	and and4(w4, carries[0], prop[0], prop[1], prop[2]);
	and and5(w5, prop[2], prop[1], gen[0]);
	and and6(w6, prop[2], gen[1]);
	or or3(carries[3], w4, w5, w6, gen[2]);
	
	//CARRY 4
	wire w7, w8, w9, w10;
	and and7(w7, prop[3], prop[2], prop[1], prop[0], carries[0]);
	and and8(w8, prop[3], prop[2], prop[1], gen[0]);
	and and9(w9, prop[3], prop[2], gen[1]);
	and and10(w10, prop[3], gen[2]);
	or or4(carries[4], gen[3], w7, w8, w9, w10);
	
	//CARRY 5
	wire w11, w12, w13, w14, w15;
	and and11(w11, prop[4], prop[3], prop[2], prop[1], prop[0], carries[0]);
	and and12(w12, prop[4], prop[3], prop[2], prop[1], gen[0]);
	and and13(w13, prop[4], prop[3], prop[2], gen[1]);
	and and14(w14, prop[4], prop[3], gen[2]);
	and and15(w15, prop[4], gen[3]);
	or or5(carries[5], w11, w12, w13, w14, w15, gen[4]);
	
	//CARRY 6
	wire w16, w17, w18, w19, w20, w21;
	and and16(w16, prop[5], prop[4], prop[3], prop[2], prop[1], prop[0], carries[0]);
	and and17(w17, prop[5], prop[4], prop[3], prop[2], prop[1], gen[0]);
	and and18(w18, prop[5], prop[4], prop[3], prop[2], gen[1]);
	and and19(w19, prop[5], prop[4], prop[3], gen[2]);
	and and20(w20, prop[5], prop[4], gen[3]);
	and and21(w21, prop[5], gen[4]);
	or or6(carries[6], gen[5], w16, w17, w18, w19, w20, w21);
	
	//CARRY 7
	wire w22, w23, w24, w25, w26, w27, w28;
	and and22(w22, prop[6], prop[5], prop[4], prop[3], prop[2], prop[1], prop[0], carries[0]);
	and and23(w23, prop[6], prop[5], prop[4], prop[3], prop[2], prop[1], gen[0]);
	and and24(w24, prop[6], prop[5], prop[4], prop[3], prop[2], gen[1]);
	and and25(w25, prop[6], prop[5], prop[4], prop[3], gen[2]);
	and and26(w26, prop[6], prop[5], prop[4], gen[3]);
	and and27(w27, prop[6], prop[5], gen[4]);
	and and28(w28, prop[6], gen[5]);
	or or7(carries[7], w22, w23, w24, w25, w26, w27, w28, gen[6]);
	
	
	//BLOCK LEVEL PROP FUNCTION
	and and29(PROP, prop[0], prop[1], prop[2], prop[3], prop[4], prop[5], prop[6], prop[7]);
	
	//BLOCK LEVEL GEN FUNCTION
	wire w29, w30, w31, w32, w33, w34, w35;
	and and30(w29, prop[1], prop[2], prop[3], prop[4], prop[5], prop[6], prop[7], gen[0]);
	and and31(w30, prop[2], prop[3], prop[4], prop[5], prop[6], prop[7], gen[1]);
	and and32(w31, prop[3], prop[4], prop[5], prop[6], prop[7], gen[2]);
	and and33(w32, prop[4], prop[5], prop[6], prop[7], gen[3]);
	and and34(w33, prop[5], prop[6], prop[7], gen[4]);
	and and35(w34, prop[6], prop[7], gen[5]);
	and and36(w35, prop[7], gen[6]);
	or or8(GEN, gen[7], w29, w30, w31, w32, w33, w34, w35);
	

	
endmodule
	
	
module full_adder(a,b,cin,sum,p,g);

	input a, b, cin;
	output sum, p, g;
	
	//SUM
	xor sumgate(sum, a, b, cin);
	
	//G,P
	and and3(g, a, b);
	or or2(p, a, b);
	
endmodule


module SL(data, ctrl, out);

	input [31:0] data;
	input[4:0] ctrl;
	output [31:0] out;

	wire[31:0] SL16_out, SL8_out, SL4_out, SL2_out, SL1_out;
	wire[31:0] SL8_in, SL4_in, SL2_in, SL1_in;

	SLL_16 sl16(.data(data), .out(SL16_out));

	genvar i;
	generate
	for(i = 0; i < 32; i=i+1) begin: loop1
		mux_21 temp(.a(data[i]), .b(SL16_out[i]), .ctrl(ctrl[4]), .out(SL8_in[i]));
	end
	endgenerate
	
	SLL_8 sl8(.data(SL8_in), .out(SL8_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop2
		mux_21 temp(.a(SL8_in[i]), .b(SL8_out[i]), .ctrl(ctrl[3]), .out(SL4_in[i]));
	end
	endgenerate
	
	SLL_4 sl4(.data(SL4_in), .out(SL4_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop3
		mux_21 temp(.a(SL4_in[i]), .b(SL4_out[i]), .ctrl(ctrl[2]), .out(SL2_in[i]));
	end
	endgenerate
	
	SLL_2 sl2(.data(SL2_in), .out(SL2_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop4
		mux_21 temp(.a(SL2_in[i]), .b(SL2_out[i]), .ctrl(ctrl[1]), .out(SL1_in[i]));
	end
	endgenerate
	
	SLL_1 sl1(.data(SL1_in), .out(SL1_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop5
		mux_21 temp(.a(SL1_in[i]), .b(SL1_out[i]), .ctrl(ctrl[0]), .out(out[i]));
	end
	endgenerate
	

endmodule
















////////////////////////////
module SLL_16(data, out);

input [31:0] data;
output [31:0] out;

assign out[15:0] = 16'b0000000000000000;
assign out[31:16] = data[15:0];

endmodule

/////////////////////////
module SLL_8(data, out);

input [31:0] data;
output [31:0] out;

assign out[7:0] = 8'b00000000;
assign out[31:8] = data[23:0];

endmodule

///////////////////////////
module SLL_4(data, out);

input [31:0] data;
output [31:0] out;

assign out[3:0] = 4'b0000;
assign out[31:4] = data[27:0];

endmodule

/////////////////////////////
module SLL_2(data, out);

input [31:0] data;
output [31:0] out;

assign out[1:0] = 2'b00;
assign out[31:2] = data[29:0];

endmodule

///////////////////////////////
module SLL_1(data, out);

input [31:0] data;
output [31:0] out;

assign out[0] = 1'b0;
assign out[31:1] = data[30:0];

endmodule


module SRA(data, ctrl, out);

	input [31:0] data;
	input [4:0] ctrl;
	output [31:0] out;

	wire[31:0] SR16_out, SR8_out, SR4_out, SR2_out, SR1_out;
	wire[31:0] SR8_in, SR4_in, SR2_in, SR1_in;

	SRA_16 SR16(.data(data), .out(SR16_out));

	genvar i;
	generate
	for(i = 0; i < 32; i=i+1) begin: loop1
		mux_21 temp(.a(data[i]), .b(SR16_out[i]), .ctrl(ctrl[4]), .out(SR8_in[i]));
	end
	endgenerate
	
	SRA_8 SR8(.data(SR8_in), .out(SR8_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop2
		mux_21 temp(.a(SR8_in[i]), .b(SR8_out[i]), .ctrl(ctrl[3]), .out(SR4_in[i]));
	end
	endgenerate
	
	SRA_4 SR4(.data(SR4_in), .out(SR4_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop3
		mux_21 temp(.a(SR4_in[i]), .b(SR4_out[i]), .ctrl(ctrl[2]), .out(SR2_in[i]));
	end
	endgenerate
	
	SRA_2 SR2(.data(SR2_in), .out(SR2_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop4
		mux_21 temp(.a(SR2_in[i]), .b(SR2_out[i]), .ctrl(ctrl[1]), .out(SR1_in[i]));
	end
	endgenerate
	
	SRA_1 SR1(.data(SR1_in), .out(SR1_out));

	generate
	for(i = 0; i < 32; i=i+1) begin: loop5
		mux_21 temp(.a(SR1_in[i]), .b(SR1_out[i]), .ctrl(ctrl[0]), .out(out[i]));
	end
	endgenerate

endmodule










//////////////////////////////


module SRA_16(data, out);
	input [31:0] data;
	output [31:0] out;

	assign out[15:0] = data[31:16];

	genvar i;
	generate
	for(i=16; i<32; i=i+1) begin:loop1
		or or_temp(out[i], data[31], 1'b0);
	end
	endgenerate

endmodule


//////////////////////////////


module SRA_8(data, out);
	input [31:0] data;
	output [31:0] out;

	assign out[23:0] = data[31:8];

	genvar i;
	generate
	for(i=24; i<32; i=i+1) begin:loop1
		or or_temp(out[i], data[31], 1'b0);
	end
	endgenerate

endmodule

//////////////////////////////////

module SRA_4(data, out);
	input [31:0] data;
	output [31:0] out;

	assign out[27:0] = data[31:4];

	genvar i;
	generate
	for(i=28; i<32; i=i+1) begin:loop1
		or or_temp(out[i], data[31], 1'b0);
	end
	endgenerate

endmodule

//////////////////////////////////

module SRA_2(data, out);
	input [31:0] data;
	output [31:0] out;

	assign out[29:0] = data[31:2];

	genvar i;
	generate
	for(i=30; i<32; i=i+1) begin:loop1
		or or_temp(out[i], data[31], 1'b0);
	end
	endgenerate

endmodule

///////////////////////////////////

module SRA_1(data, out);
	input [31:0] data;
	output [31:0] out;

	assign out[30:0] = data[31:1];

	or or_temp(out[31], data[31], 1'b0);


endmodule

module counter33 (clock, reset, out);

input clock, reset;
output [5:0] out;
reg [5:0] next;

dff dff0(.d(next[0]), .clk(clock), .q(out[0]), .clrn(1'b1));
dff dff1(.d(next[1]), .clk(clock), .q(out[1]), .clrn(1'b1));
dff dff2(.d(next[2]), .clk(clock), .q(out[2]), .clrn(1'b1));
dff dff3(.d(next[3]), .clk(clock), .q(out[3]), .clrn(1'b1));
dff dff4(.d(next[4]), .clk(clock), .q(out[4]), .clrn(1'b1));
dff dff5(.d(next[5]), .clk(clock), .q(out[5]), .clrn(1'b1));


always@(*) begin

casex({reset, out})
7'b1xxxxxx: next = 1;
7'd0: next = 0;
7'd1: next = 2;
7'd2: next = 3;
7'd3: next = 4;
7'd4: next = 5;
7'd5: next = 6;
7'd6: next = 7;
7'd7: next = 8;
7'd8: next = 9;
7'd9: next = 10;
7'd10: next = 11;
7'd11: next = 12;
7'd12: next = 13;
7'd13: next = 14;
7'd14: next = 15;
7'd15: next = 16;
7'd16: next = 17;
7'd17: next = 18;
7'd18: next = 19;
7'd19: next = 20;
7'd20: next = 21;
7'd21: next = 22;
7'd22: next = 23;
7'd23: next = 24;
7'd24: next = 25;
7'd25: next = 26;
7'd26: next = 27;
7'd27: next = 28;
7'd28: next = 29;
7'd29: next = 30;
7'd30: next = 31;
7'd31: next = 32;
7'd32: next = 33;
7'd33: next = 0;

endcase
end
endmodule








