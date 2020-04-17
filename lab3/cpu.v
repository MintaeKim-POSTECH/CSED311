`include "opcodes.v" 	   
`include "register.v"
`include "alu.v"
`include "mux.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "adder.v"
`include "jmp_control.v"

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
	reg [`WORD_SIZE-1:0] data;
	reg readM, writeM;
	
	reg [1:0] CS, NS;	

	wire [5:0] opcode;
	wire [3:0] funcode;
	
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
	// TODO: Control

	// Register
	wire [1:0] wb_reg_id;
	wire [1:0] rt_vs_rd;
	mux mux_wb_target (isRtype, rt, rd, rt_vs_rd);
	
	// ALU: R Type
	wire [`WORD_SIZE-1:0] wd_wire;
	
	register reg_cpu (rs_id, rt_id, wb_reg_id, wd_wire, (not isStore), rs, rt);
	
	alu_control alu_con (data_wire, opcode, funcode);
	
	// I Type
	wire [`WORD_SIZE-1:0] B;
	imm_generator imm_gen (imm, imm_extend);
	mux mux_imm ((isImmCal or isStore), rt, imm_extend, B);

	wire [`WORD_SIZE-1:0] alu_res;
	wire [`WORD_SIZE-1:0] alu_mem_res;
	
	wire bcond;
	alu alu_1 (opcode, funcode, rs, B, alu_res, bcond);
	mux mux_load (isLoadInstruction, alu_res, data_wire, alu_mem_res);

	// J Type : JMP & JAL
	wire [`WORD_SIZE-1:0] jmp_addr;
	wire [`WORD_SIZE-1:0] PC_wire_jtype;
	jmp_control jmp_addr_calc (PC_wire_cur, target, jmp_addr);
	mux mux_j (isJtype, PC_wire_p1, jmp_addr, PC_wire_jtype);

	// J Type: JAL & JRL
	mux mux_jal_wb ((isJAL or isJRL), rt_vs_rd, 2, wb_reg_id);
	mux mux_jal_wd ((isJAL or isJRL), alu_mem_res, PC_wire_cur, wd_wire);

	// I Type: JRL & JPR
	wire [`WORD_SIZE-1:0] PC_wire_itype_final;
	mux mux_jrl ((isJRL or isJPR), PC_wire_jtype, rs, PC_wire_itype_final);
	
	// I Type: Branch
	wire [`WORD_SIZE-1:0] branch_addr;
	adder add_b (PC_wire_cur, imm_extend, branch_addr);
	mux mux_final (bcond, PC_wire_itype_final, branch_addr, PC_wire_next);
	
	initial begin // Initial Logic
		assign data = 16'bz;
		assign PC = 0;
		assign CS = 0;
		assign NS = 0;

		assign readM = 0;
		assign writeM = 0;
	end

	always @(*) begin // Calculation: Combinational Logic
		if (CS == 1) begin // TODO: ID & EX
			if(data[15:12]==15)begin
				
				if(data[5:0]<8)begin
					
				end
			end
			else if(data[15:12]>8)begin
			end
			else begin
			end
		end
		else begin // TODO: MEM (Memory Access Stage)
		end
	end

	always @(posedge inputReady) begin // ID & EX
		readM <= 0;		
		CS <= NS;
	end
	always @(posedge ackOutput) begin // Write Back
		CS <= 0;
		NS <= 0;
		readM <= 0;
		writeM <= 0;
	end

	
	always @(posedge clk) begin // Clock I: IF (Instruction Fetch Stage)
		if (CS == 0 and data == 16'bz) begin
			readM <= 1;
			NS <= 1;
		end
	end
	always @(negedge clk) begin // Clock II: MEM (Memory Access Stage)
		if (NS == 2) begin // Store
			readM <= 0;
			writeM <= 1;
		end
		else if(NS == 3) begin // Load
			readM <= 1;
			writeM <= 0;
		end
	end
	

	always @(negedge reset_n) begin // Reset Activated

	end																																				  
endmodule							  																		  