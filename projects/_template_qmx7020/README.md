# QMX ZYNQ 7020 FPGA Project Template

This is the reusable starting point for projects on the 正点原子启明星 ZYNQ 7020 board.

Defaults:

- Board: 启明星 ZYNQ 7020
- Part: `xc7z020clg400-2`
- Tools: Vivado/Vitis 2020.2
- Base clock: `sys_clk`, 50 MHz, pin `U18`
- Active-low reset: `sys_rst_n`, pin `N16`
- Base LEDs: `led[0]` pin `H15`, `led[1]` pin `L15`

## Layout

```text
01_hls/          Optional Vitis HLS stage
02_vivado/       Vivado RTL, constraints, Tcl scripts, reports and outputs
03_vitis/        Optional Vitis 2020.2 software stage
04_petalinux/    Optional PetaLinux 2020.2 stage
docs/            Requirements, design notes, waveform and flow checklist
.vscode/         VSCode tasks for repeatable commands
fpga_project.yaml
```

## Common Commands

Run from the workspace root:

```powershell
.\fpga validate projects\_template_qmx7020
.\fpga create projects\_template_qmx7020
.\fpga sim projects\_template_qmx7020
.\fpga bitstream projects\_template_qmx7020
```

## Derive a New Project

Prefer copying this template through the helper:

```powershell
.\new-fpga my_project
```

Then update:

- `fpga_project.yaml`
- `docs/requirements.md`
- `docs/system_design.md`
- `02_vivado/rtl/qmx7020_base_top.v`
- `02_vivado/constraints/qmx7020_base.xdc`

Keep simulation passing before moving to synthesis and board testing.
