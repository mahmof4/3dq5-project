# add waves to waveform

add wave -divider {Top-Level Signals}

add wave Clock_50

add wave -hexadecimal uut/top_state

add wave -hexadecimal uut/SRAM_address

add wave -hexadecimal uut/SRAM_read_data

add wave -hexadecimal uut/SRAM_write_data

add wave uut/SRAM_we_n


add wave -divider {Milestone 2 Signals}

add wave -hexadecimal uut/milestone2_unit/top_state

add wave -hexadecimal uut/milestone2_unit/Sprime_counter
add wave -hexadecimal uut/milestone2_unit/SRAM_address
add wave -hexadecimal uut/milestone2_unit/SRAM_read_data
add wave -hexadecimal uut/milestone2_unit/write_data_Sprime
add wave -hexadecimal uut/milestone2_unit/address_Sprime
add wave -hexadecimal uut/milestone2_unit/read_data_Sprime
add wave -hexadecimal uut/milestone2_unit/write_enable_Sprime

add wave -divider {Compute T}

add wave -hexadecimal uut/milestone2_unit/compute_t_counter
add wave -hexadecimal uut/milestone2_unit/Sprime_column_counter
add wave -hexadecimal uut/milestone2_unit/Sprime_row_counter

add wave -hexadecimal uut/milestone2_unit/Sprime_flag
add wave -hexadecimal uut/milestone2_unit/C_even_counter
add wave -hexadecimal uut/milestone2_unit/C_odd_counter

add wave -hexadecimal uut/milestone2_unit/read_data_C_even
add wave -hexadecimal uut/milestone2_unit/read_data_C_odd

add wave -hexadecimal uut/milestone2_unit/address_C_even
add wave -hexadecimal uut/milestone2_unit/address_C_odd


add wave -hexadecimal uut/milestone2_unit/multiplier_1
add wave -hexadecimal uut/milestone2_unit/multiplier_2
add wave -hexadecimal uut/milestone2_unit/multiplier_3
add wave -hexadecimal uut/milestone2_unit/multiplier_4

add wave -hexadecimal uut/milestone2_unit/multiplier_1_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_2_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_3_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_4_buf

add wave -hexadecimal uut/milestone2_unit/MAC1
add wave -hexadecimal uut/milestone2_unit/MAC2
add wave -hexadecimal uut/milestone2_unit/MAC3
add wave -hexadecimal uut/milestone2_unit/MAC4

add wave -hexadecimal uut/milestone2_unit/address_T_even
add wave -hexadecimal uut/milestone2_unit/address_T_odd

add wave -hexadecimal uut/milestone2_unit/write_enable_T

add wave -hexadecimal uut/milestone2_unit/write_data_T1
add wave -hexadecimal uut/milestone2_unit/write_data_T2

add wave -hexadecimal uut/milestone2_unit/address_Sprime
add wave -hexadecimal uut/milestone2_unit/read_data_Sprime

add wave -hexadecimal uut/milestone2_unit/read_data_T1
add wave -hexadecimal uut/milestone2_unit/read_data_T2

add wave -divider {Compute S}

add wave -hexadecimal uut/milestone2_unit/top_state

add wave -hexadecimal uut/milestone2_unit/compute_s_counter

add wave -hexadecimal uut/milestone2_unit/T_row_counter
add wave -hexadecimal uut/milestone2_unit/T_column_counter
add wave -hexadecimal uut/milestone2_unit/address_T_even

add wave -hexadecimal uut/milestone2_unit/read_data_T1

add wave -hexadecimal uut/milestone2_unit/T_flag
add wave -hexadecimal uut/milestone2_unit/C_even_counter
add wave -hexadecimal uut/milestone2_unit/C_odd_counter
add wave -hexadecimal uut/milestone2_unit/address_C_even
add wave -hexadecimal uut/milestone2_unit/address_C_odd

add wave -hexadecimal uut/milestone2_unit/multiplier_1S
add wave -hexadecimal uut/milestone2_unit/multiplier_2S
add wave -hexadecimal uut/milestone2_unit/multiplier_3S
add wave -hexadecimal uut/milestone2_unit/multiplier_4S

add wave -hexadecimal uut/milestone2_unit/multiplier_1_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_2_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_3_buf
add wave -hexadecimal uut/milestone2_unit/multiplier_4_buf

add wave -hexadecimal uut/milestone2_unit/MAC1
add wave -hexadecimal uut/milestone2_unit/MAC2
add wave -hexadecimal uut/milestone2_unit/MAC3
add wave -hexadecimal uut/milestone2_unit/MAC4

add wave -hexadecimal uut/milestone2_unit/MAC1S
add wave -hexadecimal uut/milestone2_unit/MAC2S
add wave -hexadecimal uut/milestone2_unit/MAC3S
add wave -hexadecimal uut/milestone2_unit/MAC4S

add wave -hexadecimal uut/milestone2_unit/S_counter

add wave -hexadecimal uut/milestone2_unit/address_S

add wave -hexadecimal uut/milestone2_unit/write_enable_S

add wave -hexadecimal uut/milestone2_unit/write_data_S

add wave -hexadecimal uut/milestone2_unit/read_data_S

add wave -divider {Write S}

add wave -hexadecimal uut/milestone2_unit/top_state

add wave -hexadecimal uut/milestone2_unit/odd_flag

add wave -hexadecimal uut/milestone2_unit/S_even_address_counter
add wave -hexadecimal uut/milestone2_unit/S_odd_address_counter

add wave -hexadecimal uut/milestone2_unit/address_S

add wave -hexadecimal uut/milestone2_unit/SRAM_column_counter
add wave -hexadecimal uut/milestone2_unit/SRAM_even_row_counter
add wave -hexadecimal uut/milestone2_unit/SRAM_odd_row_counter

add wave -hexadecimal uut/milestone2_unit/S_buf1
add wave -hexadecimal uut/milestone2_unit/S_buf2
add wave -hexadecimal uut/milestone2_unit/S_buf3
add wave -hexadecimal uut/milestone2_unit/S_buf4
add wave -hexadecimal uut/milestone2_unit/S_buf5
add wave -hexadecimal uut/milestone2_unit/S_buf6
add wave -hexadecimal uut/milestone2_unit/S_buf7
add wave -hexadecimal uut/milestone2_unit/S_buf8

add wave -hexadecimal uut/milestone2_unit/SRAM_address

add wave -hexadecimal uut/milestone2_unit/SRAM_write_data

add wave -hexadecimal uut/milestone2_unit/SRAM_read_data

add wave -hexadecimal uut/milestone2_unit/SRAM_we_n
