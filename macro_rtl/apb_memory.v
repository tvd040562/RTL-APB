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
