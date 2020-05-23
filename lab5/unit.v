`include "macro.v"

module haz_detect_unit (hazard, ID_inst, EX_MemWrite, _____sth additional input____ );
	output hazard;

	input [size:0] ID_inst;
	input [size:0] EX_MemWrite;

	always @(*) begin
		// TODO: Set Hazard in specific condition
	end
endmodule

module imm_generator_unit (imm_val, imm_val_raw);
	input [`IMM_BITS-1:0] before;
	output wire [`WORD_SIZE-1:0] extended;

	// TODO: Sign Extend
	assign extended[7:0]=before[7:0];
	assign extended[`WORD_SIZE-1:8]= before[7]? 8'b11111111 : 0;

endmodule

module bcond_calc_unit (isTaken, opcode, funcode, regData1, regData2);
