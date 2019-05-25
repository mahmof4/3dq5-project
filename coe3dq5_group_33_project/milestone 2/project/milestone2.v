/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

/////////////////////////////////////////////////////////////////////////////////////
/////////////////// MILESTONE 2 CODE - ONLY RUNS FOR ONE BLOCK //////////////////////
/////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module milestone2 (
		input logic Clock,
		input logic Resetn,
		input logic milestone2_start,
		input logic [15:0] SRAM_read_data,
		output logic [15:0] SRAM_write_data,
		output logic [17:0] SRAM_address,
		output logic SRAM_we_n,
		output logic milestone2_done
);

M2_state_type top_state;

// always_comb
logic signed [31:0] multiplier_1;
logic signed [31:0] multiplier_2;
logic signed [31:0] multiplier_3;
logic signed [31:0] multiplier_4;

logic signed [63:0] multiplier_1S;
logic signed [63:0] multiplier_2S;
logic signed [63:0] multiplier_3S;
logic signed [63:0] multiplier_4S;

logic signed [31:0] MAC1;
logic signed [31:0] MAC2;
logic signed [31:0] MAC3;
logic signed [31:0] MAC4;

logic signed [7:0] MAC1S;
logic signed [7:0] MAC2S;
logic signed [7:0] MAC3S;
logic signed [7:0] MAC4S;

// always_ff
logic [2:0] compute_t_counter;
logic compute_t_flag;
logic [2:0] compute_s_counter;

logic [5:0] Sprime_counter;
logic [2:0] column_counter;
logic [2:0] row_counter;
logic [7:0] C_even_counter;
logic [7:0] C_odd_counter;
logic [7:0] S_counter;

logic signed [63:0] multiplier_1_buf;
logic signed [63:0] multiplier_2_buf;
logic signed [63:0] multiplier_3_buf;
logic signed [63:0] multiplier_4_buf;

logic signed [31:0] mult3_buf;
logic signed [31:0] mult4_buf;

logic [2:0] Sprime_column_counter;
logic [2:0] Sprime_row_counter;
logic Sprime_flag;

logic [2:0] even_column_counter;
logic [2:0] odd_column_counter;

logic [2:0] T_row_counter;
logic [2:0] T_column_counter;
logic T_flag;
logic [2:0] S_even_row_counter;
logic [2:0] S_odd_row_counter;

logic [7:0] S_even_address_counter;
logic [7:0] S_odd_address_counter;

logic signed [7:0] S_buf1;
logic signed [7:0] S_buf2;
logic signed [7:0] S_buf3;
logic signed [7:0] S_buf4;
logic signed [7:0] S_buf5;
logic signed [7:0] S_buf6;
logic signed [7:0] S_buf7;
logic signed [7:0] S_buf8;

logic odd_flag;
logic [2:0] SRAM_column_counter;
logic [2:0] SRAM_even_row_counter;
logic [2:0] SRAM_odd_row_counter;

/////////////////////////////////////////////////////////////////////////////////////

logic [6:0] address_Sprime;
logic signed [31:0] write_data_Sprime;
logic signed [31:0] read_data_Sprime;
logic write_enable_Sprime;

logic [6:0] address_S;
logic signed [31:0] write_data_S;
logic signed [31:0] read_data_S;
logic write_enable_S;

/////////////////////////////////////////////////////////////////////////////////////

logic [6:0] address_T_even;
logic [6:0] address_T_odd;
logic signed [31:0] write_data_T1;
logic signed [31:0] write_data_T2;
logic signed [31:0] read_data_T1;
logic signed [31:0] read_data_T2;
logic write_enable_T;
//logic [31:0] read_data_T ;

/////////////////////////////////////////////////////////////////////////////////////

logic [6:0] address_C_even;
logic [6:0] address_C_odd;
logic signed [31:0] read_data_C_even;
logic signed [31:0] read_data_C_odd;

/////////////////////////////////////////////////////////////////////////////////////

//Store S' and C
dual_port_RAM0 dual_port_RAM_inst0 ( 
	.address_a ( address_Sprime ), //Address
	.address_b ( address_S ),
	.clock ( Clock ),
	.data_a ( write_data_Sprime ), //Write data
	.data_b ( write_data_S ),
	.wren_a ( write_enable_Sprime ), //Write enable
	.wren_b ( write_enable_S  ),
	.q_a ( read_data_Sprime ), //Read data
	.q_b ( read_data_S )
	);

//Store T = CS'
dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_T_even ), //Address
	.address_b ( address_T_odd ),
	.clock ( Clock ),
	.data_a ( write_data_T1 ), //Write data
	.data_b ( write_data_T2 ),
	.wren_a ( write_enable_T ), //Write enable
	.wren_b ( write_enable_T ),
	.q_a ( read_data_T1 ), //Read data
	.q_b ( read_data_T2 )
	);

//Store C
dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a ( address_C_even ), //Address
	.address_b ( address_C_odd ),
	.clock ( Clock ),
	.data_a ( 32'h00 ), //Write data
	.data_b ( 32'h00 ),
	.wren_a ( 1'b0 ), //Write enable
	.wren_b ( 1'b0 ),
	.q_a ( read_data_C_even ), //Read data
	.q_b ( read_data_C_odd )
	);

/////////////////////////////////////////////////////////////////////////////////////
// always_comb block for addresses of DP RAMs and SRAM

always_comb begin
	SRAM_address = 'b0;
	address_C_even = 'b0;
	address_C_odd = 'b1;
	address_Sprime = 'b0;
	address_T_even = 'b0;
	address_T_odd = 'b1;
	address_S = 'b0;
	
	case (top_state)
	
		//S_FETCH_SPRIME_0: SRAM_address = 32'd76800 + (18'd320 * row_counter + column_counter);
		S_FETCH_SPRIME_0: SRAM_address = 32'd76800 + (row_counter << 8) + (row_counter << 6) + column_counter;
		
		S_FETCH_SPRIME_1: SRAM_address = 32'd76800 + (row_counter << 8) + (row_counter << 6) + column_counter;
		
		S_FETCH_SPRIME_2: begin
			address_Sprime = Sprime_counter;
			SRAM_address = 32'd76800 + (row_counter << 8) + (row_counter << 6) + column_counter;
		end
		
		S_FETCH_SPRIME_3: begin
			address_Sprime = Sprime_counter;
		end
		
		S_FETCH_SPRIME_4: begin
			address_Sprime = Sprime_counter;
		end
							
		S_COMPUTE_T_0: begin
		
			//address_Sprime = 18'd8 * Sprime_row_counter + Sprime_column_counter;
			address_Sprime = {Sprime_row_counter, Sprime_column_counter};
			
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_COMPUTE_T_1: begin
			
			//address_T_even = 18'd8 * T_row_counter + even_column_counter;
			//address_T_odd = 18'd8 * T_row_counter + odd_column_counter;
			
			address_T_even = {T_row_counter, even_column_counter};
			address_T_odd = {T_row_counter, odd_column_counter};
			
			//address_Sprime = 18'd8 * Sprime_row_counter + Sprime_column_counter;
			address_Sprime = {Sprime_row_counter, Sprime_column_counter};
			
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_COMPUTE_T_2: begin
		
			//address_T_even = 18'd8 * T_row_counter + even_column_counter;
			//address_T_odd = 18'd8 * T_row_counter + odd_column_counter;
			
			address_T_even = {T_row_counter, even_column_counter};
			address_T_odd = {T_row_counter, odd_column_counter};
			
			//address_Sprime = 18'd8 * Sprime_row_counter + Sprime_column_counter;
			address_Sprime = {Sprime_row_counter, Sprime_column_counter};
			
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_COMPUTE_T_3: begin
		
			//address_T_even = 18'd8 * T_row_counter + even_column_counter;
			//address_T_odd = 18'd8 * T_row_counter + odd_column_counter;
			
			address_T_even = {T_row_counter, even_column_counter};
			address_T_odd = {T_row_counter, odd_column_counter};
			
		end
		
		S_COMPUTE_S_0: begin
			
			//address_T_even = 18'd8 * T_row_counter + T_column_counter;
			
			address_T_even = {T_row_counter, T_column_counter};
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_COMPUTE_S_1: begin
			
			//address_T_even = 18'd8 * T_row_counter + T_column_counter;
			
			address_T_even = {T_row_counter, T_column_counter};
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_COMPUTE_S_2: begin
			
			//address_T_even = 18'd8 * T_row_counter + T_column_counter;
			
			address_T_even = {T_row_counter, T_column_counter};
			address_S = 18'd64 + S_counter;
			address_C_even = C_even_counter;
			address_C_odd = C_odd_counter;
			
		end
		
		S_WRITE_S_0: begin
			
			if (odd_flag) address_S = 18'd64 + S_odd_address_counter;
			else address_S = 18'd64 + S_even_address_counter;
			
		end
		
		S_WRITE_S_1: begin
		
			if (odd_flag) address_S = 18'd64 + S_odd_address_counter;
			else address_S = 18'd64 + S_even_address_counter;
			
		end
		
		S_WRITE_S_2: begin
			 
			/* 
			if (odd_flag) begin
				SRAM_address = 18'd640 + 18'd160 * SRAM_odd_row_counter + SRAM_column_counter;
			end else begin
				SRAM_address = 18'd160 * SRAM_even_row_counter + SRAM_column_counter;
			end 
			*/
		
			if (odd_flag) begin
				SRAM_address = 18'd640 + (SRAM_odd_row_counter << 7) + (SRAM_odd_row_counter << 5) + SRAM_column_counter;
			end else begin
				SRAM_address = (SRAM_even_row_counter << 7) + (SRAM_even_row_counter << 5) + SRAM_column_counter;
			end
		
		end
		
		S_WRITE_S_3: begin
		
			if (odd_flag) begin
				SRAM_address = 18'd640 + (SRAM_odd_row_counter << 7) + (SRAM_odd_row_counter << 5) + SRAM_column_counter;
			end else begin
				SRAM_address = (SRAM_even_row_counter << 7) + (SRAM_even_row_counter << 5) + SRAM_column_counter;
			end
		
		end
		
		S_WRITE_S_4: begin
		
			if (odd_flag) begin
				SRAM_address = 18'd640 + (SRAM_odd_row_counter << 7) + (SRAM_odd_row_counter << 5) + SRAM_column_counter;
			end else begin
				SRAM_address = (SRAM_even_row_counter << 7) + (SRAM_even_row_counter << 5) + SRAM_column_counter;
			end
		
		end
		
		S_WRITE_S_5: begin
		
			if (odd_flag) begin
				SRAM_address = 18'd640 + (SRAM_odd_row_counter << 7) + (SRAM_odd_row_counter << 5) + SRAM_column_counter;
			end else begin
				SRAM_address = (SRAM_even_row_counter << 7) + (SRAM_even_row_counter << 5) + SRAM_column_counter;
			end
		
		end
		
	endcase
end

/////////////////////////////////////////////////////////////////////////////////////
// always_comb block for writing and reading values from DP RAMs and SRAM

always_comb begin
	
	multiplier_1 = 'b0;
	multiplier_2 = 'b0;
	multiplier_3 = 'b0;
	multiplier_4 = 'b0;
	
	multiplier_1S = 'b0;
	multiplier_2S = 'b0;
	multiplier_3S = 'b0;
	multiplier_4S = 'b0;
	
	SRAM_we_n = 'b1;
	write_enable_Sprime = 'b0;
	write_enable_T = 'b0;
	write_enable_S = 'b0;
	write_data_Sprime = 'b0;
	write_data_T1 = 'b0;
	write_data_T2 = 'b0;
	write_data_S = 'b0;
	SRAM_write_data = 'b0;
	
	MAC1 = 'b0;
	MAC2 = 'b0;
	MAC3 = 'b0;
	MAC4 = 'b0;
	
	MAC1S = 'b0;
	MAC2S = 'b0;
	MAC3S = 'b0;
	MAC4S = 'b0;
	
	case (top_state)
	
		S_FETCH_SPRIME_2: begin
			
			write_enable_Sprime = 1'b0;
			
			if (Sprime_counter < 9'd62) begin
				write_enable_Sprime = 1'b1;
				write_data_Sprime = $signed(SRAM_read_data);
			end
			
		end
		
		S_FETCH_SPRIME_3: begin
			
			write_enable_Sprime = 1'b1;
			write_data_Sprime = $signed(SRAM_read_data);
			
		end
		
		S_FETCH_SPRIME_4: begin
			
			write_enable_Sprime = 1'b1;
			write_data_Sprime = $signed(SRAM_read_data);
			
		end
		
		S_COMPUTE_T_1: begin

			multiplier_1 = read_data_Sprime * $signed(read_data_C_even [31:16]);
			multiplier_2 = read_data_Sprime * $signed(read_data_C_even [15:0]);
			multiplier_3 = read_data_Sprime * $signed(read_data_C_odd [31:16]);
			multiplier_4 = read_data_Sprime * $signed(read_data_C_odd [15:0]);
			
			MAC3 = $signed(mult3_buf)>>>8;
			MAC4 = $signed(mult4_buf)>>>8;
			
			if (compute_t_counter == 9'd0 && compute_t_flag) begin
			
				write_enable_T = 1'b1;
				// Writing to even addresses 
				write_data_T1 = MAC3;
				// Writing to odd addresses 
				write_data_T2 = MAC4;
				
			end
			
		end
		
		S_COMPUTE_T_2: begin
			
			write_enable_T = 1'b1;
			
			MAC1 = $signed(multiplier_1_buf)>>>8;
			MAC2 = $signed(multiplier_2_buf)>>>8;
 			
			// Writing to even addresses
			write_data_T1 = MAC1;
			// Writing to odd addresses 
			write_data_T2 = MAC2;
			
		end
		
		S_COMPUTE_T_3: begin
			
			write_enable_T = 1'b1;
			
			MAC3 = $signed(mult3_buf)>>>8;
			MAC4 = $signed(mult4_buf)>>>8;
			
			// Writing to even addresses 
			write_data_T1 = MAC3;
			// Writing to odd addresses 
			write_data_T2 = MAC4;
			
		end
		
		S_COMPUTE_S_1: begin

			multiplier_1S = read_data_T1 * $signed(read_data_C_even [31:16]);
			multiplier_2S = read_data_T1 * $signed(read_data_C_even [15:0]);
			multiplier_3S = read_data_T1 * $signed(read_data_C_odd [31:16]);
			multiplier_4S = read_data_T1 * $signed(read_data_C_odd [15:0]);
			
		end
		
		S_COMPUTE_S_2: begin
			
			write_enable_S = 1'b1;
			
			MAC1 = $signed(multiplier_1_buf)>>>16;
			MAC1S [7:0] = MAC1[31] ? 8'd0 : |MAC1 [14:8] ? 32'd255 : MAC1 [7:0];
			
			MAC2 = $signed(multiplier_2_buf)>>>16;
			MAC2S [7:0] = MAC2[31] ? 8'd0 : |MAC2 [14:8] ? 32'd255 : MAC2 [7:0];
			
			MAC3 = $signed(multiplier_3_buf)>>>16;
			MAC3S [7:0] = MAC3[31] ? 8'd0 : |MAC3 [14:8] ? 32'd255 : MAC3 [7:0];
			
			MAC4 = $signed(multiplier_4_buf)>>>16;
			MAC4S [7:0] = MAC4[31] ? 8'd0 : |MAC4 [14:8] ? 32'd255 : MAC4[7:0];
			
			// Writing to odd addresses
			write_data_S [31:24] = MAC1S [7:0];
			write_data_S [23:16] = MAC2S [7:0];
			write_data_S [15:8] = MAC3S [7:0];
			write_data_S [7:0] = MAC4S [7:0];
			
		end
		
		S_WRITE_S_2: begin
			
			SRAM_we_n = 1'b0;
			
			SRAM_write_data [15:8] = S_buf1; //Y0
			SRAM_write_data [7:0] = read_data_S [31:24]; //Y1
		
		end
		
		S_WRITE_S_3: begin
		
			SRAM_we_n = 1'b0;
			
			SRAM_write_data [15:8] = S_buf2; //Y320
			SRAM_write_data [7:0] = S_buf6; //Y321
		
		end	
		
		S_WRITE_S_4: begin
		
			SRAM_we_n = 1'b0;
			
			SRAM_write_data [15:8] = S_buf3; //Y640
			SRAM_write_data [7:0] = S_buf7; //Y641
		
		end	
		
		S_WRITE_S_5: begin
		
			SRAM_we_n = 1'b0;
			
			SRAM_write_data [15:8] = S_buf4; //Y960
			SRAM_write_data [7:0] = S_buf8; //Y961
		
		end	
	
	endcase
end

/////////////////////////////////////////////////////////////////////////////////////
// always_ff block for buffers, flags and incrementing counters

always_ff @(posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		top_state <= S_M2_IDLE;
		
		compute_t_counter <= 'b0;
		compute_t_flag <= 1'b0;
		compute_s_counter <= 'b0;
		
		Sprime_counter <= 'b0;
		column_counter <= 'b0;
		row_counter <= 'b0;
		
		multiplier_1_buf <= 'b0;
		multiplier_2_buf <= 'b0;
		multiplier_3_buf <= 'b0;
		multiplier_4_buf <= 'b0;
		
		mult3_buf <= 'b0;
		mult4_buf <= 'b0;
		
		Sprime_column_counter <= 'b0;
		Sprime_row_counter <= 'b0;
		Sprime_flag <= 'b0;
		
		C_even_counter <= 'b0;
		C_odd_counter <= 'b1;
		
		even_column_counter <= 'b0;
		odd_column_counter <= 'b1;
		
		T_row_counter <= 'b0;
		T_column_counter <= 'b0;
		T_flag <= 'b0;
		
		S_counter <= 'b0;
		
		S_even_address_counter <= 'b0;
		S_odd_address_counter <= 'b1;
		
		S_buf1 <= 'b0;
		S_buf2 <= 'b0;
		S_buf3 <= 'b0;
		S_buf4 <= 'b0;
		S_buf5 <= 'b0;
		S_buf6 <= 'b0;
		S_buf7 <= 'b0;
		S_buf8 <= 'b0;
		
		odd_flag <= 'b0;
		
		SRAM_column_counter <= 'b0;
		SRAM_even_row_counter <= 'b0;
		SRAM_odd_row_counter <= 'b0;
		
	end else begin

		case (top_state)

		S_M2_IDLE: begin
			if (milestone2_start) top_state <= S_FETCH_SPRIME_0;
		end
		
		// Repeat 64 times for Fetching S prime values and storing in DP RAM0
		
		//LEAD IN
		S_FETCH_SPRIME_0: begin
			top_state <= S_FETCH_SPRIME_1;
			column_counter <= column_counter + 18'h00001;
		end
		
		S_FETCH_SPRIME_1: begin
			top_state <= S_FETCH_SPRIME_2;
			column_counter <= column_counter + 18'h00001;
		end
		
		//COMMON STATE
		S_FETCH_SPRIME_2: begin
			
			Sprime_counter <= Sprime_counter + 18'h00001;
			
			if (Sprime_counter < 9'd61) begin
				top_state <= S_FETCH_SPRIME_2;
				
				// Column and Row Counters
				column_counter <= column_counter + 18'h00001;
				if (column_counter == 9'd7) begin
					column_counter <= 1'b0;
					row_counter <= row_counter + 18'h00001;
					if (row_counter == 9'd7) begin
						row_counter <= 1'b0;
					end
				end
			
			end else top_state <= S_FETCH_SPRIME_3;
			
		end
		
		//LEAD OUT
		S_FETCH_SPRIME_3: begin
			top_state <= S_FETCH_SPRIME_4;
			Sprime_counter <= Sprime_counter + 18'h00001;
		end
		
		S_FETCH_SPRIME_4: begin
			top_state <= S_COMPUTE_T_0;
		end
		
		// Repeats 128 times to compute T and store values in DP RAM1
		
		//LEAD IN
		S_COMPUTE_T_0: begin
			top_state <= S_COMPUTE_T_1;
			C_even_counter <= C_even_counter + 18'h00002;
			C_odd_counter <= C_odd_counter + 18'h00002;
			Sprime_column_counter <= Sprime_column_counter + 18'h00001;
		end
		
		//COMMON STATE
		S_COMPUTE_T_1: begin
			if (compute_t_counter == 9'd7) top_state <= S_COMPUTE_T_2;
			
			else begin
				
				top_state <= S_COMPUTE_T_1;
				
				if (compute_t_counter < 9'd7) begin
					C_even_counter <= C_even_counter + 18'h00002;
					C_odd_counter <= C_odd_counter + 18'h00002;
				end
				
				compute_t_counter <= compute_t_counter + 18'h00001;
				
				Sprime_column_counter <= Sprime_column_counter + 18'h00001;
				
			end
			
			if (compute_t_counter == 9'd7 && compute_t_flag) begin
			
				// T: Even counter for writing T to DRAM
				even_column_counter <= even_column_counter + 18'h00002;
				if (even_column_counter == 9'd6) begin
					even_column_counter <= 1'b0;
				end
				
				// T: Odd counter for writing T to DRAM
				odd_column_counter <= odd_column_counter + 18'h00002;
				if (odd_column_counter == 9'd7) begin
					odd_column_counter <= 1'b1;
					T_row_counter <= T_row_counter + 18'h00001;
					if (T_row_counter == 9'd7) T_row_counter <= 1'b0; 
				end
				
			end
			
			if (compute_t_counter == 9'd7 && Sprime_flag) begin
				C_even_counter <= 'b0;
				C_odd_counter <= 'b1;
				Sprime_row_counter <= Sprime_row_counter + 18'h00001;
				if (Sprime_row_counter == 9'd7) begin
					Sprime_row_counter <= 'b0;
				end
			end				
			
			multiplier_1_buf <= $signed(multiplier_1_buf) + multiplier_1;
			multiplier_2_buf <= $signed(multiplier_2_buf) + multiplier_2;
			multiplier_3_buf <= $signed(multiplier_3_buf) + multiplier_3;
			multiplier_4_buf <= $signed(multiplier_4_buf) + multiplier_4;
			
		end
		
		//COMMON STATE
		S_COMPUTE_T_2: begin
			if (address_T_odd == 18'd61) begin
				top_state <= S_COMPUTE_T_3;
			end else top_state <= S_COMPUTE_T_1;
			
			multiplier_1_buf <= 'b0;
			multiplier_2_buf <= 'b0;
			multiplier_3_buf <= 'b0;
			multiplier_4_buf <= 'b0;
			
			mult3_buf <= multiplier_3_buf;
			mult4_buf <= multiplier_4_buf;
			
			compute_t_counter <= 'b0;
			Sprime_flag <= ~Sprime_flag;
			compute_t_flag <= 1'b1;
				
			C_even_counter <= C_even_counter + 18'h00002;
			C_odd_counter <= C_odd_counter + 18'h00002;
			
			Sprime_column_counter <= Sprime_column_counter + 18'h00001;
			
			// T: Even counter for writing T to DRAM
			even_column_counter <= even_column_counter + 18'h00002;
			if (even_column_counter == 9'd6) begin
				even_column_counter <= 'b0;
			end
			
			// T: Odd counter for writing T to DRAM
			odd_column_counter <= odd_column_counter + 18'h00002;
			if (odd_column_counter == 9'd7) begin
				odd_column_counter <= 'b1;
				T_row_counter <= T_row_counter + 18'h00001;
				if (T_row_counter == 9'd7) T_row_counter <= 1'b0; 
			end
			
		end
		
		//LEAD OUT
		S_COMPUTE_T_3: begin
			top_state <= S_COMPUTE_S_0;
			C_even_counter <= 'b0;
			C_odd_counter <= 'b1;
			T_row_counter <= 'b0;
			T_column_counter <= 'b0;
		end
		
		
		// Repeats 128 times to compute S and store in DP RAM0 in addresses 64 - 79
		
		//LEAD IN
		S_COMPUTE_S_0: begin
			top_state <= S_COMPUTE_S_1;
			C_even_counter <= C_even_counter + 18'h00002;
			C_odd_counter <= C_odd_counter + 18'h00002;
			T_row_counter <= T_row_counter + 18'h00001;
		end
		
		//COMMON STATE
		S_COMPUTE_S_1: begin
		
			if (compute_s_counter == 9'd7) top_state <= S_COMPUTE_S_2;
			
			else begin
				
				top_state <= S_COMPUTE_S_1;
				
				if (compute_s_counter < 9'd7) begin
					C_even_counter <= C_even_counter + 18'h00002;
					C_odd_counter <= C_odd_counter + 18'h00002;
					T_row_counter <= T_row_counter + 18'h00001;
				end
				
				compute_s_counter <= compute_s_counter + 18'h00001;
				
			end
			
			if (T_flag && compute_s_counter == 9'd7) begin
				T_column_counter <= T_column_counter + 18'h00001;
				C_even_counter <= 'b0;
				C_odd_counter <= 'b1;
				if (T_column_counter == 9'd7) begin
					T_column_counter <= 'b0;
				end
			end
			
			multiplier_1_buf <= $signed(multiplier_1_buf) + multiplier_1S;
			multiplier_2_buf <= $signed(multiplier_2_buf) + multiplier_2S;
			multiplier_3_buf <= $signed(multiplier_3_buf) + multiplier_3S;
			multiplier_4_buf <= $signed(multiplier_4_buf) + multiplier_4S;
			
		end
		
		//LEAD OUT
		S_COMPUTE_S_2: begin
		
			if (address_S == 18'd79) begin
				top_state <= S_WRITE_S_0;
			end else top_state <= S_COMPUTE_S_1;
			
			compute_s_counter <= 'b0;
			T_flag <= ~T_flag;
			
			C_even_counter <= C_even_counter + 18'h00002;
			C_odd_counter <= C_odd_counter + 18'h00002;
			
			S_counter <= S_counter + 18'h00001;
			T_row_counter <= T_row_counter + 18'h00001;
			
			multiplier_1_buf <= 'b0;
			multiplier_2_buf <= 'b0;
			multiplier_3_buf <= 'b0;
			multiplier_4_buf <= 'b0;

		end
		
		// Repeats 32 times to write S to SRAM 
		
		//STATE1 for asking for values for DP RAM
		S_WRITE_S_0: begin
			top_state <= S_WRITE_S_1;
			
			if (odd_flag) S_odd_address_counter <= S_odd_address_counter + 18'h00002;
			else S_even_address_counter <= S_even_address_counter + 18'h00002;
			
		end
		
		//STATE 2 for storing values in buffers
		S_WRITE_S_1: begin
			top_state <= S_WRITE_S_2;
			
			if (odd_flag) S_odd_address_counter <= S_odd_address_counter + 18'h00002;
			else S_even_address_counter <= S_even_address_counter + 18'h00002;
			
			S_buf1 <= read_data_S [31:24]; //Y0
			S_buf2 <= read_data_S [24:16]; //Y320
			S_buf3 <= read_data_S [15:8]; //Y640
			S_buf4 <= read_data_S [7:0]; //Y960
			
		end
		
		//STATE 3 for storing values and writing Y0 Y1 etc
		S_WRITE_S_2: begin
			top_state <= S_WRITE_S_3;
			
			if (odd_flag) SRAM_odd_row_counter <= SRAM_odd_row_counter + 18'h00001;
			else SRAM_even_row_counter <= SRAM_even_row_counter + 18'h00001;
			
			S_buf5 <= read_data_S [31:24]; //Y1
			S_buf6 <= read_data_S [24:16]; //Y321
			S_buf7 <= read_data_S [15:8]; //Y641
			S_buf8 <= read_data_S [7:0]; //Y961
			
		end
		
		//STATE 4 for writing stored values Y320 and Y321 etc
		S_WRITE_S_3: begin
			top_state <= S_WRITE_S_4;
			
			if (odd_flag) SRAM_odd_row_counter <= SRAM_odd_row_counter + 18'h00001;
			else SRAM_even_row_counter <= SRAM_even_row_counter + 18'h00001;
						
		end
		
		//STATE 5 for writing stored values Y640 and Y641 etc
		S_WRITE_S_4: begin
			top_state <= S_WRITE_S_5;
			
			if (odd_flag) SRAM_odd_row_counter <= SRAM_odd_row_counter + 18'h00001;
			else SRAM_even_row_counter <= SRAM_even_row_counter + 18'h00001;
		
		end
		
		//STATE 6 for writing stored values Y940 and Y941 etc
		S_WRITE_S_5: begin
			if (SRAM_column_counter == 9'd3 && SRAM_odd_row_counter == 9'd3) top_state <= S_MILESTONE_2_DONE;
			else top_state <= S_WRITE_S_0;
			
			odd_flag <= ~odd_flag;
			
			if (odd_flag) SRAM_odd_row_counter <= SRAM_odd_row_counter + 18'h00001;
			else SRAM_even_row_counter <= SRAM_even_row_counter + 18'h00001;
			
			if (SRAM_even_row_counter == 9'd3) begin
				SRAM_even_row_counter <= 1'b0;
			end
			
			if (SRAM_odd_row_counter == 9'd3) begin
				SRAM_odd_row_counter <= 1'b0;
				SRAM_column_counter <= SRAM_column_counter + 18'h00001;
				if (SRAM_column_counter == 9'd3) begin
					SRAM_column_counter <= 1'b0;
				end
			end
		
		end
		
		S_MILESTONE_2_DONE: begin
			milestone2_done <= 1'b1;
			
			top_state <= S_M2_IDLE;
		end
			
		default: top_state <= S_M2_IDLE;
		endcase
	end
end

endmodule