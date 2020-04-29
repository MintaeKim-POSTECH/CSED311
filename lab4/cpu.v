`include "opcodes.v" 	   
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
	
	reg[2:0] CS; //current state 
	
	// Data Line Wiring
	reg [`WORD_SIZE-1:0] data_reg;
	wire [`WORD_SIZE-1:0] data_output;

	assign data = readM ? 16'bz:data_output;

	// Parameters
	wire [3:0] opcode;
	wire [5:0] funcode;
	
	reg [`WORD_SIZE-1:0] reg_data1, reg_data2;
	
	wire [`WORD_SIZE-1:0] imm_extend;


	// Module Instantiation & Wire Connection
	// PC
	reg [`WORD_SIZE-1:0] PC;
	wire [`WORD_SIZE-1:0] PC_next, PC_wire_p1;

	adder add_1 (PC, 16'b1, PC_wire_p1);
	
	// Control Unit
	wire RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2;
	control control_unit(data_reg, RegDest, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Reg2Save, PCSrc1, PCSrc2);

	// Register
	wire [1:0] wb_reg_id;
	wire [1:0] rt_vs_rd_id;
	reg [`WORD_SIZE-1:0] register [`NUM_REGS-1:0];
	integer i;
	
	// ALU: R Type
	wire [`WORD_SIZE-1:0] wd_wire;
	// module   register(reset_n, readReg1, readReg2, writeReg, writeBack, RegWrite, readData1, readData2);
	// register reg_cpu (reset_n, data_reg[11:10], data_reg[9:8], wb_reg_id, wd_wire, RegWrite, reg_data1, reg_data2);
	alu_control alu_con (data_reg, opcode, funcode);
	
	// I Type
	wire [`WORD_SIZE-1:0] B;
	imm_generator imm_gen (data_reg[7:0], imm_extend);
	mux mux_imm (ALUSrc, reg_data2, imm_extend, B);

	wire [`WORD_SIZE-1:0] alu_res;
	wire [`WORD_SIZE-1:0] alu_mem_res;
	
	wire PCSrc3_bcond;
	alu alu_1 (opcode, funcode, reg_data1, B, alu_res, PCSrc3_bcond);
	mux mux_load (MemtoReg, alu_res, data_reg, alu_mem_res);
	
	assign address = (CS<=1)?PC:alu_res;
	assign data_output = reg_data2;

	// J Type : JMP & JAL
	wire [`WORD_SIZE-1:0] jmp_addr;
	wire [`WORD_SIZE-1:0] PC_wire_jtype;
	jmp_control jmp_addr_calc (PC, data_reg[11:0], jmp_addr);
	mux mux_j (PCSrc1, PC_wire_p1, jmp_addr, PC_wire_jtype);

	// J Type: JAL & JRL
	mux_2bit mux_wb_target (RegDest, data_reg[9:8], data_reg[7:6], rt_vs_rd_id);
	mux_2bit mux_jal_wb (Reg2Save, rt_vs_rd_id, 2'b10, wb_reg_id);

	mux mux_jal_wd (Reg2Save, alu_mem_res, PC, wd_wire);

	// I Type: JRL & JPR
	wire [`WORD_SIZE-1:0] PC_wire_itype_final;
	mux mux_jrl (PCSrc2, PC_wire_jtype, reg_data1, PC_wire_itype_final);
	
	// I Type: Branch
	wire [`WORD_SIZE-1:0] branch_addr;
	adder add_b (PC_wire_p1, imm_extend, branch_addr);
	mux mux_final (PCSrc3_bcond, PC_wire_itype_final, branch_addr, PC_next);

	initial begin // Initial Logic
		data_reg = 0;
		readM = 1;
		writeM = 0;
		CS = 0;
		PC = -1;
		for (i = 0; i < `NUM_REGS; i = i+1) begin
			register[i] = 16'b0000_0000_0000_0000;
		end
	end

	always @(*) begin // Register: Combinational Logic
		reg_data1 = register[data_reg[11:10]];
		reg_data2 = register[data_reg[9:8]];
	end

	always @(posedge clk) begin // Clock I: IF (Instruction Fetch Stage)
		if (!reset_n) begin
			$display ("Reset Activated");
			for (i = 0; i < `NUM_REGS; i = i+1) register[i] <= 16'b0000_0000_0000_0000;
			data_reg <= 0;
			readM <= 1;
			writeM <= 0;
			PC <= -1;
			CS <= 0;
		end
		else begin
			$display ("Posedge Visited: CS : %d", CS);
			if (RegWrite == 1) begin
				register[wb_reg_id] <= wd_wire;
			end
			PC <= PC_next;
			if(CS==0) begin
				$display ("clk+ - PC: %d / PC_next: %d", PC, PC_next);
				readM <= 1;
				writeM <= 0;
				CS <= 1;
			end 
		end		
	end
	always @(posedge inputReady) begin // ID & EX
		$display ("inputReady Visited: PC: %d / PC_next: %d", PC, PC_next);
		if(CS==1)begin
			data_reg <= data;
			readM <= 0;
			writeM <= 0;
			CS <= 2;
		end
		else if(CS==3) begin
			data_reg <= data;
			readM <= 0;
			writeM <= 0;
			CS <= 0;
		end
	end

	always @(negedge clk) begin // Clock II: MEM (Memory Access Stage)
		$display ("Negedge Visited");
		if(CS==2)begin
			if(MemRead==1)begin
				readM <= 1;
				CS <= 3;
			end
			else if(MemWrite==1)begin
				writeM <= 1;
				CS <= 4;
			end
			else begin
				CS <= 0;
			end
		end
		
	end
	always @(posedge ackOutput) begin // Write Back
		$display ("ackOutput Visited");
		if(CS==4)begin
			readM <= 0;
			writeM <= 0;
			CS <= 0;
		end
	end																																  
endmodule
