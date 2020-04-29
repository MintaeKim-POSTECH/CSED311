`include "opcodes.v"

module control(inst, RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2);
	input [`WORD_SIZE-1:0] inst;
	output reg RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2;

	reg [3:0] opcode;

	initial begin
		RegDest = 0;
		MemRead = 0;
		MemtoReg = 0;
		MemWrite = 0;
		ALUSrc = 0;
		RegWrite = 0;
		Reg2Save = 0;
		PCSrc1 = 0;
		PCSrc2 = 0;
	end

	always @(*) begin
		RegDest = 0;
		MemRead = 0;
		MemtoReg = 0;
		MemWrite = 0;
		ALUSrc = 0;
		RegWrite = 0;
		Reg2Save = 0;
		PCSrc1 = 0;
		PCSrc2 = 0;
	
		opcode=inst[15:12];

		//RegDest: R Type (rd) vs I Type (rt)
		if (opcode==15)begin
			RegDest = 1; 
		end

		//MemRead, MemtoReg: True for Load Instruction
		if (opcode==7)begin
			MemRead = 1;
			MemtoReg = 1;
		end

		//MemWrite: True for Store Instruction(opcode 8)
		if (opcode==8)begin
			MemWrite = 1;
		end

		//ALUSrc: True when opcode is 4~8 
		if(opcode > 3&&opcode <= 8) begin
		ALUSrc = 1;
		end

		//RegWrite: True for opcode 4~7, 10~14 and False when
		if (opcode>=4&&opcode<=7 || opcode>=10&&opcode<=15)begin
			if(opcode==15&&inst[5:0]==25) RegWrite = 0;
			else RegWrite = 1;
		end

		//Reg2Save: isJAL || isJRL, 
		// JAL: opcode 10
		// JRL: opcode 15 and function code 26
		if (opcode==10||(opcode==15&&inst[5:0]==26))begin
			Reg2Save=1;
		end

		//PCSrc1
		if (opcode==9||opcode==10)begin
			PCSrc1 = 1;
		end

		//PCSrc2: isJRL || isJPR
		//JRL: opcode 15 and function code 26
		//JPR: opcode 15 and function code 25
		if (opcode==15)begin
			if(inst[5:0]==25||inst[5:0]==26) PCSrc2 = 1;
		end
	end
endmodule
