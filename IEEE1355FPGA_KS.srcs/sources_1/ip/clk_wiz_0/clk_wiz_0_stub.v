// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed May 04 10:50:22 2016
// Host        : DESKTOP-K3PR8B2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Github/IEEE1355FPGA_KS/IEEE1355FPGA_KS.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_in1, clk_tx, clk_rx, resetn, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_tx,clk_rx,resetn,locked" */;
  input clk_in1;
  output clk_tx;
  output clk_rx;
  input resetn;
  output locked;
endmodule
