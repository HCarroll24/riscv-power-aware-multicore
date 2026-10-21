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


// $File: //acds/rel/25.1/ip/iconnect/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v $
// $Revision: #1 $
// $Date: 2025/02/06 $
// $Author: psgswbuild $
//------------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_st_clock_crosser(
                                 in_clk,
                                 in_reset,
                                 in_ready,
                                 in_valid,
                                 in_data,
                                 out_clk,
                                 out_reset,
                                 out_ready,
                                 out_valid,
                                 out_data
                                );

  parameter  SYMBOLS_PER_BEAT    = 1;
  parameter  BITS_PER_SYMBOL     = 8;
  parameter  FORWARD_SYNC_DEPTH  = 2;
  parameter  BACKWARD_SYNC_DEPTH = 2;
  parameter  USE_OUTPUT_PIPELINE = 1;
  
  localparam  DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;

  input                   in_clk;
  input                   in_reset;
  output                  in_ready;
  input                   in_valid;
  input  [DATA_WIDTH-1:0] in_data;

  input                   out_clk;
  input                   out_reset;
  input                   out_ready;
  output                  out_valid;
  output [DATA_WIDTH-1:0] out_data;

  // Data is guaranteed valid by control signal clock crossing.  Cut data
  // buffer false path.
  (* altera_attribute = {"-name SUPPRESS_DA_RULE_INTERNAL \"D101,D102\""} *) reg [DATA_WIDTH-1:0] in_data_buffer;
  (* altera_attribute = {"-name DESIGN_ASSISTANT_EXCLUDE \"CDC-50006\""} *) reg    [DATA_WIDTH-1:0] out_data_buffer;

  reg                     in_data_toggle;
  wire                    in_data_toggle_returned;
  wire                    out_data_toggle;
  reg                     out_data_toggle_flopped, out_data_toggle_1, out_data_toggle_flopped_n;

  wire                    take_in_data;
  wire                    out_data_taken;

  wire                    out_valid_internal;
  wire                    out_ready_internal;
  wire                    reset_merged;
  wire                    out_reset_merged;
  wire                    in_reset_merged;

  assign in_ready =  (in_data_toggle_returned ^ in_data_toggle);
  assign take_in_data = in_valid & in_ready;
  assign out_valid_internal = out_data_toggle_1 ^ out_data_toggle_flopped;
  assign out_data_taken = out_ready_internal & out_valid_internal;
 
assign reset_merged = in_reset  | out_reset;
 
   altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_in_rst
        (
            .clk        (in_clk),
            .reset_in   (reset_merged),
            .reset_out  (in_reset_merged)
        );
 
 altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_out_rst
        (
            .clk        (out_clk),
            .reset_in   (reset_merged),
            .reset_out  (out_reset_merged)
        );

  always @(posedge in_clk or posedge in_reset_merged) begin
    if (in_reset_merged) begin
      in_data_buffer <= {DATA_WIDTH{1'b0}};
      in_data_toggle <= 1'b0;
    end else begin
      if (take_in_data) begin
        in_data_toggle <= ~in_data_toggle;
        in_data_buffer <= in_data;
      end
    end //in_reset
  end //in_clk always block

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_1 <= 1'b0;
    end else begin
        out_data_toggle_1 <= out_data_toggle;
    end //end if
  end //out_clk always block
  
  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped <= 1'b0;
      out_data_buffer <= {DATA_WIDTH{1'b0}};
    end else begin
      out_data_buffer <= in_data_buffer;
      if (out_data_taken) begin
        out_data_toggle_flopped <= out_data_toggle_1;
      end
    end //end if
  end //out_clk always block

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped_n <= 1'b0;
    end else begin
        out_data_toggle_flopped_n <= ~out_data_toggle_flopped;
     end //end if
  end //out_clk always block
 
  altera_std_synchronizer_nocut #(.depth(FORWARD_SYNC_DEPTH)) in_to_out_synchronizer (
				     .clk(out_clk),
				     .reset_n(~out_reset_merged),
				     .din(in_data_toggle),
				     .dout(out_data_toggle)
				     );
  
  altera_std_synchronizer_nocut #(.depth(BACKWARD_SYNC_DEPTH)) out_to_in_synchronizer (
				     .clk(in_clk),
				     .reset_n(~in_reset_merged),
				     .din(out_data_toggle_flopped_n),
				     .dout(in_data_toggle_returned)
				     );


  generate if (USE_OUTPUT_PIPELINE == 1) begin

      altera_avalon_st_pipeline_base 
      #(
         .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
         .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT)
      ) output_stage (
         .clk(out_clk),
         .reset(out_reset_merged),
         .in_ready(out_ready_internal),
         .in_valid(out_valid_internal),
         .in_data(out_data_buffer),
         .out_ready(out_ready),
         .out_valid(out_valid),
         .out_data(out_data)
      );
 
  end else begin

      assign out_valid = out_valid_internal;
      assign out_ready_internal = out_ready;
      assign out_data = out_data_buffer;
 
  end
 
  endgenerate
 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "1FVOSNyCgXHsL22c7r3AHKrCm6IbQChWZCSU4GQrYiOLmks9PAwtpVpTJ1dpxoTf0P1G+LZfbkl4GmGB/8/17mRlJNJc3b1lMXbq5dx37l/LH6BxVKF5gDg0QgV+28ExoiYdhaE6NKezqIRoJdglFmiTSZReFwv1sFcqG/JmslTIWW8HndWTz1FTPT9w7xOxtMOfpbj/gktz60Pz8392fLou6V7RaQMJ5drRQa/eihbeJb6tfQ0HmYzBDGJe6C/9F1jYOLfrTDqC+Gj6teqPSjybkRp7A2xW+y/NDLW9s4Qb8kTzaOendXZ694IOVJL7loTZhZrLf6JPW5uE1DZqk25IqF2ftuo9veEB8iKzINELnnHetpubVbJoHsTCo2piCp+IMgfqcSoCCdHn+6CWfn8G8b49S6LT7CTZnt/PxxQ2L1JyCg0PSCtSehqaNnXEd6CydXVAdzB6gwbISox6DNY8v3I+9I/hVjj3w3ZG4axu20yoUX0VptAnf7oFt/jB75X6bwLOz+Lg7i0AQJO3YGsRl82/ckwDSRlBKWlwq6jwuempCvFB4pkTBJcYpr+n1uBYoDxXH9FnBq7H0ZM0sIiK34iBMy56YVeurg3CiHxNqbysWBqjvdiAlTe3EJrNH+XQuDDB/jD9G9aimGe+bAwa4ftS8jH3hwiyrzCzNKBjoCDbtiyHgrNhe4H7CM9BOaU5snjCVAqzPSpSg7IHkfp27FwUjLdGw6B9ldv9JW9eKZdc6+4jZByYH2ou/8FzghVsjSbFbqMJa7+sjeMzUTwjJc1vMH+U3SQutdWa2ZMQYBvJgI8smZAWXUkT1wA2phjdM21gztbU4IskPJEeFSIJbXzKlXosURU56DmoFGqS1PmqA5ZyFaiejLuz0H06O7L1UeiBITr4kelzuxmO7n0At24i/tFj1FonZZrtvCa9ziPWnMB4s4hQfA0ienGGDmRlexAs9uW7YSu5lXX1Fx2HyQ6uUieNG+iIc7ed9JVVGnlU6rNz8EJr3no9/eIL"
`endif