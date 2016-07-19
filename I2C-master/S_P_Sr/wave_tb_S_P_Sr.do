onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_s_p_sr/clk_50MHz
add wave -noupdate /tb_s_p_sr/rst_variable
add wave -noupdate /tb_s_p_sr/sda_out
add wave -noupdate /tb_s_p_sr/rst_1
add wave -noupdate /tb_s_p_sr/ena_1
add wave -noupdate /tb_s_p_sr/casc_in_1
add wave -noupdate /tb_s_p_sr/clk_ena
add wave -noupdate /tb_s_p_sr/scl_tick
add wave -noupdate /tb_s_p_sr/scl_in_fast
add wave -noupdate /tb_s_p_sr/scl_in_slow
add wave -noupdate /tb_s_p_sr/rising_point
add wave -noupdate /tb_s_p_sr/writing_point
add wave -noupdate /tb_s_p_sr/falling_point
add wave -noupdate /tb_s_p_sr/sampling_point
add wave -noupdate /tb_s_p_sr/stop_point
add wave -noupdate /tb_s_p_sr/start_point
add wave -noupdate /tb_s_p_sr/error_point
add wave -noupdate /tb_s_p_sr/scl_out
add wave -noupdate -divider Start
add wave -noupdate /tb_s_p_sr/command_start
add wave -noupdate /tb_s_p_sr/CTL_start
add wave -noupdate /tb_s_p_sr/sda_out_S
add wave -noupdate /tb_s_p_sr/M_start_generator/state
add wave -noupdate -divider Stop
add wave -noupdate /tb_s_p_sr/command_stop
add wave -noupdate /tb_s_p_sr/CTL_stop
add wave -noupdate /tb_s_p_sr/sda_out_P
add wave -noupdate /tb_s_p_sr/M_stop_generator/state
add wave -noupdate -divider Restart
add wave -noupdate /tb_s_p_sr/command_restart
add wave -noupdate /tb_s_p_sr/CTL_restart
add wave -noupdate /tb_s_p_sr/sda_out_Sr
add wave -noupdate /tb_s_p_sr/M_restart_generator/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59866 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
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
WaveRestoreZoom {41954 ns} {82896 ns}
