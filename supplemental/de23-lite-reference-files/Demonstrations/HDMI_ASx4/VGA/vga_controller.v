module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data);
input iRST_n;
input iVGA_CLK;
output  oBLANK_n;
output  oHS;
output  oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [20:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));

reg iRST_n_sync;									
always@(posedge iVGA_CLK)							
begin
	iRST_n_sync <= iRST_n;
end		
										
										////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n_sync)
begin
  if (!iRST_n_sync)
     ADDR<=21'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=21'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end

//////////////////////////
//////INDEX addr.

wire [23:0] m20k_index;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( iVGA_CLK ),
	.q ( m20k_index )
	);
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	

wire [23:0] mlab_index;
////Color table output
img_data_mlab	img_data_mlab_inst (
	.address ( ADDR-21'd896000),
	.clock ( iVGA_CLK ),
	.q ( mlab_index)
	);	

	assign index  = (ADDR <= 21'd896000)? m20k_index: mlab_index;


///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
localparam PIPEDEPTH = 10;
parameter DATA_W = 27;
hyper_pipe #(.WIDTH(DATA_W), .NUM_PIPES(PIPEDEPTH)) video_control_pipe
			(.din({bgr_data_raw,cBLANK_n,cVS,cHS}), .dout ({b_data,g_data,r_data,oBLANK_n,oVS,oHS}), .clk (iVGA_CLK));
			

endmodule
 	
















