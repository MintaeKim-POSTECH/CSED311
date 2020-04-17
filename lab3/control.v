`include "opcodes.v"

module control(inst, RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2);
	input [`WORD_SIZE-1:0] inst;
	output reg RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2;
	reg isJAL, isJRL, isJPR, isLoad, isStore;

	reg [3:0] opcode;
	always @(*) begin
		opcode=inst[15:12];
		if(opcode<=8)begin
			// ALUSrc: Using Immediate Values?
			ALUSrc = 1;
			if(opcode==7)begin
				isLoad = 1;
			end
			else if(opcode==8)begin
				isStore = 1;
			end
		end
		// PCSrc1: isJtype?
		else if(opcode==9)begin
			PCSrc1 = 1;
		end
		else if(opcode==10)begin
			PCSrc1 = 1;
			isJAL = 1;
		end
		else if (opcode==15)begin
			// RegDest: R Type (rd) vs I Type (rt)
			RegDest = 1; 
			if(inst[5:0]==25)begin
				isJPR = 1;
			end
			else if(inst[5:0]==26)begin
				isJRL = 1;
			end
		end

		// RegWrite
		if (isStore == 1) RegWrite = 0;
		else if (opcode >= 0 && opcode <= 3) RegWrite = 0;
		else RegWrite = 1;

		// Reg2Save: Instructions that Saves PC in $2 / (isJAL || isJRL)
		Reg2Save = (isJAL || isJRL);

		// PCSrc2: (isJRL || isJPR)
		PCSrc2 = (isJRL || isJPR);

		// MemtoReg: isLoad
		MemtoReg = isLoad;
		// MemWrite: isStore
		MemWrite = isStore;
		// MemRead: isLoad
		MemRead = isLoad;
	end
endmodule
