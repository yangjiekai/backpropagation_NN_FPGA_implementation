transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/cycloneiv_hssi_ver
vmap cycloneiv_hssi_ver ./verilog_libs/cycloneiv_hssi_ver
vlog -vlog01compat -work cycloneiv_hssi_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/cycloneiv_hssi_atoms.v}

vlib verilog_libs/cycloneiv_pcie_hip_ver
vmap cycloneiv_pcie_hip_ver ./verilog_libs/cycloneiv_pcie_hip_ver
vlog -vlog01compat -work cycloneiv_pcie_hip_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/cycloneiv_pcie_hip_atoms.v}

vlib verilog_libs/cycloneiv_ver
vmap cycloneiv_ver ./verilog_libs/cycloneiv_ver
vlog -vlog01compat -work cycloneiv_ver {c:/altera/13.0sp1/quartus/eda/sim_lib/cycloneiv_atoms.v}

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {XOR_6_1200mv_85c_slow.vo}

vlog -sv -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/ChipInterface.sv}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/multiplier_32.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/multiplier_16.v}
vlog -sv -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/fixed_point_multiplier.sv}
vlog -sv -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/sigmoid.sv}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/adder4_32.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/FP_MUL.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/FP_MUL_bb.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/mu.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/FP_Mu.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/test_bench_tb.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/file_reader_a.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/file_reader_b.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/file_writer.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/multiplier.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR/multiplier {C:/NN_FPGA/XOR/multiplier/test_bench.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/int_to_float.v}
vlog -vlog01compat -work work +incdir+C:/NN_FPGA/XOR {C:/NN_FPGA/XOR/CONVERT.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L gate_work -L work -voptargs="+acc"  TopTest

add wave *
view structure
view signals
run -all
