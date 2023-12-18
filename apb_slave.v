`define WCYC 2

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
  reg ren, wen, ready, data_chg;
  reg [7:0] test_rd_data;
  
  assign wen = psel & penable & pwrite;
  assign ren = psel & penable & !pwrite;
  assign prdata = ren ? test_rd_data : 0;
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

  always @(posedge pclk or negedge rst_n) begin
    if (!rst_n) begin
      data_chg = 0;
      test_rd_data = 55;
    end
    else if (ren && !data_chg)
      data_chg = 1;
    if (data_chg && !ren) begin
      data_chg = 0;
      test_rd_data++;
    end
  end

endmodule

