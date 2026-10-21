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

module altera_avalon_i2c_fifo #(
    parameter DSIZE = 8,
    parameter FIFO_DEPTH = 256,
    parameter FIFO_DEPTH_LOG2 = 8,
    parameter LATENCY = 2
) (
    input                       clk,
    input                       rst_n,
    input                       s_rst,
    input [DSIZE-1:0]           wdata,
    input                       put,
    input                       get,
    
    output                      full,
    output                      empty,
    output                      empty_dly,
    output [FIFO_DEPTH_LOG2:0]  navail,
    output [DSIZE-1:0]          rdata
);


reg [FIFO_DEPTH_LOG2-1:0]  write_address;
reg [FIFO_DEPTH_LOG2-1:0]  read_address;
reg [FIFO_DEPTH_LOG2:0] internal_used;
reg empty_d1;
reg empty_d2;

wire internal_full;
wire internal_empty;
wire [(DSIZE/8)-1:0]  write_byteenables;


  always @ (posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      write_address <= 0;
    end
    else
    begin
      if (s_rst)
      begin
        write_address <= 0;
      end
      else if (put == 1)
      begin
        write_address <= write_address + 1'b1;
      end
    end
  end

  always @ (posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      read_address <= 0;
    end
    else
    begin
      if (s_rst)
      begin
        read_address <= 0;
      end
      else if (get == 1)
      begin
        read_address <= read_address + 1'b1;
      end
    end
  end

  assign write_byteenables = {(DSIZE/8){1'b1}};

  // TODO:  Change this to an inferrered RAM when Quartus II supports byte enables for inferred RAM
  altsyncram #(
	 .operation_mode                     ("DUAL_PORT"),
	 .lpm_type                           ("altsyncram"),
	 .read_during_write_mode_mixed_ports ("DONT_CARE"),
	 .power_up_uninitialized             ("TRUE"),
     .byte_size                          (8),
	 .width_a                            (DSIZE),
	 .width_b                            (DSIZE),
	 .widthad_a                          (FIFO_DEPTH_LOG2),
	 .widthad_b                          (FIFO_DEPTH_LOG2),
	 .width_byteena_a                    (DSIZE/8),
	 .numwords_a                         (FIFO_DEPTH),
	 .numwords_b                         (FIFO_DEPTH),
	 .address_reg_b                      ("CLOCK0"),
	 .outdata_reg_b                      ((LATENCY == 2)? "CLOCK0" : "UNREGISTERED")
	) the_dp_ram (
    .clock0 (clk),
    .wren_a (put),
    .byteena_a (write_byteenables),
    .data_a (wdata),
    .address_a (write_address),
    .q_b (rdata),
    .address_b (read_address),
    .clock1	     (1'b1),
    .aclr0           (1'b0),
    .aclr1           (1'b0),
    .clocken0        (1'b1),
    .clocken1        (1'b1),
    .clocken2        (1'b1),
    .clocken3        (1'b1),
    .rden_a          (1'b1),
    .addressstall_a  (1'b0),
    .q_a             (),
    .wren_b          (1'b0),
    .rden_b          (1'b1),
    .data_b          ({DSIZE{1'b1}}),
    .byteena_b       (1'b1),     // {(DATA_WIDTH/8){1'b1}}),
    .addressstall_b  (1'b0),
    .eccstatus       ()
  );
  // defparam the_dp_ram.operation_mode = "DUAL_PORT";  // simple dual port (one read, one write port)
  // defparam the_dp_ram.lpm_type = "altsyncram";
  // defparam the_dp_ram.read_during_write_mode_mixed_ports = "DONT_CARE";
  // defparam the_dp_ram.power_up_uninitialized = "TRUE";
  // defparam the_dp_ram.byte_size = 8;
  // defparam the_dp_ram.width_a = DSIZE;
  // defparam the_dp_ram.width_b = DSIZE;
  // defparam the_dp_ram.widthad_a = FIFO_DEPTH_LOG2;
  // defparam the_dp_ram.widthad_b = FIFO_DEPTH_LOG2;
  // defparam the_dp_ram.width_byteena_a = (DSIZE/8);
  // defparam the_dp_ram.numwords_a = FIFO_DEPTH;
  // defparam the_dp_ram.numwords_b = FIFO_DEPTH;
  // defparam the_dp_ram.address_reg_b = "CLOCK0";
  // defparam the_dp_ram.outdata_reg_b = (LATENCY == 2)? "CLOCK0" : "UNREGISTERED";

  always @ (posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      internal_used <= 0;
    end
    else
    begin
      if (s_rst)
      begin
        internal_used <= 0;
      end
      else
      begin
        case ({put, get})
          2'b01: internal_used <= internal_used - 1'b1;
          2'b10: internal_used <= internal_used + 1'b1;
          default: internal_used <= internal_used;
        endcase
      end
    end
  end


  assign internal_empty = (read_address == write_address) & (internal_used == 0);
  assign internal_full = (write_address == read_address) & (internal_used != 0);

  assign navail = internal_used;    // this signal reflects the number of words in the FIFO
  assign empty = internal_empty;  // combinational so it'll glitch a little bit
  assign full = internal_full;    // dito

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        empty_d1    <= 1'b1;
        empty_d2    <= 1'b1;
    end
    else begin
        empty_d1    <= empty;
        empty_d2    <= empty_d1;
    end
  end

  assign empty_dly = empty | empty_d1 | empty_d2;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "MoZxDPGn2oiONfndjEKhaVT4+sN63kZ3QvPG9TSmKRlmByuPtVRALwvax08te6y0fBxqP8p/nuBVVr64MrOEExISzSeSKfzm++ecWyPhCzurlnEOfNi6ungUUY+kkok1v2z7WTOTyDn5MyuWyBonjW167pfBw9EpSnPOcy01c7SBjr1e7gmIBxSz3jK48TsJYA7EYQleLnd99JDB4ft4E56TECKUHVf/gsWE8kyQkTqdL9UrG3tBPrT5Pb+jFhzn9UA0J47/VbVtd2wl83TdmsaPfUzokYERMQF7L28tywbsczDMthtkMTzp6C8D65weT3bsbalZ2QfTOXOJKNfnWwFbdbKU83SGQpW4E1fdwrFDJgdl9+AwN5gffvYzHbh9bX4kZwKSZHMf9b4lx4jSCNeFQ2uoZG5/+KUakCFoSVxC4ldN1fE/m4vN/K30LB5VBp8T7GJsKByZgGY8w3VZHf+U0UxbbHcb9pRPzHEVEpyJlIU1jlNrJpP4rdQ1RSYI2iSpTq5Um0BMickU77Z//frZ15n4rq8MX6qfd+TVrqIUc64PmMx9rb+WpfLBip0Qgx6P5HOY2D/H0ALk40SyQTY0B9zmzui0Q4uIW6qYNPTQjVF7x/IygXoMC4PEM5MFvlx0W8teWzjn0zsn2yoQ9xgAgENEn41hKHrKtDVdIEsVgK2QuOtjzmL0/bF6WxZ4Nvx+kpvjFA8YTT4W/db/wbAqQp2BiXzws4t+C8BOI1u2/AmGHyPVx3w6/1aaFhslN2Y8556/JZF6Ya4YsTuuGfpHr0pRjNiGkN4yeY/qMouousIqQYuEz3Es8LKlYOtix9FEJu4uNF9OKJ/BJDevsdF1CkO0jwf4nge5TZCFqEZeX8nKsNU8wmS4Xv/NbSF4mE8Ejs7W7bxOU61yIEU00ePsU0iQbTnIZ8TFVePA/xvHjMyDJe4qwe/sOKHdjsjaobRFUsQRbL3uokMv3yUUvwREyIDsaD/ld0AlUuCZbJI1VULNUO2C7oGfxsTNjKcb"
`endif