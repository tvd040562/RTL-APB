`define PERIOD 10

module apb_master (
  pclk,
  rst_n,
  paddr,
  pwrite,
  psel,
  penable,
  pwdata,
  prdata,
  pready);

  input pclk;
  output reg rst_n;
  output reg [3:0] paddr;
  output reg pwrite;
  output reg psel;
  output reg penable;
  output reg [7:0] pwdata;
  input reg [7:0] prdata;
  input pready;
  
  task wait4clk(integer n);
  begin
    repeat (n)
      @(posedge pclk);
  end
  endtask

  task reset;
  begin
    rst_n = 0;
    wait4clk(4);
    rst_n = 1;
    wait4clk(2);
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
    while (!pready)
    	wait4clk(1);
    psel = 0;
    penable = 0;
  end
  endtask

  task apb_read(input [3:0] addr);
  begin
    pwrite = 0;
    psel = 1;
    penable = 0;
    paddr = addr;
    wait4clk(1);
    penable = 1;
    wait4clk(1);
    while (!pready)
    	wait4clk(1);
    $display("Read data: %d", prdata);
    penable = 0;
    psel = 0;
  end
  endtask
endmodule

module tb();
  logic clk, sclk;
  logic rst_n;
  reg [3:0] paddr;
  logic pwrite;
  logic psel;
  logic penable;
  reg [7:0] pwdata;
  reg [7:0] prdata;
  logic pready;

  initial begin
    clk = 0;
    forever
      #(`PERIOD/2) clk = ~clk;
  end

  assign #0 sclk = clk;

  apb_master apb_m(
    .pclk(clk),
    .rst_n(rst_n),
    .paddr(paddr),
    .pwrite(pwrite),
    .psel(psel),
    .penable(penable),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );

  apb_slave apb_s(
    .pclk(sclk),
    .rst_n(rst_n),
    .paddr(paddr),
    .pwrite(pwrite),
    .psel(psel),
    .penable(penable),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0,tb);
    apb_m.reset();
    apb_m.wait4clk(2);
    apb_m.apb_write(2,5);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_write(3,10);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_write(4,5);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_write(5,10);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_read(1);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_read(2);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_read(3);
    `ifdef GAPCLK
      apb_m.wait4clk(1);
    `endif
    apb_m.apb_read(4);
    apb_m.wait4clk(2);
    $finish;
  end
endmodule
