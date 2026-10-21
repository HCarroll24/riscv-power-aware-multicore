// Address Space Parameters
`define COLSTART        0  //8:0
`define COLSIZE         9

`define ROWSTART        9  //21:9          
`define ROWSIZE         13


`define BANKSTART       22 //23:22 
`define BANKSIZE        2  


// Address and Data Bus Sizes
`define  SASIZE          13

`define  ASIZE           24      //16M//25      // 4MX32bit total address width of the SDRAM
`define  DSIZE           32      // Width of data bus to SDRAMS

//parameter	INIT_PER	=	100;		//	For Simulation

//	Controller Parameter
////////////	166 MHz	PASS///////////////
//parameter	INIT_PER	=	39840;
//parameter	REF_PER  =	1700;
//parameter	SC_CL		=	3;
//parameter	SC_RCD   =	3;
//parameter	SC_RRD	=	7;
//parameter	SC_PM		=	1;
//parameter	SC_BL		=	1;
///////////////////////////////////////


////////////	133 MHz	PASS///////////////
//parameter	INIT_PER	=	31920;
//parameter	REF_PER		=	1362;
//parameter	SC_CL		   =	3;
//parameter	SC_RCD		=	3;
//parameter	SC_RRD		=	7;
//parameter	SC_PM		=	1;
//parameter	SC_BL		=	1;
/////////////////////////////////////
////////////	125 MHz	PASS///////////////
parameter	INIT_PER	=	30000;
parameter	REF_PER  =	1280;
parameter	SC_CL		=	3;
parameter	SC_RCD   =	3;
parameter	SC_RRD	=	7;
parameter	SC_PM		=	1;
parameter	SC_BL		=	1;
///////////////////////////////////////


//////////////	100 MHz	///////////////
//parameter	INIT_PER	=	24000;
//parameter	REF_PER  =	1024;
//parameter	SC_CL		=	3;
//parameter	SC_RCD   =	3;
//parameter	SC_RRD	=	7;
//parameter	SC_PM		=	1;
//parameter	SC_BL		=	1;
///////////////////////////////////////
////////////	50 MHz	///////////////
/*
parameter	INIT_PER	=	12000;
parameter	REF_PER		=	512;
parameter	SC_CL		=	3;
parameter	SC_RCD		=	3;
parameter	SC_RRD		=	7;
parameter	SC_PM		=	1;
parameter	SC_BL		=	1;
*/
///////////////////////////////////////

//	SDRAM Parameter
parameter	SDR_BL		=	(SC_PM == 1)?	3'b111	://Reserved//3BIT
							      (SC_BL == 1)?	3'b000	:
							      (SC_BL == 2)?	3'b001	:
							      (SC_BL == 4)?	3'b010	:
											3'b011	;
parameter	SDR_BT		=	1'b0;	//	Sequential             //1BIT
							     //	1'b1:	//	Interteave
parameter	SDR_CL		=	(SC_CL == 2)?	3'b010: //burst 4 3BIT
											         3'b011; //burst 8
 	
