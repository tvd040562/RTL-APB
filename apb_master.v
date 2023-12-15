module apb_master (
  pclk,
  paddr,
  pwrite,
  psel,
  penable,
  pwdata,
  pready);

  input pclk;
  output reg [3:0] paddr;
  output reg pwrite;
  output reg psel;
  output reg penable;
  output reg [7:0] pwdata;
  input pready;

  task wait4clk(integer n);
  begin
    repeat (n)
      @(posedge pclk);
  end
  endtask

  task apb_write(input [3:0] addr, input [7:0] data);
  begin
    pwrite = 1;
    psel = 1;
    penable = 0;
    paddr = addr;
    pwdata = data;
    wait4clk(1);
    penable = 1;
    wait4clk(1);
    psel = 0;
  end
  endtask
endmodule

`define PERIOD 10

module tb();
  logic clk;

  initial begin
    clk = 0;
    forever
      #(`PERIOD/2) clk = ~clk;
  end

  apb_master apb_m(.pclk(clk));

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0,tb);
    apb_m.wait4clk(2);
    apb_m.apb_write(2,5);
    apb_m.wait4clk(1);
    apb_m.apb_write(3,10);
    apb_m.wait4clk(1);
    apb_m.apb_write(4,5);
    apb_m.wait4clk(1);
    apb_m.apb_write(5,10);
    apb_m.wait4clk(2);
    $finish;
  end
endmodule
