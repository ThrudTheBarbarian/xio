transcript on

#
# New libraries
#
if {[file exists work]} {
	vdel -lib work -all
}
vlib work

#
# Compile the testbench and its dependencies
#
vmap work work
vlog -sv -work work {defines.sv}
vlog -sv -work work {xio.sv}
vlog -sv -work work {xio_tb.sv}
vlog -sv -work work {xio_tb.sv}
vlog -sv -work work {BusMonitor.sv}
vlog -sv -work work {Aperture.sv}
vlog -sv -work work {priorityEncoder.sv}

#
# Start simulation
#
vsim -t 1ps -L work -voptargs="+acc"  work.xio_tb

#
# Look at everything
#
log -r /*


# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave /xio_tb/clk
add wave /xio_tb/a8_clk
add wave -color white /xio_tb/a8_rst_n

add wave -height 40 -divider {outputs}
add wave -color yellow -radix hex /xio_tb/a8_addr
add wave -color {green yellow} /xio_tb/a8_rw
add wave -color red -radix hex /xio_tb/a8d_pin

add wave -height 40 -divider {internals}
add wave -color blue -radix hex  sim:/xio_tb/dut/aperture_gen[0]/aperture/apCfg
add wave -color blue -radix hex  sim:/xio_tb/dut/aperture_gen[0]/aperture/apCfgValid
add wave -color green -radix hex sim:/xio_tb/dut/sdramAddr

view wave

## part 6: run 
run -all

