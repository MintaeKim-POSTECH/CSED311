// lab1_demux16.v

// DeMUX (DeMultiplexer) 1-to-16
// Module for Classifying Operations

// Output: x; corresponding data line, 16bit binary
// Input: s; selected input, 4bit binary


module DeMUX_4to16 (output [15:0] x, input [3:0] s);

	// DeMUX Scheme Implementation
	// Reference : https://tibyte.kr/201
	assign x[0] = (~(s[3]) & ~(s[2]) & ~(s[1]) & ~(s[0]));
	assign x[1] = (~(s[3]) & ~(s[2]) & ~(s[1]) & (s[0]));
	assign x[2] = (~(s[3]) & ~(s[2]) & (s[1]) & ~(s[0]));
	assign x[3] = (~(s[3]) & ~(s[2]) & (s[1]) & (s[0]));
	assign x[4] = (~(s[3]) & (s[2]) & ~(s[1]) & ~(s[0]));
	assign x[5] = (~(s[3]) & (s[2]) & ~(s[1]) & (s[0]));
	assign x[6] = (~(s[3]) & (s[2]) & (s[1]) & ~(s[0]));
	assign x[7] = (~(s[3]) & (s[2]) & (s[1]) & (s[0]));
	assign x[8] = ((s[3]) & ~(s[2]) & ~(s[1]) & ~(s[0]));
	assign x[9] = ((s[3]) & ~(s[2]) & ~(s[1]) & (s[0]));
	assign x[10] = ((s[3]) & ~(s[2]) & (s[1]) & ~(s[0]));
	assign x[11] = ((s[3]) & ~(s[2]) & (s[1]) & (s[0]));
	assign x[12] = ((s[3]) & (s[2]) & ~(s[1]) & ~(s[0]));
	assign x[13] = ((s[3]) & (s[2]) & ~(s[1]) & (s[0]));
	assign x[14] = ((s[3]) & (s[2]) & (s[1]) & ~(s[0]));
	assign x[15] = ((s[3]) & (s[2]) & (s[1]) & (s[0]));
	
endmodule
