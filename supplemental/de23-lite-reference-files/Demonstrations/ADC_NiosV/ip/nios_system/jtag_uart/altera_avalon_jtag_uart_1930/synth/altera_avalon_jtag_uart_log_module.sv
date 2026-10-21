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

module altera_avalon_jtag_uart_log_module #(
  parameter FIFO_WIDTH = 8
  ) (
  // inputs:
   clk,
   data,
   strobe,
   valid
    )
;

  input                     clk;
  input   [FIFO_WIDTH-1: 0] data;
  input                     strobe;
  input                     valid;



//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
   reg [31:0] text_handle; // for $fopen
   initial text_handle = $fopen ("altera_avalon_jtag_uart_output_stream.dat");

   always @(posedge clk) begin
      if (valid && strobe) begin
	 // Send \n (linefeed) instead of \r (^M, Carriage Return)...
         $fwrite (text_handle, "%s", ((data == 8'hd) ? 8'ha : data));
	 // non-standard; poorly documented; required to get real data stream.
	 $fflush (text_handle);
      end
   end // clk


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KWfTDvi2Z9+gZZrQnBORLq1vF2Q/2gJdMC/jwTvY2B667l0Bb4LijLtyngWqE4g2sxCqwK/9nVNz7nUGoNc6vdCUgLLqZza+q5/nSAOQC1WJNQ+DZErxB+2D1G72rWOUrNLG8roOTCcNEUYx4LQphYdJNBN9B8KhpJ3nd8OzJfi61+ZPOITs7M3vq/mYkVxt+15P/XU9uEEzS1WrC2B2cJrppMPnKKTJBh9RM4W9RkWnYAK8EUQdC4Zj9Dk6ZJwRV0xyEyl83de121g+QoFtBHhLo4v0S0m6xgcL5yuA69x2/PAu5r6SyrbJBXl6N0Jf7RpCJVb/S9HfFRaCi7YMh9d4RlYel4fzRH91IEc4KbA0VLFRfXCnvYSacg2MArpnYazTePah0rI6zMVKFeag1ey20r6M0c+XWLiShmVKtZCYTl53AEUwf21TiP/js9cBtyOu7zk5PNKOZ4HbEfXmnH/psteEBfP9jgxiRo7OWqhh1kCsXJl71kBCVqxGCVsXEgmyz5Q28K9XKI1oJE0h2cGUuJLBp1HughdIlgarTnhcrpUI1OaXECFaRuMdP+NUBhfU3bwXZKb7bbjokhhiSBcsnuCaAc9F00vSMIcCSCH4+eXf/bp/cp/3Uwll3tK972O143JPrNwECcyeLydP5NYmpAzeBNWQQgqSH8uSGXnmk1PznzbmZBW5o3Zz5P/SgpQun5lIVfKTPt5PeGRAmDnmacNeSL1kfhjw7kjkO6NJZ8lUt/TmkbOdNtxKyEPXa2nyaPt8IdafF+e8AOw3KnQSxtl5LiVC26uQdYFzGaej7hvQMRYcUVyrwiUnoo2Ur+35G3FhXjiJV6fhMTCmRQms88izaii4SAImHGbAWgAXrRrh7ZrcZ9zfMPhBrQBOTifJycOktjxdlXapNuIVC93GbQgTfBQAkitKK4zD+pQH2afxyRUUI3sxxnq1sz/1rJfSRTrbbc3PGdqQ5gIpuC1na9BtXM2OX/5wdkTPU06rCp76BwDTMPk3FIgCIq3Q"
`endif