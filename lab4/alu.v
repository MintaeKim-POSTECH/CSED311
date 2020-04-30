`include "macro.v"	   

module alu(opcode, funcode, A, B, result, bcond);
	input [3:0] opcode;
	input [5:0] funcode;
	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;

	output reg [`WORD_SIZE-1:0] result;
	output reg bcond;

	initial begin
		result = 0;
		bcond = 0;
	end

	always @(*) begin
		// Result determination
		if (opcode == 15) begin // R Type
			case (funcode)
				0: result = (A + B);  // ADD
				1: result = (A - B);  // SUB
				2: result = (A & B);  // AND
				3: result = (A | B);  // OR
				4: result = ~A;       // NOT
				5: result = (~A + 1); // TCP
				6: result = (A << 1); // SHL
				7: result = (A >> 1); // SHR
				28: result = A;       // WWD
			endcase
		end
		else begin // I Type
			case (opcode)
				4: result = (A + B);  // ADI
				5: result = (A | B);  // ORI
				6: result = (B << 8); // LHI
				7: result = (A + B);  // LWD (Load)
				8: result = (A + B);  // SWD (Store)
			endcase
		end
		// Branch Condition Determination
		case (opcode)
			0: bcond = ((A == B) ? 0 : 1);
			1: bcond = ((A == B) ? 1 : 0);
			2: bcond = ((A > 0) ? 1 : 0);
			3: bcond = ((A < 0) ? 1 : 0);
			default: bcond = 0;
		endcase
	end
endmodule
