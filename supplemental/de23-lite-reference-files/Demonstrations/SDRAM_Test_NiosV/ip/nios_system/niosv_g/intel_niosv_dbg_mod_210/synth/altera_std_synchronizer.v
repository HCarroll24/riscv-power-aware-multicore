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


// $Id: //acds/rel/25.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2025/02/06 $
// $Author: psgswbuild $
//-----------------------------------------------------------------------------
//
// File: altera_std_synchronizer.v
//
// Abstract: Single bit clock domain crossing synchronizer. 
//           Composed of two or more flip flops connected in series.
//           Random metastable condition is simulated when the 
//           __ALTERA_STD__METASTABLE_SIM macro is defined.
//           Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//           on the Verilog simulator compiler command line to 
//           enable this mode. In addition, dfine the macro
//           __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//           with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_std_synchronizer (
				clk, 
				reset_n, 
				din, 
				dout
				);

   parameter depth = 3; // This value must be >= 2 !
     
   input   clk;
   input   reset_n;    
   input   din;
   output  dout;

   // QuartusII synthesis directives:
   //     1. Preserve all registers ie. do not touch them.
   //     2. Do not merge other flip-flops with synchronizer flip-flops.
   // QuartusII TimeQuest directives:
   //     1. Identify all flip-flops in this module as members of the synchronizer 
   //        to enable automatic metastability MTBF analysis.
   //     2. Cut all timing paths terminating on data input pin of the first flop din_s1.

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]\" "} *) reg din_s1;

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    
   
   //synthesis translate_off
   initial begin
      if (depth <2) begin
	 $display("%m: Error: synchronizer length: %0d less than 2.", depth);
      end
   end

   // the first synchronizer register is either a simple D flop for synthesis
   // and non-metastable simulation or a D flop with a method to inject random
   // metastable events resulting in random delay of [0,1] cycles
   
`ifdef __ALTERA_STD__METASTABLE_SIM

   reg[31:0]  RANDOM_SEED = 123456;      
   wire  next_din_s1;
   wire  dout;
   reg   din_last;
   reg 	 random;
   event metastable_event; // hook for debug monitoring

   initial begin
      $display("%m: Info: Metastable event injection simulation mode enabled");
   end
   
   always @(posedge clk) begin
      if (reset_n == 0)
	random <= $random(RANDOM_SEED);
      else
	random <= $random;
   end

   assign next_din_s1 = (din_last ^ din) ? random : din;   

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_last <= 1'b0;
       else
	 din_last <= din;
   end

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= next_din_s1;
   end
   
`else 

   //synthesis translate_on   
   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= din;
   end
   //synthesis translate_off      

`endif

`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
   always @(*) begin
      if (reset_n && (din_last != din) && (random != din)) begin
	 $display("%m: Verbose Info: metastable event @ time %t", $time);
	 ->metastable_event;
      end
   end      
`endif

   //synthesis translate_on

   // the remaining synchronizer registers form a simple shift register
   // of length depth-1
   generate
      if (depth < 3) begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};	    
	    else
	      dreg <= din_s1;
	 end	 
      end else begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};
	    else
	      dreg <= {dreg[depth-3:0], din_s1};
	 end
      end
   endgenerate

   assign dout = dreg[depth-2];
   
endmodule 


			
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "hlK5p7gqkhZ0rrT8MCWy/4wFZTxBwK6WCX8H+0bhikwExK/0r4yZYU+FxhJFKY/hERYvL1skSLwY3blFYE2AWmRab8WKw0bR1OdvZbPuSVLw4Jt66JoXbmtKCUjKYxX2lWrLztPKnA73vY0JOm1nLX6VK8iOsSL9J7exWKXrHZDLp8T/vaj7PFkV3t5gJjreBnmO/YjqMyfe+nk54Gdq+1V99awZWin/OMNGtBY0/0iGSz9RuW4vcYPhH/hW+jG8i1qcS4NXpTn+GEubjmTwx11lbEq7FY3Q4qw/FVboHrZBbREYJD/BglTxsm3X37Ud8J+8YGupbizVe95GoXGiVIGg3OfW2DGA1+l4G5xs8fYxmm1FHD19WXNucOOL3cUdBYICGt22E9GKfJwsBHOxWAgnv8RllpmxdjQ7moHzTQSeix9bRUBxvBwFFxbY3JlYFW17BK8ATpHZHciGtwbAckfKzki4Qg3ZHYluFbUR2CgZkGbugf98WOoTyZavJv+0ML9hVedMuDtXlAm1ZvbG3t73awQ2nSV0Ng4Z2QwXyT9MvqRSHd2mSZ2JsOv9gNVSATy32IKhEVr3RJCQ42pPYY/iDpzc1DxrvWLRWzL8VS4fSQ9gNEUc8f0cD8OxtfzIlplTtbBiPJaKaZq0PpaPdiEl/nDWSJOIDan+TFmVuPGNerJYEUlRJlG78/cL94+qYzWZAm/6KEqgZZzQEQX3KtyL9TDJFbD071fliB/xceK0gQKBTQgmS7EWv5U/8C4kegZ5yPaMzbYgUUxUj5/TYJri4ahlrTMw6eTvoi9xHRmQwRqJuXr2hur4J+fzH4rgLLorZ4zjaOlc99GE4qiyJR0TwxDHqtT+mPy+hqh43xLDncQqF8e0lXzH/ItB+AYvTnoCatr2oGzhjXBoiGGYYaeA1/fDJrcgq754cFzlZtsk1kXq8ITu+qGgD/s8ZVwZ5P3/qDJQkTalejS6Wm7inXkAe+X6zMf/atppZSiZ2DDzOmQdFTEphIGnHbFJ+Hto"
`endif