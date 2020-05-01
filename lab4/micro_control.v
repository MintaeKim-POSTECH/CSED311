

`include "macro.v"

module mcode_control(inst, reset_n, clk 
,PCWriteCond
,PCWrite
,IorD
,MemRead
,MemWrite
,IRWrite
,PCSource
,ALUSrcA
,ALUSrcB
,RegWrite
,WriteDataCtrl
,WriteRegCtrl);

	input reset_n, clk;
	input [`WORD_SIZE-1:0] inst;

	output reg PCWriteCond ,PCWrite,IorD,MemRead,MemWrite,IRWrite,ALUSrcA,RegWrite;
	output reg [1:0] PCSource,ALUSrcB,WriteDataCtrl, WriteRegCtrl;


	reg [3:0] opcode;
	reg [5:0] funcode;
	reg [3:0] state;
	reg PVSWriteEn;

	initial begin
		PCWriteCond = 0;
		PCWrite = 0;
		IorD = 0;
		MemRead = 0;
		MemWrite = 0;
		IRWrite = 0;
		ALUSrcA = 0;
		ALUSrcB = 0;
		RegWrite = 0;
		WriteDataCtrl = 0;
		WriteRegCtrl = 0;
		state = `INIT_STATE;

		PVSWriteEn=0;
	end

	always @(*) begin // Combinational Logic
		PCWriteCond=0;
		PCWrite = 0;//
		IorD = 0;//
		MemRead = 0;//
		MemWrite = 0;//
		IRWrite = 0;//
		PCSource = 0;
		ALUSrcA = 0;//
		ALUSrcB = 0;//
		RegWrite = 0;
		WriteDataCtrl = 0;//
		WriteRegCtrl = 0;//

		opcode=inst[15:12];
		funcode=inst[5:0];
		
		//PCWriteCond : 1 for branch instruction in EX state
		if(opcode<=3&&state==`EX2) PCWriteCond = 1;

		//PCWrite : 1 for IF4 state and  JAL, JRL instructions in WB state
		if(state == `IF1) PCWrite = 1;
		else if(state ==`WB && (opcode ==10 || opcode ==15 && funcode==26)) PCWrite = 1;

		//IorD: 0 For IF stage, 1 for load or store in mem stage (default 0)
		if( state>=`IF1 && state<=`MEM4 ) IorD = 1;

		//MemRead: True for IF state and Load Instruction in MEM state
		if ( (opcode==7 && state>=`MEM1) || (state>=`IF1 && state<=`IF4) )begin
			MemRead = 1;
		end

		//MemWrite: True for Store Instruction and PVSWriteEn==True 
		if ( opcode==8 && PVSWriteEn == 1 )begin
			MemWrite = 1;
		end

		//IRWrite: True for IF state only
		if( state>=`IF1 && state<=`IF4 ) IorD = 1;

		//PCSource
		//00: for JMP, JAL instrucion and IF4 state
		//01: for JPR and JRL instruction
		//10: for PC+4 or PC+IMM => when using alu to add pc address
		//11: take data from ALUOut, for branch condition in EX state
		if(opcode<=10&&opcode>=9) PCSource=2'b00;
		else if(state<=`IF4) PCSource=2'b10;
		else if(opcode==15&&(funcode==25||funcode==26)) PCSource=2'b01;
		else if(opcode<=3&&state==`EX2) PCSource=2'b11;
		

		//ALUSrcA: True at ID for ALU calculation of data in resister
		// False for WWD at ID state
		if(state>=`ID&&state<`MEM4)begin 
			ALUSrcA=1;
			if(opcode==15&&funcode==28)ALUSrcA=0;
		end

		//ALUSrcB: 
		// 00: take 2nd Resister value: PVSWriteEn!=1 and Rtype instruction 
		// 01: For PC+4 => When IF state 
		// 10: For Imm value calculation => For I type instruction
		if(state<`IF4) ALUSrcB=2'b01;
		else if(opcode<=3) ALUSrcB=2'b10;
		
		
		//RegWrite: True for WB state
		if(state == `WB) RegWrite = 1;
		
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
					// JAL: Goto WB
					else if (opcode == 9) state <= `WB;
					// JMP: Goto IF1
					else if (opcode == 10) begin 
						state <= `IF1;
						PVSWriteEn <= 1;
					end
					else state <= (state + 1);
				`ID:
					// WWD & JPR: Goto IF1
					if ((opcode == 15) && (funcode == 25 || funcode == 28)) begin
						state <= `IF1;
						PVSWriteEn <= 1;
					end
					// JRL: Goto WB
					else if (opcode == 15 && funcode == 26) state <= `WB;
					else state <= (state + 1);
				`EX2:
					// Bxx : Goto IF1
					if (opcode <= 3) begin
						state <= `IF1;
						PVSWriteEn <= 1;
					end
					// LWD & SWD: Goto MEM1
					else if (opcode == 7 || opcode == 8) state <= (state + 1);
					else state <= `WB;
				`MEM4:
					// SWD: Goto IF1
					if (opcode == 8) begin
						state <= `IF1;
						PVSWriteEn <= 1;
					end
					else state <= (state + 1);
				`WB: begin
					state <= `IF1;
					PVSWriteEn <= 1;
				end
				`HLT:   // TODO: Do Nothing
					;
				default: state <= (state + 1);
			endcase
		end
	end

endmodule