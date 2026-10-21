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

//`define ENABLE_CAM

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

`ifdef ENABLE_CAM
      ///////// CAM /////////
      input              CAM_CLK_p,
      input              CAM_CLK_n,
      input    [ 1: 0]   CAM_D_p,
      input    [ 1: 0]   CAM_D_n,
      inout              CAM_I2C_SCL,
      inout              CAM_I2C_SDA,
      inout              CAM_GPIO,
      input              CAM_RZQ1,
`endif /*ENABLE_CAM*/

      ///////// I2C for HDMI and ADC /////////
      inout              FPGA_I2C_SCL,
      inout              FPGA_I2C_SDA,

      ///////// UART /////////
      output             FPGA_UART_TX,
      input              FPGA_UART_RX,

      ///////// GPIO /////////
      inout    [35: 0]   GPIO_D

);

//=======================================================
//  REG/WIRE declarations
//=======================================================

//=======================================================
//  Structural coding
//=======================================================
//----led off 
assign  LEDR[9:2]=8'hff ; 

//----SDRAM off
assign DRAM_DQ   =32'hzzzz_zzzzz;
assign DRAM_CS_n =1'b1;
assign DRAM_WE_n =1'b1;
assign DRAM_CAS_n=1'b1;
assign DRAM_RAS_n=1'b1;
assign DRAM_DQM  =4'b1111;

//---400khz heat--	
CLOCKMEM u_CLOCKMEM( .CLK(CLK_400K) ,.CLK_FREQ(400_000) ,.CK_1HZ(LEDR[0]) ) ;

	
//-------TLA2528_ADC Reading Data in manual mode-----	
wire [15:0]CH0_D;
wire [15:0]CH1_D;
wire [15:0]CH2_D;
wire [15:0]CH3_D;
wire [15:0]CH4_D;
wire [15:0]CH5_D;
wire [15:0]CH6_D;
wire [15:0]CH7_D;


wire I2C_READY ;
wire CLK_400K  ; 
TLA2528_ADC_CTRL u_TLA2518_ADC_CTRL(
		.iRESET_N    (KEY[0]   ),
		.iCLK        (CLOCK0_50),
		.CLK_400K    (CLK_400K ) ,
      .iSLAVE_ADDR (8'h20    ),  
		.CH0_D       (CH0_D),//unit mV
		.CH1_D       (CH1_D),//unit mV
		.CH2_D       (CH2_D),//unit mV
		.CH3_D       (CH3_D),//unit mV
		.CH4_D       (CH4_D),//unit mV
		.CH5_D       (CH5_D),//unit mV
		.CH6_D       (CH6_D),//unit mV
		.CH7_D       (CH7_D),//unit mV
		
		.I2C_SDA	    (FPGA_I2C_SDA),	
		.I2C_SCL	    (FPGA_I2C_SCL),	
		.READY	    (I2C_READY  )
);

assign LEDR[1] = ~I2C_READY ; 

//----ADC SEL to BCD
wire [15:0] BCD ; 
BCD_MUX u_BCD_MUX(
      .iSW   ( SW[2:0]),
      .iCH0_D( CH0_D),
      .iCH1_D( CH1_D),
      .iCH2_D( CH2_D),
      .iCH3_D( CH3_D),
      .iCH4_D( CH4_D),
      .iCH5_D( CH5_D),
      .iCH6_D( CH6_D),
      .iCH7_D( CH7_D),
      .oBCD  ( BCD  )
);

//----hex4 no use
assign HEX4 = 7'b011_1111;

//----HEX to BCD
SEG7_LUT_5 u_SEG7_LUT_5(	
      .oSEG0( HEX0),
      .oSEG1( HEX1),
      .oSEG2( HEX2),
      .oSEG3( HEX3),
      .oSEG4( HEX5),
      .iDIG ( {1'b0,SW[2:0],BCD[15:0] } )
 );


endmodule
