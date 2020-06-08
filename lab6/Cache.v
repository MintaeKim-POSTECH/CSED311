`include "macro.v"

// Non-Cache (BaseLine)
module non_cache(clk, reset_n, iReady, dReady, m_address1, mReadM1, cReadM1, address1, data1, m_address2, mReadM2, mWriteM2, cReadM2, cWriteM2, address2, data2);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	// True if iData or dData is ready
	output reg iReady, dReady;

	// Memory Access Address
	output [`WORD_SIZE-1:0] m_address1, m_address2;

	// Memory mReadM1, mReadM2, mWriteM2
	output reg mReadM1, mReadM2, mWriteM2;
	
	// Cache
	input wire cReadM1, cReadM2, cWriteM2;
	
	
	input [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	output data1;
	wire [`WORD_SIZE-1:0] data1;

	input [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;
	inout data2;
	wire [`WORD_SIZE-1:0] data2;
	
	// Register State
	reg state1, state2;

	// Assign
	assign m_address1 = address1;
	assign m_address2 = address2;

	initial begin
		iReady = 1;
		dReady = 1;
		mReadM1 = 0;
		mReadM2 = 0;
		mWriteM2 = 0;

		state1 = 0;
		state2 = 0;
	end

	// Combinational Logic
	always @(*) begin
		if (cReadM1) begin
			if (state1 == 0) begin
				mReadM1 = 0;
				iReady = 0;				
			end
			else if (state1 == `NON_CACHE_LATENCY - 1) begin
				mReadM1 = cReadM1;
				iReady = 1;
			end
		end
		else begin
			mReadM1 = 0;
			iReady = 1;
		end

		if (cReadM2 || cWriteM2) begin
			if (state2 == 0) begin
				mReadM2 = 0;
				mWriteM2 = 0;
				dReady = 0;
			end
			else if (state2 == `NON_CACHE_LATENCY - 1) begin
				mReadM2 = cReadM2;
				mWriteM2 = cWriteM2;
				dReady = 1;
			end
		end
		else begin
			mReadM2 = 0;
			mWriteM2 = 0;
			dReady = 1;
		end
	end

	// Sequential logic
	always @(posedge clk) begin
		if (!reset_n) begin
			state1 <= 0;
			state2 <= 0;
		end
		else begin
			if (state1 == `NON_CACHE_LATENCY - 1) begin
				state1 <= 0;
			end
			else begin
				if (cReadM1 == 1) 
					state1 <= state1 + 1;
			end
			if (state2 == `NON_CACHE_LATENCY - 1) begin
				state2 <= 0;
			end
			else begin
				if (cReadM2 == 1 || cWriteM2 == 1)
					state2 <= state2 + 1;
			end
		end
	end

	always @(negedge clk) begin
		/*
		$display ("");
		$display ("--=Non-Cache=--");
		$display ("iReady : %d, dReady : %d", iReady, dReady);
		$display ("m_addr1 : %h, mReadM1 : %d, cReadM1 : %d, addr1 : %h, data1 : %h", m_address1, mReadM1, cReadM1, address1, data1);
		$display ("m_addr2 : %h, mReadM2 : %d, mWriteM2 : %d, cReadM2 : %d, cWriteM2, addr1 : %h, data2 : %h", m_address2, mReadM2, mWriteM2, cReadM2, cWriteM2, address2, data2);
		$display ("state1 : %d, state2 : %d", state1, state2);
		$display ("-=Non-Cache=-");
		$display ("");
		*/
	end

endmodule


// Way
module way_unit(clk, reset_n, w_valid, w_tag, w_data, w_dirty, wWriteM, address, data);
	input clk, reset_n;

	output wire w_valid;
	output wire [`TAG_BITS-1:0] w_tag;
	output wire [`TAG_BITS-1:0] w_data;
	output wire w_dirty;

	input wWriteM;

	input wire [`WORD_SIZE-1:0] address;
	inout wire [`WORD_SIZE-1:0] data;

	reg [`INDEX_PER_CACHE-1:0] valid_arr;
	reg [`INDEX_PER_CACHE-1:0] tag_arr [`TAG_BITS-1:0];
	reg [`INDEX_PER_CACHE-1:0] data_arr [`DATA_BITS-1:0];
	reg [`INDEX_PER_CACHE-1:0] dirty_arr [`WORD_PER_LINE-1:0];

	integer i;

	// Parse address
	wire [`TAG_BITS-1:0] c_tag;
	wire [`OFFSET_BITS-1:0] c_offset;
	wire c_index;

	assign c_tag = address[`WORD_SIZE-1 : `WORD_SIZE-`TAG_BITS];
	assign c_index = address[`OFFSET_BITS];
	assign c_offset = address[`OFFSET_BITS-1:0];

	// Fetch Cache Data
	assign w_valid = valid_arr[c_index];
	assign w_tag = tag_arr[c_index];
	assign w_data = data_arr[c_index][c_offset*`WORD_SIZE +: `WORD_SIZE];
	assign w_dirty = dirty_arr[c_index][c_offset];

	initial begin
		valid_arr = 0;
		for (i = 0; i < `INDEX_PER_CACHE; i = i + 1) begin
			tag_arr[i] = 0;
			data_arr[i] = 0;
			dirty_arr[i] = 0;
		end
	end

	// Posedge CLK: Update Cache Line
	always @(posedge clk) begin
		if (!reset_n) begin
			valid_arr <= 0;
			for (i = 0; i < `INDEX_PER_CACHE; i = i + 1) begin
				tag_arr[i] <= 0;
				data_arr[i] <= 0;
				dirty_arr[i] <= 0;
			end
		end
		else begin
			if (wWriteM) begin
				valid_arr[c_index] <= 1;
				tag_arr[c_index] <= c_tag;
				data_arr[c_index][c_offset*`WORD_SIZE +: `WORD_SIZE] <= data;
				dirty_arr[c_index][c_offset] <= 1;
			end
		end
	end
	
endmodule

// Cache
module cache_unit(clk, reset_n, ready, mReadM, mWriteM, m_address, cReadM, cWriteM, address, data);
	input clk, reset_n;

	output reg ready;

	output reg mReadM, mWriteM;
	output reg [`WORD_SIZE-1:0] m_address;

	input cReadM, cWriteM;

	input wire [`WORD_SIZE-1:0] address;
	inout wire [`WORD_SIZE-1:0] data;

	wire w_valid1, w_valid2;
	wire [`TAG_BITS-1:0] w_tag1, w_tag2;
	wire [`WORD_SIZE-1:0] w_data1, w_data2;
	wire w_dirty1, w_dirty2;

	reg wReadM1, wReadM2;
	reg wWriteM1, wWriteM2;

	// Parse address
	wire [`TAG_BITS-1:0] c_tag;
	wire [`OFFSET_BITS-1:0] c_offset;
	wire c_index;

	assign c_tag = address[`WORD_SIZE-1 : `WORD_SIZE-`TAG_BITS];
	assign c_index = address[`OFFSET_BITS];
	assign c_offset = address[`OFFSET_BITS-1:0];

	// Way
	way_unit way1(clk, reset_n, w_valid1, w_tag1, w_data1, w_dirty1, wWriteM1, m_address, data);
	way_unit way2(clk, reset_n, w_valid2, w_tag2, w_data2, w_dirty2, wWriteM2, m_address, data);

	// Register
	reg [`INDEX_PER_CACHE-1:0] lru_cache;
	reg cacheMiss, evictCache;

	// State
	reg [`LATENCY_BITS-1:0] state;
	reg state_negedge;

	// Assignment
	assign data = ((wReadM1) ? w_data1 : ((wReadM2) ? w_data2 : 16'bz));

	initial begin
		ready = 1;

		wReadM1 = 0;
		wReadM2 = 0;
		wWriteM1 = 0;
		wWriteM2 = 0;
		mReadM = 0;
		mWriteM = 0;

		lru_cache = 0;
		cacheMiss = 0;
		evictCache = 0;

		state = 0;
		state_negedge = 0;
	end

	always @(*) begin
		wReadM1 = 0;
		wReadM2 = 0;
		wWriteM1 = 0;
		wWriteM2 = 0;
		mReadM = 0;
		mWriteM = 0;

		if (state == 0) begin
			m_address = address;
			cacheMiss = 0;
			evictCache = 0;
			ready = 1;
		end

		// I'll read / write data in the corresponding position.
		if (cReadM == 1 || cWriteM == 1) begin
			if (cacheMiss == 0) begin
				// Cache Hit
				if (w_valid1 == 1 && w_tag1 == c_tag) begin
					if (cWriteM == 1) begin
						wWriteM1 = 1;
					end
					else if (cReadM == 1) begin
						wReadM1 = 1;
					end
					ready = 1;
				end
				else if (w_valid2 == 1 && w_tag2 == c_tag) begin
					if (cWriteM == 1) begin
						wWriteM2 = 1;
					end
					else if (cReadM == 1) begin
						wReadM2 = 1;
					end
					ready = 1;
				end

				// Cache Miss
				else begin
					cacheMiss = 1;
					
					// Select Non-Valid Cache,
					// IF there's no Non-Valid Cache, than choose LRU Cache
					if ((w_valid1 == 0 && w_valid2 == 1) || (lru_cache[c_index] == 1)) begin
						evictCache = 0;
					end
					else begin
						evictCache = 1;
					end
				end
			end
			else begin
				// Write-back: Check if corresponding block is dirty
				// Comparison of state (State 2~5)
				if (state < `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 1 && state >= `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - `WORD_PER_LINE - 1) begin
					m_address = (address & 16'hfffc) + (state - `CACHE_HIT_LATENCY - `CACHE_MISS_LATENCY + `WORD_PER_LINE - 1);
					
					// Way 1
					if (evictCache == 0) begin
						// Write-back: Check if corresponding block is dirty or not. (Need negedge to fetch new data)
						if (w_dirty1 == 1) begin
							if (state_negedge == 0) begin // Negedge: Cache -> Memory	
								// Write-back: Address
								m_address = {w_tag1, m_address[`OFFSET_BITS+`INDEX_BITS-1:0]};

								// Read from Way 1
								wReadM1 = 1;
								// Write to Main Memory
								mWriteM = 1;
							end
							else begin // Posedge: Cache
								// Write to Way 1
								wWriteM1 = 1;
							end
						end
						
						else begin
							// Write to Way 1
							wWriteM1 = 1;
						end
					end
					
					// Way 2
					else begin
						// Write-back: Check if corresponding block is dirty or not. (Need negedge to fetch new data)
						if (w_dirty2 == 1) begin
							if (state_negedge == 0) begin // Negedge: Cache -> Memory
								// Write-back: Address
								m_address = {w_tag2, m_address[`OFFSET_BITS+`INDEX_BITS-1:0]};

								// Read from Way 2
								wReadM2 = 1;
								// Write to Main Memory
								mWriteM = 1;
							end
							else begin // Posedge: Cache
								// Write to Way 2
								wWriteM2 = 1;
							end
						end
						
						else begin
							// Write to Way 2
							wWriteM1 = 2;
						end
					end	
				end
				
				// Setting status as ready (State 6)
				if (state == `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 1) ready = 1;
			end
		end
		else ready = 1;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			ready <= 1;

			wReadM1 <= 0;
			wReadM2 <= 0;
			wWriteM1 <= 0;
			wWriteM2 <= 0;
			mReadM <= 0;
			mWriteM <= 0;

			lru_cache <= 0;
			cacheMiss <= 0;
			evictCache <= 0;
			
			state <= 0;
		end
		else begin
			// Least Recently Used Cache
			if (wWriteM1 == 1) begin
				lru_cache[c_index] <= 0;
			end
			else lru_cache[c_index] <= 1;

			// State Transition
			if (cacheMiss) begin
				if (state == `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 1) state <= 0;
				else state <= state + 1;
			end

			state_negedge <= 0;
		end
	end

	always @(negedge clk) begin
		state_negedge <= 1;
	end

endmodule


module cache(clk, reset_n, iReady, dReady, m_address1, mReadM1, cReadM1, address1, data1, m_address2, mReadM2, mWriteM2, cReadM2, cWriteM2, address2, data2);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	// True if iData or dData is ready
	output wire iReady, dReady;

	// Memory mReadM1, mReadM2, mWriteM2
	output wire mReadM1, mReadM2, mWriteM2;

	// Cache
	input wire cReadM1, cReadM2, cWriteM2;
	
	// Memory Access Address
	output wire [`WORD_SIZE-1:0] m_address1, m_address2;

	input [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	output data1;
	wire [`WORD_SIZE-1:0] data1;

	input [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;
	inout data2;
	wire [`WORD_SIZE-1:0] data2;
	
	// cache_unit(clk, reset_n, ready, mReadM, mWriteM, m_address, cReadM, cWriteM, address, data)
	// Cache Modules
	cache_unit iCache(clk, reset_n, iReady, mReadM1,         , m_address1, cReadM1,         , address1, data1);
	cache_unit dCache(clk, reset_n, dReady, mReadM2, mWriteM2, m_address2, cReadM2, cWriteM2, address2, data2);

	/*
	always @(negedge clk) begin
		$display ("=Cache=");
		$display ("PC_M : %h, writeReg_M : %d", PC_M, writeReg_M);
		$display ("readM2 : %b, writeM2 : %b, writeData_latch : %h", readM2, writeM2, writeData_latch);
		$display ("M_address : %h, M_Mdata : %h", address2, data2);
	end
	*/

endmodule
