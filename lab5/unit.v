`include "macro.v"

module haz_detect_unit (hazard, ID_inst, EX_MemWrite, _____sth additional input____ );
	output hazard;

	input [size:0] ID_inst;
	input [size:0] EX_MemWrite;

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
