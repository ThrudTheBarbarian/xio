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
vlog -sv -work work {BusMonitor.sv}
vlog -sv -work work {BusMonitor_tb.sv}

#
# Start simulation
#
vsim -t 1ps -L work -voptargs="+acc"  work.BusMonitor_tb

#
# Look at everything
#
log -r /*


# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave /BusMonitor_tb/clk
add wave /BusMonitor_tb/a8_clk
add wave -color white /BusMonitor_tb/a8_rst_n

add wave -height 40 -divider {outputs}
add wave -color yellow /BusMonitor_tb/a8_addr_strobe
add wave -color yellow /BusMonitor_tb/a8_write_strobe
add wave -color yellow /BusMonitor_tb/a8_read_strobe
add wave -color yellow /BusMonitor_tb/a8_clk_falling

view wave

## part 6: run 
run -all

