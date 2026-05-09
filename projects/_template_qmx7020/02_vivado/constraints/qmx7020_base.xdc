##############################################################
# QMX ZYNQ 7020 base constraints
# Board: 正点原子启明星 ZYNQ 7020
# Part:  xc7z020clg400-2
##############################################################

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]

set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]

set_property PACKAGE_PIN N16 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

set_property PACKAGE_PIN H15 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property DRIVE 8 [get_ports {led[0]}]
set_property SLEW SLOW [get_ports {led[0]}]

set_property PACKAGE_PIN L15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property DRIVE 8 [get_ports {led[1]}]
set_property SLEW SLOW [get_ports {led[1]}]
