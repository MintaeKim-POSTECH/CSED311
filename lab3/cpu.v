`include "opcodes.v" 	   
`include "register.v"
`include "alu.v"
`include "mux.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "adder.v"
`include "jmp_control.v"
`include "control.v"

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;

	// Read & Write
	reg readM, writeM;
	
	// Data Line Wiring
	reg [`WORD_SIZE-1:0] data_reg;
	wire [`WORD_SIZE-1:0] data_output;

	assign data = readM ? data_output : 16'bz;

	// Parameters
	wire [3:0] opcode;
	wire [5:0] funcode;
	
	wire [`WORD_SIZE-1:0] rs, rt, rd;
	
	wire [`WORD_SIZE-1:0] imm_extend;


	// Module Instantiation & Wire Connection
	// PC
	wire [`WORD_SIZE-1:0] PC_wire_cur;
	wire [`WORD_SIZE-1:0] PC_wire_next, PC_wire_p1;
	PC pc_cpu (clk, reset_n, PC_wire_next, PC_wire_cur);
	
	//TODO
	//assign address = ;
	adder add_1 (PC_wire_cur, 16'b1, PC_wire_p1);
	
	// Control Unit
	wire RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2;
	control control_unit(data_reg, RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2);

	// Register
	wire [1:0] wb_reg_id;
	wire [1:0] rt_vs_rd_id;
	
	// ALU: R Type
	wire [`WORD_SIZE-1:0] wd_wire;
	register reg_cpu (reset_n, data_reg[11:10], data_reg[9:8], wb_reg_id, wd_wire, RegWrite, rs, rt);
	alu_control alu_con (data_reg, opcode, funcode);
	
	// I Type
	wire [`WORD_SIZE-1:0] B;
	imm_generator imm_gen (data_reg[7:0], imm_extend);
	mux mux_imm (ALUSrc, rt, imm_extend, B);

	wire [`WORD_SIZE-1:0] alu_res;
	wire [`WORD_SIZE-1:0] alu_mem_res;
	
	wire PCSrc3_bcond;
	alu alu_1 (opcode, funcode, rs, B, alu_res, PCSrc3_bcond);
	mux mux_load (MemtoReg, alu_res, data_output, alu_mem_res);

	// J Type : JMP & JAL
	wire [`WORD_SIZE-1:0] jmp_addr;
	wire [`WORD_SIZE-1:0] PC_wire_jtype;
	jmp_control jmp_addr_calc (PC_wire_cur, data_reg[11:0], jmp_addr);
	mux mux_j (PCSrc1, PC_wire_p1, jmp_addr, PC_wire_jtype);

	// J Type: JAL & JRL
	mux_2bit mux_wb_target (RegDest, data_reg[9:8], data_reg[7:6], rt_vs_rd_id);
	mux_2bit mux_jal_wb (Reg2Save, rt_vs_rd_id, 2'b10, wb_reg_id);

	mux mux_jal_wd (Reg2Save, alu_mem_res, PC_wire_cur, wd_wire);

	// I Type: JRL & JPR
	wire [`WORD_SIZE-1:0] PC_wire_itype_final;
	mux mux_jrl (PCSrc2, PC_wire_jtype, rs, PC_wire_itype_final);
	
	// I Type: Branch
	wire [`WORD_SIZE-1:0] branch_addr;
	adder add_b (PC_wire_cur, imm_extend, branch_addr);
	mux mux_final (PCSrc3_bcond, PC_wire_itype_final, branch_addr, PC_wire_next);

	initial begin // Initial Logic
		data_reg = 0;
		readM = 0;
		writeM = 0;
		$display("initial \n");
	end

	always @(posedge clk) begin // Clock I: IF (Instruction Fetch Stage)
		readM <= 1;
		writeM <= 0;
		$display("state1 \n");
	end
	always @(posedge inputReady) begin // ID & EX
		data_reg <= data;
		readM <= 0;
		writeM <= 0;
		$display("state2 \n");
	end

	always @(negedge clk) begin // Clock II: MEM (Memory Access Stage)
		if (MemRead == 0) readM <= 0;
		else readM <= 1;
		if (MemWrite == 0) writeM <= 0;
		else writeM <= 1;
		$display("state2 \n");
	end
	always @(posedge ackOutput) begin // Write Back
		readM <= 0;
		writeM <= 0;
		$display("state2 \n");
	end

	always @(negedge reset_n) begin // Reset Activated
		data_reg <= 0;
		readM <= 0;
		writeM <= 0;
		$display("state2 \n");
	end	
																																			  
endmodule							  																		  