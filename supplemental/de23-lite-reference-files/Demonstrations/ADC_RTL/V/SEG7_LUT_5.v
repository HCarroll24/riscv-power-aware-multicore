module SEG7_LUT_5 (	oSEG0,oSEG1,oSEG2,oSEG3,oSEG4,iDIG );
input	[19:0]	iDIG;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3,oSEG4;

SEG7_LUT	u0	(	oSEG0,iDIG[3:0]		);
SEG7_LUT	u1	(	oSEG1,iDIG[7:4]		);
SEG7_LUT	u2	(	oSEG2,iDIG[11:8]	);
SEG7_LUT	u3	(	oSEG3,iDIG[15:12]	);
SEG7_LUT	u4	(	oSEG4,iDIG[19:16]	);

endmodule