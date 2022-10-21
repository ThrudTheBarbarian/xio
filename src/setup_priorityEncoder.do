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
vlog -sv -work work {priorityEncoder.sv}
vlog -sv -work work {priorityEncoder_tb.sv}

#
# Start simulation
#
vsim -t 1ps -L work -voptargs="+acc"  work.PriorityEncoder_tb

#
# Look at everything
#
log -r /*


# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave /PriorityEncoder_tb/clk

add wave -height 40 -divider {outputs}
add wave -color yellow /PriorityEncoder_tb/inputs
add wave -color yellow /PriorityEncoder_tb/result

view wave

## part 6: run 
run -all

