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
      output             HDMI_TX_CLK,
      output             HDMI_TX_HS,
      output             HDMI_TX_VS,
      output   [23: 0]   HDMI_TX_D,
      output             HDMI_TX_DE,
      input              HDMI_TX_INT,
      inout              HDMI_LRCLK,
      inout              HDMI_MCLK,
      inout              HDMI_SCLK,
      inout              HDMI_I2S0,

      ///////// UART /////////
      output             UART_TX,
      input              UART_RX,

      ///////// I2C for HDMI and ADC /////////
      inout              I2C_SCL,
      inout              I2C_SDA,

      ///////// GPIO /////////
      inout    [35: 0]   GPIO_D

);


//=======================================================
//  REG/WIRE declarations
//=======================================================
reg  [31:0]	Cont;

//hdmi
wire [7:0] hdmi_b;
wire [7:0] hdmi_g;
wire [7:0] hdmi_r;
wire       disp_clk;
wire       disp_de;
wire       disp_hs;
wire       disp_vs;
wire       DLY_RST;
wire		  reset_n;
//=======================================================
//  Structural coding
//=======================================================
assign reset_n = !ninit_done;
wire ninit_done;
agilex_reset_release reset_release_Inst (
	.ninit_done(ninit_done)
	);
	

	
wire beat;
heart_beat heart_beat_clk50(
	.clk(CLOCK0_50),
	.led(beat)
	);


assign LEDR = (!KEY[0])?10'h0:
				  (!KEY[1])?10'h3ff:{10{~PWM_width[6]}};
				  
wire [23:0]	mSEG7_DIG;		
assign	mSEG7_DIG	=	KEY[0]? {	counter[27:24], counter[27:24], counter[27:24], counter[27:24], counter[27:24], counter[27:24]} :{6{4'b1000}};							  
//7 segment LUT
SEG7_LUT_6 SEG7_LUT_6_Inst 
(	
	.oSEG0(HEX0),
	.oSEG1(HEX1),
	.oSEG2(HEX2),
	.oSEG3(HEX3),
	.oSEG4(HEX4),
	.oSEG5(HEX5),
	.iDIG(mSEG7_DIG) 
);
	
	
reg 	[27:0] 	counter;
reg 	[5:0]   PWM_adj;
reg   [6:0]   PWM_width;
always @(posedge CLOCK0_50 or negedge reset_n)
begin
	if(!reset_n)
		begin
			counter <= 0;
		end
	else 
	begin
		counter   <= counter+1;
		PWM_width <= PWM_width[5:0]+ PWM_adj;
		if(counter[26])
		begin
			PWM_adj <= counter[25:20];
		end
		else 
		begin
			PWM_adj <= ~ counter[25:20];
		end
	end
end
		  
									  
//	Reset Delay Timer
Reset_Delay			r0	(	
							 .iCLK(CLOCK0_50),
							 .oRESET(DLY_RST));									  

//=======================================================
//  Structural coding
//=======================================================


sys_pll u_sys_pll (
   .refclk(CLOCK0_50),
	.rst(!reset_n),
	.outclk_0(disp_clk),
	.outclk_1(pll_1536k)
	);
	
//HDMI I2C	
I2C_HDMI_Config u_I2C_HDMI_Config (
	.iCLK(CLOCK0_50),
	.iRST_N(reset_n),
	.I2C_SCLK(I2C_SCL),
	.I2C_SDAT(I2C_SDA),
	.HDMI_TX_INT(HDMI_TX_INT)
	);


vga_controller hdmi_ins(.iRST_n(DLY_RST),
                      .iVGA_CLK(disp_clk),
                      .oBLANK_n(disp_de),
                      .oHS(disp_hs),
                      .oVS(disp_vs),
                      .b_data(hdmi_b),
                      .g_data(hdmi_g),
                      .r_data(hdmi_r));	
							 
							 
assign HDMI_TX_CLK	= disp_clk;
assign HDMI_TX_D		= {hdmi_r,hdmi_g,hdmi_b};
assign HDMI_TX_DE		= disp_de;
assign HDMI_TX_HS		= disp_hs;
assign HDMI_TX_VS		= disp_vs;
	
	
AUDIO_IF u_AVG(
	.clk(!KEY[0]&pll_1536k),
	.reset_n(reset_n),
	.sclk(HDMI_SCLK),
	.lrclk(HDMI_LRCLK),
	.i2s(HDMI_I2S0)
);





endmodule 

