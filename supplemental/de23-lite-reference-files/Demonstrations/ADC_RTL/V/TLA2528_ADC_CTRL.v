module TLA2528_ADC_CTRL 	(	
   input         [7:0] iSLAVE_ADDR , 
   input             iCLK,	
   output            CLK_400K,	
   input             iRESET_N, 
	
   inout              I2C_SCL, 
   inout              I2C_SDA,
	output	reg [2:0 ]CH , 
   output	reg [15:0]CH0_D,
   output	reg [15:0]CH1_D,
   output	reg [15:0]CH2_D,
   output	reg [15:0]CH3_D,
   output	reg [15:0]CH4_D,
   output	reg [15:0]CH5_D,
   output	reg [15:0]CH6_D,
   output	reg [15:0]CH7_D,
   output	    [15:0]Voltage,
	
		
	//--TEST -- 
   output reg         READY,
	output reg [7:0]   BYTE ,
	//-
	output reg [7:0]   SLAVE_ADDR , 
   output reg [7:0]   ST ,
   output reg [7:0]   CNT,
	output reg [7:0 ]  WCNT,
   output reg [15:0]  W_WORD_DATA,
   output reg [7:0]   W_POINTER_REG,
	
	output             W_WORD_END ,
   output reg         W_WORD_GO ,
	output             W_POINTER_END,
   output reg         W_POINTER_GO,
   output             R_END,
   output reg         R_GO,
	
	
   output       [15:0]R_DATA ,
   
	output       [7:0 ]SEQUENCE_CFG,
	output       [7:0 ]AUTO_SEQ_CH_SEL,
	output SDAO,
	output SCLO
	
);	
	
//----time----	
parameter SEC    =400_000; //1 second
parameter SEC0d5 =SEC/2;   //0.5 second
parameter SEC2   =SEC*2;   //2 second

//---register number --- 
parameter  P_SEQUENCE_CFG    =8'h10 ; //SEQUENCE_CFG Register
parameter  P_AUTO_SEQ_CH_SEL =8'h12 ; //Enable analog input channels AIN7 through AIN0 in auto sequencingmode.
parameter  P_CHANNEL_SEL     =8'h11 ; //CHANNEL_SEL Register
parameter  P_DATA_CFG        =8'h02 ; //SET 0x80 : out fix data = A5A 
parameter  P_GENERAL_CFG     =8'h01 ; //SET 0x08 :  Initiate start of conversion

//---parameter---
parameter  SEQ_MODE          =2'h0  ;// 0Bmanual: 1b = Auto sequence mode
parameter  SEQ_START         =1'h0  ;// 1b = Start auto sequencing from first enabled analog input channe starting from channel ID = 0 (ascending order).

//--w/r command
parameter  WRITE_CMD         =8'h08;
parameter  READ_CMD          =8'h10;

//----wire
assign     SEQUENCE_CFG      = {3'h0, SEQ_START, 2'h0,SEQ_MODE[1:0] };// 
assign     AUTO_SEQ_CH_SEL   = {7'h0 ,1'h1} ;//bit0=1  Analog input channel is enabled in scanning sequence.

//--

//=======================================================
//  WIRE /REGISETER 
//=======================================================

reg  [31:0] DELY;
//-----I2C-BUS-I/O----

wire        W_WORD_SCL; 
wire        W_WORD_SDAO;  
wire        W_POINTER_SCL; 
wire        W_POINTER_SDAO; 
wire        R_SCL; 
wire        R_SDAO;  

//=======================================================
//  Structural coding
//======================================================= 

																 
assign Voltage =(R_DATA[15:4]*122) / 100 ;  // 1000*5V/4095 , ADC digital binary data to mV

//---400khz clock generater 
CLOCKMEM u_CLOCKMEM( .CLK(iCLK) ,.CLK_FREQ(125) ,.CK_1HZ(CLK_400K ) );
																 
//--I2C Main Controller--- 
always @(negedge iRESET_N or posedge CLK_400K )begin 
if (!iRESET_N  ) begin 
    ST <=0;
 	 W_POINTER_GO <=1;
    R_GO         <=1;		 
	 W_WORD_GO    <=1;
	 WCNT         <=0;  
	 CNT          <=0;
	 DELY         <=0; 
	 READY        <=1; 
	 CH           <=0;
	 
end 
else begin
case (ST)
0: begin 
    ST           <=31; //---first I2C WRITE Channel_ID
	 W_POINTER_GO <=1;
    R_GO         <=1;		 
	 W_WORD_GO    <=1;
	 WCNT         <=0;  
	 CNT          <=0;
	 DELY         <=0;   
   end
//------------- READ -------	
1: begin 
    ST          <=6; 	
	 BYTE        <=2;  
	end	
	//------- Read DATA  		 
6: begin 
	 if ( R_END ) begin  
	  R_GO  <=0; 
	  ST<=7 ; 
	  DELY<=0; 
	 end
	end                
7: begin 
    DELY  <=DELY +1;
    if ( DELY ==2 ) begin 	 
      R_GO  <=1;
      ST<=8 ; 
	 end
	end       
8: begin 
     ST<=9 ; 
	end       
9: begin 
   if  ( R_END ) 
	 begin 		
	      //---READ  channel ADC DATA
		        if ( CH==0) 	CH0_D  <= Voltage ; 
			else if ( CH==1) 	CH1_D  <= Voltage ; 
			else if ( CH==2) 	CH2_D  <= Voltage ; 
			else if ( CH==3) 	CH3_D  <= Voltage ; 
			else if ( CH==4) 	CH4_D  <= Voltage ; 
			else if ( CH==5) 	CH5_D  <= Voltage ; 
			else if ( CH==6) 	CH6_D  <= Voltage ; 
			else if ( CH==7) 	CH7_D  <= Voltage ; 
	      ST<=10 ; 	
	 end 
  end	
10: begin   
		  ST           <= 31; 
	     W_POINTER_GO <=1;
        R_GO         <=1 ;		 
	     W_WORD_GO    <=1; 		    		 		  
		  CH <=CH+1 ; 
	 end 
//----  READ END ----

//----  WRITE----
31: begin 
 {SLAVE_ADDR ,W_POINTER_REG ,W_WORD_DATA,BYTE} <= { iSLAVE_ADDR[7:0] ,WRITE_CMD[7:0] ,{P_CHANNEL_SEL[7:0], 5'h0,CH[2:0]} ,8'h02};
	 if (  W_WORD_END ) begin  
	   W_WORD_GO  <=0; 
		ST   <=32 ;  
		DELY <=0;  
	 end
	end           
32: begin 
    DELY  <=DELY +1;
	   if (  DELY ==5 )  begin
        W_WORD_GO  <=1;
        ST         <=33 ; 
	 end
	 
	end       
33: begin 
    ST<=34 ; 
	end       	
34: begin 
     if  ( W_WORD_END )  begin 	
			 ST<=35 ; 
	  end
	end              
35: begin 
	         ST       <= 36; 
				CNT      <= 0; 
				DELY     <= 0;	          
	 end 
36:begin	
 if ( DELY == SEC ) ST<=1;//display delay 
 else DELY <=DELY +1 ; 
end 
	 
endcase
end
end
//-----------------------------MAIN-ST END ------------------------------------------ 

//---i2c bus out --
assign SCLO           = W_POINTER_SCL  & R_SCL   & W_WORD_SCL;
assign SDAO           = W_POINTER_SDAO & R_SDAO  & W_WORD_SDAO;
assign I2C_SDA        = (SDAO)?1'bz :0;
assign I2C_SCL        = (SCLO)?1'bz :0;


//==== I2C WRITE data ===
I2C_WRITE  I2C_WRITE_i(
   .BYTE_NUM     ( BYTE   ),
   .RESET_N      ( iRESET_N),
	.PT_CK        ( CLK_400K),
	.GO           ( W_WORD_GO),
	.POINTER      ( W_POINTER_REG),
   .WDATA	     ( W_WORD_DATA),
	.SLAVE_ADDRESS( SLAVE_ADDR ),
	.SDAI         ( I2C_SDA),
	.SDAO         ( W_WORD_SDAO),
	.SCLO         ( W_WORD_SCL ),
	.END_OK       ( W_WORD_END)
);

//==== I2C WRITE POINTER ===
I2C_WRITE_POINTER  I2C_WRITE_POINTER_i(
   .RESET_N      (iRESET_N   ),
	.PT_CK        ( CLK_400K ),
	.GO           ( W_POINTER_GO ),
	.POINTER      ( W_POINTER_REG),
	.SLAVE_ADDRESS( SLAVE_ADDR ),
	.SDAI         ( I2C_SDA    ),
	.SDAO         ( W_POINTER_SDAO),
	.SCLO         ( W_POINTER_SCL ),
	.END_OK       ( W_POINTER_END )
);
//-----I2C READ data---- 
I2C_READ_DATA I2C_READ_DATA_i( 
   .RESET_N      ( iRESET_N    ),
	.PT_CK        ( CLK_400K   ),
	.GO           ( R_GO       ),
	.SLAVE_ADDRESS( SLAVE_ADDR ),
 	.BYTE_NUM     ( 2       ) , // I2C read 16 bit data 
	.SDAI         ( I2C_SDA),
	.SDAO         ( R_SDAO ),
	.SCLO         ( R_SCL  ),
	.END_OK       ( R_END  ),
	.DATA         ( R_DATA )
);
	
endmodule



