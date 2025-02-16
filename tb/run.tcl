quit -sim
vlib work
vmap work
vlog -work work -incr "./../src/delay_line.sv"
vlog -work work -incr tb_delay_line.sv
vsim -debugdb=+acc work.tb 
add wave -position insertpoint sim:/tb/dut/*
run 1ns