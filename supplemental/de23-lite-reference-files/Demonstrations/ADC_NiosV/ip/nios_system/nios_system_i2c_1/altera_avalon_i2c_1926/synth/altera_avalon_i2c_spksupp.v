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

module altera_avalon_i2c_spksupp (
    input       clk,
    input       rst_n,
    input [7:0] spike_len,
    input       sda_in,
    input       scl_in,
    output      sda_int,
    output      scl_int
);

// Status Register bit definition


// wires & registers declaration
reg [7:0]   scl_spike_cnt;
reg         scl_int_reg;
reg         scl_doublesync_a;
reg [7:0]   sda_spike_cnt;
reg         sda_int_reg;
reg         sda_doublesync_a;
reg         scl_in_synced;
reg         sda_in_synced;

wire        scl_clear_cnt;
wire        scl_cnt_limit;
wire        scl_int_next;
wire        sda_clear_cnt;
wire        sda_cnt_limit;
wire        sda_int_next; 
 
 
// double sync flops for scl  
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scl_doublesync_a    <= 1'b1;
        scl_in_synced       <= 1'b1;
    end
    else begin
        scl_doublesync_a    <= scl_in;
        scl_in_synced       <= scl_doublesync_a;
    end
end
  
  
//assign scl_in_synced = scl_doublesync_b;
// XOR: return 1 to increase counter ; return 0 to reset counter
assign scl_clear_cnt = ~(scl_in_synced ^ scl_int_next) ;

// scl counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        scl_spike_cnt <= 8'h0;
    else if(scl_clear_cnt)
        scl_spike_cnt <= 8'h0;
    else 
        scl_spike_cnt <= scl_spike_cnt + 8'h1;
end

// to allow scl_in pass through to scl_int when the comparator returns 1
// if disallow to pass through, scl_int returns the prev value
// to make the scl_in pass through at the same clock as the counter reaching the limit value of suppression length
assign scl_cnt_limit = (scl_spike_cnt >= spike_len);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        scl_int_reg <= 1'b1;
    else 
        scl_int_reg <= scl_int_next;
end

assign scl_int_next = scl_cnt_limit ? scl_in_synced : scl_int_reg; 
//assign scl_int = scl_cnt_limit ? scl_in_synced : scl_int_reg ;
assign scl_int = scl_int_reg; // Using the registered version to improve timing



// double sync flops for sda
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sda_doublesync_a <= 1'b1;
        sda_in_synced <= 1'b1;
    end
    else begin
        sda_doublesync_a <= sda_in;
        sda_in_synced <=sda_doublesync_a;
    end
end


//  assign sda_in_synced = sda_doublesync_b;
// XOR: return 1 to increase counter ; return 0 to reset counter
assign sda_clear_cnt = ~(sda_in_synced ^ sda_int_next) ;

// sda counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        sda_spike_cnt <= 8'h0;
    else if(sda_clear_cnt)
        sda_spike_cnt <= 8'h0;
    else
        sda_spike_cnt <= sda_spike_cnt + 8'h1;
end

// to allow scl_in pass through to scl_int when the comparator returns 1
// if disallow to pass through, scl_int returns the prev value
// to make the scl_in pass through at the same clock as the counter reaching the limit value of suppression length
assign sda_cnt_limit = (sda_spike_cnt >= spike_len);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sda_int_reg <= 1'b1;
    else
        sda_int_reg <= sda_int_next;
end

assign sda_int_next = sda_cnt_limit ? sda_in_synced : sda_int_reg;
//assign sda_int = sda_cnt_limit ? sda_in_synced : sda_int_reg ;
assign sda_int = sda_int_reg;  // Using the registered version to improve timing


endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "MoZxDPGn2oiONfndjEKhaVT4+sN63kZ3QvPG9TSmKRlmByuPtVRALwvax08te6y0fBxqP8p/nuBVVr64MrOEExISzSeSKfzm++ecWyPhCzurlnEOfNi6ungUUY+kkok1v2z7WTOTyDn5MyuWyBonjW167pfBw9EpSnPOcy01c7SBjr1e7gmIBxSz3jK48TsJYA7EYQleLnd99JDB4ft4E56TECKUHVf/gsWE8kyQkTpqNkyLPVByE71tOnRJe0VddEAehGzjVL8NwSmlyXVL+Cga5psn+rgg496BtW6IqcTd9GQRTqOnVObDTxGTGx+kHZ/dLSVg7BbL/PDgnqgcCWWrd7D/EUTXUz07J+f18uAFoZRlTM45Qt4GcCQ+iWdd5IPqi6v91kWxjYa07kk3xZ88MjI7KjUey7fJexH7Gtvqc36QYsijeqzyGN/KnkAP5lGY/wa2kSmqy1fsZutzWXBjH28bf1DE/kkMg8lyuK830u4Lczg1xNGbZ5O1BqomDR7c09DjE9C8Hw6P3kUmfcRFaDJURQ4yKEEqu60pNlcgvpCGXe90QwbNKWa4WLnG9JhGpWOhhBGPDGoZ2jwvnbhh/IvDTEoD0YPHtlaWZkbZt8dt3t90MqSG3rDFueoRWHIc1ABg3gjO0D+uVnRhC0JCLQ0YpNp8GZT5i0YGm8WHiHyKOBs2bpFByMvDrz7//H0/HQGsS9mCFE4ZQl3ZKYkT6P5UJvl98HqwWac4upRKqBUjWmtJijhB50M3r8oNs1c/wvjvcy+TxpmAsdCLoGa8DRUn45i7ZVytBz4VI3uiRtClViJ3zZSbZF89aQwdujaz2VqjDGU0gWXDxFIzgtWrDpK4TWs9qt/zRz5o8j50iYNq+4OlfG2gdGuC7zBbe76dkDfRRg9YdInAV9RiFu/90oiE+p2gJgn4Q/1OG/6ZkzC0e2Q2aIGbo38YoJVWgiYELhiVOdvq0ckyHHdM9hm0r7NREcvG313vgf4PkyXotjC1NN2hTaO9T7WsEv0Z"
`endif