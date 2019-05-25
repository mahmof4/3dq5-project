# add waves to waveform

add wave -divider {Top-Level Signals}

add wave Clock_50

add wave -hexadecimal uut/top_state

add wave -hexadecimal uut/SRAM_address

add wave -hexadecimal uut/SRAM_read_data

add wave -hexadecimal uut/SRAM_write_data

add wave uut/SRAM_we_n


add wave -divider {Milestone 1 Signals}

add wave -hexadecimal uut/milestone1_unit/top_state

add wave -hexadecimal uut/milestone1_unit/SRAM_address

add wave -hexadecimal uut/milestone1_unit/SRAM_read_data

add wave -hexadecimal uut/milestone1_unit/SRAM_write_data

add wave uut/milestone1_unit/SRAM_we_n

add wave -hexadecimal uut/milestone1_unit/column_counter
add wave -hexadecimal uut/milestone1_unit/line_counter

add wave -hexadecimal uut/milestone1_unit/multiplier_result

add wave -hexadecimal uut/milestone1_unit/U0_prime
add wave -hexadecimal uut/milestone1_unit/U1_prime

add wave -hexadecimal uut/milestone1_unit/V0_prime
add wave -hexadecimal uut/milestone1_unit/V1_prime

add wave -hexadecimal uut/milestone1_unit/Y0_buf
add wave -hexadecimal uut/milestone1_unit/Y1_buf

add wave -hexadecimal uut/milestone1_unit/U_shift_register
add wave -hexadecimal uut/milestone1_unit/V_shift_register

add wave -hexadecimal uut/milestone1_unit/R0_buf
add wave -hexadecimal uut/milestone1_unit/G0_buf
add wave -hexadecimal uut/milestone1_unit/B0_buf

add wave -hexadecimal uut/milestone1_unit/R1_buf
add wave -hexadecimal uut/milestone1_unit/G1_buf
add wave -hexadecimal uut/milestone1_unit/B1_buf

add wave -hexadecimal uut/milestone1_unit/R2_buf
add wave -hexadecimal uut/milestone1_unit/G2_buf
add wave -hexadecimal uut/milestone1_unit/B2_buf

add wave -hexadecimal uut/milestone1_unit/R3_buf
add wave -hexadecimal uut/milestone1_unit/B3_buf
add wave -hexadecimal uut/milestone1_unit/G3_buf
