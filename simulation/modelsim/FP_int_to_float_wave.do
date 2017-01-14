onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TopTest/clk
add wave -noupdate /TopTest/sw
add wave -noupdate /TopTest/key
add wave -noupdate /TopTest/finalVal
add wave -noupdate /TopTest/hexDisplays
add wave -noupdate /TopTest/dataa
add wave -noupdate /TopTest/datab
add wave -noupdate /TopTest/result
add wave -noupdate -expand /TopTest/inttofloat/output_z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 281
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {184671 ps}
