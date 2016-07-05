rm -rf work
vlib work
vlog -sv ../RTL/dumping/random_index_block.sv
vlog -sv ../RTL/dumping/tb_dumping.sv
vsim -c -novopt tb -do "run -all"
