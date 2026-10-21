	nios_system u0 (
		.clk_clk                       (_connected_to_clk_clk_),                       //   input,   width = 1,                    clk.clk
		.i2c_master_i2c_serial_sda_in  (_connected_to_i2c_master_i2c_serial_sda_in_),  //   input,   width = 1,  i2c_master_i2c_serial.sda_in
		.i2c_master_i2c_serial_scl_in  (_connected_to_i2c_master_i2c_serial_scl_in_),  //   input,   width = 1,                       .scl_in
		.i2c_master_i2c_serial_sda_oe  (_connected_to_i2c_master_i2c_serial_sda_oe_),  //  output,   width = 1,                       .sda_oe
		.i2c_master_i2c_serial_scl_oe  (_connected_to_i2c_master_i2c_serial_scl_oe_),  //  output,   width = 1,                       .scl_oe
		.sw_external_connection_export (_connected_to_sw_external_connection_export_), //   input,  width = 10, sw_external_connection.export
		.reset_reset_n                 (_connected_to_reset_reset_n_)                  //   input,   width = 1,                  reset.reset_n
	);

