

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
,WriteRegCtrl
,ALUOp
,instExecuted
,isHalt
,isWWD
);

	input reset_n, clk;
	input [`WORD_SIZE-1:0] inst;

	output reg PCWriteCond ,PCWrite,IorD,MemRead,MemWrite,IRWrite,ALUSrcA,RegWrite,instExecuted,isHalt,isWWD;
	output reg [1:0] PCSource,ALUSrcB,WriteDataCtrl, WriteRegCtrl,ALUOp;


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
		ALUOp = 0;
		instExecuted = 0;
		isHalt = 0;
		isWWD = 0;
		state = `INIT_STATE;
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
		ALUOp = 0;
		instExecuted = 0;
		isHalt = 0;
		isWWD = 0;

		opcode=inst[15:12];
		funcode=inst[5:0];
		
		//PCWriteCond : 1 for branch instruction in EX state
		if(opcode<=3&&state==`EX2) PCWriteCond = 1;

		//PCWrite : 1 for IF4 state and  JAL, JMP instructions in ID state, JRL  in EX??2 state
		if(state == `IF4) PCWrite = 1;
		else if(state ==`ID && (opcode ==10 || opcode ==9)) PCWrite = 1;
 		else if(state ==`EX2&& (opcode ==15 && funcode==26)) PCWrite = 1;

		//IorD: 1 For IF stage, 1 for load or store in mem stage (default 0)
		if((state>=`EX2 && state<=`MEM4)|| (state==`WB && opcode==7)) IorD = 1;

		//MemRead: True for IF state and Load Instruction in MEM state
		//Theoretically: It should be end ~ IF4, but we'll make an approximation to IF1 ~ IF4
		if ( (opcode==7 && state>=`EX2&&state<=`MEM3) || (state<=`IF4) )begin
			MemRead = 1;
		end

		//MemWrite: True for Store Instruction and PVSWriteEn==True 
		if ( opcode==8 && state>=`EX2&&state<=`MEM3)begin
			MemWrite = 1;
		end

		//IRWrite: True for IF state only
		if(state == `IF4) IRWrite = 1;

		//PCSource
		//00: jump address,   for JMP, JAL instrucion and IF4 state
		//01: ALU Result      for PC+1    JPR and JRL instruction
		//10: ALU Out         for  PC+IMM => For branch inst
		if(state<=`IF4) PCSource=2'b01;
		else if(opcode==15&&(funcode==25||funcode==26)) PCSource=2'b01;
		else if(opcode<=3&&state==`EX2) PCSource=2'b10;
		else if(opcode<=10||opcode>=9) PCSource=2'b00;


		//ALUSrcA: True at ID for ALU calculation of data in resister
		// False for WWD at ID state
		if(state>=`EX2)begin 
			ALUSrcA=1;
		end

		//ALUSrcB: 
		//mux16_4to1 mux_b (ALUSrcB, B, 16'b0000_0000_0000_0001, imm_extend, , alu_op2);
		// 00: take 2nd Resister value: Rtype instruction 
		// 01: For PC+1 => When IF state 
		// 10: For Imm value calculation => For I type instruction
		if(state<=`IF4) ALUSrcB=2'b01;
		else if(state==`ID || state == `EX1) ALUSrcB=2'b10;
		else if(opcode<=8&&opcode>=4)  ALUSrcB=2'b10;
		
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

		//ALUOp
		if(state<=`IF4 && state>=`IF1) ALUOp=`IF_STAGE;
		else if(state==`ID) ALUOp=`ID_STAGE;
		else if(state<=`EX2 && state>=`EX1) ALUOp=`EX_STAGE;
		
		//instExecuted
		if(opcode==15&& funcode==29&&state==`ID) instExecuted = 1;
		else if (opcode == 9 && state == `ID) instExecuted = 1;
		else if(state==`MEM4&&opcode == 8) instExecuted = 1;
		else if(opcode==15 && (funcode==28 || funcode==25) && state==`EX2) instExecuted = 1;
		else if(opcode<=3&&state==`EX2) instExecuted = 1;
		else if(state==`WB) instExecuted = 1;

		//isHalt
		if(state==`HLT) isHalt=1;

		//isWWD
		if(state==`EX2&&opcode==15&&funcode==28) isWWD=1;
	end

	always @(posedge clk) begin // Sequential Logic
		$display ("-- State : %d / inst : %h --", state, inst);
		$display ("-- opcode = %d, funcode = %d --", opcode, funcode);
		if (!reset_n) begin
			state <= `INIT_STATE;
		end
		else begin	
			case (state)
				`ID: begin
					// HLT: Goto HLT
					if (opcode == 15 && funcode == 29) state <= `HLT;

					// JMP: Goto IF1
					if (opcode == 9) begin 
						state <= `IF1;
					end
					// JAL: Goto WB
					else if (opcode == 10) state <= `WB;
					else state <= (state + 1);
				end
				`EX2:
					// WWD & JPR &Bxx: go to IF1
					if ((opcode == 15) && (funcode == 25 || funcode == 28)||opcode <= 3) begin
						state <= `IF1;
					end
					// LWD & SWD: Goto MEM1
					else if (opcode == 7 || opcode == 8) state <= (state + 1);
					else state <= `WB;

				`MEM4:
					// SWD: Goto IF1
					if (opcode == 8) begin
						state <= `IF1;
					end
					else state <= (state + 1);
				`WB: begin
					state <= `IF1;
				end
				`HLT:   // TODO: Do Nothing
					;
				default: state <= (state + 1);
			endcase
		end
	end

endmodule