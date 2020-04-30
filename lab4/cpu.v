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
`include "control.v"

module cpu(clk, reset_n, readM, writeM, address, data, num_inst, output_port, is_halted);
	// In : num_inst, output_port, is_halted
	// Out : ackOutput, inputReady

	input clk;
	input reset_n;
	
	output readM;
	output writeM;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;	// number of instruction during execution (for debuging & testing purpose)
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;


	// Read & Write
	reg readM, writeM;
	
	// Data Line Wiring
	wire [`WORD_SIZE-1:0] inst_reg_data;
	wire [`WORD_SIZE-1:0] data_output;

	assign data = readM ? 16'bz:data_output;

	// Parameters
	wire [3:0] opcode;
	wire [5:0] funcode;

	// Module Instantiation & Wire Connection
	// PC
	wire [`WORD_SIZE-1:0] PC_next, PC_cur;
	PC pc (PC_cur, PC_next, reset_n, clk);
	
	// Control Unit
	wire MemRead, WriteDataCtrl, WriteRegCtrl, MemWrite, ALUSrc, RegWrite, PCSrc1, PCSrc2;
	mcode_control control_unit(inst_reg_data, reset_n, clk, MemRead, WriteDataCtrl, WriteRegCtrl, MemWrite, ALUSrc, RegWrite, PCSrc1, PCSrc2);

	// Register
	wire [1:0] wb_reg_id;
	wire [`WORD_SIZE-1:0] reg_data1, reg_data2, wd_wire;
	register_cpu reg_cpu (reg_data1, reg_data2, inst_reg_data[11:10], inst_reg_data[9:8], wb_reg_id, wd_wire, RegWrite, reset_n, clk);
	
	// Instruction Register & Memory Data Register
	inst_register inst_reg(data, inst_reg_data, IRWrite, reset_n, clk);
	reg [`WORD_SIZE-1:0] mem_reg_data;

	// Register A, B
	reg [`WORD_SIZE-1:0] A, B;

	wire [`WORD_SIZE-1:0] PC_wire_p1;
	adder add_1 (PC_cur, 16'b1, PC_wire_p1);

	// ALU: R Type
	alu_control alu_con (inst_reg_data, opcode, funcode);
	
	// I Type
	wire [`WORD_SIZE-1:0] alu_op2, imm_extend;
	imm_generator imm_gen (inst_reg_data[7:0], imm_extend);
	mux16_2to1 mux_imm (ALUSrc, B, imm_extend, alu_op2);

	wire [`WORD_SIZE-1:0] alu_res;
	wire [`WORD_SIZE-1:0] alu_mem_res;
	
	wire PCSrc3_bcond;
	alu alu_1 (opcode, funcode, A, alu_op2, alu_res, PCSrc3_bcond);
	
	assign address = (CS<=1)?PC_cur:alu_res;
	assign data_output = B;

	// J Type : JMP & JAL
	wire [`WORD_SIZE-1:0] jmp_addr;
	wire [`WORD_SIZE-1:0] PC_wire_jtype;
	jmp_control jmp_addr_calc (PC_cur, inst_reg_data[11:0], jmp_addr);
	mux16_2to1 mux_j (PCSrc1, PC_wire_p1, jmp_addr, PC_wire_jtype);

	// J Type: JAL & JRL
	// wire [1:0] rt_vs_rd_id;
	// mux2_2to1 mux_wb_target (RegDest, data_reg[9:8], data_reg[7:6], rt_vs_rd_id);
	// mux2_2to1 mux_jal_wb (Reg2Save, rt_vs_rd_id, 2'b10, wb_reg_id);
	mux2_4to1 mux_wb (WriteRegCtrl, inst_reg_data[9:8], inst_reg_data[7:6], 2'b10, 16'b0, wb_reg_id);
	
	//mux16_2to1 mux_load (MemtoReg, alu_res, data_reg, alu_mem_res);
	//mux16_2to1 mux_jal_wd (Reg2Save, alu_mem_res, PC_cur, wd_wire);
	mux16_4to1 mux_wd(WriteDataCtrl, alu_res, mem_reg_data, PC_cur, 16'b0, wd_wire);

	// I Type: JRL & JPR
	wire [`WORD_SIZE-1:0] PC_wire_itype_final;
	mux16_2to1 mux_jrl (PCSrc2, PC_wire_jtype, A, PC_wire_itype_final);
	
	// I Type: Branch
	wire [`WORD_SIZE-1:0] branch_addr;
	adder add_b (PC_wire_p1, imm_extend, branch_addr);
	mux16_2to1 mux_final (PCSrc3_bcond, PC_wire_itype_final, branch_addr, PC_next);

	initial begin // Initial Logic
		mem_reg_data = 0;
		readM = 0;
		writeM = 0;
		CS = 0;
		A = 0;
		B = 0;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			mem_reg_data <= 0;
			readM <= 0;
			writeM <= 0;
			A <= 0;
			B <= 0;
		end
		else begin
			mem_reg_data <= data;
			readM <= MemRead;
			writeM <= MemWrite;

			// TODO: Update A, B
			A <= reg_data1;
			B <= reg_data2;
		end
	end
																													  
endmodule
