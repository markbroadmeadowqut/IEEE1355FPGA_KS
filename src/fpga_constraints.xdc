
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


##Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_pad]
create_clock -period 10.000 -name clk_pad -waveform {0.000 5.000} -add [get_ports clk_pad]

##Resets
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports rst_n]

##Switches
set_property PACKAGE_PIN A8 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN C11 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN C10 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN A10 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

##Buttons
set_property PACKAGE_PIN D9 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]
set_property PACKAGE_PIN C9 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]
set_property PACKAGE_PIN B9 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]
set_property PACKAGE_PIN B8 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]

##LEDs
set_property PACKAGE_PIN H5 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN J5 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN T9 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN T10 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

## Blue LEDs
set_property PACKAGE_PIN E1 [get_ports {ledb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ledb[0]}]
set_property PACKAGE_PIN G4 [get_ports {ledb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ledb[1]}]
set_property PACKAGE_PIN H4 [get_ports {ledb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ledb[2]}]
set_property PACKAGE_PIN K2 [get_ports {ledb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ledb[3]}]

##Pmod Header JA
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { d_outA }]
#set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { s_outA }]

##Pmod Header JD
#set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { d_inA }]
#set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports { s_inA }]

##Pmod Header JB



##Pmod Header JC



##ChipKit Digital I/O On Inner Analog Header
##NOTE: These pins will need to be connected to the XADC core when used as differential analog inputs (Chipkit analog pins A6-A11)

set_property PACKAGE_PIN F5 [get_ports {debug[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[30]}]
set_property PACKAGE_PIN D8 [get_ports {debug[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[31]}]
set_property PACKAGE_PIN C7 [get_ports {debug[32]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[32]}]
set_property PACKAGE_PIN E7 [get_ports {debug[33]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[33]}]
set_property PACKAGE_PIN D7 [get_ports {debug[34]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[34]}]
set_property PACKAGE_PIN D5 [get_ports {debug[35]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[35]}]

##ChipKit Digital I/O High

set_property PACKAGE_PIN U11 [get_ports {debug[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[28]}]
set_property PACKAGE_PIN V16 [get_ports {debug[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[26]}]
set_property PACKAGE_PIN M13 [get_ports {debug[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[24]}]
set_property PACKAGE_PIN R10 [get_ports {debug[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[22]}]
set_property PACKAGE_PIN R11 [get_ports {debug[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[20]}]
set_property PACKAGE_PIN R13 [get_ports {debug[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[18]}]
set_property PACKAGE_PIN R15 [get_ports {debug[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[16]}]
set_property PACKAGE_PIN P15 [get_ports {debug[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[14]}]
set_property PACKAGE_PIN R16 [get_ports {debug[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[12]}]
set_property PACKAGE_PIN N16 [get_ports {debug[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[10]}]
set_property PACKAGE_PIN N14 [get_ports {debug[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[8]}]
set_property PACKAGE_PIN U17 [get_ports {debug[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[6]}]
set_property PACKAGE_PIN T18 [get_ports {debug[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[4]}]
set_property PACKAGE_PIN R18 [get_ports {debug[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[2]}]
set_property PACKAGE_PIN P18 [get_ports {debug[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[1]}]
set_property PACKAGE_PIN N17 [get_ports {debug[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[0]}]

##ChipKit Digital I/O Low

set_property PACKAGE_PIN V15 [get_ports {debug[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[29]}]
set_property PACKAGE_PIN U16 [get_ports {debug[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[27]}]
set_property PACKAGE_PIN P14 [get_ports {debug[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[25]}]
set_property PACKAGE_PIN T11 [get_ports {debug[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[23]}]
set_property PACKAGE_PIN R12 [get_ports {debug[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[21]}]
set_property PACKAGE_PIN T14 [get_ports {debug[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[19]}]
set_property PACKAGE_PIN T15 [get_ports {debug[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[17]}]
set_property PACKAGE_PIN T16 [get_ports {debug[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[15]}]
set_property PACKAGE_PIN N15 [get_ports {debug[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[13]}]
set_property PACKAGE_PIN M16 [get_ports {debug[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[11]}]
set_property PACKAGE_PIN V17 [get_ports {debug[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[9]}]
set_property PACKAGE_PIN U18 [get_ports {debug[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[7]}]
set_property PACKAGE_PIN R17 [get_ports {debug[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[5]}]
set_property PACKAGE_PIN P17 [get_ports {debug[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[3]}]




set_property IOSTANDARD TMDS_33 [get_ports A_d_in_P]
set_property IOSTANDARD TMDS_33 [get_ports A_d_out_P]
set_property IOSTANDARD TMDS_33 [get_ports A_s_in_P]
set_property IOSTANDARD TMDS_33 [get_ports A_s_out_P]
set_property IOSTANDARD TMDS_33 [get_ports B_d_in_P]
set_property IOSTANDARD TMDS_33 [get_ports B_d_out_P]
set_property IOSTANDARD TMDS_33 [get_ports B_s_in_P]
set_property IOSTANDARD TMDS_33 [get_ports B_s_out_P]
