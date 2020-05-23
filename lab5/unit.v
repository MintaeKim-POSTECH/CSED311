`include "macro.v"

// haz_detect_unit hdu (hazard, rs_ID, rt_ID, writeReg_EX, WB_sig_EX, writeReg_M, WB_sig_M, writeReg_WB, WB_sig_WB); 
module haz_detect_unit (hazard, rs_ID, rt_ID, writeReg_EX, WB_sig_EX, writeReg_M, WB_sig_M, writeReg_WB, WB_sig_WB);
	output hazard;

	input [`REG_BITS-1:0] rs_ID, rt_ID;
	input [`REG_BITS-1:0] writeReg_EX, writeReg_M, writeReg_WB;

	input [`WB_SIG_COUNT] WB_sig_EX, WB_sig_M, WB_sig_WB;

	always @(*) begin
		// TODO: Set Hazard in specific condition
	end
endmodule

module pred_flush_unit (IF_flush, opcode, funcode, isTaken);

	// TODO: Implement
endmodule

module imm_generator_unit (imm_val, imm_val_raw);
	input [`IMM_BITS-1:0] before;
	output wire [`WORD_SIZE-1:0] extended;

	// TODO: Sign Extend
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
