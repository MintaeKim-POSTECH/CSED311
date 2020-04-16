`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;

	reg [`WORD_SIZE-1:0] address;
	reg [`WORD_SIZE-1:0] PC;
	reg readM, writeM;
	reg CS, NS; // Keep
	
	initial begin // Initial Logic
		assign data = 16'bz;
		assign PC = 0;
		assign CS = 0;
		assign NS = 0;
	end

	always @(*) begin // Calculation: Combinational Logic
		if (CS == 1) begin // TODO: ID (Instruction Decoding)
			
		end
		else begin // TODO: MEM (Memory Access Stage)
		end
	end

	always @(posedge inputRready) begin // Clock I Starting Point: Combinational Logic
		CS <= NS;
	end
	always @(posedge ackOutput) begin // Clock II Starting Point: Combinational Logic
		CS <= NS;
	end

	
	always @(posedge clk) begin // Clock I
		if (CS == 0) begin
			readM <= 1;
			writeM <= 0;
			NS <= 1;
		end
	end
	always @(negedge clk) begin // Clock II
		if (CS == 1) begin
			readM <= 0;
			writeM <= 1;
			NS <= 0;
		end
	end
	

	always @(negedge reset_n) begin // Reset Activated

	end																																				  
endmodule							  																		  