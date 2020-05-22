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


module ID_EX (clk, reset_n, o_WB, o_M, o_EX, o_regData1, o_regData2, o_immVal, o_wbRegID, o_wd, i_WB, i_M, i_EX, i_regData1, i_regData2, i_immVal, i_wbRegID, i_wd);
	input clk, reset_n;

	output reg [`WB_SIG_COUNT-1:0] o_WB;
	output reg [`M_SIG_COUNT-1:0] o_M;
	output reg [`EX_SIG_COUNT-1:0] o_EX;
	
	output reg [`REG_BITS-1:0] o_wbRegID;
	output reg [`WORD_SIZE-1:0] o_regData1, o_regData2, o_immVal, o_wd;

	input [`WB_SIG_COUNT-1:0] i_WB;
	input [`M_SIG_COUNT-1:0] i_M;
	input [`EX_SIG_COUNT-1:0] i_EX;
	
	input [`REG_BITS-1:0] i_wbRegID;
	input [`WORD_SIZE-1:0] i_regData1, i_regData2, i_immVal, i_wd;

	
	initial begin
		o_WB = 0;
		o_M = 0;
		o_EX = 0;
		o_wbRegID = 0;
		o_regData1 = 0;
		o_regData2 = 0;
		o_immVal = 0;
		o_wd = 0;
	end
	
	always @(posedge clk) begin
		if (!reset_n) begin
			o_WB <= 0;
			o_M <= 0;
			o_EX <= 0;
			o_wbRegID <= 0;
			o_regData1 <= 0;
			o_regData2 <= 0;
			o_immVal <= 0;
			o_wd <= 0;
		end
		else begin
			o_WB <= i_WB;
			o_M <= i_M;
			o_EX <= i_EX;
			o_wbRegID <= i_wbRegID;
			o_regData1 <= i_regData1;
			o_regData2 <= i_regData2;
			o_immVal <= i_immVal;
			o_wd <= i_wd;
		end
	end
endmodule

module EX_MEM (clk, reset_n, o_WB, o_M, o_ALURes, o_ALUOp2, o_wd, i_WB, i_M, i_ALURes, i_ALUOp2, i_wd);
	input clk, reset_n;

	output reg [`WB_SIG_COUNT-1:0] o_WB;
	output reg [`M_SIG_COUNT-1:0] o_M;
	
	output reg [`WORD_SIZE-1:0] o_ALURes, o_ALUOp2, o_wd;

	input [`WB_SIG_COUNT-1:0] i_WB;
	input [`M_SIG_COUNT-1:0] i_M;
	
	input [`WORD_SIZE-1:0] i_ALURes, i_ALUOp2, i_wd;

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

module MEM_WB (clk, reset_n, o_WB, o_Mdata, o_addr, o_wd, i_WB, i_Mdata, i_addr, i_wd);
endmodule
