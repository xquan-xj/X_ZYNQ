# Device part: xc7z020clg400-2
# Edit these pins according to your board schematic/manual before bitstream generation.

## Clock input
# set_property PACKAGE_PIN <CLK_PIN> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]
# create_clock -period 20.000 -name sys_clk [get_ports clk]

## Active-low reset input
# set_property PACKAGE_PIN <RST_N_PIN> [get_ports rst_n]
# set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## LED output
# set_property PACKAGE_PIN <LED_PIN> [get_ports led]
# set_property IOSTANDARD LVCMOS33 [get_ports led]

