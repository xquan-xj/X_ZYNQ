# Zynq-7000 PS Configuration Guide

> **Device**: Zynq-7000 (xc7zxxx), PS IP: `xilinx.com:ip:processing_system7:5.5`
> **Vivado**: 2018.x–2024.x
> **Reference**: UG585 (Zynq-7000 TRM)

## PS IP Instantiation

```tcl
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7_0
```

## Key PS Configuration Parameters

### DDR3 Memory

```tcl
set_property -dict [list \
  CONFIG.PCW_DDR_RAM_HIGHADDR     {0x1FFFFFFF} \
  CONFIG.PCW_UIPARAM_DDR_PARTNO   {MT41J256M16 RE-125} \
  CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
  CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
  CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
  CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
] [get_bd_cells ps7_0]
```

### MIO Peripherals

```tcl
set_property -dict [list \
  # UART1 (default debug console, MIO 48-49)
  CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_UART1_UART1_IO          {MIO 48 .. 49} \
  CONFIG.PCW_UART1_BAUD_RATE         {115200} \
  # Ethernet 0 (MIO 16-27)
  CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_ENET0_ENET0_IO         {MIO 16 .. 27} \
  CONFIG.PCW_ENET0_GRP_MDIO_ENABLE   {1} \
  CONFIG.PCW_ENET0_GRP_MDIO_IO      {MIO 52 .. 53} \
  # USB 0 (MIO 28-39)
  CONFIG.PCW_USB0_PERIPHERAL_ENABLE  {1} \
  CONFIG.PCW_USB0_USB0_IO           {MIO 28 .. 39} \
  # SD 0 (MIO 40-45)
  CONFIG.PCW_SD0_PERIPHERAL_ENABLE   {1} \
  CONFIG.PCW_SD0_SD0_IO             {MIO 40 .. 45} \
  # QSPI (MIO 1-6)
  CONFIG.PCW_QSPI_PERIPHERAL_ENABLE  {1} \
  CONFIG.PCW_QSPI_QSPI_IO           {MIO 1 .. 6} \
  CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
  CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO  {MIO 1 .. 6} \
  # GPIO (MIO)
  CONFIG.PCW_GPIO_MIO_GPIO_ENABLE    {1} \
  CONFIG.PCW_GPIO_MIO_GPIO_IO       {MIO} \
  # I2C 0 (MIO 14-15 if not used by UART)
  # CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
  # CONFIG.PCW_I2C0_I2C0_IO          {MIO 14 .. 15} \
] [get_bd_cells ps7_0]
```

### PL Clock Configuration

```tcl
set_property -dict [list \
  # FCLK_CLK0 (main PL clock, typical 100 MHz)
  CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
  # FCLK_CLK1 (optional second clock)
  CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} \
  # FCLK_CLK2/3 (disable if not needed)
  CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {0} \
  CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {0} \
] [get_bd_cells ps7_0]
```

### PS-PL AXI Interfaces

Zynq-7000 has different AXI port naming than MPSoC:

| PS Port | Direction | Width | Purpose |
|---------|-----------|-------|---------|
| `M_AXI_GP0` | PS→PL Master | 32-bit | PS controls PL peripherals |
| `M_AXI_GP1` | PS→PL Master | 32-bit | Optional second master |
| `S_AXI_GP0` | PL→PS Slave | 32-bit | PL (DMA) accesses PS DDR/OCM |
| `S_AXI_GP1` | PL→PS Slave | 32-bit | Optional second slave |
| `S_AXI_ACP` | PL→PS Slave | 64-bit | Accelerator Coherency Port (cache-coherent) |
| `S_AXI_HP0–HP3` | PL→PS Slave | 64-bit | High-performance ports for DMA |

```tcl
set_property -dict [list \
  CONFIG.PCW_USE_M_AXI_GP0      {1} \
  CONFIG.PCW_USE_M_AXI_GP1      {0} \
  CONFIG.PCW_USE_S_AXI_GP0      {0} \
  CONFIG.PCW_USE_S_AXI_HP0      {1} \
  CONFIG.PCW_USE_S_AXI_HP1      {0} \
  CONFIG.PCW_USE_S_AXI_ACP      {0} \
] [get_bd_cells ps7_0]
```

### Interrupts

```tcl
set_property -dict [list \
  CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
  CONFIG.PCW_IRQ_F2P_INTR         {1} \
] [get_bd_cells ps7_0]
```

## Full Zynq-7000 Block Design Template

```tcl
# ============================================
# Zynq-7000 Block Design (PS + PL minimal)
# ============================================
create_bd_design "design_1"

# 1. PS7 Processing System
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7_0

# Apply board preset (if available) or manual config
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
  -config {apply_board_preset "1"} [get_bd_cells ps7_0]

# 2. Processor System Reset (for FCLK_CLK0)
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk0
connect_bd_net [get_bd_pins ps7_0/FCLK_CLK0] \
               [get_bd_pins rst_clk0/slowest_sync_clk]
connect_bd_net [get_bd_pins ps7_0/FCLK_RESET0_N] \
               [get_bd_pins rst_clk0/ext_reset_in]

# 3. AXI Interconnect / SmartConnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic
set_property CONFIG.NUM_MI {2} [get_bd_cells axi_ic]
connect_bd_intf_net [get_bd_intf_pins ps7_0/M_AXI_GP0] \
                    [get_bd_intf_pins axi_ic/S00_AXI]
connect_bd_net [get_bd_pins ps7_0/FCLK_CLK0] [get_bd_pins axi_ic/ACLK]
connect_bd_net [get_bd_pins ps7_0/FCLK_CLK0] [get_bd_pins axi_ic/M00_ACLK]
connect_bd_net [get_bd_pins ps7_0/FCLK_CLK0] [get_bd_pins axi_ic/M01_ACLK]
connect_bd_net [get_bd_pins rst_clk0/interconnect_aresetn] \
               [get_bd_pins axi_ic/ARESETN]
connect_bd_net [get_bd_pins rst_clk0/interconnect_aresetn] \
               [get_bd_pins axi_ic/M00_ARESETN]
connect_bd_net [get_bd_pins rst_clk0/interconnect_aresetn] \
               [get_bd_pins axi_ic/M01_ARESETN]

# 4. Add PL IPs (example: AXI GPIO)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property CONFIG.C_GPIO_WIDTH {8} [get_bd_cells axi_gpio_0]
set_property CONFIG.C_ALL_OUTPUTS {1} [get_bd_cells axi_gpio_0]

connect_bd_intf_net [get_bd_intf_pins axi_ic/M00_AXI] \
                    [get_bd_intf_pins axi_gpio_0/S_AXI]
connect_bd_net [get_bd_pins ps7_0/FCLK_CLK0] \
               [get_bd_pins axi_gpio_0/s_axi_aclk]
connect_bd_net [get_bd_pins rst_clk0/peripheral_aresetn] \
               [get_bd_pins axi_gpio_0/s_axi_aresetn]

# 5. External GPIO ports
make_bd_pins_external [get_bd_pins axi_gpio_0/gpio_io_o]
set_property name led [get_bd_ports gpio_io_o_0]

# 6. Address + validate
assign_bd_address
validate_bd_design
save_bd_design

# 7. Generate outputs
generate_target all [get_files design_1.bd]
make_wrapper -files [get_files design_1.bd] -top
add_files -norecurse [glob ./*/*/sources_1/bd/design_1/hdl/*wrapper*]
set_property top design_1_wrapper [current_fileset]
```

## Zynq-7000 vs MPSoC Differences

| Feature | Zynq-7000 | MPSoC (ZU+) |
|---------|-----------|-------------|
| PS IP | `processing_system7` | `zynq_ultra_ps_e` |
| CPU | Dual A9 (32-bit) | Quad A53 (64-bit) + Dual R5 |
| AXI GP | 2x Master, 2x Slave (32-bit) | HPM0/1 + HPC0/1 (32/128-bit) |
| AXI HP | 4x Slave (64-bit) | 4x HP + 2x HPC (128-bit) |
| PL Clock | FCLK_CLK[0:3] (max ~250 MHz) | PL_CLK[0:3] (max ~500 MHz) |
| IRQ | 1x IRQ_F2P (shared) | pl_ps_irq[0:1] (2x 8-bit vectors) |
| MIO | 54 pins (2 banks) | 78 pins (3 banks) |
| Ref Doc | UG585 | UG1085 |
