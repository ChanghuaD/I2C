onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_flip_flop/clk_50MHz
add wave -noupdate /tb_flip_flop/rst_variable
add wave -noupdate /tb_flip_flop/rst_1
add wave -noupdate /tb_flip_flop/ena_1
add wave -noupdate /tb_flip_flop/casc_in_1
add wave -noupdate /tb_flip_flop/clk_ena
add wave -noupdate -divider RW_RC
add wave -noupdate /tb_flip_flop/RW_RC_data_in
add wave -noupdate /tb_flip_flop/RW_RC_write_command
add wave -noupdate /tb_flip_flop/RW_RC_clear_command
add wave -noupdate /tb_flip_flop/RW_RC_data_out
add wave -noupdate -divider RW_R
add wave -noupdate /tb_flip_flop/RW_R_data_in
add wave -noupdate /tb_flip_flop/RW_R_write_command
add wave -noupdate /tb_flip_flop/RW_R_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 243
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
WaveRestoreZoom {0 ns} {905 ns}
