 `include "macro.v"

module alu_control (inst, ALUOp, ALUAction, btype);
	input [`WORD_SIZE-1:0] inst;
	input [1:0] ALUOp;
	output reg [3:0] ALUAction;
	output reg [2:0] btype;

	wire [3:0] opcode;
	wire [5:0] funcode;

	assign opcode = inst[15:12];
	assign funcode = inst[5:0];

	initial begin
		ALUAction = 0;
		btype = 0;
	end

	always @(*) begin
		// ALUAction
		case (ALUOp)
			`IF_STAGE:
				ALUAction = 0; // result = (PC + 1);
			`ID_STAGE:
				ALUAction = 0; // result = (PC + ImmediateValue);
			`EX_STAGE:
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
		endcase

		// btype
		case (opcode)
			0: btype = 1;       // bcond = ((A == B) ? 0 : 1);
			1: btype = 2;       // bcond = ((A == B) ? 1 : 0);
			2: btype = 3;       // bcond = ((A > 0) ? 1 : 0);
			3: btype = 4;       // bcond = ((A < 0) ? 1 : 0);
			default: btype = 0; // bcond = 0;
		endcase
	end
endmodule
