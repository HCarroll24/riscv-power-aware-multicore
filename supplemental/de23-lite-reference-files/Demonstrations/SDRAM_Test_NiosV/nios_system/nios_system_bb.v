module nios_system (
		input  wire        clk_clk,                        //                     clk.clk
		output wire        sdram_clk_clk,                  //               sdram_clk.clk
		input  wire [3:0]  key_external_connection_export, // key_external_connection.export
		output wire [9:0]  led_external_connection_export, // led_external_connection.export
		input  wire [9:0]  sw_external_connection_export,  //  sw_external_connection.export
		input  wire        reset_reset_n,                  //                   reset.reset_n
		output wire        sdram_cke,                      //                   sdram.cke
		output wire        sdram_cs_n,                     //                        .cs_n
		output wire        sdram_ras_n,                    //                        .ras_n
		output wire        sdram_cas_n,                    //                        .cas_n
		output wire        sdram_we_n,                     //                        .we_n
		output wire [3:0]  sdram_dqm,                      //                        .dqm
		output wire [12:0] sdram_addr,                     //                        .addr
		output wire [1:0]  sdram_ba,                       //                        .ba
		output wire [31:0] sdram_data_out,                 //                        .data_out
		output wire        sdram_data_oe,                  //                        .data_oe
		input  wire [31:0] sdram_data_in                   //                        .data_in
	);
endmodule

