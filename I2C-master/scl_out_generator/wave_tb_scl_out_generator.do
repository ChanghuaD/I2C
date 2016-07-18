onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_scl_out_generator/clk_50MHz
add wave -noupdate /tb_scl_out_generator/rst_variable
add wave -noupdate /tb_scl_out_generator/clk_ena
add wave -noupdate /tb_scl_out_generator/scl_tick
add wave -noupdate /tb_scl_out_generator/uut/state
add wave -noupdate /tb_scl_out_generator/scl_out
add wave -noupdate /tb_scl_out_generator/scl_in_slow
add wave -noupdate /tb_scl_out_generator/scl_in_fast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 253
configure wave -valuecolwidth 80
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
WaveRestoreZoom {149212 ns} {150692 ns}
