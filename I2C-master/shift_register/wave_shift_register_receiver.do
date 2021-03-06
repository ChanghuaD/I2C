onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_shift_register_receiver/clk_50MHz
add wave -noupdate /tb_shift_register_receiver/rst_variable
add wave -noupdate /tb_shift_register_receiver/sda_in
add wave -noupdate /tb_shift_register_receiver/rst_1
add wave -noupdate /tb_shift_register_receiver/ena_1
add wave -noupdate /tb_shift_register_receiver/casc_in_1
add wave -noupdate /tb_shift_register_receiver/clk_ena
add wave -noupdate /tb_shift_register_receiver/scl_tick
add wave -noupdate /tb_shift_register_receiver/scl_in_fast
add wave -noupdate /tb_shift_register_receiver/scl_in_slow
add wave -noupdate -divider SCL_detect
add wave -noupdate /tb_shift_register_receiver/rising_point
add wave -noupdate /tb_shift_register_receiver/writing_point
add wave -noupdate /tb_shift_register_receiver/falling_point
add wave -noupdate /tb_shift_register_receiver/sampling_point
add wave -noupdate /tb_shift_register_receiver/stop_point
add wave -noupdate /tb_shift_register_receiver/start_point
add wave -noupdate /tb_shift_register_receiver/error_point
add wave -noupdate -divider {I2C Line}
add wave -noupdate /tb_shift_register_receiver/scl_out
add wave -noupdate /tb_shift_register_receiver/sda_out
add wave -noupdate -divider Transmitter
add wave -noupdate /tb_shift_register_receiver/TX
add wave -noupdate /tb_shift_register_receiver/ACK_out
add wave -noupdate /tb_shift_register_receiver/ACK_valued
add wave -noupdate /tb_shift_register_receiver/sda_out_1
add wave -noupdate /tb_shift_register_receiver/M_shift_regisiter_transmitter/reg_write
add wave -noupdate /tb_shift_register_receiver/TX_captured
add wave -noupdate /tb_shift_register_receiver/M_shift_regisiter_transmitter/go
add wave -noupdate /tb_shift_register_receiver/M_shift_regisiter_transmitter/byte_to_be_sent
add wave -noupdate /tb_shift_register_receiver/M_shift_regisiter_transmitter/data
add wave -noupdate /tb_shift_register_receiver/M_shift_regisiter_transmitter/state
add wave -noupdate -divider Receiver
add wave -noupdate /tb_shift_register_receiver/data_received
add wave -noupdate /tb_shift_register_receiver/RX
add wave -noupdate /tb_shift_register_receiver/ACK_in
add wave -noupdate /tb_shift_register_receiver/sda_out_2
add wave -noupdate /tb_shift_register_receiver/M_shift_register_receiver/reg_write
add wave -noupdate /tb_shift_register_receiver/M_shift_register_receiver/go
add wave -noupdate /tb_shift_register_receiver/M_shift_register_receiver/data
add wave -noupdate /tb_shift_register_receiver/M_shift_register_receiver/byte_to_be_used
add wave -noupdate /tb_shift_register_receiver/M_shift_register_receiver/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {237564 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 382
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {130508 ns} {131966 ns}
