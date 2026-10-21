	core_sdram_axi4 #(
		.SDRAM_MHZ          (INTEGER_VALUE_FOR_SDRAM_MHZ),
		.SDRAM_ADDR_W       (INTEGER_VALUE_FOR_SDRAM_ADDR_W),
		.SDRAM_COL_W        (INTEGER_VALUE_FOR_SDRAM_COL_W),
		.SDRAM_READ_LATENCY (INTEGER_VALUE_FOR_SDRAM_READ_LATENCY)
	) u0 (
		.sdram_cke_o         (_connected_to_sdram_cke_o_),         //  output,                     width = 1,             sdram.cke
		.sdram_cs_o          (_connected_to_sdram_cs_o_),          //  output,                     width = 1,                  .cs_n
		.sdram_ras_o         (_connected_to_sdram_ras_o_),         //  output,                     width = 1,                  .ras_n
		.sdram_cas_o         (_connected_to_sdram_cas_o_),         //  output,                     width = 1,                  .cas_n
		.sdram_we_o          (_connected_to_sdram_we_o_),          //  output,                     width = 1,                  .we_n
		.sdram_dqm_o         (_connected_to_sdram_dqm_o_),         //  output,                     width = 4,                  .dqm
		.sdram_addr_o        (_connected_to_sdram_addr_o_),        //  output,                    width = 13,                  .addr
		.sdram_ba_o          (_connected_to_sdram_ba_o_),          //  output,                     width = 2,                  .ba
		.sdram_data_output_o (_connected_to_sdram_data_output_o_), //  output,                    width = 32,                  .data_out
		.sdram_data_out_en_o (_connected_to_sdram_data_out_en_o_), //  output,                     width = 1,                  .data_oe
		.sdram_data_input_i  (_connected_to_sdram_data_input_i_),  //   input,                    width = 32,                  .data_in
		.clk_i               (_connected_to_clk_i_),               //   input,                     width = 1,        clock_sink.clk
		.clk_sample_i        (_connected_to_clk_sample_i_),        //   input,                     width = 1, clock_sample_sink.clk
		.rst_i               (_connected_to_rst_i_),               //   input,                     width = 1,        reset_sink.reset
		.inport_awvalid_i    (_connected_to_inport_awvalid_i_),    //   input,                     width = 1,        axi4_slave.awvalid
		.inport_awaddr_i     (_connected_to_inport_awaddr_i_),     //   input,  width = ((SDRAM_ADDR_W-0)+2),                  .awaddr
		.inport_awid_i       (_connected_to_inport_awid_i_),       //   input,                     width = 4,                  .awid
		.inport_awlen_i      (_connected_to_inport_awlen_i_),      //   input,                     width = 8,                  .awlen
		.inport_awburst_i    (_connected_to_inport_awburst_i_),    //   input,                     width = 2,                  .awburst
		.inport_wvalid_i     (_connected_to_inport_wvalid_i_),     //   input,                     width = 1,                  .wvalid
		.inport_wdata_i      (_connected_to_inport_wdata_i_),      //   input,                    width = 64,                  .wdata
		.inport_wstrb_i      (_connected_to_inport_wstrb_i_),      //   input,                     width = 8,                  .wstrb
		.inport_wlast_i      (_connected_to_inport_wlast_i_),      //   input,                     width = 1,                  .wlast
		.inport_bready_i     (_connected_to_inport_bready_i_),     //   input,                     width = 1,                  .bready
		.inport_arvalid_i    (_connected_to_inport_arvalid_i_),    //   input,                     width = 1,                  .arvalid
		.inport_araddr_i     (_connected_to_inport_araddr_i_),     //   input,  width = ((SDRAM_ADDR_W-0)+2),                  .araddr
		.inport_arid_i       (_connected_to_inport_arid_i_),       //   input,                     width = 4,                  .arid
		.inport_arlen_i      (_connected_to_inport_arlen_i_),      //   input,                     width = 8,                  .arlen
		.inport_arburst_i    (_connected_to_inport_arburst_i_),    //   input,                     width = 2,                  .arburst
		.inport_rready_i     (_connected_to_inport_rready_i_),     //   input,                     width = 1,                  .rready
		.inport_awready_o    (_connected_to_inport_awready_o_),    //  output,                     width = 1,                  .awready
		.inport_wready_o     (_connected_to_inport_wready_o_),     //  output,                     width = 1,                  .wready
		.inport_bvalid_o     (_connected_to_inport_bvalid_o_),     //  output,                     width = 1,                  .bvalid
		.inport_bresp_o      (_connected_to_inport_bresp_o_),      //  output,                     width = 2,                  .bresp
		.inport_bid_o        (_connected_to_inport_bid_o_),        //  output,                     width = 4,                  .bid
		.inport_arready_o    (_connected_to_inport_arready_o_),    //  output,                     width = 1,                  .arready
		.inport_rvalid_o     (_connected_to_inport_rvalid_o_),     //  output,                     width = 1,                  .rvalid
		.inport_rdata_o      (_connected_to_inport_rdata_o_),      //  output,                    width = 64,                  .rdata
		.inport_rresp_o      (_connected_to_inport_rresp_o_),      //  output,                     width = 2,                  .rresp
		.inport_rid_o        (_connected_to_inport_rid_o_),        //  output,                     width = 4,                  .rid
		.inport_rlast_o      (_connected_to_inport_rlast_o_),      //  output,                     width = 1,                  .rlast
		.inport_awsize_i     (_connected_to_inport_awsize_i_),     //   input,                     width = 3,                  .awsize
		.inport_arsize_i     (_connected_to_inport_arsize_i_)      //   input,                     width = 3,                  .arsize
	);

