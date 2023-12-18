#iverilog -g2005-sv apb_master.v apb_slave.v -o run;./run;gtkwave tb.vcd
iverilog -g2005-sv -DGAPCLK apb_master.v apb_slave.v -o run;./run;gtkwave tb.vcd
