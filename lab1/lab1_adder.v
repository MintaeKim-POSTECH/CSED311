// lab1_adder.v

// 1bit Adder
// Submodule of sign_adder16

// Output 1: R_cur; calculation result, 1bit binary
// Output 2: C_out; Carry for next position, 1bit binary
// Input 1: A_cur; input, 1bit binary
// Input 2: B_cur; input, 1bit binary
// Input 3: C_in; Carry for current position, 1bit binary

module adder1 (output R_cur, output C_out, 
	input A_cur, input B_cur, input C_in);
	
	assign R_cur = A_cur ^ B_cur ^ C_in;

	// If there are more than two 1s among A_cur, B_cur, and C_in, than C_out would be 1
	wire and_1, and_2, and_3;
	and op_3 (and_1, A_cur, B_cur);
	and op_4 (and_2, A_cur, C_in);
	and op_5 (and_3, B_cur, C_in);

	assign C_out = and_1 | and_2 | and_3;
	
endmodule
