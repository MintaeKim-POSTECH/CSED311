`include "macro.v"

module haz_detect_unit (hazard, rs_ID, rt_ID, writeReg_EX, WB_sig_EX, writeReg_M, WB_sig_M, opcode);
	output reg hazard;

	input [`REG_BITS-1:0] rs_ID, rt_ID;
	input [`REG_BITS-1:0] writeReg_EX, writeReg_M;

	input [`WB_SIG_COUNT-1:0] WB_sig_EX, WB_sig_M;
	input [`OPCODE_BITS-1:0] opcode;

	initial begin
		hazard = 0;
	end

	always @(*) begin
		hazard = 0;

		if (opcode == 14) hazard = 0; // Nop: No Hazard
		else begin
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
	end
endmodule

module pred_flush_unit (IF_flush, opcode, funcode, isTaken);
	output reg IF_flush;

	input isTaken;
	input [`OPCODE_BITS-1:0] opcode;
	input [`FUNCODE_BITS-1:0] funcode;

	initial begin
		IF_flush = 0;
	end

	always @(*) begin
		IF_flush = 0;
		if (opcode <= 3 && isTaken) IF_flush = 1;
		else if (opcode >= 9 && opcode <= 10) IF_flush = 1;
		else if (opcode == 15 && (funcode == 25 || funcode == 26)) IF_flush = 1;
	end
endmodule

module imm_generator_unit (imm_val, imm_val_raw);
	output wire [`WORD_SIZE-1:0] imm_val;
	input [`IMM_BITS-1:0] imm_val_raw;	

	// Sign Extend
	assign imm_val[`IMM_BITS-1:0] = imm_val_raw[`IMM_BITS-1:0];
	assign imm_val[`WORD_SIZE-1:8]= imm_val[`IMM_BITS-1]? 8'hff : 0;

endmodule

module bcond_calc_unit (isTaken, opcode, funcode, A, B);
	output reg isTaken;

	input [`OPCODE_BITS-1:0] opcode;
	input [`FUNCODE_BITS-1:0] funcode;

	input signed [`WORD_SIZE-1:0] A, B;

	initial begin
		isTaken = 0;
	end

	always @(*) begin
		isTaken = 0;

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
