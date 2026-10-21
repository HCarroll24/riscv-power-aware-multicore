	nios_system u0 (
		.clk_clk                        (_connected_to_clk_clk_),                        //   input,   width = 1,                     clk.clk
		.sdram_clk_clk                  (_connected_to_sdram_clk_clk_),                  //  output,   width = 1,               sdram_clk.clk
		.key_external_connection_export (_connected_to_key_external_connection_export_), //   input,   width = 4, key_external_connection.export
		.led_external_connection_export (_connected_to_led_external_connection_export_), //  output,  width = 10, led_external_connection.export
		.sw_external_connection_export  (_connected_to_sw_external_connection_export_),  //   input,  width = 10,  sw_external_connection.export
		.reset_reset_n                  (_connected_to_reset_reset_n_),                  //   input,   width = 1,                   reset.reset_n
		.sdram_cke                      (_connected_to_sdram_cke_),                      //  output,   width = 1,                   sdram.cke
		.sdram_cs_n                     (_connected_to_sdram_cs_n_),                     //  output,   width = 1,                        .cs_n
		.sdram_ras_n                    (_connected_to_sdram_ras_n_),                    //  output,   width = 1,                        .ras_n
		.sdram_cas_n                    (_connected_to_sdram_cas_n_),                    //  output,   width = 1,                        .cas_n
		.sdram_we_n                     (_connected_to_sdram_we_n_),                     //  output,   width = 1,                        .we_n
		.sdram_dqm                      (_connected_to_sdram_dqm_),                      //  output,   width = 4,                        .dqm
		.sdram_addr                     (_connected_to_sdram_addr_),                     //  output,  width = 13,                        .addr
		.sdram_ba                       (_connected_to_sdram_ba_),                       //  output,   width = 2,                        .ba
		.sdram_data_out                 (_connected_to_sdram_data_out_),                 //  output,  width = 32,                        .data_out
		.sdram_data_oe                  (_connected_to_sdram_data_oe_),                  //  output,   width = 1,                        .data_oe
		.sdram_data_in                  (_connected_to_sdram_data_in_)                   //   input,  width = 32,                        .data_in
	);

