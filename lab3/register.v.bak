`include "opcodes.v"

module register(readReg1, readReg2, writeReg, writeBack, RegWrite, readData1, readData2);
	input [1:0] readReg1, readReg2, writeReg; // NUM_REG : 4
	input RegWrite; // If needed
	input [`WORD_SIZE-1:0] writeBack;
	output reg [`WORD_SIZE-1:0] readData1, readData2;

	reg [`WORD_SIZE-1:0] register [`NUM_REGS-1:0];

	always @(*) begin // Combinational Logic	
		readData1 = register[readReg1];
		readData2 = register[readReg2];
	end

	always @(posedge RegWrite) begin // Write-Back
		register[writeReg] <= writeBack;
	end
endmodule 
