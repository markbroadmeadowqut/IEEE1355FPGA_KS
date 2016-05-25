// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4.2 (win64) Build 1494164 Fri Feb 26 04:18:56 MST 2016
// Date        : Wed May 04 19:25:57 2016
// Host        : SEF-PA00122509 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub c:/GitHub/IEEE1355FPGA_KS/src_ip/pll/pll_stub.v
// Design      : pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module pll(clk_pad, clk_100, clk_200)
/* synthesis syn_black_box black_box_pad_pin="clk_pad,clk_100,clk_200" */;
  input clk_pad;
  output clk_100;
  output clk_200;
endmodule
