`timescale 1ns/1ns

`include "macro.v" 

`include "PC.v"
`include "register.v"
`include "inst_register.v"
	   
`include "alu.v"
`include "mux.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "adder.v"
`include "jmp_control.v"
// `include "control.v"
`include "micro_control.v"

module cpu(clk, reset_n, readM, writeM, address, data, num_inst, output_port, is_halted);
	// In : num_inst, output_port, is_halted
	// Out : ackOutput, inputReady

	input clk;
	input reset_n;
	
	output readM;
	output writeM;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output reg [`WORD_SIZE-1:0] num_inst;	// number of instruction during execution (for debuging & testing purpose)
	output reg [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;

	// Read & Write
	reg readM, writeM;
	
	// Data Line Wiring
	wire [`WORD_SIZE-1:0] inst_reg_data;

	// Register A, B
	reg [`WORD_SIZE-1:0] A, B, ALUOut;
	
	// Data Assignment
	assign data = (readM ? 16'bz : B);

	// Control Unit
	wire PCWriteCond, PCWrite, IorD, MemRead, MemWrite, IRWrite, ALUSrcA, RegWrite;
	wire instExecuted, isWWD;
	wire [1:0] PCSource,ALUSrcB,WriteDataCtrl, WriteRegCtrl, ALUOp;
	
	mcode_control microCode_control(inst_reg_data, reset_n, clk, PCWriteCond, PCWrite, IorD,
MemRead,MemWrite,IRWrite,PCSource,ALUSrcA,ALUSrcB,RegWrite,
WriteDataCtrl,WriteRegCtrl,ALUOp,instExecuted,is_halted,isWWD);

	// PC
	wire [`WORD_SIZE-1:0] PC_next, PC_cur;
	wire PC_update;
	wire PC_sem;
	wire bcond;
	and and_op(PC_sem, PCWriteCond, bcond);
	or or_op(PC_update, PC_sem, PCWrite);
	PC pc (PC_cur, PC_next, PC_update, reset_n, clk);

	// Register
	wire [1:0] wb_reg_id;
	wire [`WORD_SIZE-1:0] reg_data1, reg_data2, wd_wire;
	register_cpu reg_cpu (reg_data1, reg_data2, inst_reg_data[11:10], inst_reg_data[9:8], wb_reg_id, wd_wire, RegWrite, reset_n, clk);
	
	// Instruction Register & Memory Data Register
	inst_register inst_reg(data, inst_reg_data, IRWrite, reset_n, clk);
	reg [`WORD_SIZE-1:0] mem_reg_data;
	
	// Immediate Generator
	wire [`WORD_SIZE-1:0] imm_extend;
	imm_generator imm_gen (inst_reg_data[7:0], imm_extend);

	// ALU Source Determination MUX
	wire [`WORD_SIZE-1:0] alu_op1, alu_op2;
	// ALUSrcA: 1Bit, ALUSrc B: 2Bit
	mux16_2to1 mux_a (ALUSrcA, PC_cur, A, alu_op1);
	mux16_4to1 mux_b (ALUSrcB, B, 16'b0000_0000_0000_0001, imm_extend, , alu_op2);

	// ALU Control
	wire [3:0] ALUAction;
	wire [2:0] btype;
	alu_control alu_con (inst_reg_data, ALUOp, ALUAction, btype);

	// ALU
	wire [`WORD_SIZE-1:0] alu_res;
	alu alu_1 (ALUAction, btype, alu_op1, alu_op2, alu_res, bcond);
	
	// Jump Address Calculation
	wire [`WORD_SIZE-1:0] jump_addr;
	jmp_control jmp_addr_calc (PC_cur, inst_reg_data[11:0], jump_addr);

	// Memory Access Address Determination
	mux16_2to1 mux_iord (IorD, PC_cur, ALUOut, address);

	// PC_next Determination
	mux16_4to1 mux_pc_next (PCSource, jump_addr, alu_res, ALUOut, , PC_next);

	// Write Register ID Determination
	mux2_4to1 mux_wb (WriteRegCtrl, inst_reg_data[9:8], inst_reg_data[7:6], 2'b10, , wb_reg_id);
	
	// Write Data Determination
	mux16_4to1 mux_wd(WriteDataCtrl, ALUOut, mem_reg_data, PC_cur, , wd_wire);

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
			$display ("---");
			$display ("inst# : %h, output_port : %d", num_inst, output_port);
			$display ("PC_next : %h, PC_cur : %h, data : %h, inst : %h, address : %h", PC_next, PC_cur, data, inst_reg_data, address);
			$display ("rs1 : %d, rs2 : %d, wr : %d, wd : %h", inst_reg_data[11:10], inst_reg_data[9:8], wb_reg_id, wd_wire);
			$display ("regdata1 : %d, regdata2 : %d, A : %d, B : %d", reg_data1, reg_data2, A, B);
			$display ("op1 : %d, op2 : %d, bcond : %d, alu_res : %d, alu_out : %d", alu_op1, alu_op2, bcond, alu_res, ALUOut); 
			$display ("==");
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
