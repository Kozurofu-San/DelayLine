quit -sim
vlib work
vmap work
vlog -work work -incr "./../../src/regs_s_spi.sv"
vlog -work work -incr tb_regs.sv
vsim -debugdb=+acc work.tb 
add wave -position insertpoint sim:/tb/dut/*
run 1ns
seetime wave 0ns