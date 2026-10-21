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


// $Id: //acds/rel/25.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer_bundle.v#1 $
// $Revision: #1 $
// $Date: 2025/02/06 $
//----------------------------------------------------------------
//
// File: altera_std_synchronizer_bundle.v
//
// Abstract: Bundle of bit synchronizers. 
//           WARNING: only use this to synchronize a bundle of 
//           *independent* single bit signals or a Gray encoded 
//           bus of signals. Also remember that pulses entering 
//           the synchronizer will be swallowed upon a metastable
//           condition if the pulse width is shorter than twice
//           the synchronizing clock period.
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//----------------------------------------------------------------

module altera_std_synchronizer_bundle(
				     clk,
				     reset_n,
				     din,
				     dout
				     );
   parameter width = 1;
   parameter depth = 3;   
   
   input clk;
   input reset_n;
   input [width-1:0] din;
   output [width-1:0] dout;
   
   generate
      genvar i;
      for (i=0; i<width; i=i+1)
	begin : sync
	   altera_std_synchronizer #(.depth(depth))
                                   u (
				      .clk(clk), 
				      .reset_n(reset_n), 
				      .din(din[i]), 
				      .dout(dout[i])
				      );
	end
   endgenerate
   
endmodule 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "hlK5p7gqkhZ0rrT8MCWy/4wFZTxBwK6WCX8H+0bhikwExK/0r4yZYU+FxhJFKY/hERYvL1skSLwY3blFYE2AWmRab8WKw0bR1OdvZbPuSVLw4Jt66JoXbmtKCUjKYxX2lWrLztPKnA73vY0JOm1nLX6VK8iOsSL9J7exWKXrHZDLp8T/vaj7PFkV3t5gJjreBnmO/YjqMyfe+nk54Gdq+1V99awZWin/OMNGtBY0/0iHv/Ucc9pGApkG5Hagdz7zseWLk2UGMXwQoYoLQuhPegaWXoLsqtLcp4JdZC+rmUHxd4+6ZIUhvtwjEVdJMNQwXMHg0nJT0c/2IBCOuTDKgy0DC2LC5KLxrU2hXHFzEU87DTW8SHne4ObSRHjw68FfCtUdCpRTFSSNnwVKvT+69YiokwpC024tp4A6Q+G/dQ1Pyi3bFlQZY1tfcenH0OxWMBMVdjHKT6p6w9ZRMa60yeiVckRZkC53qdlONSSXQg1UmKDNbq8W9iv17WpoO2cuXawo5vw4BYnK/MQ6LT0JIMYgw2w1tqN3LXwaVsXGxrgS21KtZpT5Sp3a4zaBqva2upgXjfthzejSxaHx4+Ivtt+PLzpyBOvWOk0teHytmILX6DWfqe5CiX1fYTcHzzqHCTVBA5eFE9ziDHpr1V6B35Gnk860JEWtxH0jjjTU7yckKIN6MTbkj+Mt9FVl9nRfx3FjzmZxo4xXYjYEY3Id0sqHooOjtJfE1jtMyWIeSv/c60UKboKk4VxDTaGGkNLkBiZpZsoDjqDKn6Pu8OtIAwoamzFKSiuPYBKy77wJrRRsz9WU04sDSdJnikpQnV7OrYbEgZxcUG/Obz5EXW87SMRRGXbBD2pmxoI3nkykYiNLX9zsTkOECbv7LNbj645zEvkv2IvDgOfvqDA3ikBXDKYL8qqKJbuhEMsl5+/AF76zYO4ppx3Q32pH3t7m5MK5neayDM9uHXxtFzuhxC7zPt5rGqKozFP0UdBeBTeZ1Os+bpIhdMsuEPy/Hvb1HCXP"
`endif