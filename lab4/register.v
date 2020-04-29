`include "opcodes.v"

module register_cpu (readData1, readData2, readReg1, readReg2, writeReg, writeBack, RegWrite, reset_n, clk);
	output reg [`WORD_SIZE-1:0] readData1, readData2;
	input [1:0] readReg1, readReg2, writeReg;
	input [`WORD_SIZE-1:0] writeBack;
	input RegWrite;
	input reset_n, clk;
	
	reg [`WORD_SIZE-1:0] register [`NUM_REGS-1:0];
	integer i;
	
	initial begin
		for (i = 0; i < `NUM_REGS; i = i+1) begin
			register[i] = 16'b0000_0000_0000_0000;
		end
	end
	always @(*) begin // Register: Combinational Logic
		readData1 = register[readReg1];
		readData2 = register[readReg2];
	end

	always @(posedge clk) begin // Register: Sequential Logic
		if (!reset_n) begin
			for (i = 0; i < `NUM_REGS; i = i+1) register[i] <= 16'b0000_0000_0000_0000;
		end
		else begin
			if (RegWrite == 1) begin
				register[writeReg] <= writeBack;
			end
		end
	end
endmodule
