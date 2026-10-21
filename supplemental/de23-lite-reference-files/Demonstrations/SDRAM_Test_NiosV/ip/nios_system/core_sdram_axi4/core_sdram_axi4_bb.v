module core_sdram_axi4 #(
		parameter SDRAM_MHZ          = 80,
		parameter SDRAM_ADDR_W       = 24,
		parameter SDRAM_COL_W        = 9,
		parameter SDRAM_READ_LATENCY = 2
	) (
		output wire                            sdram_cke_o,         //             sdram.cke
		output wire                            sdram_cs_o,          //                  .cs_n
		output wire                            sdram_ras_o,         //                  .ras_n
		output wire                            sdram_cas_o,         //                  .cas_n
		output wire                            sdram_we_o,          //                  .we_n
		output wire [3:0]                      sdram_dqm_o,         //                  .dqm
		output wire [12:0]                     sdram_addr_o,        //                  .addr
		output wire [1:0]                      sdram_ba_o,          //                  .ba
		output wire [31:0]                     sdram_data_output_o, //                  .data_out
		output wire                            sdram_data_out_en_o, //                  .data_oe
		input  wire [31:0]                     sdram_data_input_i,  //                  .data_in
		input  wire                            clk_i,               //        clock_sink.clk
		input  wire                            clk_sample_i,        // clock_sample_sink.clk
		input  wire                            rst_i,               //        reset_sink.reset
		input  wire                            inport_awvalid_i,    //        axi4_slave.awvalid
		input  wire [((SDRAM_ADDR_W-0)+2)-1:0] inport_awaddr_i,     //                  .awaddr
		input  wire [3:0]                      inport_awid_i,       //                  .awid
		input  wire [7:0]                      inport_awlen_i,      //                  .awlen
		input  wire [1:0]                      inport_awburst_i,    //                  .awburst
		input  wire                            inport_wvalid_i,     //                  .wvalid
		input  wire [63:0]                     inport_wdata_i,      //                  .wdata
		input  wire [7:0]                      inport_wstrb_i,      //                  .wstrb
		input  wire                            inport_wlast_i,      //                  .wlast
		input  wire                            inport_bready_i,     //                  .bready
		input  wire                            inport_arvalid_i,    //                  .arvalid
		input  wire [((SDRAM_ADDR_W-0)+2)-1:0] inport_araddr_i,     //                  .araddr
		input  wire [3:0]                      inport_arid_i,       //                  .arid
		input  wire [7:0]                      inport_arlen_i,      //                  .arlen
		input  wire [1:0]                      inport_arburst_i,    //                  .arburst
		input  wire                            inport_rready_i,     //                  .rready
		output wire                            inport_awready_o,    //                  .awready
		output wire                            inport_wready_o,     //                  .wready
		output wire                            inport_bvalid_o,     //                  .bvalid
		output wire [1:0]                      inport_bresp_o,      //                  .bresp
		output wire [3:0]                      inport_bid_o,        //                  .bid
		output wire                            inport_arready_o,    //                  .arready
		output wire                            inport_rvalid_o,     //                  .rvalid
		output wire [63:0]                     inport_rdata_o,      //                  .rdata
		output wire [1:0]                      inport_rresp_o,      //                  .rresp
		output wire [3:0]                      inport_rid_o,        //                  .rid
		output wire                            inport_rlast_o,      //                  .rlast
		input  wire [2:0]                      inport_awsize_i,     //                  .awsize
		input  wire [2:0]                      inport_arsize_i      //                  .arsize
	);
endmodule

