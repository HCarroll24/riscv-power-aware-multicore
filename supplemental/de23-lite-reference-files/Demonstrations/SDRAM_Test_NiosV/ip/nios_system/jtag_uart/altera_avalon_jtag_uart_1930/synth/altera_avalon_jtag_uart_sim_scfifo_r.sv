// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 13469 16735 16788 

module altera_avalon_jtag_uart_sim_scfifo_r #(
  parameter FIFO_WIDTH = 8,
  parameter RD_WIDTHU = 6,
  parameter HEX_READ_DEPTH_STR = 64
  ) (
  // inputs:
   clk,
   fifo_rd,
   rst_n,

  // outputs:
   fifo_EF,
   fifo_rdata,
   rfifo_full,
   rfifo_used
    )
;

  output                    fifo_EF;
  output  [FIFO_WIDTH-1: 0] fifo_rdata;
  output                    rfifo_full;
  output  [RD_WIDTHU-1: 0]  rfifo_used;
  input                     clk;
  input                     fifo_rd;
  input                     rst_n;


reg     [31: 0]           bytes_left;
wire                      fifo_EF;
reg                       fifo_rd_d;
wire    [FIFO_WIDTH-1: 0] fifo_rdata;
wire                      new_rom;
wire    [31: 0]           num_bytes;
wire    [RD_WIDTHU+1: 0]  rfifo_entries;
wire                      rfifo_full;
wire    [RD_WIDTHU-1: 0]  rfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  // Generate rfifo_entries for simulation
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          bytes_left <= 32'h0;
          fifo_rd_d <= 1'b0;
        end
      else 
        begin
          fifo_rd_d <= fifo_rd;
          // decrement on read
          if (fifo_rd_d)
              bytes_left <= bytes_left - 1'b1;
          // catch new contents
          if (new_rom)
              bytes_left <= num_bytes;
        end
    end


  assign fifo_EF = bytes_left == 32'b0;
  assign rfifo_full = bytes_left > HEX_READ_DEPTH_STR;
  assign rfifo_entries = (rfifo_full) ? HEX_READ_DEPTH_STR : bytes_left;
  assign rfifo_used = rfifo_entries[RD_WIDTHU-1 : 0];
  assign new_rom = 1'b0;
  assign num_bytes = 32'b0;
  assign fifo_rdata = 8'b0;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KWfTDvi2Z9+gZZrQnBORLq1vF2Q/2gJdMC/jwTvY2B667l0Bb4LijLtyngWqE4g2sxCqwK/9nVNz7nUGoNc6vdCUgLLqZza+q5/nSAOQC1WJNQ+DZErxB+2D1G72rWOUrNLG8roOTCcNEUYx4LQphYdJNBN9B8KhpJ3nd8OzJfi61+ZPOITs7M3vq/mYkVxt+15P/XU9uEEzS1WrC2B2cJrppMPnKKTJBh9RM4W9RkWhvCgJOXDz7DG91lfgmHxVVjMQyyHDTagG8yR8YI990ZlGQ/w5+EDOpNdztjX6RFGonTmztqkOjwG7uUSHmTa/xjL37EgHRn2O3dfkiffrNL94gDKCFAGp6ACE69/fPknuvU8ttn27O8QW5h6rnAQ6wRyjS0/wHhSYPqbmn+8/GSUqusjgu0+hQLYC24s1jbtpaZvafnBkCCAZvry8wB3Lbmv2hl5z4VIDP58P9SRvnvkf53FLI3tyIpSPR8zASEjmbIX1hAlFKNp3jJeroz5wr13KdiMlJVCEjMKCcKJ/vw7rfvIU2DnMFlFTpvLBb73R33pvmOzifSbiqzqpJZEl42Rv6hN3tC9CFd2f67T1tL7NkBv06/sZz7hJ8WKA2zRX+pxsV97g7OJEOvgJf09GhHseBvrdc5ynRLGmUjQteF1OAgT3JJBV0FDUz8/qRMZxiwjnIFzbSDbc5JrOiKcNMRc8UNHA7LNokomYC611xIbFUWuVlIsMtyNzWscYhe2koWmpGT0nT2CxFLle27OxTCTnMBpH64F5qwzM93smUHNbuF7gqbyYtgKc/aEnHB49YhIM9Kcg/pXRq9dUsYEn5CE385D/tq/Jh11B27kXd7THYTWhZaA+QVRC2fz6BAbWVxXJ2VuDRCM74mRXeAXTpgm9ad+THiP4vcVPV8K7hPs+CGQZoSI480mbKw1sCdU1ZN3ABlnmnvJM3SL3oxMrx4lLJYz15HMer+xxTGYF/JXtUxsG2neeSK3EN9070MWjYQRKRyZhyBWJ2mX0gPSU"
`endif