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
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_avalon_sysid_qsys #(
    parameter ID_VALUE   = 1,
    parameter TIMESTAMP  = 1
)(
    // inputs:
     address,
     clock,
     reset_n,
    
    // outputs:
     readdata
)
;

  output  [ 31: 0] readdata;
  input            address;
  input            clock;
  input            reset_n;

  wire    [ 31: 0] readdata;
  //control_slave, which is an e_avalon_slave
  assign readdata = address ? TIMESTAMP : ID_VALUE;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KWfTDvi2Z9+gZZrQnBORLq1vF2Q/2gJdMC/jwTvY2B667l0Bb4LijLtyngWqE4g2sxCqwK/9nVNz7nUGoNc6vdCUgLLqZza+q5/nSAOQC1WJNQ+DZErxB+2D1G72rWOUrNLG8roOTCcNEUYx4LQphYdJNBN9B8KhpJ3nd8OzJfi61+ZPOITs7M3vq/mYkVxt+15P/XU9uEEzS1WrC2B2cJrppMPnKKTJBh9RM4W9RkVd+hyFpFVj0bGqHvLrKf3xPa0zlnmnY4h0MbCXYAwJtFj6OHO+XaHmjN8rjceayiwx2D8G96LkdbHPKyglZn6iak1SDl+GOvLiXHxXGUMkNP0nntdUVOHEIIU+jTEU/cFqNVFaD5+hHYTJEITyzjEQL1squ3dNm98vHdqkC/O2Md6mAd/4+j6AQ8iddz5MZUzeWcmTsDqR1TkjhPy6edHAF29BgX3lTa89EZb17rxg0kVVNVQoBCiPbVGDjVK9/4sl+3B59Bs4kNAlZVh2ANI3EBzYrSMcX748t5VhNe8zzmVi/sHwdvDiIqAUwMh9lsyF2ZbNCqoGgYSa+Q0xL0K0yvbIsz+poASJg9vvEvLbEoWgtRgu48M+5Ykt/LXcgEkQRUh00R7Hjuei/S92uc7gMRZaFaDOyzCr1a+u9hVstyB5AUTHv9Xysjq39soEAc1N4kCEgtpu+skjwusDhMnGwgrBu9Ukmo8W/93dJsXrDXDDJCHJ/mhpqqKbEBevRaBciCuXdT1V/yTExUhAOG9AtK/fViNnXMqAPpZVOHupYmRqn9gsbzqd2/+A3hyEDVWASfSJhW2odfDJCTX7gwSfrxWsgV74pSitSvo5Fr5VxuXHYa5PtSDJOt06zEYgCp1j4NYADLVvWfG5S4Ux1SPpI5+HZj5NMTDY3nPTDw5gOG5naf8PzpKHragj9jgVL9elPbsP8UExxAsRBUfMFsZuXIBvBbLvK7/G/Ty4ZhPr4xfep6+sF1YqsoExWD81mnVSJ0VQrLXXAH79KiYFvXOl"
`endif