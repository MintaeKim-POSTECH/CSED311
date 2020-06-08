`include "macro.v"

// Non-Cache (BaseLine)
module non_cache (clk, reset_n, iReady, dReady, mReadM1, mReadM2, mWriteM2, m_address1, m_address2, m_data1, m_data2, cReadM1, cReadM2, cWriteM2, c_address1, c_address2, c_data1, c_data2);
	
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	// True if iData or dData is ready
	output reg iReady, dReady;

	// Memory Access Address
	input [`WORD_SIZE-1:0] c_address1, c_address2;
	output [`WORD_SIZE-1:0] m_address1, m_address2;

	// Signal
	input wire cReadM1, cReadM2, cWriteM2;
	output wire mReadM1, mReadM2, mWriteM2;
	
	// Data
	output wire [`WORD_SIZE-1:0] c_data1;
	input wire [`WORD_SIZE-1:0] m_data1;

	inout wire [`WORD_SIZE-1:0] c_data2;
	inout wire [`WORD_SIZE-1:0] m_data2;
	
	// Register State
	reg state1, state2;

	// Assign
	assign mReadM1 = cReadM1;
	assign mReadM2 = cReadM2;
	assign mWriteM2 = cWriteM2;

	assign m_address1 = c_address1;
	assign m_address2 = c_address2;

	assign c_data1 = m_data1;
	assign c_data2 = m_data2;

	initial begin
		iReady = 1;
		dReady = 1;

		state1 = 0;
		state2 = 0;
	end

	// Combinational Logic
	always @(*) begin
		if (cReadM1) begin
			if (state1 == 0) begin
				iReady = 0;				
			end
			else if (state1 == `NON_CACHE_LATENCY - 1) begin
				iReady = 1;
			end
		end
		else begin
			iReady = 1;
		end

		if (cReadM2 || cWriteM2) begin
			if (state2 == 0) begin
				dReady = 0;
			end
			else if (state2 == `NON_CACHE_LATENCY - 1) begin
				dReady = 1;
			end
		end
		else begin
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
		$display ("");
		$display ("--=POS-Cache=--");
		$display ("iReady : %d, dReady : %d", iReady, dReady);
		$display ("m_addr1 : %h, mReadM1 : %d, cReadM1 : %d, m_data1 : %h", m_address1, mReadM1, cReadM1, m_data1);
		$display ("m_addr2 : %h, mReadM2 : %d, mWriteM2 : %d, cReadM2 : %d, cWriteM2 : %d, m_data2 : %h, c_data2 : %h", m_address2, mReadM2, mWriteM2, cReadM2, cWriteM2, m_data2, c_data2);
		$display ("state1 : %d, state2 : %d", state1, state2);
		$display ("-=POS-Cache=-");
		$display ("");
	end

	always @(negedge clk) begin
		$display ("");
		$display ("--=Non-Cache=--");
		$display ("iReady : %d, dReady : %d", iReady, dReady);
		$display ("m_addr1 : %h, mReadM1 : %d, cReadM1 : %d, m_data1 : %h", m_address1, mReadM1, cReadM1, m_data1);
		$display ("m_addr2 : %h, mReadM2 : %d, mWriteM2 : %d, cReadM2 : %d, cWriteM2 : %d, m_data2 : %h, c_data2 : %h", m_address2, mReadM2, mWriteM2, cReadM2, cWriteM2, m_data2, c_data2);
		$display ("state1 : %d, state2 : %d", state1, state2);
		$display ("-=Non-Cache=-");
		$display ("");
	end

endmodule


// Way
module way_unit(clk, reset_n, w_valid, w_tag, w_data, w_dirty, wWriteM, w_address, data);
	input clk, reset_n;

	output wire w_valid;
	output wire [`TAG_BITS-1:0] w_tag;
	output wire [`WORD_SIZE-1:0] w_data;
	output wire w_dirty;

	input wWriteM;

	input wire [`WORD_SIZE-1:0] w_address;
	inout wire [`WORD_SIZE-1:0] data;

	reg [`INDEX_PER_CACHE-1:0] valid_arr;
	reg [`TAG_BITS-1:0] tag_arr [`INDEX_PER_CACHE-1:0];
	reg [`WORD_SIZE-1:0] data_arr [`INDEX_PER_CACHE-1:0][`BLOCK_COUNT-1:0];
	reg [`WORD_PER_LINE-1:0] dirty_arr [`INDEX_PER_CACHE-1:0];

	integer i, j;

	// Parse address
	wire [`TAG_BITS-1:0] c_tag;
	wire [`OFFSET_BITS-1:0] c_offset;
	wire c_index;

	assign c_tag = w_address[`WORD_SIZE-1 : `WORD_SIZE-`TAG_BITS];
	assign c_index = w_address[`OFFSET_BITS];
	assign c_offset = w_address[`OFFSET_BITS-1:0];

	// Fetch Cache Data
	assign w_valid = valid_arr[c_index];
	assign w_tag = tag_arr[c_index];
	assign w_data = data_arr[c_index][c_offset];
	assign w_dirty = dirty_arr[c_index][c_offset];

	initial begin
		valid_arr = 0;
		for (i = 0; i < `INDEX_PER_CACHE; i = i + 1) begin
			tag_arr[i] = 0;
			dirty_arr[i] = 0;
			
			for (j = 0; j < `BLOCK_COUNT; j = j + 1) begin
					data_arr[i][j] = 0;
			end
		end
	end

	// Posedge CLK: Update Cache Line
	always @(posedge clk) begin
		if (!reset_n) begin
			valid_arr <= 0;
			for (i = 0; i < `INDEX_PER_CACHE; i = i + 1) begin
				tag_arr[i] <= 0;
				dirty_arr[i] <= 0;
				for (j = 0; j < `BLOCK_COUNT; j = j + 1) begin
					data_arr[i][j] <= 0;
				end
			end
		end
		else begin
			if (wWriteM) begin
				$display ("data_arr[c_index][c_offset] : %h", data_arr[c_index][c_offset]);
				valid_arr[c_index] <= 1;
				tag_arr[c_index] <= c_tag;
				data_arr[c_index][c_offset] <= data;

				if (tag_arr[c_index] == c_tag) dirty_arr[c_index][c_offset] <= 1;
				else dirty_arr[c_index][c_offset] <= 0;
			end
		end
	end

	always @(negedge clk) begin
		$display (" == Neg: Way ==");
		$display ("%h %h %h %h", data_arr[0][0], data_arr[0][1], data_arr[0][2], data_arr[0][3]);
		$display ("%h %h %h %h", data_arr[1][0], data_arr[1][1], data_arr[1][2], data_arr[1][3]);
		$display (" == Neg: Way ==");
	end
	
endmodule

// Cache
module cache_unit(clk, reset_n, ready, mReadM, mWriteM, m_address, m_data, cReadM, cWriteM, c_address, c_data);
	input clk, reset_n;

	output reg ready;

	output reg mReadM, mWriteM;
	input cReadM, cWriteM;

	output reg [`WORD_SIZE-1:0] m_address;
	input wire [`WORD_SIZE-1:0] c_address;

	inout wire [`WORD_SIZE-1:0] m_data;
	inout wire [`WORD_SIZE-1:0] c_data;

	wire [`WORD_SIZE-1:0] data1, data2; // TODO: Assignment

	wire w_valid1, w_valid2;
	wire [`TAG_BITS-1:0] w_tag1, w_tag2;
	wire [`WORD_SIZE-1:0] w_data1, w_data2;
	wire w_dirty1, w_dirty2;

	reg [`WORD_SIZE-1:0] w_address;
	reg wReadM1, wReadM2;
	reg wWriteM1, wWriteM2;

	// Parse address
	wire [`TAG_BITS-1:0] c_tag;
	wire [`OFFSET_BITS-1:0] c_offset;
	wire c_index;

	assign c_tag = c_address[`WORD_SIZE-1 : `WORD_SIZE-`TAG_BITS];
	assign c_index = c_address[`OFFSET_BITS];
	assign c_offset = c_address[`OFFSET_BITS-1:0];

	// Way
	way_unit way1(clk, reset_n, w_valid1, w_tag1, w_data1, w_dirty1, wWriteM1, w_address, data1);
	way_unit way2(clk, reset_n, w_valid2, w_tag2, w_data2, w_dirty2, wWriteM2, w_address, data2);

	// Register
	reg [`INDEX_PER_CACHE-1:0] lru_cache;
	reg cacheMiss, writeWay;

	// State
	reg [`LATENCY_BITS-1:0] state;
	reg state_negedge;

	// Assignment
	assign data1 = ((wReadM1) ? w_data1 : ((mReadM) ? m_data : c_data));
	assign data2 = ((wReadM2) ? w_data2 : ((mReadM) ? m_data : c_data));

	assign c_data = ((cReadM) ? ((writeWay == 0) ? w_data1 : w_data2) : 16'bz);
	assign m_data = ((mReadM) ? 16'bz : ((writeWay == 0) ? w_data1 : w_data2));

	initial begin
		ready = 1;

		wReadM1 = 0;
		wReadM2 = 0;
		wWriteM1 = 0;
		wWriteM2 = 0;
		mReadM = 0;
		mWriteM = 0;

		w_address = 0;
		m_address = 0;
		cacheMiss = 0;
		writeWay = 0;
		
		lru_cache = 0;

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
			ready = 1; // Basically Ready = 1

			w_address = c_address;
			m_address = c_address;
			cacheMiss = 0;
			writeWay = 0;
		end

		// I'll read / write data in the corresponding position.
		if (cReadM == 1 || cWriteM == 1) begin
			// First Entry
			if (cacheMiss == 0) begin
				// Cache Hit
				if (w_valid1 == 1 && w_tag1 == c_tag) begin
					writeWay = 0;
					if (cWriteM == 1) begin
						wWriteM1 = 1;
					end
					else if (cReadM == 1) begin
						wReadM1 = 1;
					end
				end
				else if (w_valid2 == 1 && w_tag2 == c_tag) begin
					writeWay = 1;
					if (cWriteM == 1) begin
						wWriteM2 = 1;
					end
					else if (cReadM == 1) begin
						wReadM2 = 1;
					end
				end

				// Cache Miss
				else begin
					cacheMiss = 1;
					ready = 0;
					// Select Non-Valid Cache,
					// IF there's no Non-Valid Cache, than choose LRU Cache
					if ((w_valid1 == 0 && w_valid2 == 1) || (lru_cache[c_index] == 1)) begin
						writeWay = 0;
					end
					else begin
						writeWay = 1;
					end
				end
			end
			else begin
				// Write-back: Check if corresponding block is dirty
				// Comparison of state (State 1~4)
				if (state < `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 2 && state >= `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - `WORD_PER_LINE - 2) begin
					w_address = (c_address & 16'hfffc) + (state - `CACHE_HIT_LATENCY - `CACHE_MISS_LATENCY + `WORD_PER_LINE + 2);
					
					// Way 1
					if (writeWay == 0) begin
						// Write-back: Check if corresponding block is dirty or not. (Need negedge to fetch new data)
						if (w_dirty1 == 1) begin
							if (state_negedge == 0) begin // Negedge: Cache -> Memory	
								// Write-back: Address
								m_address = {w_tag1, w_address[`OFFSET_BITS+`INDEX_BITS-1:0]};

								// Read from Way 1
								wReadM1 = 1;
								// Write to Main Memory
								mWriteM = 1;
							end
							else begin // Posedge: Cache
								// Fetching New Address
								m_address = w_address;

								// Read from Main Memory
								mReadM = 1;
								// Write to Way 1
								wWriteM1 = 1;
							end
						end
						
						else begin
							// Fetching New Address
							m_address = w_address;

							// Read from Main Memory
							mReadM = 1;
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
								m_address = {w_tag2, w_address[`OFFSET_BITS+`INDEX_BITS-1:0]};

								// Read from Way 2
								wReadM2 = 1;
								// Write to Main Memory
								mWriteM = 1;
							end
							else begin // Posedge: Cache
								// Fetching New Address
								m_address = w_address;

								// Read from Main Memory
								mReadM = 1;
								// Write to Way 2
								wWriteM2 = 1;
							end
						end
						
						else begin
							// Fetching New Address
							m_address = w_address;

							// Read from Main Memory
							mReadM = 1;
							// Write to Way 2
							wWriteM2 = 1;
						end
					end	
				end

				// Updating Information (State 5) (Way is updated in Posedge)
				if (state == `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 2) begin
					w_address = c_address;

					if (cWriteM == 1) begin
						if (writeWay == 0) wWriteM1 = 1;
						else wWriteM2 = 1;
					end
					
					ready = 0;
				end

				// Setting status as ready (State 6)
				if (state == `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 1) begin
					w_address = c_address;

					if (writeWay == 0) wReadM1 = 1;
					else wReadM2 = 1;
					
					ready = 1;
				end
			end
		end
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
			writeWay <= 0;
			w_address <= 0;
			m_address <= 0;
			
			state <= 0;
			state_negedge <= 0;
		end
		else begin
			// Least Recently Used Cache
			if (wWriteM1 == 1 || wReadM1 == 1) begin
				lru_cache[c_index] <= 0;
			end
			else lru_cache[c_index] <= 1;

			// State Transition
			if (cacheMiss == 1) begin
				if (state == `CACHE_HIT_LATENCY + `CACHE_MISS_LATENCY - 1) state <= 0;
				else state <= state + 1;
			end

			state_negedge <= 0;
		end

		$display ("== Posedge ==");
		$display ("c_address : %h, c_data : %h, cReadM : %d, cWriteM : %d", c_address, c_data, cReadM, cWriteM);
		$display ("c_tag : %h, c_index : %d, c_offset : %d", c_tag, c_index, c_offset);
		$display ("m_addrs : %h, m_data : %h, mReadM : %d, mWriteM : %d", m_address, m_data, mReadM, mWriteM);
		$display ("data1 : %h, data2 : %h", data1, data2);
		$display ("----");
		$display ("State: %d, State_Negedge : %d, ready : %d, cacheMiss : %d, writeWay : %d", state, state_negedge, ready, cacheMiss, writeWay);
		$display ("w_addrs : %h, wReadM1 : %d, wWriteM1 : %d, wReadM2 : %d, wWriteM2 : %d", w_address, wReadM1, wWriteM1, wReadM2, wWriteM2);
		$display ("w_valid1 : %b, w_dirty1 : %b, w_tag1 : %h, w_data1 : %h", w_valid1, w_dirty1, w_tag1, w_data1);
		$display ("w_valid2 : %b, w_dirty2 : %b, w_tag2 : %h, w_data2 : %h", w_valid2, w_dirty2, w_tag2, w_data2);
		$display ("== Posedge ==");
		$display ("");
	end

	always @(negedge clk) begin
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
			writeWay <= 0;
			w_address <= 0;
			m_address <= 0;
			
			state <= 0;
			state_negedge <= 0;
		end
		else state_negedge <= 1;

		$display ("== Negedge ==");
		$display ("c_address : %h, c_data : %h, cReadM : %d, cWriteM : %d", c_address, c_data, cReadM, cWriteM);
		$display ("c_tag : %h, c_index : %d, c_offset : %d", c_tag, c_index, c_offset);
		$display ("m_addrs : %h, m_data : %h, mReadM : %d, mWriteM : %d", m_address, m_data, mReadM, mWriteM);
		$display ("data1 : %h, data2 : %h", data1, data2);
		$display ("----");
		$display ("State: %d, State_Negedge : %d, ready : %d, cacheMiss : %d, writeWay : %d", state, state_negedge, ready, cacheMiss, writeWay);
		$display ("w_addrs : %h, wReadM1 : %d, wWriteM1 : %d, wReadM2 : %d, wWriteM2 : %d", w_address, wReadM1, wWriteM1, wReadM2, wWriteM2);
		$display ("w_valid1 : %b, w_dirty1 : %b, w_tag1 : %h, w_data1 : %h", w_valid1, w_dirty1, w_tag1, w_data1);
		$display ("w_valid2 : %b, w_dirty2 : %b, w_tag2 : %h, w_data2 : %h", w_valid2, w_dirty2, w_tag2, w_data2);
		$display ("== Negedge ==");
		$display ("");
	end

endmodule

module cache (clk, reset_n, iReady, dReady, mReadM1, mReadM2, mWriteM2, m_address1, m_address2, m_data1, m_data2, cReadM1, cReadM2, cWriteM2, c_address1, c_address2, c_data1, c_data2);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	// True if iData or dData is ready
	output wire iReady, dReady;

	// Memory Access Address
	input [`WORD_SIZE-1:0] c_address1, c_address2;
	output [`WORD_SIZE-1:0] m_address1, m_address2;

	// Signal
	input wire cReadM1, cReadM2, cWriteM2;
	output wire mReadM1, mReadM2, mWriteM2;
	
	// Data
	output wire [`WORD_SIZE-1:0] c_data1;
	input wire [`WORD_SIZE-1:0] m_data1;

	inout wire [`WORD_SIZE-1:0] c_data2;
	inout wire [`WORD_SIZE-1:0] m_data2;

	
	// cache_unit(clk, reset_n, ready, mReadM, mWriteM, m_address, cReadM, cWriteM, address, data)
	// Cache Modules
	cache_unit iCache(clk, reset_n, iReady, mReadM1,         , m_address1, m_data1, cReadM1,     1'b0, c_address1, c_data1);
	cache_unit dCache(clk, reset_n, dReady, mReadM2, mWriteM2, m_address2, m_data2, cReadM2, cWriteM2, c_address2, c_data2);
	/*
	always @(negedge clk) begin
		$display ("=Cache=");
		$display ("PC_M : %h, writeReg_M : %d", PC_M, writeReg_M);
		$display ("readM2 : %b, writeM2 : %b, writeData_latch : %h", readM2, writeM2, writeData_latch);
		$display ("M_address : %h, M_Mdata : %h", address2, data2);
	end
	*/
endmodule
