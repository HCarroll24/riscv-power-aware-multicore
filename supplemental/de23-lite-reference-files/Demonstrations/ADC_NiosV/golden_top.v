// ============================================================================
// Copyright (c) 2025 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  No.80, Fenggong Rd., Hukou Township, Hsinchu County 303035. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun  2 00:32:49 2025
// ============================================================================

module golden_top(

      ///////// CLOCK /////////
      input              CLOCK0_50,
      input              CLOCK1_50,

      ///////// KEY /////////
      input    [ 3: 0]   KEY, //BUTTON is Low-Active

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LED /////////
      output   [ 9: 0]   LEDR, //LED is Low-Active

      ///////// Seg7 /////////
      output   [ 6: 0]   HEX0,
      output   [ 6: 0]   HEX1,
      output   [ 6: 0]   HEX2,
      output   [ 6: 0]   HEX3,
      output   [ 6: 0]   HEX4,
      output   [ 6: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [31: 0]   DRAM_DQ,
      output             DRAM_CS_n,
      output             DRAM_WE_n,
      output             DRAM_CAS_n,
      output             DRAM_RAS_n,
      output   [ 3: 0]   DRAM_DQM,

      ///////// HDMI /////////
      inout              HDMI_LRCLK,
      inout              HDMI_MCLK,
      inout              HDMI_SCLK,
      output             HDMI_TX_CLK,
      output             HDMI_TX_HS,
      output             HDMI_TX_VS,
      output   [23: 0]   HDMI_TX_D,
      output             HDMI_TX_DE,
      input              HDMI_TX_INT,
      inout              HDMI_I2S0,

      ///////// I2C for HDMI and ADC /////////
      inout              I2C_SCL,
      inout              I2C_SDA,

      ///////// UART /////////
      output             UART_TX,
      input              UART_RX,

      ///////// GPIO /////////
      inout    [35: 0]   GPIO_D

);

//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================

	wire ninit_done;
	reset_release reset_release_inst (
		.ninit_done (ninit_done)  //  output,  width = 1, ninit_done.ninit_done
	);
	
wire reset_n;
assign reset_n = ~ninit_done;	


// HDMI-Out Controller i2c 
wire i2c_serial_sda_in;
wire i2c_serial_scl_in;
wire i2c_serial_sda_oe;
wire i2c_serial_scl_oe;
		
assign i2c_serial_scl_in = I2C_SCL;
assign i2c_serial_sda_in = I2C_SDA;
assign I2C_SCL = i2c_serial_scl_oe ? 1'b0 : 1'bz;
assign I2C_SDA = i2c_serial_sda_oe ? 1'b0 : 1'bz;


nios_system u0 (
    .clk_clk                        (CLOCK0_50),     //                     clk.clk
    .reset_reset_n                  (reset_n),         //                   reset.reset_n
    .sw_external_connection_export  (SW),           //  sw_external_connection.export
	 
    .i2c_master_i2c_serial_sda_in  (i2c_serial_sda_in),  //   input,   width = 1,  i2c_master_i2c_serial.sda_in
    .i2c_master_i2c_serial_scl_in  (i2c_serial_scl_in),  //   input,   width = 1,                       .scl_in
    .i2c_master_i2c_serial_sda_oe  (i2c_serial_sda_oe),  //  output,   width = 1,                       .sda_oe
    .i2c_master_i2c_serial_scl_oe  (i2c_serial_scl_oe)   //  output,   width = 1,                       .scl_oe
	 

	 
);





endmodule
