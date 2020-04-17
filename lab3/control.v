`include "opcodes.v"

module control(inst, isRtype, isLoad, isJtype, isStore, isImmCal, isJAL, isJRL, isJPR);
	input [`WORD_SIZE-1:0]instruction;
	output reg isRtype, isLoad, isJtype, isStore, isImmCal, isJAL, isJRL, isJPR;

	initial begin
		isRtype = 0;
		isLoad = 0;
		isJtype = 0;
		isStore = 0;
		isImmCal = 0;
		isJAL = 0;
		isJRL = 0;
		isJPR = 0;
	end

	reg [3:0]opcode;
	always @(*) begin
		opcode=inst[15:12];
		if(opcode<8)begin
			isImmCal = 1;
			if(opcode==7)begin
				isLoad = 1;
			end
			else if(opcode==8)begin
				isStore = 1;
			end
		end
		else if(opcode==9)begin
			isJype = 1;
		end
		else if(opcode==10)begin
			isJype = 1;
			isJAL = 1;
		end
		else if (opcode==15)begin
			isRtype = 1;
			if(inst[5:0]==25)begin
				isJPR = 1;
			end
			else if(inst[5:0]==26)begin
				isJRL = 1;
			end
		end
	end
endmodule
