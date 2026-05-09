# ZYNQ FPGA Workspace

This workspace is tuned for 正点原子启明星 ZYNQ 7020 development with Vivado/Vitis 2020.2. It keeps the board knowledge local, scriptable, and easy for Codex/Claude to use.

## What Was Borrowed From FPGABuilder

FPGABuilder is a general FPGA build framework with a YAML-driven project model, unified CLI commands, plugin-style hooks, and organized build outputs. This workspace borrows the useful lightweight ideas without replacing the existing Xilinx/board-aware flow:

- `fpga_project.yaml` template for project metadata and build settings
- `tools/fpga.cmd` and `tools/fpga.ps1` as unified command entry points
- `hooks/` convention for pre/post build steps
- `tools/validate_fpga_project.ps1` for basic project checks
- `build/logs`, `reports`, `sim`, and bitstream output conventions

The workspace does not adopt FPGABuilder's full framework or generic board templates. Board pins and electrical notes remain sourced from the local QMX 7020 assets.

## Board Knowledge

Use these files before writing XDC or PS configuration:

- `assets/qmx7020_pin_index.csv`
- `assets/qmx7020_pin_index.md`
- `assets/qmx7020_schematic_index.md`
- `assets/qmx7020_base_schematic.txt`
- `assets/qmx7020_core_schematic.txt`

For final hardware confirmation, cross-check against the original PDFs in `assets/`.

Common PL pins:

```text
sys_clk   U18  50 MHz
sys_rst_n N16  active-low
led[0]    H15  bottom-board PL_LED0
led[1]    L15  bottom-board PL_LED1
led       J16  core-board PL_LED
key[0]    L14
key[1]    K16
uart_rxd  T19
uart_txd  J15
```

## Workspace Layout

Keep shared resources at the workspace root and concrete FPGA projects under `projects/`:

```text
D:\FPGA\ZYNQ\
├── assets/
├── tools/
├── templates/
├── .codex/
├── .claude/
├── .mcp/
└── projects/
    ├── _template_qmx7020/
    └── led/
```

`tools/` is for local helper scripts such as wrappers, validators, index generators, and report helpers. `.mcp/` is for MCP servers/connectors and should stay separate.

## Project Template

Use `projects/_template_qmx7020/` as the preferred starting point for new QMX ZYNQ 7020 projects. It contains:

- staged Xilinx layout: `01_hls/`, `02_vivado/`, `03_vitis/`, `04_petalinux/`
- Vivado 2020.2 scripts for project creation, simulation, synthesis, bitstream, and GUI launch
- a minimal heartbeat RTL design and testbench
- base board constraints for `sys_clk`, `sys_rst_n`, and two PL LEDs
- design docs under `docs/`
- VSCode tasks under `.vscode/tasks.json`
- optional hook entry points

Create a derived project through the `tools/` entry point:

```powershell
tools\new-fpga uart_loopback
```

Equivalent unified form:

```powershell
tools\fpga new uart_loopback
```

Then update the derived project's `fpga_project.yaml`, `docs/requirements.md`, RTL, testbench, and XDC files.

## Project Configuration

The lightweight config-only template remains available at:

```text
templates/qmx7020_fpga_project.yaml
```

For complete projects, prefer deriving from `projects/_template_qmx7020/` because it already includes scripts, docs, VSCode tasks, and a working Vivado base design.

## Unified Commands

Always pass a concrete project path. The wrapper changes Vivado's process working directory to that project before launching Vivado:

```powershell
tools\fpga validate projects/_template_qmx7020
tools\fpga create projects/_template_qmx7020
tools\fpga sim projects/_template_qmx7020
tools\fpga synth projects/_template_qmx7020
tools\fpga bitstream projects/_template_qmx7020
tools\fpga gui projects/_template_qmx7020
```

Do not run Vivado directly from the workspace root, `.codex/`, or `.claude/`.

The wrapper looks for scripts in either:

```text
<project>/scripts/
<project>/02_vivado/
```

## Hooks

Optional hooks live under each project:

```text
hooks/pre_create.ps1
hooks/post_create.ps1
hooks/pre_sim.ps1
hooks/post_sim.ps1
hooks/pre_synth.ps1
hooks/post_synth.ps1
hooks/pre_bitstream.ps1
hooks/post_bitstream.ps1
```

Use hooks for report copying, artifact naming, checksums, notifications, or release packaging. Keep hardware-tool commands in Tcl scripts unless there is a clear reason to move them.

## Validation

The validator checks for:

- project config presence
- expected QMX 7020 / Vivado 2020.2 context
- RTL, testbench, constraints, and Tcl script locations
- XDC placeholders
- missing `create_clock`
- missing `IOSTANDARD`
- availability of board asset indexes

It is intentionally conservative. Passing validation does not prove the hardware is correct; it catches common omissions before Vivado or board bring-up.

## Recommended Flow

```text
requirements -> design docs -> RTL -> simulation -> synthesis -> implementation -> bitstream -> board bring-up
```

For new projects, follow the local skill:

```text
.codex/skills/xilinx-suite/SKILL.md
```

and load only the needed references from:

```text
.codex/skills/xilinx-suite/references/
```

The most relevant reference for workspace structure is:

```text
.codex/skills/xilinx-suite/references/vscode_fpga_workflow.md
```
