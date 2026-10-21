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


`timescale 1ps/1ps

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "STbanMqy8UpvYjUJXR/AuKniYmV/XZ0zJn/xzMvub2v72ixIJ7RUF/NrPoLZm9VpGYB+6/h3sGK2eBCGD8WgzYV4s04rwJV/gFlBTxheWC+sVCOTbBzPz91EJjQVEkx36RN/HJdQoD8GpU5YEjaU0qB+68AKbYYQBDCCuFskkWV1Ncy+T+wBSgFHyoxeoiMh9z1OKFVWiKp5JLyFZLmSp4sAD90mao8g5EAIvtCteI+reYGxHVHnmvbXHHOqnfYcoZRGeGsr0JVrdiLxE5Lu9MRFaBnOkfSt0gPljHJAQoVn3bOGqAlxiEtFNsqze5IUFixD5nLkTsoSu/st3xEA++12jmkppH+9mdIy8JppC8kjeojvaIeoSAQo485q11AQgbSLcma/qvFHQV1/HzmJ8hjVWd8AVlg3zkcFMvHHsxkfbqjqfQDkf1fgcE1z0zp7YrDmp2qRZOcsyP1OTEXyPu0lXu7ne468K5xQiOvBAQSC/vvzyDR4grgSm5e5Q//1OxaTV0/tygv9UYkB1RN7Sn1w+xLgUwyoEEZXXdv5qJVls4TeYdvIkhuojyggxcRBGhESKjnq33wJkv4WlrsxQBBe4kHwS4CEacW/jBgiZjydqXI8v/+nxehZ0MraT7JG+qvmZLIRu6P4wiNbtGsHOeWJhDSUS0VMiUQyTWx2oESx7LS0omkjhqP2pqirF1zx3h9JFJVY6fjbL78ZeD2ZtZVf0MeIgEi/bPy/FpnVQihHXOw30yk9m+4q/6e8dHdtN8an2eEg/8VuW7SvM0XNEd+xKHo7tXhiEjoutz44E8FTiqyLgRSRpm6dMUsR7bdLMJRf8O/9Cd8POWvaEyvUSb7wMYs2Ct+dvdB6YPs2q/weDe3pUWWII3x7L3JNnyJtH//Tpk1Xb4gcU8BKurvH4pBvR+BwJgGXhVmQQiqnyjg9dam+L0CZFH7oBGwzLkTdfkvCpdiY061IPwvn6MjrfN1zHR3JLN7gDZaL4XUBtSLM0JO7lelqYn38zNH9ke7r"
`endif