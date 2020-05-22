`include "macro.v"	   

module alu(ALUAction, btype, A, B, result, bcond);
	input [3:0] ALUAction;
	input [2:0] btype;

	input signed [`WORD_SIZE-1:0] A;
	input signed [`WORD_SIZE-1:0] B;

	output reg signed [`WORD_SIZE-1:0] result;
	output reg bcond;

	initial begin
		result = 0;
		bcond = 0;
	end

	always @(*) begin
		// Operation Execution
		case (ALUAction)
			0: result = (A + B);
			1: result = (A - B);
			2: result = (A & B);
			3: result = (A | B);
			4: result = ~A;
			5: result = (~A + 1);
			6: result = (A << 1);
			7: result = (A >> 1);
			8: result = (B << 8);
			9: result = A;
		endcase 
		
		// Branch Condition Execution
		case (btype)
			0: bcond = 0;
			1: bcond = ((A == B) ? 0 : 1);
			2: bcond = ((A == B) ? 1 : 0);
			3: bcond = ((A > 0) ? 1 : 0);
			4: bcond = ((A < 0) ? 1 : 0);
		endcase
	end
endmodule
