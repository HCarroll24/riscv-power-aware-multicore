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

module altera_avalon_i2c_txout (
    input           clk,
    input           rst_n,
    input [15:0]    sda_hold,
    input           start_sda_out,
    input           restart_sda_out,
    input           stop_sda_out,
    input           mst_tx_sda_out,
    input           mst_rx_sda_out,
    input           restart_scl_out,
    input           stop_scl_out,
    input           mst_tx_scl_out,
    input           mst_rx_scl_out,
    input           pop_tx_fifo_state,
    input           pop_tx_fifo_state_dly,

    output          sda_oe,
    output          scl_oe

);

reg         data_oe;
reg         clk_oe;
reg         clk_oe_nxt_dly;
reg [15:0]  sda_hold_cnt;
reg [15:0]  sda_hold_cnt_nxt;

wire        data_oe_nxt;
wire        clk_oe_nxt;
wire        clk_oe_nxt_hl;
wire        load_sda_hold_cnt;
wire        sda_hold_en;

assign data_oe_nxt  =   ~start_sda_out   |
                        ~restart_sda_out |
                        ~stop_sda_out    |
                        ~mst_tx_sda_out  |
                        ~mst_rx_sda_out;

assign clk_oe_nxt   =   ~restart_scl_out |
                        ~stop_scl_out    |
                        ~mst_tx_scl_out  |
                        ~mst_rx_scl_out;

assign clk_oe_nxt_hl        = clk_oe_nxt & ~clk_oe_nxt_dly;
assign load_sda_hold_cnt    = clk_oe_nxt_hl;
assign sda_hold_en          = (sda_hold_cnt_nxt != 16'h0) | pop_tx_fifo_state | pop_tx_fifo_state_dly;

assign sda_oe   = data_oe;
assign scl_oe   = clk_oe;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        clk_oe_nxt_dly <= 1'b0;
    else
        clk_oe_nxt_dly <= clk_oe_nxt;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_oe <= 1'b0;
    else if (sda_hold_en)
        data_oe <= data_oe;
    else
        data_oe <= data_oe_nxt;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        clk_oe <= 1'b0;
    else if (pop_tx_fifo_state_dly)
        clk_oe <= clk_oe;
    else
        clk_oe <= clk_oe_nxt;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sda_hold_cnt <= 16'h0;
    else
        sda_hold_cnt <= sda_hold_cnt_nxt;
end

always @* begin
    if (load_sda_hold_cnt)
        sda_hold_cnt_nxt = sda_hold;
    else if (sda_hold_cnt != 16'h0)
        sda_hold_cnt_nxt = sda_hold_cnt - 16'h1;
    else
        sda_hold_cnt_nxt = sda_hold_cnt;
end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "MoZxDPGn2oiONfndjEKhaVT4+sN63kZ3QvPG9TSmKRlmByuPtVRALwvax08te6y0fBxqP8p/nuBVVr64MrOEExISzSeSKfzm++ecWyPhCzurlnEOfNi6ungUUY+kkok1v2z7WTOTyDn5MyuWyBonjW167pfBw9EpSnPOcy01c7SBjr1e7gmIBxSz3jK48TsJYA7EYQleLnd99JDB4ft4E56TECKUHVf/gsWE8kyQkTq8oXn9jaODG/J6DPDezaXuamuzNjkwac3MOb20HU18FSlgZOnxLlUDn4IsIoGBkwopjrubU5x/DfktQLQgb2QDxT2oRI6Thkc0z1RSRfZport5y0S6A7Ed83MnkCXu1tVBsJVn0xj/A31NuImuieSXLDvxa8G1wwXnQJcc9sVM9aYhKGu6q6RzNJoXGHLA7oo9xeh5NY5D7YUgIUDsQ6Pw2uKFhBmYiAjfdTk8Yy3aRGmTd94fifCnDmCFoeOTAZ210eJLBdkDl59SczqaxwxUJvhwWyLZZHKot3uhBAs7CDmdsltsQ7oCv7a2gWFHhvJgAoXO2iczNCbb2srvKCNrUCdJIqAQvqBUFlpc/tyR5jtOonv6LYeW3E8so0c12PD7BRre14wD6vDE07mt1JEc/jfGUuK68ztPO3dxfgDqfL6CweazB6gDINXbF9J84zkJQbLgPHR6GI4yfLlJ501i1SceK/5u4n4pdSxrjPp5cnlpT1MrBz6TKwb9K7YfHHKFyWf2PD1vt7cz3oQnhnuh+b2npEHTvKlG3c0AgjOPogExncWpMIgTmEUD5uRsnY56VxcXR7X8BLigspmOkChqL+gDIJhYxMx7Ux/US3qtz+NcMSJHhKSCIfprpD5ERb+AbH/yy14HChDeMesGEz/iWmgXAKerTbF+E/fLeUFYTrRmd/edSiRsu0qrb8c+kv/pTjzf8pyzW70pBZcDpzlEmwBgzUPzlX/Npq1sziblcIzMnlyjpZ6I3I6Wx/5u7AnFkOhwMM2zaD22wZkehxcZ"
`endif