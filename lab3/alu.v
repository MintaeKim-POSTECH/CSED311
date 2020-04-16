`include "opcodes.v" 	   

module alu(opcode, A, B, result);
	input [3:0] opcode; // 8 Operations: ADD, SUB, AND, OR, NOT, TCP, SHL, SHR
	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;

	output reg [`WORD_SIZE-1:0] result;

	always @(*) begin
		case (opcode)
			0: result = (A + B);  // ADD
			1: result = (A - B);  // SUB
			2: result = (A & B);  // AND
			3: result = (A | B);  // OR
			4: result = ~A;       // NOT
			5: result = (~A + 1); // TCP
			6: result = (A << 1); // SHL
			7: result = (A >> 1); // SHR
		endcase
	end
endmodule
