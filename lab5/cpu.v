`timescale 1ns/1ns

`include "macro.v"
`include "mux.v"`
`include "PC.v"
`include "adder.v"
`include "latch.v"
`include "unit.v"
`include "control.v"
`include "register.v"

module cpu(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	output readM1;
	wire readM1;
	output [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	output readM2;
	wire readM2;
	output writeM2;
	wire writeM2;
	output [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	wire [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;
	wire [`WORD_SIZE-1:0] data2;

	output [`WORD_SIZE-1:0] num_inst;
	wire [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	wire [`WORD_SIZE-1:0] output_port;
	output is_halted;
	wire is_halted;
	
	// TODO : Implement your pipelined CPU!
	
	// Control Wire
	wire [`CONT_SIG_COUNT-1:0] control_signals;

	// Control Wire: ID Stage
	wire [1:0] PCSrc;
	assign PCSrc = control_signals[___:___];
	wire RegWrite;
	assign RegWrite = control_signals[___];
	wire RegDest;
	assign RegDest = control_signals[__];

	// Hazard Wire
	wire hazard, IF_flush;
	
	// PCSrc MUX

	wire [`WORD_SIZE-1:0] PC_next, PC_cur;
	wire [`WORD_SIZE-1:0] PC_inc, PC_offset, PC_cat, PC_reg;
	mux16_4to1 mux_PC (PCSrc, PC_next, PC_inc, PC_offset, PC_cat, PC_reg);

	// PC
	PC pc (clk, reset_n, hazard, PC_cur, PC_next);

	// PC_inc Implementation
	adder pc_increment (PC_inc, PC_cur, 16'h0001);

	// Instruction MemoryD:/CSED311/lab5/cpu.v
	assign address1 = PC_cur;
	assign readM1 = 1; // Always Reading

	// IF/ID
	wire [`WORD_SIZE-1:0] PC_cur_latch, Idata_latch;
	IF_ID if_id_latch (clk, reset_n, IF_flush, hazard, PC_cur, data1, PC_cur_latch, Idata_latch);
	
	// ID Stage
	wire [`OPCODE_BITS-1:0] opcode;
	assign opcode = Idata_latch[15:12];

	wire [`FUNCODE_BITS-1:0] funcode;
	assign funcode = Idata_latch[5:0];

	wire [`IMM_BITS-1:0] imm_raw;
	assign imm_raw = Idata_latch[7:0];

	wire [`TARGET_BITS-1:0] target_raw;
	assign target_raw = Idata_latch[11:0];

	wire [`REG_BITS-1:0] rs, rt, rd;
	assign rs = Idata_latch[11:10];
	assign rt = Idata_latch[9:8];
	assign rd = Idata_latch[7:6];

	// PC_offset Implementation
	wire [`WORD_SIZE-1:0] imm_val;
	imm_generator_unit imm_gen (imm_val, imm_raw);
	wire [`WORD_SIZE-1:0] imm_val_p1;
	adder imm_p1 (imm_val_p1, imm_val, 16'h0001);

	adder pc_offset_adder (PC_offset, imm_val_p1, PC_cur_latch);

	// Control
	control con (control_signals, opcode, funcode);

	// Control Propagation MUX
	wire [`PROPA_SIG_COUNT-1:0] control_signals_propagation;
	assign control_signals_propagation = control_signals[`CONT_SIG_COUNT-1:`ID_SIG_COUNT]; 

	wire [`PROPA_SIG_COUNT-1:0] next_signals;
	mux_control_2to1 mux_con (hazard, next_signals, control_signals_propagation, 0);
	
	// Register
	// module register_cpu (clk, reset_n, readData1, readData2, readReg1, readReg2, writeReg, writeBack, RegWrite);
	wire [`WORD_SIZE-1:0] readData1, readData2;
	
	wire [`REG_BITS-1:0] readReg1, readReg2, writeReg;
	wire [`WORD_SIZE-1:0] writeBack;

	register_cpu register (clk, reset_n, RegWrite, readData1, readData2, readReg1, readReg2, writeReg, writeBack);

	// Register: MUX
	wire [`REG_BITS-1:0] writeReg_propa;
	mux2_2to1 rt_rd (RegDest, writeReg_propa, rt, rd);

	// Branch Prediction Calculation
	

	// 

	// Hazard Detection Unit
	haz_detect_unit hdu (hazard, ); 
	
	
	initial begin // Initial Logic
		mem_reg_data = 0;
		readM = 0;
		writeM = 0;
		A = 0;
		B = 0;
		ALUOut = 0;

		num_inst = 0;
		output_port = 16'bx;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			mem_reg_data <= 0;
			readM <= 0;
			writeM <= 0;
			A <= 0;
			B <= 0;
			ALUOut <= 0;

			output_port <= 16'bx;
			num_inst <= 0;
		end
		else begin
			$display ("inst# : %h, inst : %h, PC_cur : %h", num_inst, inst_reg_data, PC_cur);
			//$display ("---");
			//$display ("inst# : %h, output_port : %d", num_inst, output_port);
			//$display ("PC_next : %h, PC_cur : %h, data : %h, inst : %h, address : %h", PC_next, PC_cur, data, inst_reg_data, address);
			//$display ("rs1 : %d, rs2 : %d, wr : %d, wd : %h", inst_reg_data[11:10], inst_reg_data[9:8], wb_reg_id, wd_wire);
			//$display ("ALUSrcB : %b, IMMVAL : %h, TARGET : %h", ALUSrcB, inst_reg_data[7:0], inst_reg_data[11:0]);
			//$display ("regdata1 : %d, regdata2 : %d, A : %d, B : %d", reg_data1, reg_data2, A, B);
			//$display ("op1 : %d, op2 : %d, bcond : %d, alu_res : %d, alu_out : %d", alu_op1, alu_op2, bcond, alu_res, ALUOut); 
			//$display ("==");
			mem_reg_data <= data;
			readM <= MemRead;
			writeM <= MemWrite;

			A <= reg_data1;
			B <= reg_data2;
			ALUOut <= alu_res;

			if (isWWD) output_port <= alu_res;
			if (instExecuted) num_inst <= (num_inst + 1);
		end
	end
	
endmodule
