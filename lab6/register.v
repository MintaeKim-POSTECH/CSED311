`include "macro.v"

module register_cpu (clk, reset_n, RegWrite, readData1, readData2, readReg1, readReg2, writeReg, writeBack);
	input clk, reset_n;
	input RegWrite;

	output reg [`WORD_SIZE-1:0] readData1, readData2;

	input [1:0] readReg1, readReg2, writeReg;
	input [`WORD_SIZE-1:0] writeBack;
	
	
	reg [`WORD_SIZE-1:0] register [`NUM_REGS-1:0];
	integer i;
	
	initial begin
		for (i = 0; i < `NUM_REGS; i = i+1) begin
			register[i] = 16'h0000;
		end
	end
	always @(*) begin // Register: Combinational Logic
		readData1 = register[readReg1];
		readData2 = register[readReg2];
	end

	// Register Write is Proceded in Neg-Edge CLK
	always @(negedge clk) begin // Register: Sequential Logic		
		// $display ("reg : %d %d %d %d", register[0], register[1], register[2], register[3]);
		if (!reset_n) begin
			for (i = 0; i < `NUM_REGS; i = i+1) register[i] <= 16'h0000;
		end
		else begin
			if (RegWrite == 1) begin
				register[writeReg] <= writeBack;
			end
		end
	end
endmodule
