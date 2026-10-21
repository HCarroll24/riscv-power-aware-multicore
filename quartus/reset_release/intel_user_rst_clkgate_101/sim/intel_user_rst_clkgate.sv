// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ns
module intel_user_rst_clkgate (
	output logic ninit_done
);

	localparam USER_RESET_DELAY = 0;
	
	initial begin
		#0 ninit_done = 1;
		#1 ninit_done = 0;
	end
					
	
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "Wb0mK1AUmeF4qoVrkkyLbt7Sh8VxWjLlDTk9QgortzHj4124um71hzWWnH0/MEp+WGQ+0FFTBk2z0dh2Vevc83z/yN9J7ls8XyXcS46aa6cwXCJ6hKbuMLAW3vsna2vrq9cpzDtTFjb1Z214U9LuDsgpBO2RQHW5Vj/Yqr9ELVuvnnwjeJTCP786MyIbXNIBgdCjlzVy0UnFa1pp6/QbxiXEbvMV+rMN7g8VzjkMaU5HV6seLCQOXrVNCdij29AjL3d1mkxjg3M4isC/YC1SvgNADsS5FIUe1TfFI1xG/+yerUNI5CaBGnhuDWOqk0Gcnp9qAFjzGnIXdN+nedKiR426S2scoJ4c2JZzwa4dGJYMnLEm6M5tYwaEIeIjE2bsUBSM/oUlsHwVkwFA/013HBKauTONyV+qEcMEPl6rwi1sf7hDYRCakvXIIuS0SArVREKP+rc+vaLUqJt6KGoWCx1kYLVl85N5Ej4Ae+7wwd/ln7HnMeE6cQNTQW1uxGy4sDBxSuvz61bNHNki6G0Z+nomNSCeirXsNOfwN2yt3Y+m7jVPnsvCBUSMPGPvcWjfrQ8uUvcgBzRiiwdVwufidocosDL/UKjYjbgDIGOPIbkYKTK1G2jCEa2FH77JmKsCeN2BWQFt+gJOipP0Cp8Rurt2kjHb0VxHft3twJyWG6FnJqUdIUsYamI6y44irMa6Gqx/GLOPtigyeIxwbmvqiIZR9ALDrcl1pPtOwfbiOFOintVXdYuLkOZFsvHcoGyXB+Ci2Dakz6X89+Mi3VG8zn83iBLNR7UA7Mjj5pO58cRfBn2Txd88uC+O13zEOjgWb378d6H2xwBT0H3gagUjhpNW2yUePmr9eSJblf4jwocr+BwKPbrebUImOeJkFa6+aX662lGbsd+OgrQ0vUB3a0PCmmY5WDOQfbx7Wk/qSL6hP2gv6GdqEgQWHSSw9OwnnUlfFm9QHoCIhNr0mnURBlTitPicrWX0T7ehUFCHSTcVxEoeLKpKU8mzbc3d8CN7"
`endif