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


wire  [31:0]  writedata;
wire  [31:0]  readdata;
wire          write;
wire          read;
wire          clk_test;

//=======================================================
//  Structural coding
//=======================================================
//ledr no use off
assign LEDR[9:3] = 7'h7f;

//hex no use off
assign HEX0=7'h7f; 
assign HEX1=7'h7f; 
assign HEX2=7'h7f; 
assign HEX3=7'h7f; 
assign HEX4=7'h7f; 
assign HEX5=7'h7f; 



//	SDRAM frame buffer
Sdram_Control	u1_Sdram_Control	(	
                     //	HOST Side
						 	.CLK        (clk_test),
							
						   .REF_CLK    (CLOCK0_50),
					      .RESET_N    (test_software_reset_n_),
							//	FIFO Write Side 
						   .WR_DATA    ( writedata  ),
							.WR         ( write      ),
							.WR_ADDR    ( 0          ),
							.WR_MAX_ADDR( 24'hfff_fff),
							.WR_LENGTH  ( 9'h80      ),
							.WR_LOAD    ( ~test_global_reset_n_ ),
							.WR_CLK     ( clk_test   ),
							
							//	FIFO Read Side 
						   .RD_DATA(readdata),
				        	.RD    (read),
				        	.RD_ADDR(0),			//	Read odd field and bypess blanking
							.RD_MAX_ADDR( 24'hfff_fff),
							.RD_LENGTH  ( 9'h80       ) ,
				        	.RD_LOAD    (~test_global_reset_n_ ),
							.RD_CLK     (clk_test    ),
                     //	SDRAM Side
						   .SA         ( DRAM_ADDR  ),
						   .BA         ( DRAM_BA    ),
						   .CS_N       ( DRAM_CS_n  ),
						   .CKE        ( DRAM_CKE   ),
						   .RAS_N      ( DRAM_RAS_n ),
				         .CAS_N      ( DRAM_CAS_n ),
				         .WE_N       ( DRAM_WE_n  ),
						   .DQ         ( DRAM_DQ    ),
				         .DQM        ( DRAM_DQM   ),
							.SDR_CLK    ( DRAM_CLK   )
							);

//------RESET 							
wire  test_software_reset_n;
wire  test_global_reset_n;
wire  test_start_n;

//------TEST result
wire  sdram_test_pass;
wire  sdram_test_fail;
wire  sdram_test_complete;

//------Control Write data to SDRAM and read data from SDRAM 
RW_Test u2_RW_Test(
      .iCLK      ( clk_test),
		.iRST_n    ( test_software_reset_n_),
		.iBUTTON   ( test_start_n_),
      .write     ( write),
		.writedata ( writedata),
	   .read      ( read),
		.readdata  ( readdata),
      .drv_status_pass         (sdram_test_pass),
		.drv_status_fail  (sdram_test_fail),
		.drv_status_test_complete(sdram_test_complete)
		
);						 
		
//--reset_n and start_n control
reg [31:0]  cont;
always@(posedge CLOCK0_50)
cont<=(cont==32'd4_000_001)?32'd0:cont+1'b1;

//--reset time
reg[4:0] sample;
always@(posedge CLOCK0_50)
begin
	if(cont==32'd4_000_000)
		sample[4:0]={sample[3:0],KEY[0]};
	else 
		sample[4:0]=sample[4:0];
end

//--reset out 
assign test_software_reset_n =(sample[1:0]==2'b10)?1'b0:1'b1;//by RW_Test clk
assign test_global_reset_n   =(sample[3:2]==2'b10)?1'b0:1'b1;//by sdram_ctrl clk
assign test_start_n          =(sample[4:3]==2'b01)?1'b0:1'b1;//by RW_Test clk

//==========RESET sync============
//---test_software_reset_n sync
wire test_software_reset_n_;
altera_std_synchronizer #(
    .depth      (3)
) test_software_reset_n_sync (
    .clk        (clk_test  ), 
    .reset_n    (1'b1),
    .din        (test_software_reset_n), 
    .dout       (test_software_reset_n_)
);

//---test_global_reset_n sync
wire test_global_reset_n_;
altera_std_synchronizer #(
    .depth      (3)
) test_global_reset_n_sync (
    .clk        (clk_test  ), 
    .reset_n    (1'b1),
    .din        (test_global_reset_n), 
    .dout       (test_global_reset_n_)
);

//---test_start_n sync
wire test_start_n_;
altera_std_synchronizer #(
    .depth      (3)
) test_start_n_sync (
    .clk        (clk_test  ), 
    .reset_n    (1'b1),
    .din        (test_start_n          ), 
    .dout       (test_start_n_)
);


//----test result report
wire [2:0] test_result;
assign test_result[2] =  KEY[0];
assign test_result[1] =  heart_beat[23];
assign test_result[0] =  sdram_test_complete? sdram_test_pass : heart_beat[23];


//----LED report pass: LED0 light ,LED1 blink, LED2 light
assign LEDR[2:0] = ~(KEY[0]?test_result[2:0]:3'b011);  //pass: LED0 light ,LED1 blink, LED2 light 
 

 //---heart gen
reg [23:0] heart_beat;
always @ (posedge CLOCK0_50)
begin
	heart_beat <= heart_beat + 1;

end



endmodule
