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

module altera_avalon_jtag_uart_scfifo_r #(
  parameter FIFO_WIDTH = 8,
  parameter RD_WIDTHU = 6,
  parameter read_le = "ON",
  parameter readBufferDepth = 64,
  parameter HEX_READ_DEPTH_STR = 64
  ) (
  // inputs:
   clk,
   fifo_clear,
   fifo_rd,
   rst_n,
   t_dat,
   wr_rfifo,

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
  input                     fifo_clear;
  input                     fifo_rd;
  input                     rst_n;
  input   [FIFO_WIDTH-1: 0] t_dat;
  input                     wr_rfifo;


wire                      fifo_EF;
wire    [FIFO_WIDTH-1: 0] fifo_rdata;
wire                      rfifo_full;
wire    [RD_WIDTHU-1: 0]  rfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  altera_avalon_jtag_uart_sim_scfifo_r
  #(
      .FIFO_WIDTH         (FIFO_WIDTH),
      .RD_WIDTHU          (RD_WIDTHU),
      .HEX_READ_DEPTH_STR (HEX_READ_DEPTH_STR)
   )
altera_avalon_jtag_uart_sim_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n)
    );


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  scfifo rfifo
//    (
//      .aclr (fifo_clear),
//      .sclr (1'b0),
//      .clock (clk),
//      .data (t_dat),
//      .empty (fifo_EF),
//      .full (rfifo_full),
//      .q (fifo_rdata),
//      .rdreq (fifo_rd),
//      .usedw (rfifo_used),
//      .wrreq (wr_rfifo)
//    );
//
//  defparam rfifo.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
//           rfifo.lpm_numwords = readBufferDepth,
//           rfifo.lpm_showahead = "OFF",
//           rfifo.lpm_type = "scfifo",
//           rfifo.lpm_width = FIFO_WIDTH,
//           rfifo.lpm_widthu = RD_WIDTHU,
//           rfifo.overflow_checking = "OFF",
//           rfifo.underflow_checking = "OFF",
//           rfifo.use_eab = read_le;
//
//synthesis read_comments_as_HDL off

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KWfTDvi2Z9+gZZrQnBORLq1vF2Q/2gJdMC/jwTvY2B667l0Bb4LijLtyngWqE4g2sxCqwK/9nVNz7nUGoNc6vdCUgLLqZza+q5/nSAOQC1WJNQ+DZErxB+2D1G72rWOUrNLG8roOTCcNEUYx4LQphYdJNBN9B8KhpJ3nd8OzJfi61+ZPOITs7M3vq/mYkVxt+15P/XU9uEEzS1WrC2B2cJrppMPnKKTJBh9RM4W9RkVlyyUpDDNOsX32u8XbIBpFDkUSO+79jUA0EyTGpAjPUx/ievQGJto1hXf6v9hu1Y/ydCN1XbonNM8eGP/4e5m08IMZRXFBGM5f95CiniZd2ZvRh2U9wC0NyZX6oVzooGOBwpMkBduOopUn5aSofu6+XTyIRPPS1bidSu7QiVMZr9r3+3nozqF2HjkO+ae7v+jLvm3NnGPbH2Pnb4g1+9KrZdfTrTLhDBX/jrhJLxGAtYl6rVXaqhYrsJqmeRBdo6TegzV0TS1S/t6IAdBt+svxc99VwOC2VRUDFUPmy4fvRbzEjCWWjOYfvW57qiLzigi03UkIsi4GHAjbGNhZnhDOqStHTsmMKKXr49PjI7CA1Xi73ClrH806t7CQ1JkROVOMnpJPSP10kQkCujfbpAL3WFNj9dDAfJwi/m6SvkiG2CgPW7GJYnPi9MH4yU8vn5iXksIawzyUPxUhQWjUSXEda5h6Cxt5fuH4GxiBA6eThazYDA96NQVGNx1+UpH/OjtdVw6a8Qao/Rc5G3lwTrp6wvsBbV23B9LOk6q6r47TFuyYk7EVUtGFaXugea5Huyz6YnINiN1f3ZXiQlRIPKVONDtBCnd5oAMffW6xGE+M0qG1ExzgffZB8B6z3mVzBD1o3r/4UObXhofcRI6c/jAhyLT3s9RY9cVK/X7gGQkhRdhyftGW30hvjL+LhEzxNsGsoROHVDODr4q3WXNt6Ngb9ny2qkMKwA/iPw57TUx9em6sznJMHiIr0We3aplC8QnnlkxuUPDNL63mILjuWf8v"
`endif