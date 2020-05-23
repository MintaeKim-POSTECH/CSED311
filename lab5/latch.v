`include "macro.v"

module IF_ID (clk, reset_n, IF_flush, hazard, o_pc, o_Idata, i_pc, i_Idata);
	input clk, reset_n, IF_flush, hazard;

	output reg [`WORD_SIZE-1:0] o_pc, o_Idata;
	input [`WORD_SIZE-1:0] i_pc, i_Idata;

	initial begin
		o_pc = 0;
		o_Idata = 0;
	end
	
	always @(posedge clk) begin
		if (!reset_n) begin
			o_pc <= 0;
			o_Idata <= 0;
		end
		// TODO: Check IF_flush & hazard
		else begin
			o_pc <= i_pc;
			o_Idata <= i_Idata;
		end
	end
endmodule


module ID_EX (clk, reset_n, o_WB, o_M, o_EX, o_readData1, o_readData2, o_immVal, o_writeReg, o_pc, i_WB, i_M, i_EX, i_readData1, i_readData2, i_immVal, i_writeReg, i_pc);
	input clk, reset_n;

	output reg [`WB_SIG_COUNT-1:0] o_WB;
	output reg [`M_SIG_COUNT-1:0] o_M;
	output reg [`EX_SIG_COUNT-1:0] o_EX;
	
	output reg [`REG_BITS-1:0] o_writeReg;
	output reg [`WORD_SIZE-1:0] o_readData1, o_readData2, o_immVal, o_pc;

	input [`WB_SIG_COUNT-1:0] i_WB;
	input [`M_SIG_COUNT-1:0] i_M;
	input [`EX_SIG_COUNT-1:0] i_EX;
	
	input [`REG_BITS-1:0] i_writeReg;
	input [`WORD_SIZE-1:0] i_readData1, i_readData2, i_immVal, i_pc;

	
	initial begin
		o_WB = 0;
		o_M = 0;
		o_EX = 0;
		o_writeReg = 0;
		o_readData1 = 0;
		o_readData2 = 0;
		o_immVal = 0;
		o_pc = 0;
	end
	
	always @(posedge clk) begin
		if (!reset_n) begin
			o_WB <= 0;
			o_M <= 0;
			o_EX <= 0;
			o_writeReg <= 0;
			o_readData1 <= 0;
			o_readData2 <= 0;
			o_immVal <= 0;
			o_pc <= 0;
		end
		else begin
			o_WB <= i_WB;
			o_M <= i_M;
			o_EX <= i_EX;
			o_writeReg <= i_writeReg;
			o_readData1 <= i_readData1;
			o_readData2 <= i_readData2;
			o_immVal <= i_immVal;
			o_pc <= i_pc;
		end
	end
endmodule


module EX_MEM (clk, reset_n, o_WB, o_M, o_ALURes, o_writeData, o_writeReg, o_pc, i_WB, i_M, i_ALURes, i_writeData, i_writeReg, i_pc);
	input clk, reset_n;

	output reg [`WB_SIG_COUNT-1:0] o_WB;
	output reg [`M_SIG_COUNT-1:0] o_M;
	output reg [`REG_BITS-1:0] o_writeReg;
	output reg [`WORD_SIZE-1:0] o_ALURes, o_writeData, o_pc;

	input [`WB_SIG_COUNT-1:0] i_WB;
	input [`M_SIG_COUNT-1:0] i_M;
	input [`REG_BITS-1:0] i_writeReg;
	input [`WORD_SIZE-1:0] i_ALURes, i_writeData, i_pc;

	initial begin
		o_WB = 0;
		o_M = 0;
		o_ALURes = 0;
		o_writeData = 0;
		o_writeReg = 0;
		o_pc = 0;
	end
	
	always @(posedge clk) begin
		if (!reset_n) begin
			o_WB <= 0;
			o_M <= 0;
			o_ALURes <= 0;
			o_writeData <= 0;
			o_writeReg <= 0;
			o_pc <= 0;
		end
		else begin
			o_WB <= i_WB;
			o_M <= i_M;
			o_ALURes <= i_ALURes;
			o_writeData <= i_writeData;
			o_writeReg <= i_writeReg;
			o_pc <= i_pc;
		end
	end
endmodule


module MEM_WB (clk, reset_n, o_WB, o_Mdata, o_addr, o_writeReg, o_pc, i_WB, i_Mdata, i_addr, i_writeReg, i_pc);
	input clk, reset_n;

	output reg [`WB_SIG_COUNT-1:0] o_WB;
	output reg [`REG_BITS-1:0] o_writeReg;
	output reg [`WORD_SIZE-1:0] o_Mdata, o_addr, o_pc;

	input [`WB_SIG_COUNT-1:0] i_WB;
	input [`REG_BITS-1:0] i_writeReg;
	input [`WORD_SIZE-1:0] i_Mdata, i_addr, i_pc;

	initial begin
		o_WB = 0;
		o_Mdata = 0;
		o_addr = 0;
		o_writeReg = 0;
		o_pc = 0;
	end
	
	always @(posedge clk) begin
		if (!reset_n) begin
			o_WB <= 0;
			o_Mdata <= 0;
			o_addr <= 0;
			o_writeReg <= 0;
			o_pc <= 0;
		end
		else begin
			o_WB <= i_WB;
			o_Mdata <= i_Mdata;
			o_addr <= i_addr;
			o_writeReg <= i_writeReg;
			o_pc <= i_pc;
		end
	end
endmodule
