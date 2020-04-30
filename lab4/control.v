`include "macro.v"

module mcode_control(inst, reset_n, clk, MemRead, WriteDataCtrl, WriteRegCtrl, MemWrite, ALUSrc, RegWrite, PCSrc1, PCSrc2);
	input reset_n, clk;
		
	input [`WORD_SIZE-1:0] inst;
	output reg MemRead, MemWrite, ALUSrc, RegWrite, PCSrc1, PCSrc2;
	output reg [1:0] WriteDataCtrl, WriteRegCtrl;

	reg [3:0] opcode;
	reg [5:0] funcode;

	reg [3:0] state;

	reg PVSWriteEn;

	initial begin
		MemRead = 0;
		WriteDataCtrl = 0;
		WriteRegCtrl = 0;
		MemWrite = 0;
		ALUSrc = 0;
		RegWrite = 0;
		PCSrc1 = 0;
		PCSrc2 = 0;
		
		state = `INIT_STATE;

		PVSWriteEn=0;
	end

	always @(*) begin // Combinational Logic
		MemRead = 0;
		WriteDataCtrl = 0;
		WriteRegCtrl = 0;
		MemWrite = 0;
		ALUSrc = 0;
		RegWrite = 0;
		PCSrc1 = 0;
		PCSrc2 = 0;
	
		opcode=inst[15:12];
		funcode=inst[5:0];

		//MemRead: True for Load Instruction
		if (opcode==7)begin
			MemRead = 1;
		end

		//WriteDataCtrl: Determines data to write.
		//0: ALU_result (default)
		//1: Memory Data (isLoad)
		//2: PC (isJAL || isJRL)
		if (opcode == 7) WriteDataCtrl = 1;
		else if (opcode==10||(opcode==15&&funcode==26)) WriteDataCtrl = 2;
		else WriteDataCtrl = 0;

		//WriteRegCtrl: Determines register to write.
		//0: <rt>
		//1: <rd> (RegDest)
		//2: 2 (Reg2Save // isJAL || isJRL)
		if (opcode == 15) WriteRegCtrl = 1;
		else if (opcode==10||(opcode==15&&funcode==26)) WriteRegCtrl = 2;
		else WriteRegCtrl = 0;

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

		//PCSrc1
		if (opcode==9||opcode==10)begin
			PCSrc1 = 1;
		end

		//PCSrc2: isJRL || isJPR
		//JRL: opcode 15 and function code 26
		//JPR: opcode 15 and function code 25
		if (opcode==15)begin
			if(funcode==25||funcode==26) PCSrc2 = 1;
		end
	end

	always @(posedge clk) begin // Sequential Logic
		if (!reset_n) begin
			state <= `INIT_STATE;
		end
		else begin
			case (state)
				`IF4:
					// HLT: Goto HLT
					if (opcode == 15 && funcode == 29) state <= `HLT;
					// JMP & JAL: Goto EX1
					else if (opcode == 9 || opcode == 10) state <= `EX1;
					else state <= (state + 1);
				`ID:
					// WWD & JPR: Goto IF1
					if ((opcode == 15) && (funcode == 25 || funcode == 28)) begin
						state <= `IF1;
						// TODO: PVSWriteEn
					end
					// JRL: Goto WB
					else if (opcode == 15 && funcode == 26) state <= `WB;
					else state <= (state + 1);
				`EX2:
					// Bxx & JMP: Goto IF1
					if (opcode <= 3 || opcode == 9) begin
						state <= `IF1;
						// TODO: PVSWriteEn
					end
					// LWD & SWD: Goto MEM1
					else if (opcode == 7 || opcode == 8) state <= (state + 1);
					else state <= `WB;
				`MEM4:
					// SWD: Goto IF1
					if (opcode == 8) begin
						state <= `IF1;
						// TODO: PVSWriteEn
					end
					else state <= (state + 1);
				`WB: begin
					state <= `IF1;
					PVSWriteEn<=1;
				 end
				`HLT:   // TODO: Do Nothing
					;
				default: state <= (state + 1);
			endcase
		end
	end
endmodule
