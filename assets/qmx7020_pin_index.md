# 启明星 ZYNQ 7020 引脚索引

来源：`assets/启明星ZYNQ开发板+IO引脚分配总表.xlsx`。此文件由表格自动提取，生成 XDC 前仍应结合原理图/手册复核。

## PL IO

### 系统时钟（50Mhz）

| Signal | Direction | Pin | Description |
|---|---|---|---|
| sys_clk | input | U18 | 系统时钟，频率：50MHz |

### PL复位按键

| Signal | Direction | Pin | Description |
|---|---|---|---|
| sys_rst_n | input | N16 | PL复位复位，低电平有效 |

### 2个PL功能按键

| Signal | Direction | Pin | Description |
|---|---|---|---|
| key[0] | input | L14 | PL按键KEY0 |
| key[1] | input | K16 | PL按键KEY1 |

### 3个PL_LED灯

| Signal | Direction | Pin | Description |
|---|---|---|---|
| led[0] | output | H15 | （底板）PL_LED0 |
| led[1] | output | L15 | （底板）PL_LED1 |
| led | output | J16 | （核心板）PL_LED |

### 触摸按键

| Signal | Direction | Pin | Description |
|---|---|---|---|
| touch_key | input | F16 | 触摸按键 tpad |

### 蜂鸣器

| Signal | Direction | Pin | Description |
|---|---|---|---|
| beep | output | M14 | 蜂鸣器 |

### UART串口

| Signal | Direction | Pin | Description |
|---|---|---|---|
| uart_rxd | input | T19 | 串口接收端UART3_RX |
| uart_txd | output | J15 | 串口发送端 |

### ATK MODULE

| Signal | Direction | Pin | Description |
|---|---|---|---|
| uart_rx | input | T19 | RXD端口 UART3_RX |
| uart_tx | output | J15 | TXD端口 |
| gbc_key | input | G14 | KEY端口 |
| gbc_led | output | N15 | LED端口 |

### IIC总线（EEPROM/RTC实时时钟/音频配置）

| Signal | Direction | Pin | Description |
|---|---|---|---|
| iic_scl | output | E18 | IIC时钟信号线 |
| iic_sda | inout | F17 | IIC双向数据线 |

### RGB TFT-LCD接口

| Signal | Direction | Pin | Description |
|---|---|---|---|
| lcd_hs | output | N18 | RGB LCD行同步 |
| lcd_vs | output | T20 | RGB LCD场同步 |
| lcd_de | output | U20 | RGB LCD数据使能 |
| lcd_bl | output | M20 | RGB LCD背光控制 |
| lcd_clk | output | P19 | RGB LCD像素时钟 |
| lcd_rst | output | L17 | RGB LCD复位信号 |
| lcd_rgb[0] | output | W18 | RGB LCD蓝色（最低位） |
| lcd_rgb[1] | output | W19 | RGB LCD蓝色 |
| lcd_rgb[2] | output | R16 | RGB LCD蓝色 |
| lcd_rgb[3] | output | R17 | RGB LCD蓝色 |
| lcd_rgb[4] | output | W20 | RGB LCD蓝色 |
| lcd_rgb[5] | output | V20 | RGB LCD蓝色 |
| lcd_rgb[6] | output | P18 | RGB LCD蓝色 |
| lcd_rgb[7] | output | N17 | RGB LCD蓝色（最高位） |
| lcd_rgb[8] | output | V17 | RGB LCD绿色（最低位） |
| lcd_rgb[9] | output | V18 | RGB LCD绿色 |
| lcd_rgb[10] | output | T17 | RGB LCD绿色 |
| lcd_rgb[11] | output | R18 | RGB LCD绿色 |
| lcd_rgb[12] | output | Y18 | RGB LCD绿色 |
| lcd_rgb[13] | output | Y19 | RGB LCD绿色 |
| lcd_rgb[14] | output | P15 | RGB LCD绿色 |
| lcd_rgb[15] | output | P16 | RGB LCD绿色（最高位） |
| lcd_rgb[16] | output | V16 | RGB LCD红色（最低位） |
| lcd_rgb[17] | output | W16 | RGB LCD红色 |
| lcd_rgb[18] | output | T14 | RGB LCD红色 |
| lcd_rgb[19] | output | T15 | RGB LCD红色 |
| lcd_rgb[20] | output | Y17 | RGB LCD红色 |
| lcd_rgb[21] | output | Y16 | RGB LCD红色 |
| lcd_rgb[22] | output | T16 | RGB LCD红色 |
| lcd_rgb[23] | output | U17 | RGB LCD红色（最高位） |
| touch_scl | output | R19 | 触摸屏IIC接口的时钟 |
| touch_sda | inout | P20 | 触摸屏IIC接口的数据 |
| touch_rst_n | output | M19 | 触摸屏的复位T_CS |
| touch_int | input | U19 | 触摸屏的中断T_PEN |

### HDMI接口

| Signal | Direction | Pin | Description |
|---|---|---|---|
| tmds_data_p[0] | output | G19 | HDMI的DATA0通道的P端 |
| tmds_data_p[1] | output | K19 | HDMI的DATA1通道的P端 |
| tmds_data_p[2] | output | J20 | HDMI的DATA2通道的P端 |
| tmds_clk_p | output | J18 | HDMI的CLK通道的P端 |
| tmds_scl | output | R19 | HDMI的SCL信号 |
| tmds_sda | output | P20 | HDMI的SDA信号 |
| tmds_hpd | input | L19 | HDMI的热插拔信号 |

### 摄像头接口（OV5640/OV7725）

| Signal | Direction | Pin | Description |
|---|---|---|---|
| cam_sgm_ctrl/cam_pwdn | output | V15 | OV7725时钟选择信号（0：使用引脚XCLK提供的时钟 1：使用摄像头自带的晶振提供时钟）/ |
| cam_rst_n | output | P14 | cmos 复位信号，低电平有效 |
| cam_vsync | input | U12 | cmos 场同步信号 |
| cam_href | input | T12 | cmos 行同步信号 |
| cam_pclk | input | W14 | cmos 数据像素时钟 |
| cam_data[0] | input | R14 | cmos 数据 |
| cam_data[1] | input | U13 | cmos 数据 |
| cam_data[2] | input | V13 | cmos 数据 |
| cam_data[3] | input | U15 | cmos 数据 |
| cam_data[4] | input | U14 | cmos 数据 |
| cam_data[5] | input | W13 | cmos 数据 |
| cam_data[6] | input | V12 | cmos 数据 |
| cam_data[7] | input | Y14 | cmos 数据 |
| cam_scl | output | T10 | cmos SCCB时钟信号线 |
| cam_sda | inout | T11 | cmos SCCB双向数据线 |

## PS IO

### 2个PS功能按键

| Signal | Direction | Pin | Description |
|---|---|---|---|
| ps_key[0] |  | MIO12 | PS按键KEY0 |
| ps_key[1] |  | MIO11 | PS按键KEY1 |

### 3个PS_LED灯

| Signal | Direction | Pin | Description |
|---|---|---|---|
| ps_led[0]（底板） |  | MIO7 | PS_LED0 |
| ps_led[1]（底板） |  | MIO8 | PS_LED1 |
| ps_led（核心板） |  | MIO0 | PS_LED |

### QSPI FLASH

| Signal | Direction | Pin | Description |
|---|---|---|---|
| QSPI_CS# |  | MIO1 | QSPI FLASH的片选，低电平有效 |
| QSPI_SCK |  | MIO6 | QSPI FLASH的时钟 |
| QSPI_D0 |  | MIO2 | QSPI FLASH的数据位0 |
| QSPI_D1 |  | MIO3 | QSPI FLASH的数据位1 |
| QSPI_D2 |  | MIO4 | QSPI FLASH的数据位2 |
| QSPI_D3 |  | MIO5 | QSPI FLASH的数据位3 |

### PS UART

| Signal | Direction | Pin | Description |
|---|---|---|---|
| PS_UART_RXD |  | MIO14 | PS UART的接收 |
| PS_UART_TXD |  | MIO15 | PS UART的发送 |

### PS 以太网

| Signal | Direction | Pin | Description |
|---|---|---|---|
| ETH_TXCK |  | MIO16 | PS以太网RGMII接口的TX_CLK |
| ETH_TXD0 |  | MIO17 | PS以太网RGMII接口的TX_D0 |
| ETH_TXD1 |  | MIO18 | PS以太网RGMII接口的TX_D1 |
| ETH_TXD2 |  | MIO19 | PS以太网RGMII接口的TX_D2 |
| ETH_TXD3 |  | MIO20 | PS以太网RGMII接口的TX_D3 |
| ETH_TXCTL |  | MIO21 | PS以太网RGMII接口的TX_CTL |
| ETH_RXCK |  | MIO22 | PS以太网RGMII接口的RX_CLK |
| ETH_RXD0 |  | MIO23 | PS以太网RGMII接口的RX_D0 |
| ETH_RXD1 |  | MIO24 | PS以太网RGMII接口的RX_D1 |
| ETH_RXD2 |  | MIO25 | PS以太网RGMII接口的RX_D2 |
| ETH_RXD3 |  | MIO26 | PS以太网RGMII接口的RX_D3 |
| ETH_RXCTL |  | MIO27 | PS以太网RGMII接口的RX_CTL |
| ETH_MDC |  | MIO52 | PS以太网MDIO接口的时钟 |
| ETH_MDIO |  | MIO53 | PS以太网MDIO接口的数据 |

### PS USB接口

| Signal | Direction | Pin | Description |
|---|---|---|---|
| OTG_DIR |  | MIO29 | USB总线方向控制 |
| OTG_STP |  | MIO30 | 数据传输的结束信号 |
| OTG_NXT |  | MIO31 | 当前数据接收完成指示信号 |
| OTG_CLK |  | MIO36 | PHY的时钟输出 |
| OTG_DATA7 |  | MIO39 | 双向数据总线位7 |
| OTG_DATA6 |  | MIO38 | 双向数据总线位6 |
| OTG_DATA5 |  | MIO37 | 双向数据总线位5 |
| OTG_DATA4 |  | MIO28 | 双向数据总线位4 |
| OTG_DATA3 |  | MIO35 | 双向数据总线位3 |
| OTG_DATA2 |  | MIO34 | 双向数据总线位2 |
| OTG_DATA1 |  | MIO33 | 双向数据总线位1 |
| OTG_DATA0 |  | MIO32 | 双向数据总线位0 |

### SD卡

| Signal | Direction | Pin | Description |
|---|---|---|---|
| SD_CLK |  | MIO40 | SD卡的时钟信号 |
| SD_CMD |  | MIO41 | SD卡的命令信号 |
| SD_D0 |  | MIO42 | SD卡的DATA0 |
| SD_D1 |  | MIO43 | SD卡的DATA1 |
| SD_D2 |  | MIO44 | SD卡的DATA2 |
| SD_D3 |  | MIO45 | SD卡的DATA3 |

### eMMC存储器

| Signal | Direction | Pin | Description |
|---|---|---|---|
| eMMC_CCLK |  | MIO48 | eMMC的时钟信号 |
| eMMC_CMD |  | MIO47 | eMMC的命令信号 |
| eMMC_D0 |  | MIO46 | eMMC的DATA0 |
| eMMC_D1 |  | MIO49 | eMMC的DATA1 |
| eMMC_D2 |  | MIO50 | eMMC的DATA2 |
| eMMC_D3 |  | MIO51 | eMMC的DATA3 |

