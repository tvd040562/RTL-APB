module apb_master (
  pclk,
  paddr,
  pwrite,
  psel,
  penable,
  pwdata,
  prdata,
  pready);

  input pclk;
  output reg [3:0] paddr;
  output reg pwrite;
  output reg psel;
  output reg penable;
  output reg [7:0] pwdata;
  output reg [7:0] prdata;
  input pready;
  reg ren, wen;
  
  assign wen = psel & penable & pwrite;
  assign ren = psel & penable & !pwrite;
  assign prdata = ren ? test_rd_data : 0;

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

  reg [7:0] test_rd_data;
  initial begin
    test_rd_data = 55;
  end

  task apb_read(input [3:0] addr);
  begin
    pwrite = 0;
    psel = 1;
    penable = 0;
    paddr = addr;
    wait4clk(1);
    penable = 1;
    wait4clk(1);
    $display("Read data: %d", test_rd_data++);
    psel = 0;
  end
  endtask
endmodule

`define PERIOD 10

module tb();
  logic clk;
  reg [7:0] prdata;

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
    apb_m.wait4clk(1);
    apb_m.apb_read(1);
    apb_m.wait4clk(1);
    apb_m.apb_read(2);
    apb_m.wait4clk(1);
    apb_m.apb_read(3);
    apb_m.wait4clk(1);
    apb_m.apb_read(4);
    apb_m.wait4clk(2);
    $finish;
  end
endmodule
