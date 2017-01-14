onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /TopTest/nh/clk
add wave -noupdate -radix hexadecimal /TopTest/nh/sw
add wave -noupdate -radix hexadecimal /TopTest/nh/key
add wave -noupdate -radix hexadecimal /TopTest/nh/hexDisplays
add wave -noupdate -radix hexadecimal /TopTest/nh/out
add wave -noupdate -radix hexadecimal /TopTest/nh/address
add wave -noupdate -radix hexadecimal /TopTest/nh/mem_data
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_products
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_sums
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_outputs
add wave -noupdate -radix hexadecimal /TopTest/nh/output_products
add wave -noupdate -radix hexadecimal /TopTest/nh/input_values
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_hidden_weights
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_output_weights
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_hidden_outputs
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_final_output
add wave -noupdate -radix hexadecimal /TopTest/nh/final_output
add wave -noupdate -radix hexadecimal /TopTest/nh/output_error
add wave -noupdate -radix binary /TopTest/nh/output_diff
add wave -noupdate -radix hexadecimal /TopTest/nh/output_inversion
add wave -noupdate -radix hexadecimal /TopTest/nh/output_err_temp
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_error
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_inversion
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_err_temp1
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_err_temp2
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_correction
add wave -noupdate -radix hexadecimal /TopTest/nh/hidden_correc_temp
add wave -noupdate -radix hexadecimal /TopTest/nh/out_correction
add wave -noupdate -radix hexadecimal /TopTest/nh/out_error_temp
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_output_error
add wave -noupdate -radix hexadecimal /TopTest/nh/stored_hidden_error
add wave -noupdate -radix hexadecimal /TopTest/nh/learn_rate
add wave -noupdate -radix hexadecimal /TopTest/nh/numIterations
add wave -noupdate -radix hexadecimal /TopTest/nh/iw
add wave -noupdate -radix hexadecimal /TopTest/nh/cs
add wave -noupdate -radix hexadecimal /TopTest/nh/ns
add wave -noupdate -radix hexadecimal /TopTest/nh/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {327683 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
configure wave -valuecolwidth 217
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {936545 ps}
