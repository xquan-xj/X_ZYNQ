# 启明星 ZYNQ 7020 原理图工程索引

本索引用于工程开发时快速定位启明星 ZYNQ 7020 的板级连接关系。它不是原理图替代品；生成 XDC、PS 配置或硬件调试前，关键接口仍应回查原始 PDF。

## 来源文件

- `assets/启明星ZYNQ底板原理图_V2.3.2.pdf`
- `assets/ZYNQ7010_7020核心板原理图_2V5.pdf`
- `assets/启明星ZYNQ开发板+IO引脚分配总表.xlsx`
- `assets/qmx7020_pin_index.md`
- `assets/qmx7020_pin_index.csv`

为便于全文检索，PDF 已提取为：

- `assets/qmx7020_base_schematic.txt`
- `assets/qmx7020_core_schematic.txt`

## 使用顺序

1. 查普通 PL/PS 管脚：先用 `qmx7020_pin_index.md` 或 `qmx7020_pin_index.csv`。
2. 查电平、连接器、上下拉、复用冲突：再查本文件。
3. 查最终硬件依据：回查原始底板/核心板 PDF。

## 板卡与器件

- 板卡：正点原子启明星 ZYNQ 7020。
- FPGA/SoC：Zynq-7000，当前工作区默认 part 为 `xc7z020clg400-2`。
- 工具链默认：Vivado/Vitis 2020.2。
- 核心板原理图首页标注：ZYNQ7000 XC7Z020，DDR3 SDRAM，QSPI Flash，eMMC，PS/PL 时钟，JTAG，复位，PL LED，DONE LED。

## 时钟与复位

| Domain | Signal | Pin / MIO | Frequency / Polarity | Notes |
|---|---|---|---|---|
| PL | `sys_clk` | U18 | 50 MHz | PL 系统时钟，来自 IO 表；核心板原理图也标注 PL oscillator clock 50 MHz。 |
| PL | `sys_rst_n` | N16 | 低有效 | PL 复位按键，IO 表和底板原理图均可查。 |
| PS | `PS_CLK` | PS clock input | 33.333333 MHz | 核心板原理图标注 PS OSC CLOCK 33.333333 MHz。 |
| PS | `PS_POR_B` / `PS_SRST_B` | PS dedicated pins | 低有效复位类信号 | 核心板原理图包含 power-on reset / reset supervisor。 |

## 常用 PL 外设

| Function | Signal | Direction | Pin | Notes |
|---|---|---:|---|---|
| PL LED0 底板 | `led[0]` | output | H15 | 底板 PL_LED0。 |
| PL LED1 底板 | `led[1]` | output | L15 | 底板 PL_LED1。 |
| PL LED 核心板 | `led` | output | J16 | 核心板 PL_LED。 |
| PL KEY0 | `key[0]` | input | L14 | PL 按键 KEY0。 |
| PL KEY1 | `key[1]` | input | K16 | PL 按键 KEY1。 |
| Touch key | `touch_key` | input | F16 | 触摸按键 tpad。 |
| Beep | `beep` | output | M14 | 底板蜂鸣器，原理图显示由三极管/3.3V 相关电路驱动，确认有效电平时需回查 PDF。 |
| PL UART RX | `uart_rxd` / `uart_rx` | input | T19 | 底板 USB-UART/ATK MODULE 复用 UART3_RX。 |
| PL UART TX | `uart_txd` / `uart_tx` | output | J15 | 底板 USB-UART/ATK MODULE 复用 UART3_TX。 |
| ATK key | `gbc_key` | input | G14 | ATK MODULE KEY。 |
| ATK led | `gbc_led` | output | N15 | ATK MODULE LED。 |
| IIC SCL | `iic_scl` | output | E18 | EEPROM/RTC/音频配置 IIC 时钟。 |
| IIC SDA | `iic_sda` | inout | F17 | EEPROM/RTC/音频配置 IIC 数据。 |

## PL 复用注意

- `uart_rxd` 与 ATK MODULE `uart_rx` 都映射到 T19。
- `uart_txd` 与 ATK MODULE `uart_tx` 都映射到 J15。
- HDMI DDC `tmds_scl/tmds_sda` 与 LCD touch `touch_scl/touch_sda` 使用同一组管脚：R19/P20。不要在同一 bitstream 中无隔离地同时驱动。
- 底板图中 ATK MODULE 区域直接标出 `UART3_TX`、`UART3_RX`、`GBC_KEY`、`GBC_LED`。

## HDMI / LCD / Camera 概览

完整管脚见 `qmx7020_pin_index.md`。

| Interface | Key Signals | Notes |
|---|---|---|
| RGB TFT-LCD | `lcd_hs`, `lcd_vs`, `lcd_de`, `lcd_bl`, `lcd_clk`, `lcd_rst`, `lcd_rgb[23:0]`, `touch_*` | 24-bit RGB + touch IIC/interrupt/reset。 |
| HDMI | `tmds_data_p[2:0]`, `tmds_clk_p`, `tmds_scl`, `tmds_sda`, `tmds_hpd` | 差分 N 端和电气细节需回查原理图/PDF。 |
| Camera OV5640/OV7725 | `cam_pclk`, `cam_vsync`, `cam_href`, `cam_data[7:0]`, `cam_rst_n`, `cam_scl`, `cam_sda` | SCCB/IIC 与像素接口；时钟选择/电源控制需按具体摄像头模块确认。 |

## PS MIO 外设

PS MIO 配置应优先参考 `qmx7020_pin_index.csv`，并在 Vivado Zynq PS 配置中匹配。

| Function | Signals / MIO | Notes |
|---|---|---|
| PS LED/KEY | `ps_led` MIO0, `ps_led[0]` MIO7, `ps_led[1]` MIO8, `ps_key[0]` MIO12, `ps_key[1]` MIO11 | 核心板/底板均有 PS LED/KEY。 |
| QSPI Flash | MIO1-MIO6 | 核心板原理图标注 Winbond W25Q256；BOOT 相关配置需回查 boot option。 |
| PS UART | RX MIO14, TX MIO15 | 默认调试串口候选。 |
| Ethernet RGMII | MIO16-MIO27, MDIO/MDC MIO52/MIO53 | 底板有 ETHERNET(PS) 区域。 |
| USB OTG | MIO28-MIO39 | ULPI 类接口，含 `OTG_CLK` MIO36。 |
| SD Card | MIO40-MIO45 | SD_CLK/CMD/D0-D3。 |
| eMMC | MIO46-MIO51 | 核心板标注 eMMC 8GB。 |

## BOOT / JTAG

底板原理图包含 BOOT OPTION 区域：

| Mode | Notes |
|---|---|
| JTAG | BOOT_CFG 对应 JTAG 选项。适合下载调试。 |
| QSPI | BOOT_CFG 对应 QSPI 启动。 |
| SD Card | BOOT_CFG 对应 SD Card 启动。 |

实际拨码/跳帽位置请以底板 PDF 的 BOOT OPTION 区域为准。核心板原理图还包含 6-pin JTAG，底板也有 JTAG 信号与 `FPGA_TMS/TCK/TDO/TDI` 相关串阻。

## 电源与 IO Bank

从核心板原理图可直接确认：

- PL Bank34 / Bank35 在核心板图中单独成页，工程里大量 PL IO 来自这两个 bank。
- PS Bank500 / Bank501 在核心板图中单独成页。
- 核心板图的 JTAG/PLL option 区域标注了 MIO bank 电压选择信息：MIO bank0 voltage = 3.3V，MIO bank1 voltage = 1.8V。
- 生成 XDC 时，普通 PL IO 默认不可只凭 pin 写约束；需要同时确认该 bank 的 VCCIO 后设置合适 `IOSTANDARD`。当前启明星常用 PL 外设多为 3.3V LVCMOS，但复杂接口必须回查原理图。

## 生成 XDC 的推荐规则

1. 从 `qmx7020_pin_index.csv` 查 `Signal` 和 `Pin`。
2. 对 PL 外设写 `PACKAGE_PIN`。
3. 对 IO 电平，先按接口类型和 bank 电压判断；不确定时回查核心板原理图 Bank34/35 和底板外设页。
4. 对 `sys_clk` 写 `create_clock -period 20.000`。
5. 对复用管脚，确保同一工程中只有一个功能驱动该物理管脚。

最小 PL LED 例子：

```tcl
set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]

set_property PACKAGE_PIN N16 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

set_property PACKAGE_PIN H15 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
```

## 维护说明

- `qmx7020_pin_index.md/csv` 适合管脚查表。
- `qmx7020_schematic_index.md` 适合工程决策和复用提醒。
- `qmx7020_base_schematic.txt`、`qmx7020_core_schematic.txt` 适合全文搜索 PDF 内容。
- 原始 PDF 是最终硬件依据。

