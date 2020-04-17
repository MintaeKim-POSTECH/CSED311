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

	reg [`WORD_SIZE-1:0] data_reg;
	reg readM, writeM;
	
	reg [1:0] CS, NS;	

	wire [3:0] opcode;
	wire [5:0] funcode;
	
	wire [1:0] rs_id = data[11:10];
	wire [1:0] rt_id = data[9:8];
	wire [1:0] rd_id = data[7:6];
	wire [`WORD_SIZE-1:0] rs, rt;
	
	wire [11:0] target = data[11:0];
	
	wire [7:0] imm = data[7:0];
	wire [`WORD_SIZE-1:0] imm_extend;

	wire [`WORD_SIZE-1:0] data_wire;
	assign data_wire = data;

	// Module Instantiation & Wire Connection
	// PC
	wire [`WORD_SIZE-1:0] PC_wire_cur;
	wire [`WORD_SIZE-1:0] PC_wire_next, PC_wire_p1;
	PC pc_cpu (clk, PC_wire_next, PC_wire_cur);

	assign address = PC_wire_cur;
	adder add_1 (PC_wire_cur, 1, PC_wire_p1);
	
	// Control Unit
	wire RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2;
	control control_unit(data_wire, RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2);

	// Register
	wire [1:0] wb_reg_id;
	wire [1:0] rt_vs_rd;
	
	// ALU: R Type
	wire [`WORD_SIZE-1:0] wd_wire;
	register reg_cpu (rs_id, rt_id, wb_reg_id, wd_wire, RegWrite, rs, rt);
	alu_control alu_con (data_wire, opcode, funcode);
	
	// I Type
	wire [`WORD_SIZE-1:0] B;
	imm_generator imm_gen (imm, imm_extend);
	mux mux_imm (ALUSrc, rt, imm_extend, B);

	wire [`WORD_SIZE-1:0] alu_res;
	wire [`WORD_SIZE-1:0] alu_mem_res;
	
	wire PCSrc3_bcond;
	alu alu_1 (opcode, funcode, rs, B, alu_res, PCSrc3_bcond);
	mux mux_load (MemtoReg, alu_res, data_wire, alu_mem_res);

	// J Type : JMP & JAL
	wire [`WORD_SIZE-1:0] jmp_addr;
	wire [`WORD_SIZE-1:0] PC_wire_jtype;
	jmp_control jmp_addr_calc (PC_wire_cur, target, jmp_addr);
	mux mux_j (PCSrc1, PC_wire_p1, jmp_addr, PC_wire_jtype);

	// J Type: JAL & JRL
	mux mux_wb_target (RegDest, rt, rd, rt_vs_rd);
	mux mux_jal_wb (Reg2Save, rt_vs_rd, 2, wb_reg_id);

	mux mux_jal_wd (Reg2Save, alu_mem_res, PC_wire_cur, wd_wire);

	// I Type: JRL & JPR
	wire [`WORD_SIZE-1:0] PC_wire_itype_final;
	mux mux_jrl (PCSrc2, PC_wire_jtype, rs, PC_wire_itype_final);
	
	// I Type: Branch
	wire [`WORD_SIZE-1:0] branch_addr;
	adder add_b (PC_wire_cur, imm_extend, branch_addr);
	mux mux_final (PCSrc3_bcond, PC_wire_itype_final, branch_addr, PC_wire_next);


	reg State;
	

	initial begin // Initial Logic
		assign data_reg = 16'bz;
	end

	always @(posedge inputReady) begin // ID & EX
	end
	always @(posedge ackOutput) begin // Write Back
	end
	
	always @(posedge clk) begin // Clock I: IF (Instruction Fetch Stage)
	end
	always @(negedge clk) begin // Clock II: MEM (Memory Access Stage)
	end	

	always @(negedge reset_n) begin // Reset Activated
	end	
																																			  
endmodule							  																		  