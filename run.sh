iverilog -g2005-sv -DUSE_RAM_MODEL apb_master.v apb_slave.v RAM/sky130_sram_16byte_1r1w.v -o run;./run;gtkwave tb.vcd
#iverilog -g2005-sv -DGAPCLK -DUSE_RAM_MODEL apb_master.v apb_slave.v RAM/sky130_sram_16byte_1r1w.v -o run;./run;gtkwave tb.vcd
