-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4.2 (win64) Build 1494164 Fri Feb 26 04:18:56 MST 2016
-- Date        : Wed May 04 19:25:57 2016
-- Host        : SEF-PA00122509 running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub c:/GitHub/IEEE1355FPGA_KS/src_ip/pll/pll_stub.vhdl
-- Design      : pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35ticsg324-1L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll is
  Port ( 
    clk_pad : in STD_LOGIC;
    clk_100 : out STD_LOGIC;
    clk_200 : out STD_LOGIC
  );

end pll;

architecture stub of pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_pad,clk_100,clk_200";
begin
end;
