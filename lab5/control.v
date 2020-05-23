`include "macro.v"

module control(control_signals, opcode, funcode);
	output reg [`CONT_SIG_COUNT-1:0] control_signals;

	input [`OPCODE_BITS-1:0] opcode;
	input [`FUNCODE_BITS-1:0] funcode;

	initial begin
		control_signals = 0;
	end

	always @(*) begin // Combinational Logic
		control_signals = 0;

		//// WB Stage ////
		// isInst: Always 1
		control_signals[`WB_BASE + `WB_ISINST] = 1;
	
		// isHalt: HLT
		if (opcode == 15 && funcode == 29) control_signals[`WB_BASE + `WB_ISHALT] = 1;

		// isWWD: WWD
		if (opcode == 15 && funcode == 28) control_signals[`WB_BASE + `WB_ISWWD] = 1;

		// RegWrite: True for opcode 4~7, 10~14 and False when inst is HLT, WWD, JPR
		if ((opcode >= 4 && opcode <= 7) || (opcode >= 10 && opcode <= 15)) begin
			if(opcode==15 && (funcode == 25 || funcode == 28 || funcode == 29)) control_signals[`WB_BASE + `WB_REGWRITE] = 0;
			else control_signals[`WB_BASE + `WB_REGWRITE] = 1;
		end

		// MemtoReg: True for Load Instruction
		if (opcode == 7) control_signals[`WB_BASE + `WB_MEMTOREG] = 1;

		// Reg2Save: isJAL || isJRL, 
		// JAL: opcode 10
		// JRL: opcode 15 and function code 26
		if (opcode==10 || (opcode == 15 && funcode == 26)) control_signals[`WB_BASE + `WB_REG2SAVE] = 1;

		
		//// M (MEM) Stage ////
		// MemRead: True for Load Instruction
		if (opcode == 7) control_signals[`M_BASE + `M_MEMREAD] = 1;

		// MemWrite: True for Store Instruction (opcode 8)
		if (opcode == 8) control_signals[`M_BASE + `M_MEMWRITE] = 1;

	
		//// EX Stage ////
		/// ALUOp
		// Opcode
		control_signals[`EX_BASE + `EX_OPCODE : `EX_BASE + `EX_FUNCODE + 1] = opcode;
		// Funcode
		control_signals[`EX_BASE + `EX_FUNCODE : `EX_BASE + `EX_ALUSRC + 1] = funcode;

		// ALUSrc: True when opcode is 4~8 
		if (opcode > 3 && opcode <= 8) control_signals[`EX_BASE + `EX_ALUSRC] = 1;


		//// ID Stage ////
		// PCSrc: TODO: Implement
		control_signals[`ID_BASE + `ID_PCSRC : `ID_BASE + `ID_REGDEST + 1];

		// RegDest: R Type (rd) vs I Type (rt)
		if (opcode==15) control_signals [`ID_BASE + `ID_REGDEST] = 1;

// ---	

/*
		// PCSrc1
		if (opcode==9||opcode==10)begin
			PCSrc1 = 1;
		end

		// PCSrc2: isJRL || isJPR
		// JRL: opcode 15 and function code 26
		// JPR: opcode 15 and function code 25
		if (opcode==15)begin
			if(funcode==25||funcode==26) PCSrc2 = 1;
		end
*/
	end
endmodule
