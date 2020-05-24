 `include "macro.v"

module alu_control (ALUAction, opcode, funcode);
	output reg [`ALU_ACTION_BITS-1:0] ALUAction;

	input [`OPCODE_BITS-1:0] opcode;
	input [`FUNCODE_BITS-1:0] funcode;

	initial begin
		ALUAction = 0;
	end

	always @(*) begin
		case (opcode)
			// Immediate Value
			4: ALUAction = 0; // result = (A + B);  // ADI
			5: ALUAction = 3; // result = (A | B);  // ORI
			6: ALUAction = 8; // result = (B << 8); // LHI
			7: ALUAction = 0; // result = (A + B);  // LWD (Load)
			8: ALUAction = 0; // result = (A + B);  // SWD (Store)
			// RType
			15:
				case (funcode)
					0: ALUAction = 0;  // result = (A + B);  // ADD
					1: ALUAction = 1;  // result = (A - B);  // SUB
					2: ALUAction = 2;  // result = (A & B);  // AND
					3: ALUAction = 3;  // result = (A | B);  // ORR
					4: ALUAction = 4;  // result = ~A;       // NOT  
					5: ALUAction = 5;  // result = (~A + 1); // TCL 
					6: ALUAction = 6;  // result = (A << 1); // SHL
					7: ALUAction = 7;  // result = (A >> 1); // SHR
					25: ALUAction = 9; // result = A;        // JPR
					26: ALUAction = 9; // result = A;        // JRL
					28: ALUAction = 9; // result = A;        // WWD
				endcase
		endcase
	end
endmodule
