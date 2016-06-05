
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

##Pmod Header JA

set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {d_outA}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {s_outA}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {d_outB}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {s_outB}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {d_inA}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {s_inA}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {d_inB}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {s_inB}]

##ChipKit Digital I/O On Inner Analog Header
##NOTE: These pins will need to be connected to the XADC core when used as differential analog inputs (Chipkit analog pins A6-A11)

set_property -dict { PACKAGE_PIN F5    IOSTANDARD LVCMOS33 } [get_ports { debugr[30] }]; #IO_0_35 Sch=ck_a[0]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { debugr[31] }]; #IO_L4P_T0_35 Sch=ck_a[1]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { debugr[32] }]; #IO_L4N_T0_35 Sch=ck_a[2]
set_property -dict { PACKAGE_PIN E7    IOSTANDARD LVCMOS33 } [get_ports { debugr[33] }]; #IO_L6P_T0_35 Sch=ck_a[3]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { debugr[34] }]; #IO_L6N_T0_VREF_35 Sch=ck_a[4]
set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { debugr[35] }]; #IO_L11P_T1_SRCC_35 Sch=ck_a[5]

##ChipKit Digital I/O High

set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { debugr[28] }]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { debugr[26] }]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { debugr[24] }] 
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { debugr[22] }]
set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { debugr[20] }]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { debugr[18] }]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { debugr[16] }]
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { debugr[14] }]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { debugr[12] }]
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { debugr[10] }]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { debugr[8] }] 
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { debugr[6] }]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { debugr[4] }]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { debugr[2] }]
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { debugr[1] }]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { debugr[0] }] 

##ChipKit Digital I/O Low

set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { debugr[29] }]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { debugr[27] }]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { debugr[25] }]
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { debugr[23] }]
set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { debugr[21] }]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { debugr[19] }]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { debugr[17] }]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { debugr[15] }]
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { debugr[13] }]
set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { debugr[11] }]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { debugr[9] }]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { debugr[7] }]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { debugr[5] }]
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { debugr[3] }]


