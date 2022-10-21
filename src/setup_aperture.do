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
vlog -sv -work work {Aperture.sv}
vlog -sv -work work {Aperture_tb.sv}

#
# Start simulation
#
vsim -t 1ps -L work -voptargs="+acc"  work.Aperture_tb

#
# Look at everything
#
log -r /*


# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave /Aperture_tb/clk
add wave /Aperture_tb/a8_rst_n
add wave -position end -radix hex sim:/Aperture_tb/a8_addr
add wave sim:/Aperture_tb/aValid
add wave -position end -radix hex sim:/Aperture_tb/a8_data
add wave -position end  sim:/Aperture_tb/a8_rw_n
add wave -position end  sim:/Aperture_tb/wValid
add wave -position end  -radix hex -color yellow sim:/Aperture_tb/apCfg
add wave -position end  -radix hex -color yellow sim:/Aperture_tb/apCfgValid
add wave -position end  -radix hex -color yellow sim:/Aperture_tb/inRange
add wave -position end  -radix hex -color yellow sim:/Aperture_tb/baseAddr

view wave

## part 6: run 
run -all

