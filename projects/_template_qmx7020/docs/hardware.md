# Hardware Notes

## Board

- Board: 正点原子启明星 ZYNQ 7020
- FPGA part: `xc7z020clg400-2`
- Toolchain: Vivado/Vitis 2020.2

## Board Indexes

- Pin index: `../../assets/qmx7020_pin_index.csv`
- Pin notes: `../../assets/qmx7020_pin_index.md`
- Schematic notes: `../../assets/qmx7020_schematic_index.md`

## Base PL Pins

| Function | Port | Pin | Electrical Note |
| --- | --- | --- | --- |
| PL clock | `sys_clk` | `U18` | 50 MHz, `LVCMOS33` |
| Reset | `sys_rst_n` | `N16` | Active-low, `LVCMOS33` |
| LED0 | `led[0]` | `H15` | `LVCMOS33` |
| LED1 | `led[1]` | `L15` | `LVCMOS33` |

## Known Shared Pins

- HDMI DDC `tmds_scl/tmds_sda` shares pins `R19/P20` with LCD touch `touch_scl/touch_sda`.
- Check the schematic index before enabling interfaces that may share pins.
