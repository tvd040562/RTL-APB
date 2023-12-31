`define WCYC 0
`define USE_POWER_PINS

module apb_memory (
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
  pclk,
  rst_n,
  paddr,
  wen,
  ren,
  pwdata,
  prdata);

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input pclk;
  input rst_n;
  input [3:0] paddr;
  input wen;
  input ren;
  input [7:0] pwdata;
  output [7:0] prdata;

  `ifndef USE_RAM_MODEL
  `ifdef MACRO_SYN 
  reg [7:0] mem[16];
  reg [7:0] rdata;
  reg write_data;

  //assign prdata = ren ? mem[paddr] : 0;
  assign prdata = rdata;

  always @(posedge pclk or negedge rst_n) begin
    if (!rst_n)
      rdata = 0;
    else if (ren)
      rdata = mem[paddr];
  end

  always @(posedge pclk or negedge rst_n) begin
    if (!rst_n)
      write_data = 0;
    else if (wen && !write_data) begin
      write_data = 1;
      mem[paddr] = pwdata;
    end
    else if (write_data && !wen) begin
      write_data = 0;
    end
  end
  `endif
  `else
    sky130_sram_16byte_1r1w u_ram
      (.clk0(pclk),
       .csb0(!wen),
       .addr0(paddr),
       .din0(pwdata),
       .clk1(pclk),
       .csb1(!ren),
       .addr1(paddr),
       .dout1(prdata)
     );
   `endif

endmodule

module apb_slave (
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
  input rst_n;
  input reg [3:0] paddr;
  input reg pwrite;
  input reg psel;
  input reg penable;
  input reg [7:0] pwdata;
  output reg [7:0] prdata;
  output pready;
  reg ren, wen, ready;
  
  apb_memory u_mem (
    .pclk(pclk),
    .rst_n(rst_n),
    .paddr(paddr),
    .wen(wen),
    .ren(ren),
    .pwdata(pwdata),
    .prdata(prdata)
  );

  assign wen = psel & penable & pwrite & ready;
  assign ren = psel & penable & !pwrite;
  assign #0 pready = ready;
  reg [2:0] wcnt;

  always @(posedge pclk or negedge rst_n) begin
    if (!rst_n)
    begin
      ready = 1;
      wcnt = `WCYC;
    end
    else if (psel && penable && (wcnt > 0))
    begin
      ready = 0;
      wcnt = wcnt-1;
    end
    else
    begin
      ready = 1;
      wcnt = `WCYC;
    end
  end


endmodule

