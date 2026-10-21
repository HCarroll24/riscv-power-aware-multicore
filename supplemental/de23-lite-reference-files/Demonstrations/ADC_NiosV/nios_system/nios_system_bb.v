module nios_system (
		input  wire       clk_clk,                       //                    clk.clk
		input  wire       i2c_master_i2c_serial_sda_in,  //  i2c_master_i2c_serial.sda_in
		input  wire       i2c_master_i2c_serial_scl_in,  //                       .scl_in
		output wire       i2c_master_i2c_serial_sda_oe,  //                       .sda_oe
		output wire       i2c_master_i2c_serial_scl_oe,  //                       .scl_oe
		input  wire [9:0] sw_external_connection_export, // sw_external_connection.export
		input  wire       reset_reset_n                  //                  reset.reset_n
	);
endmodule

