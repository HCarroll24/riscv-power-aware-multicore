module BCD_MUX(
input  [2:0]iSW,
input  [15:0]iCH0_D,
input  [15:0]iCH1_D,
input  [15:0]iCH2_D,
input  [15:0]iCH3_D,
input  [15:0]iCH4_D,
input  [15:0]iCH5_D,
input  [15:0]iCH6_D,
input  [15:0]iCH7_D,
output [15:0]oBCD,

//---test
output [15:0]CH_DATA//mV

);

//---adc data mux
assign CH_DATA = (
         (iSW==0)? iCH0_D :(
         (iSW==1)? iCH1_D :(
         (iSW==2)? iCH2_D :(
         (iSW==3)? iCH3_D :(
         (iSW==4)? iCH4_D :(
         (iSW==5)? iCH5_D :(
         (iSW==6)? iCH6_D :(
         (iSW==7)? iCH7_D :iCH7_D
			))))))));
			
//---BCD transfer			
wire [3:0]B0,B1,B2,B3 ; 

wire [15:0] temp1,temp2,temp3,temp4 ;
assign      temp1 = CH_DATA/10 ; 
assign      temp2 = temp1/10 ; 
assign      temp3 = temp2/10 ; 
assign      temp4 = temp3/10 ; 

//--binary to bcd
assign B0 = CH_DATA - temp1*10; 
assign B1 = temp1   - temp2*10; 
assign B2 = temp2   - temp3*10; 
assign B3 = temp3   - temp4*10; 

			
//---BCD out			
assign oBCD = { B3,B2,B1,B0 };
			
endmodule 