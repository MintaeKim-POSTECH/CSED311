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
	
	initial begin // Initial Logic
		assign data = 16'bz;
	end

	always (*) begin // Combinational Logic
	end

	always @(posedge clk) begin // Clock I
	end

	always @(negedge clk) begin // Clock II
	end

	always @(negedge reset_n) begin // Reset Activated
	end
																																					  
endmodule							  																		  