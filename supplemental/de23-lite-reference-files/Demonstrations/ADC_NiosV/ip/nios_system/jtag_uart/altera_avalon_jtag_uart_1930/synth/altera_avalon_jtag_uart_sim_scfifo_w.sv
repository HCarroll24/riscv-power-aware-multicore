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

module altera_avalon_jtag_uart_sim_scfifo_w #(
  parameter FIFO_WIDTH = 8,
  parameter WR_WIDTHU = 6,
  parameter printingMethod = 0
  ) (
  // inputs:
   clk,
   fifo_wdata,
   fifo_wr,
   rst_n,

  // outputs:
   fifo_FF,
   r_dat,
   wfifo_empty,
   wfifo_used
    )
;

  output                    fifo_FF;
  output  [FIFO_WIDTH-1: 0] r_dat;
  output                    wfifo_empty;
  output  [WR_WIDTHU-1: 0]  wfifo_used;
  input                     clk;
  input   [FIFO_WIDTH-1: 0] fifo_wdata;
  input                     fifo_wr;
  input                     rst_n;


wire                            fifo_FF;
wire  [FIFO_WIDTH-1: 0]         r_dat;
wire                            wfifo_empty;
wire  [WR_WIDTHU-1: 0]          wfifo_used;


`ifndef QUARTUS_CDC
//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  altera_avalon_jtag_uart_log_module
    #(
      .FIFO_WIDTH (FIFO_WIDTH)
     )

altera_avalon_jtag_uart_log
    (
      .clk    (clk),
      .data   (fifo_wdata),
      .strobe (fifo_wr),
      .valid  (fifo_wr)
    );

string str_buf = "";

generate
  if (printingMethod == 0)
  begin
    always @(posedge clk)
      begin
        if (fifo_wr)
          $write("%c", fifo_wdata);
      end
    end

  else if (printingMethod == 1)
  begin
    always @(posedge clk or negedge rst_n)
      begin
        if (rst_n == 0)
          begin
            str_buf = "";
          end
        else if (fifo_wr)
          begin
            str_buf = $sformatf("%s%c", str_buf, fifo_wdata);
            if (fifo_wdata == "\n")
              begin
                #2 $write("%s", str_buf);
                str_buf = "";
              end
          end
      end
  end
endgenerate

  assign wfifo_used = {WR_WIDTHU{1'b0}};
  assign r_dat = {FIFO_WIDTH{1'b0}};
  assign fifo_FF = 1'b0;
  assign wfifo_empty = 1'b1;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KWfTDvi2Z9+gZZrQnBORLq1vF2Q/2gJdMC/jwTvY2B667l0Bb4LijLtyngWqE4g2sxCqwK/9nVNz7nUGoNc6vdCUgLLqZza+q5/nSAOQC1WJNQ+DZErxB+2D1G72rWOUrNLG8roOTCcNEUYx4LQphYdJNBN9B8KhpJ3nd8OzJfi61+ZPOITs7M3vq/mYkVxt+15P/XU9uEEzS1WrC2B2cJrppMPnKKTJBh9RM4W9RkX/46/LzJFwE4mlfkYX++MxtbqGdKSB8GlldmcXFnlGE6RZCZ0/Mbas3iEM49mcESAZkOsR3KVUhz7XvRGk26hbhZQSL9/i90/BxJODmy9jcjmdl6SXlFZcmr6wY1K2byzMQW4wVeWtpWniTm++H5+W7J7AgvUwGcZAoO2srLFzl+i0IdR2fSbKiLSJkk/eg8drVwAIAzd7N4d8+269l58pzbKsa1rKxGJV9dpz1EBoJDy3vWxaOzezEnqKOkShUA/IV915WWzpAlQPFNxMk/zR7UQM0yNDrIcI/3So3iN1Ey9oMRAYkLoVak6m1hAtkr+UGTzcg+wMt70G/+eRk1/JjMuRm2gIoQ7wvfCdh3e2TGFSqS3v1W7oa2G5NiG9qMeGSXkWjLUk1u0QRLi3VLgSQp9nf9Xb4HFTsSdmhuIqGkH625SSXOvQ52bJ2SIU584sHO+vd3A3DkZfkNcfqz1TYNlED4WJIz2iF57BJcUjaTUJeugxJ6DaMH9mbRlPOXFZfUSBVqDr6XHJzM7b9EydT0W6guIw+fByXGFkYHL+MtOXYEEtVrhhWoFJQ5eMe0oDewyPl0ecR8kud4Jf3tfEJUoF1pdnWbsWpQVSmAV5webTqBn5bTCwNu5Aa5blefOC7VfEizYrXazqqWZQS0GYGdJn4BwBVcD6gAA3U89+UsfnKe3xeita8KrPsAUECurbQXFxi6T+iVaNqcVeOT6FihvDNMeuLf+OJpdIJg9WKZyHEFFc8jhHnhn1C6p3tRhYFOmE0R3xLiIIeeCjUrid"
`endif