set current_design apb_slave
#set ::env(CLOCK_PORT) [get_pins {pclk}]
#set ::env(CLOCK_NET) {core.CLK}

create_clock $::env(CLOCK_PORT) -name $::env(CLOCK_PORT) -period $::env(CLOCK_PERIOD)
set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_DELAY_CONSTRAINT)]
set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_DELAY_CONSTRAINT)]
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]
set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]

set_input_delay $input_delay_value  -clock [get_clocks $::env(CLOCK_PORT)] [all_inputs]
set_output_delay $output_delay_value  -clock [get_clocks $::env(CLOCK_PORT)] [all_outputs]

set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]
#set_false_path -through u_mem/wen
#set_false_path -through u_mem/ren
#set_multicycle_path -to mem.u_ram/csb0 2
#set_multicycle_path -to mem.u_ram/csb1 2
