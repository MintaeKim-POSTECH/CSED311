`include "opcodes.v"

module register(reset_n, readReg1, readReg2, writeReg, writeBack, RegWrite, readData1, readData2);
	input reset_n;
	input [1:0] readReg1, readReg2, writeReg; // NUM_REG : 4
	input RegWrite; // If needed
	input [`WORD_SIZE-1:0] writeBack;
	output reg [`WORD_SIZE-1:0] readData1, readData2;

	reg [`WORD_SIZE-1:0] register [`NUM_REGS-1:0];
	integer i,j;

	initial begin
		for (i = 0; i < `NUM_REGS; i = i+1) begin
			register[i] = 16'b0000_0000_0000_0000;
		end
	end

	always @(*) begin // Combinational Logic	
		readData1 = register[readReg1];
		readData2 = register[readReg2];
		if (RegWrite == 1) begin
			register[writeReg] = writeBack;
		end
	end

	always @(negedge reset_n) begin // Reset Activated
		for (j = 0; j < `NUM_REGS; j = j+1) register[j] <= 16'b0000_0000_0000_0000;
	end

endmodule 
