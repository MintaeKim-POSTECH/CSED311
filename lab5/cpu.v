`timescale 1ns/1ns

`include "macro.v"
`include "mux.v"`
`include "PC.v"
`include "adder.v"
`include "latch.v"
`include "unit.v"
`include "control.v"
`include "register.v"
`include "alu_control.v"
`include "alu.v"

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
	
	// Control Wire (For ID Stage)
	wire [`CONT_SIG_COUNT-1:0] control_signals;
	wire [`PROPA_SIG_COUNT-1:0] control_signals_propagation, next_signals;

	// Control Wire: Propagation
	wire [`WB_SIG_COUNT] WB_sig_ID, WB_sig_EX, WB_sig_M, WB_sig_WB;
	wire [`M_SIG_COUNT] M_sig_ID, M_sig_EX, M_sig_M;
	wire [`EX_SIG_COUNT] EX_sig_ID, EX_sig_EX;

	// Control Wire: WB Stage
	wire isInst;
	assign isInst = WB_sig_WB[`WB_ISINST];
	
	assign is_halted = WB_sig_WB[`WB_ISHALT];
	wire isWWD;
	assign isWWD = WB_sig_WB[`WB_ISWWD];
	wire RegWrite;
	assign RegWrite = WB_sig_WB[`WB_REGWRITE];
	wire MemtoReg;
	assign MemtoReg = WB_sig_WB[`WB_MEMTOREG];
	wire Reg2Save;
	assign Reg2Save = WB_sig_WB[`WB_REG2SAVE];

	// Control Wire: M (MEM) Stage
	// ALUOp: opcode_EX + funcode_EX
	wire MemRead;
	assign MemRead = M_sig_M[`M_MEMREAD];
	wire MemWrite;
	assign MemWrite = M_sig_M[`M_MEMWRITE];

	// Control Wire: EX Stage
	// ALUOp: opcode_EX + funcode_EX
	wire [`OPCODE_BITS-1:0] opcode_EX;
	assign opcode_EX = EX_sig_EX[`EX_OPCODE:`EX_OPCODE - `OPCODE_BITS + 1];
	wire [`FUNCODE_BITS-1:0] funcode_EX:
	assign funcode_EX = EX_sig_EX[`EX_FUNCODE:`EX_FUNCODE - `FUNCODE_BITS + 1];
	wire ALUSrc;
	assign ALUSrc = EX_sig_EX[`EX_ALUSRC];

	// Control Wire: ID Stage
	wire [1:0] PCSrc;
	assign PCSrc = control_signals[`ID_PCSRC:`ID_PCSRC-1];
	wire RegWrite;
	assign RegWrite = control_signals[`ID_REGWRITE];
	wire RegDest;
	assign RegDest = control_signals[`ID_REGDEST];

	// Hazard Wire
	wire hazard, IF_flush;
	

	//// IF Stage ////
	// PCSrc MUX
	wire [`WORD_SIZE-1:0] PC_next, PC_cur;
	wire [`WORD_SIZE-1:0] PC_inc, PC_offset, PC_cat, PC_reg;
	mux16_4to1 mux_PC (PCSrc, PC_next, PC_inc, PC_offset, PC_cat, PC_reg);

	// PC
	PC pc (clk, reset_n, hazard, PC_cur, PC_next);

	// PC Wire: Propagation
	wire [`WORD_SIZE=1:0] PC_ID, PC_EX, PC_M, PC_WB;

	// PC_inc Implementation
	adder pc_increment (PC_inc, PC_cur, 16'h0001);

	// Instruction Memory
	assign address1 = PC_cur;
	assign readM1 = 1; // Always Reading

	// IF/ID
	wire [`WORD_SIZE-1:0] Idata_latch;
	IF_ID if_id_latch (clk, reset_n, IF_flush, hazard, PC_ID, Idata_latch, PC_cur, data1);
	
	//// ID Stage ////
	// Instruction Decoding
	wire [`OPCODE_BITS-1:0] opcode;
	assign opcode = Idata_latch[15:12];

	wire [`FUNCODE_BITS-1:0] funcode;
	assign funcode = Idata_latch[5:0];

	wire [`IMM_BITS-1:0] imm_raw;
	assign imm_raw = Idata_latch[7:0];

	wire [`TARGET_BITS-1:0] target_raw;
	assign target_raw = Idata_latch[11:0];

	wire [`REG_BITS-1:0] rs_ID, rt_ID, rd_ID;
	assign rs_ID = Idata_latch[11:10];
	assign rt_ID = Idata_latch[9:8];
	assign rd_ID = Idata_latch[7:6];

	// writeReg: Propagation
	wire [`REG_BITS-1:0] writeReg_ID, writeReg_EX, writeReg_M, writeReg_WB;

	// PC_offset Implementation
	wire [`WORD_SIZE-1:0] imm_val;
	imm_generator_unit imm_gen (imm_val, imm_raw);
	wire [`WORD_SIZE-1:0] imm_val_p1;
	adder imm_p1 (imm_val_p1, imm_val, 16'h0001);

	adder pc_offset_adder (PC_offset, imm_val_p1, PC_ID);

	// Control
	control con (control_signals, opcode, funcode);

	// Control Propagation MUX
	assign control_signals_propagation = control_signals[`CONT_SIG_COUNT-1:`ID_SIG_COUNT]; 
	mux_control_2to1 mux_con (hazard, next_signals, control_signals_propagation, 0);

	// Control Propagation: Next Signals
	assign WB_sig_ID = next_signals[`PROPA_SIG_COUNT-1:`PROPA_SIG_COUNT-`M_SIG_COUNT];
	assign M_sig_ID = next_signals[`PROPA_SIG_COUNT-`M_SIG_COUNT-1:`EX_SIG_COUNT];
	assign EX_sig_ID = next_signals[`EX_SIG_COUNT-1:0];
	
	// Register
	wire [`WORD_SIZE-1:0] readData1, readData2;
	wire [`WORD_SIZE-1:0] writeData;

	register_cpu register (clk, reset_n, RegWrite, readData1, readData2, rs_ID, rt_ID, writeReg_WB, writeData);

	// Register: MUX
	mux2_2to1 rt_rd (RegDest, writeReg_ID, rt_ID, rd_ID);

	// Branch Prediction Calculation
	wire isTaken;
	bcond_calc_unit bcond_unit (isTaken, opcode, funcode, readData1, readData2);

	// ID/EX
	wire [`WORD_SIZE-1:0] readData1_latch, readData2_latch, imm_val_latch;
	wire [`REG_BITS-1:0] wbRegID_latch;
	ID_EX id_ex_latch (clk, reset_n, WB_sig_EX, M_sig_EX, EX_sig_EX, readData1_latch, readData2_latch, imm_val_latch, writeReg_EX, PC_EX, 
					WB_sig_ID, M_sig_ID, EX_sig_ID, readData1, readData2, imm_val, writeReg_ID, PC_ID);
	
	//// EX Stage ////
	// ALUSrc MUX
	wire [`WORD_SIZE-1:0] ALUOp2;
	mux16_2to1 mux_alusrc (ALUSrc, ALUOp2, readData2_latch, imm_val_latch);

	// ALU Control
	wire [`ALU_ACTION_BITS-1:0] ALUAction;
	alu_control alu_con (ALUAction, opcode_EX, funcode_EX);

	// ALU
	wire [`WORD_SIZE-1:0] ALURes;
	alu alu_cpu (ALUAction, ALURes, readData1_latch, ALUOp2);
	
	// EX/M
	wire [`WORD_SIZE-1:0] ALURes_latch, writeData_latch;
	EX_M ex_m_latch (clk, reset_n, WB_sig_M, M_sig_M, ALURes_latch, writeData_latch, writeReg_M, PC_M,
					WB_sig_EX, M_sig_EX, ALURes, readData2_latch, writeReg_EX, PC_EX);

	//// M (MEM) Stage ////
	assign address2 = ALURes_latch;
	assign data2 = ((readM2 == 1) ? 16'bz : writeData_latch);

	// M/WB
	wire [`WORD_SIZE-1:0] writeReg_WB_candidate;
	M_WB m_wb_latch (clk, reset_n, WB_sig_WB, Mdata_latch, addr_latch, writeReg_WB_candidate, PC_WB, 
					WB_sig_M, data2, ALURes_latch, writeReg_M, PC_M);

	//// WB Stage ////
	wire [`WORD_SIZE-1:0] writeData_candidate;
	mux16_2to1 mux_memtoreg (MemtoReg, writeData_candidate, addr_latch, Mdata_latch);

	mux16_2to1 mux_wd (Reg2Save, writeData, writeData_candidate, PC_WB);
	mux2_2to1 mux_wr (Reg2Save, writeReg_WB, writeReg_WB_candidate, 2'b10);
	
	// Output Port

	// Num Inst

	// Hazard Detection Unit
	// TODO: Implement
	haz_detect_unit hdu (hazard, rs, rt, writeReg_EX, WB_sig_EX, writeReg_M, WB_sig_M, writeReg_WB, WB_sig_WB); 

	// Flushing Unit: Prediction Failed
	// TODO: Implement
	pred_flush_unit ();

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
