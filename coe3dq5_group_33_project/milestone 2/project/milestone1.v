/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

// This is the top module
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module milestone1 (
		input logic Clock,
		input logic Resetn,
		input logic milestone1_start,
		input logic[15:0] SRAM_read_data,
		output logic[15:0] SRAM_write_data,
		output logic[17:0] SRAM_address,
		output logic SRAM_we_n,
		output logic milestone1_done
);

parameter Y_segment = 18'd0,
		U_segment = 32'd38400,
		V_segment = 32'd57600,
		RGB_segment = 32'd146944;

M1_state_type top_state;

// flag, counter, SRAM_address_Y
logic row_flag;
logic [7:0] column_counter;
logic [7:0] line_counter;

logic [17:0] SRAM_address_UV;
logic [17:0] SRAM_address_Y;
logic [17:0] SRAM_address_RGB;

// U
logic [47:0] U_shift_register;
logic [32:0] U0_buf;
logic [32:0] U1_buf;
logic [32:0] U0_prime;
logic [32:0] U1_prime;
logic [32:0] U2_prime;
logic [32:0] U3_prime;

// V
logic [47:0] V_shift_register;
logic [32:0] V0_buf;
logic [32:0] V1_buf;
logic [32:0] V0_prime;
logic [32:0] V1_prime;
logic [32:0] V2_prime;
logic [32:0] V3_prime;

// Y
logic [32:0] Y0_buf;
logic [32:0] Y1_buf;
logic [32:0] Y2_buf;
logic [32:0] Y3_buf;

// RGB
logic [7:0] R0_buf;
logic [7:0] G0_buf;
logic [7:0] B0_buf;
logic [7:0] R1_buf;
logic [7:0] G1_buf;
logic [7:0] B1_buf;

logic [7:0] R2_buf;
logic [7:0] G2_buf;
logic [7:0] B2_buf;
logic [7:0] R3_buf;
logic [7:0] G3_buf;
logic [7:0] B3_buf;

// Multipliers
logic [31:0] multiplier_1;
logic [31:0] multiplier_2;
logic [31:0] multiplier_3;

logic [31:0] multiplier_1_buf;
logic signed [31:0] multiplier_result;

logic [31:0] R_multiplier_result;
logic [31:0] G_multiplier_result;
logic [31:0] B_multiplier_result;

// Assigning addresses to be read

always_comb begin
	SRAM_address = 1'b0;
	
	case (top_state)
	
		S_LEAD_IN_1: SRAM_address = SRAM_address_UV + U_segment;
		S_LEAD_IN_2: SRAM_address = SRAM_address_UV + V_segment;
		S_LEAD_IN_3: SRAM_address = SRAM_address_UV + U_segment;
		S_LEAD_IN_4: SRAM_address = SRAM_address_UV + V_segment;
		
		S_COMMON_8: SRAM_address = SRAM_address_Y + Y_segment;
		S_COMMON_9: SRAM_address = SRAM_address_UV + U_segment;
		S_COMMON_10: SRAM_address = SRAM_address_UV + V_segment;
		S_COMMON_11: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_COMMON_12: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_COMMON_13: SRAM_address = SRAM_address_RGB + RGB_segment;
		
		S_COMMON_14: SRAM_address = SRAM_address_Y + Y_segment;
		S_COMMON_17: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_COMMON_18: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_COMMON_19: SRAM_address = SRAM_address_RGB + RGB_segment;
		
		S_LEAD_OUT_1: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_LEAD_OUT_2: SRAM_address = SRAM_address_RGB + RGB_segment;
		S_LEAD_OUT_3: SRAM_address = SRAM_address_RGB + RGB_segment;

	endcase
end

//Using multipliers for calculations

always_comb begin

	multiplier_1 = 1'b0;
	multiplier_2 = 1'b0;
	multiplier_3 = 1'b0;
	multiplier_result = 1'b0;
	R_multiplier_result = 1'b0;
	G_multiplier_result = 1'b0;
	B_multiplier_result = 1'b0;
	SRAM_we_n = 1'b1;
	SRAM_write_data = 1'b0;
	
	case (top_state)
		
		S_COMMON_8: begin
			
			SRAM_we_n = 1'b1;
		
			multiplier_1 = 18'd21 * (U_shift_register[47:40] + U_shift_register[7:0]);
			multiplier_2 = 18'd52 * (U_shift_register[39:32] + U_shift_register[15:8]);
			multiplier_3 = 18'd159 * (U_shift_register[31:24] + U_shift_register[23:16]);
			
			multiplier_result = $signed(multiplier_1 - multiplier_2 + multiplier_3 + 18'd128)>>>8;
		
		end
		
		S_COMMON_9: begin
			
			SRAM_we_n = 1'b1;
			
			multiplier_1 = 18'd21 * (V_shift_register[47:40] + V_shift_register[7:0]);
			multiplier_2 = 18'd52 * (V_shift_register[39:32] + V_shift_register[15:8]);
			multiplier_3 = 18'd159 * (V_shift_register[31:24] + V_shift_register[23:16]);
			
			multiplier_result = $signed(multiplier_1 - multiplier_2 + multiplier_3 + 18'd128)>>>8;
		
		end
		
		S_COMMON_10: begin
		
			SRAM_we_n = 1'b1;
			
			multiplier_1 = 32'd76284 * (SRAM_read_data[15:8] - 18'd16);
			multiplier_2 = 32'd104595 * (V0_prime - 18'd128);
			
			R_multiplier_result = $signed(multiplier_1 + multiplier_2)>>>16;
			R_multiplier_result[7:0] = R_multiplier_result [31] ? 8'd0 : |R_multiplier_result [30:8] ? 32'd255 : R_multiplier_result [7:0];
		
		end
		
		S_COMMON_11: begin
			
			SRAM_we_n = 1'b1;
		
			multiplier_1 = -32'd25624 * (U0_prime - 18'd128);
			multiplier_2 = -32'd53281 * (V0_prime - 18'd128);
			multiplier_3 = 32'd132251 * (U0_prime - 18'd128);
			
			G_multiplier_result = $signed(multiplier_1_buf + multiplier_1 + multiplier_2)>>>16;
			G_multiplier_result[7:0] = G_multiplier_result[31] ? 8'd0 : |G_multiplier_result[30:8] ? 32'd255 : G_multiplier_result[7:0];
			
			B_multiplier_result = $signed(multiplier_1_buf + multiplier_3)>>>16; 
			B_multiplier_result[7:0] = B_multiplier_result[31] ? 8'd0 : |B_multiplier_result[30:8] ? 32'd255 : B_multiplier_result[7:0];
			
			if (!row_flag) begin
				SRAM_we_n = 1'b0;
				SRAM_write_data[15:8] = R2_buf;
				SRAM_write_data[7:0] = G2_buf;
			end
			
		end
		
		S_COMMON_12: begin
			
			SRAM_we_n = 1'b1;
			
			multiplier_1 = 32'd76284 * (Y1_buf - 18'd16);
			multiplier_2 = 32'd104595 * (V1_prime - 18'd128);
			
			R_multiplier_result = $signed(multiplier_1 + multiplier_2)>>>16;
			R_multiplier_result[7:0] = R_multiplier_result [31] ? 8'd0 : |R_multiplier_result [30:8] ? 32'd255 : R_multiplier_result [7:0];
			
			if (!row_flag) begin
				SRAM_we_n = 1'b0;
				SRAM_write_data[15:8] = B2_buf;
				SRAM_write_data[7:0] = R3_buf;
			end
		
		end
		
		S_COMMON_13: begin
		
			SRAM_we_n = 1'b1;
			
			multiplier_1 = -32'd25624 * (U1_prime - 18'd128);
			multiplier_2 = -32'd53281 * (V1_prime - 18'd128);
			multiplier_3 = 32'd132251 * (U1_prime - 18'd128);
			
			G_multiplier_result = $signed(multiplier_1_buf + multiplier_1 + multiplier_2)>>>16;
			G_multiplier_result[7:0] = G_multiplier_result[31] ? 8'd0 : |G_multiplier_result[30:8] ? 32'd255 : G_multiplier_result[7:0];
			
			B_multiplier_result = $signed(multiplier_1_buf + multiplier_3)>>>16; 
			B_multiplier_result[7:0] = B_multiplier_result[31] ? 8'd0 : |B_multiplier_result[30:8] ? 32'd255 : B_multiplier_result[7:0];
			
			if (!row_flag) begin
				SRAM_we_n = 1'b0;
				SRAM_write_data[15:8] = G3_buf;
				SRAM_write_data[7:0] = B3_buf;
			end
			
		end
		
		S_COMMON_14: begin
		
			SRAM_we_n = 1'b1;
		
			multiplier_1 = 18'd21 * (U_shift_register[47:40] + U_shift_register[7:0]);
			multiplier_2 = 18'd52 * (U_shift_register[39:32] + U_shift_register[15:8]);
			multiplier_3 = 18'd159 * (U_shift_register[31:24] + U_shift_register[23:16]);
			
			multiplier_result = $signed(multiplier_1 - multiplier_2 + multiplier_3 + 18'd128)>>>8;
		
		end
		
		S_COMMON_15: begin
			
			SRAM_we_n = 1'b1;
			
			multiplier_1 = 18'd21 * (V_shift_register[47:40] + V_shift_register[7:0]);
			multiplier_2 = 18'd52 * (V_shift_register[39:32] + V_shift_register[15:8]);
			multiplier_3 = 18'd159 * (V_shift_register[31:24] + V_shift_register[23:16]);
			
			multiplier_result = $signed(multiplier_1 - multiplier_2 + multiplier_3 + 18'd128)>>>8;
		
		end
		
		S_COMMON_16: begin
		
			SRAM_we_n = 1'b1;
		
			multiplier_1 = 32'd76284 * (SRAM_read_data[15:8] - 18'd16);
			multiplier_2 = 32'd104595 * (V0_prime - 18'd128);
			
			R_multiplier_result = $signed(multiplier_1 + multiplier_2)>>>16;
			R_multiplier_result[7:0] = R_multiplier_result [31] ? 8'd0 : |R_multiplier_result [30:8] ? 32'd255 : R_multiplier_result [7:0];
		
		end
		
		S_COMMON_17: begin
		
			SRAM_we_n = 1'b0;
			
			multiplier_1 = -32'd25624 * (U0_prime - 18'd128);
			multiplier_2 = -32'd53281 * (V0_prime - 18'd128);
			multiplier_3 = 32'd132251 * (U0_prime - 18'd128);
			
			G_multiplier_result = $signed(multiplier_1_buf + multiplier_1 + multiplier_2)>>>16;
			G_multiplier_result[7:0] = G_multiplier_result[31] ? 8'd0 : |G_multiplier_result[30:8] ? 32'd255 : G_multiplier_result[7:0];
			
			B_multiplier_result = $signed(multiplier_1_buf + multiplier_3)>>>16; 
			B_multiplier_result[7:0] = B_multiplier_result[31] ? 8'd0 : |B_multiplier_result[30:8] ? 32'd255 : B_multiplier_result[7:0];
			
			SRAM_write_data[15:8] = R0_buf;
			SRAM_write_data[7:0] = G0_buf;
			
		end
		
		S_COMMON_18: begin
		
			SRAM_we_n = 1'b0;
		
			multiplier_1 = 32'd76284 * (Y1_buf - 18'd16);
			multiplier_2 = 32'd104595 * (V1_prime - 18'd128);
			
			R_multiplier_result = $signed(multiplier_1 + multiplier_2)>>>16;
			R_multiplier_result[7:0] = R_multiplier_result [31] ? 8'd0 : |R_multiplier_result [30:8] ? 32'd255 : R_multiplier_result [7:0];
			
			SRAM_write_data[15:8] = B0_buf;
			SRAM_write_data[7:0] = R1_buf;
		
		end
		
		S_COMMON_19: begin
		
			SRAM_we_n = 1'b0;
		
			multiplier_1 = -32'd25624 * (U1_prime - 18'd128);
			multiplier_2 = -32'd53281 * (V1_prime - 18'd128);
			multiplier_3 = 32'd132251 * (U1_prime - 18'd128);
			
			G_multiplier_result = $signed(multiplier_1_buf + multiplier_1 + multiplier_2)>>>16;
			G_multiplier_result[7:0] = G_multiplier_result[31] ? 8'd0 : |G_multiplier_result[30:8] ? 32'd255 : G_multiplier_result[7:0];
			
			B_multiplier_result = $signed(multiplier_1_buf + multiplier_3)>>>16; 
			B_multiplier_result[7:0] = B_multiplier_result[31] ? 8'd0 : |B_multiplier_result[30:8] ? 32'd255 : B_multiplier_result[7:0];
			
			SRAM_write_data[15:8] = G1_buf;
			SRAM_write_data[7:0] = B1_buf;
			
		end
		
		S_LEAD_OUT_1: begin
		
			SRAM_we_n = 1'b0;
			SRAM_write_data[15:8] = R2_buf;
			SRAM_write_data[7:0] = G2_buf;
			
		end
		
		S_LEAD_OUT_2: begin
		
			SRAM_we_n = 1'b0;
			SRAM_write_data[15:8] = B2_buf;
			SRAM_write_data[7:0] = R3_buf;
			
		end
		
		S_LEAD_OUT_3: begin
		
			SRAM_we_n = 1'b0;
			SRAM_write_data[15:8] = G3_buf;
			SRAM_write_data[7:0] = B3_buf;
			
		end
		
	endcase
end
always_ff @(posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		top_state <= S_START;
		
		row_flag <= 1'b1;
		column_counter <= 1'b0;
		line_counter <= 1'b0;
		milestone1_done <= 1'b0;
		
		U0_buf <= 1'b0;
		U1_buf <= 1'b0;
		U0_prime <= 1'b0;
		U1_prime <= 1'b0;
		U2_prime <= 1'b0;
		U3_prime <= 1'b0;
		U_shift_register <= 1'b1;
		
		V0_buf <= 1'b0;
		V1_buf <= 1'b0;
		V0_prime <= 1'b0;
		V1_prime <= 1'b0;
		V2_prime <= 1'b0;
		V3_prime <= 1'b0;
		V_shift_register <= 1'b1;
		
		Y0_buf <= 1'b0;
		Y1_buf <= 1'b0;
		Y2_buf <= 1'b0;
		Y3_buf <= 1'b0;
				
		multiplier_1_buf <= 1'b0;
		
		R0_buf <= 1'b0;
		G0_buf <= 1'b0;
		B0_buf <= 1'b0;
		R1_buf <= 1'b0;
		B1_buf <= 1'b0;
		G1_buf <= 1'b0;
		
		R2_buf <= 1'b0;
		G2_buf <= 1'b0;
		B2_buf <= 1'b0;
		R3_buf <= 1'b0;
		B3_buf <= 1'b0;
		G3_buf <= 1'b0;
		
		SRAM_address_UV <= 1'b0;
		SRAM_address_Y <= 1'b0;
		SRAM_address_RGB <= 1'b0;
		
	end else begin

		case (top_state)
		
		/////////////////////////////////////////////////////////////////////////////////////
		// LEAD IN STATE //
		/////////////////////////////////////////////////////////////////////////////////////
		
		S_START: begin
			if (milestone1_start) top_state <= S_DELAY;
		end
		
		S_DELAY: begin
			top_state <= S_LEAD_IN_0;
		end
		
		S_LEAD_IN_0: begin
			column_counter <= 1'b0;
			row_flag <= 1'b1;
			top_state <= S_LEAD_IN_1;
		end
		
		S_LEAD_IN_1: begin
			top_state <= S_LEAD_IN_2;
		end
		
		S_LEAD_IN_2: begin
			SRAM_address_UV <= SRAM_address_UV + 18'h00001;
			top_state <= S_LEAD_IN_3;
		end
		
		S_LEAD_IN_3: begin
			U0_buf <= SRAM_read_data[15:8]; //U0
			U1_buf <= SRAM_read_data[7:0]; //U1
			
			U_shift_register[47:40] <= SRAM_read_data[15:8];
			U_shift_register[39:32] <= SRAM_read_data[15:8];
			U_shift_register[31:24] <= SRAM_read_data[15:8];
			U_shift_register[23:16] <= SRAM_read_data[15:8];
			U_shift_register[15:8] <= SRAM_read_data[15:8];
			U_shift_register[7:0] <= SRAM_read_data[15:8];

			top_state <= S_LEAD_IN_4;
		end
		
		S_LEAD_IN_4: begin
			U_shift_register <= (U_shift_register << 4'd8);
			U_shift_register[7:0] <= U1_buf;
			
			V0_buf <= SRAM_read_data[15:8]; //V0
			V1_buf <= SRAM_read_data[7:0]; //V1
			
			V_shift_register[47:40] <= SRAM_read_data[15:8];
			V_shift_register[39:32] <= SRAM_read_data[15:8];
			V_shift_register[31:24] <= SRAM_read_data[15:8];
			V_shift_register[23:16] <= SRAM_read_data[15:8];
			V_shift_register[15:8] <= SRAM_read_data[15:8];
			V_shift_register[7:0] <= SRAM_read_data[15:8];

			top_state <= S_LEAD_IN_5;
		end
		
		S_LEAD_IN_5: begin
			U0_buf <= SRAM_read_data[15:8]; //U2
			U1_buf <= SRAM_read_data[7:0]; //U3
			
			U_shift_register <= (U_shift_register << 18'd8);
			U_shift_register[7:0] <= SRAM_read_data[15:8];
			
			V_shift_register <= (V_shift_register << 18'd8);
			V_shift_register[7:0] <= V1_buf;
			
			top_state <= S_LEAD_IN_6;
		end
		
		S_LEAD_IN_6: begin
			U_shift_register <= (U_shift_register << 18'd8);
			U_shift_register[7:0] <= U1_buf;
			
			V0_buf <= SRAM_read_data[15:8]; //V2
			V1_buf <= SRAM_read_data[7:0]; //V3
			
			V_shift_register <= (V_shift_register << 18'd8);
			V_shift_register[7:0] <= SRAM_read_data[15:8];

			top_state <= S_LEAD_IN_7;
		end
		
		S_LEAD_IN_7: begin
		
			V_shift_register <= (V_shift_register << 18'd8);
			V_shift_register[7:0] <= V1_buf;

			top_state <= S_COMMON_8;
		end
		
		/////////////////////////////////////////////////////////////////////////////////////
		// COMMON CASE //
		/////////////////////////////////////////////////////////////////////////////////////
		
		S_COMMON_8: begin
			
			if (column_counter < 9'd78) SRAM_address_UV <= SRAM_address_UV + 18'h00001;
			
			U0_prime <= U_shift_register[31:24];
			U1_prime <= multiplier_result;

			top_state <= S_COMMON_9;
		end
		
		S_COMMON_9: begin
			V0_prime <= V_shift_register[31:24];
			V1_prime <= multiplier_result;

			top_state <= S_COMMON_10;
		end
			
		S_COMMON_10: begin
			Y0_buf <= SRAM_read_data[15:8]; //Y0
			Y1_buf <= SRAM_read_data[7:0]; //Y1
			
			multiplier_1_buf <= multiplier_1;
			
			R0_buf <= R_multiplier_result; //R0

			top_state <= S_COMMON_11;
		end
		
		S_COMMON_11: begin
		
			if (column_counter < 9'd78) begin
				U0_buf <= SRAM_read_data[15:8]; //U4
				U1_buf <= SRAM_read_data[7:0]; //U5
				U_shift_register <= (U_shift_register << 18'd8);
				U_shift_register[7:0] <= SRAM_read_data[15:8];
			end else begin
				U_shift_register <= (U_shift_register << 18'd8);
				U_shift_register[7:0] <= U1_buf;
			end
			
			G0_buf <= G_multiplier_result; //G0
			B0_buf <= B_multiplier_result; //B0
			
			if (!row_flag) begin
				SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			end
			
			top_state <= S_COMMON_12;
		end
		
		S_COMMON_12: begin
		
			if (column_counter < 9'd78) begin
				V0_buf <= SRAM_read_data[15:8]; //V4
				V1_buf <= SRAM_read_data[7:0]; //V5
				V_shift_register <= (V_shift_register << 18'd8);
				V_shift_register[7:0] <= SRAM_read_data[15:8];
			end else begin
				V_shift_register <= (V_shift_register << 18'd8);
				V_shift_register[7:0] <= V1_buf;
			end
			
			R1_buf <= R_multiplier_result; //R1
			
			multiplier_1_buf <= multiplier_1;
			
			if (!row_flag) begin
				SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			end
			
			top_state <= S_COMMON_13;
		end
		
		S_COMMON_13: begin
			SRAM_address_Y <= SRAM_address_Y + 18'h00001;
			
			G1_buf <= G_multiplier_result; //G1
			B1_buf <= B_multiplier_result; //B1
			
			if (!row_flag) begin
				SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			end
			
			top_state <= S_COMMON_14;
		end
		
		S_COMMON_14: begin
			U0_prime <= U_shift_register[31:24];
			U1_prime <= multiplier_result;
			
			top_state <= S_COMMON_15;
		end
		
		S_COMMON_15: begin
			V0_prime <= V_shift_register[31:24];
			V1_prime <= multiplier_result;
			
			top_state <= S_COMMON_16;
		end
			
		S_COMMON_16: begin
			Y0_buf <= SRAM_read_data[15:8]; //Y2
			Y1_buf <= SRAM_read_data[7:0]; //Y3
			
			R2_buf <= R_multiplier_result; //R2
			
			multiplier_1_buf <= multiplier_1;
			
			top_state <= S_COMMON_17;
		end
		
		S_COMMON_17: begin
			U_shift_register <= (U_shift_register << 18'd8);
			U_shift_register[7:0] <= U1_buf;
			
			G2_buf <= G_multiplier_result; //G2
			B2_buf <= B_multiplier_result; //B2
			
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			
			top_state <= S_COMMON_18;
		end
		
		S_COMMON_18: begin
			V_shift_register <= (V_shift_register << 18'd8);
			V_shift_register[7:0] <= V1_buf;
			
			R3_buf <= R_multiplier_result; //R3
			
			multiplier_1_buf <= multiplier_1;
			
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			
			column_counter <= column_counter + 1'b1;
			
			top_state <= S_COMMON_19;
		end
		
		S_COMMON_19: begin
			SRAM_address_Y <= SRAM_address_Y + 18'h00001;
			
			G3_buf <= G_multiplier_result; //G3
			B3_buf <= B_multiplier_result; //B3
			row_flag <= 1'b0;
			
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			
			top_state <= S_COMMON_8;
			
			if (column_counter < 9'd80) top_state <= S_COMMON_8;
			else top_state <= S_LEAD_OUT_1;
		end
		
		/////////////////////////////////////////////////////////////////////////////////////
		// LEAD OUT //
		/////////////////////////////////////////////////////////////////////////////////////
		
		S_LEAD_OUT_1: begin
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			
			top_state <= S_LEAD_OUT_2;
		end
		
		S_LEAD_OUT_2: begin
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			line_counter <= line_counter + 18'h00001;
			
			top_state <= S_LEAD_OUT_3;
		end
			
		S_LEAD_OUT_3: begin
			SRAM_address_RGB <= SRAM_address_RGB + 18'h00001;
			SRAM_address_UV <= SRAM_address_UV + 18'h00001;
			
			if (line_counter < 18'd240) top_state <= S_LEAD_IN_0;
			else top_state <= S_MILESTONE_1_DONE;
		end
		
		S_MILESTONE_1_DONE: begin
			milestone1_done <= 1'b1;
			
			top_state <= S_START;
		end
		
		default: top_state <= S_START;
		endcase
	end
end

endmodule
