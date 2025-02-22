quit -sim
vlib work
vmap work
vlog -work work -incr "./../../src/mux.sv"
vlog -work work -incr "./../../src/demux.sv"
vlog -work work -incr tb_mux.sv
vsim -debugdb=+acc work.tb 
add wave -position insertpoint sim:/tb/*
run 1ns
seetime wave 0ns