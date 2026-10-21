module video_sync_generator(reset,
                            vga_clk,
                            blank_n,
                            HS,
                            VS);
                            
input reset;
input vga_clk;
output reg blank_n;
output reg HS;
output reg VS;
///////////////////
/*
--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line
--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line
*////////////////////////////////////////////
////////////////////////                          
//parameter 640*480
//parameter hori_line  = 800;    
//parameter hori_back  = 144;		
//parameter hori_front = 16;		
//parameter vert_line  = 525;		
//parameter vert_back  = 34;		
//parameter vert_front = 11;		
//parameter H_sync_cycle = 96;	
//parameter V_sync_cycle = 2;		 

//parameter 1080p
//parameter hori_line  = 2200;                       
//parameter hori_back  = 192;		 
//parameter hori_front = 88;			 
//parameter vert_line  = 1125;		 
//parameter vert_back  = 41;			 
//parameter vert_front = 4;			 
//parameter H_sync_cycle = 44;		 
//parameter V_sync_cycle = 5;		 
//////////////////////////
// parameter 1280 x 720 @ 60Hz 
parameter hori_line    = 1650;         
parameter hori_back    = 260;          
parameter hori_front   = 110;          
parameter vert_line    = 750;          
parameter vert_back    = 25;           
parameter vert_front   = 5;            
parameter H_sync_cycle = 40;           
parameter V_sync_cycle = 5;            

reg [31:0] h_cnt;
reg [31:0]  v_cnt;
wire cHD,cVD,cDEN,hori_valid,vert_valid;
///////
reg reset_sync;
always@(negedge vga_clk)
begin
	reset_sync <= reset;
end
always@(negedge vga_clk)
begin
  if (reset_sync)
  begin
     h_cnt<=32'd0;
     v_cnt<=32'd0;
  end
    else
    begin
      if (h_cnt==hori_line-1)
      begin 
         h_cnt<=32'd0;
         if (v_cnt==vert_line-1)
            v_cnt<=32'd0;
         else
            v_cnt<=v_cnt+1;
      end
      else
         h_cnt<=h_cnt+1;
    end
end
/////
assign cHD = (h_cnt<H_sync_cycle)?1'b0:1'b1;
assign cVD = (v_cnt<V_sync_cycle)?1'b0:1'b1;

assign hori_valid = (h_cnt<(hori_line-hori_front)&& h_cnt>=hori_back)?1'b1:1'b0;
assign vert_valid = (v_cnt<(vert_line-vert_front)&& v_cnt>=vert_back)?1'b1:1'b0;

assign cDEN = hori_valid && vert_valid;

always@(negedge vga_clk)
begin
  HS<=cHD;
  VS<=cVD;
  blank_n<=cDEN;
end

endmodule


