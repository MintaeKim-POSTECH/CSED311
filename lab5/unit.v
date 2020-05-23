`include "macro.v"

module haz_detect_unit (hazard, rs_ID, rt_ID, writeReg_EX, WB_sig_EX, writeReg_M, WB_sig_M, opcode);
	output reg hazard;

	input [`REG_BITS-1:0] rs_ID, rt_ID;
	input [`REG_BITS-1:0] writeReg_EX, writeReg_M, writeReg_WB;

	input [`WB_SIG_COUNT] WB_sig_EX, WB_sig_M, WB_sig_WB;

	initial begin
		hazard = 0;
	end

	always @(*) begin
		hazard = 0;

		// Set Hazard in specific condition
		if (rs_ID == writeReg_EX && WB_sig_EX[`WB_REGWRITE] == 1) hazard = 1;
		else if (rs_ID == writeReg_M && WB_sig_M[`WB_REGWRITE] == 1) hazard = 1;
		else if (rs_ID == 2'b10 && WB_sig_EX[`WB_REGWRITE] == 1 && WB_sig_EX[`WB_REG2SAVE] == 1) hazard = 1;
		else if (rs_ID == 2'b10 && WB_sig_M[`WB_REGWRITE] == 1 && WB_sig_M[`WB_REG2SAVE] == 1) hazard = 1;

		// !isJ-Format (JMP, JAL)
		if (opcode < 9 || opcode > 10) begin
			if (rt_ID == writeReg_EX && WB_sig_EX[`WB_REGWRITE] == 1) hazard = 1;
			else if (rt_ID == writeReg_M && WB_sig_M[`WB_REGWRITE] == 1) hazard = 1;
			else if (rt_ID == 2'b10 && WB_sig_EX[`WB_REGWRITE] == 1 && WB_sig_EX[`WB_REG2SAVE] == 1) hazard = 1;
			else if (rt_ID == 2'b10 && WB_sig_M[`WB_REGWRITE] == 1 && WB_sig_M[`WB_REG2SAVE] == 1) hazard = 1;
		end
	end
endmodule

module pred_flush_unit (IF_flush, hazard, opcode, funcode, isTaken);
	output reg IF_flush;

	input hazard, opcode, funcode, isTaken;

	initial begin
		IF_flush = 0;
	end

	always @(*) begin
		IF_flush = 0;
		if (hazard == 1) IF_flush = 0;
		else begin
			if (opcode <= 3 && isTaken) IF_flush = 1;
			else if (opcode >= 9 && opcode <= 10) IF_flush = 1;
			else if (opcode == 15 && (funcode == 25 || funcode == 26)) IF_flush = 1;
		end
	end
endmodule

module imm_generator_unit (imm_val, imm_val_raw);
	input [`IMM_BITS-1:0] before;
	output wire [`WORD_SIZE-1:0] extended;

	// Sign Extend
	assign extended[`IMM_BITS-1:0]=before[`IMM_BITS-1:0];
	assign extended[`WORD_SIZE-1:8]= before[`IMM_BITS-1]? 8'b11111111 : 0;

endmodule

module bcond_calc_unit (isTaken, opcode, funcode, A, B);
	output isTaken;

	input [`OPCODE_BITS-1:0] opcode;
	input [`FUNCODE_BITS-1:0] funcode;

	input [`WORD_SIZE-1:0] A, B;

	always @(*) begin
		// Branch Condition Execution
		case (opcode)
			0: isTaken = ((A == B) ? 0 : 1);
			1: isTaken = ((A == B) ? 1 : 0);
			2: isTaken = ((A > 0) ? 1 : 0);
			3: isTaken = ((A < 0) ? 1 : 0);
			default: isTaken = 0;
		endcase
	end
endmodule
