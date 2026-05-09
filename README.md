# ZYNQ FPGA Workspace

This workspace is tuned for 正点原子启明星 ZYNQ 7020 development with Vivado/Vitis 2020.2. It keeps the board knowledge local, scriptable, and easy for Codex/Claude to use.

## What Was Borrowed From FPGABuilder

FPGABuilder is a general FPGA build framework with a YAML-driven project model, unified CLI commands, plugin-style hooks, and organized build outputs. This workspace borrows the useful lightweight ideas without replacing the existing Xilinx/board-aware flow:

- `fpga_project.yaml` template for project metadata and build settings
- `tools/fpga.ps1` as a single command entry point
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
    ├── led/
    └── led_twinkle/
```

`tools/` is for local helper scripts such as wrappers, validators, index generators, and report helpers. `.mcp/` is for MCP servers/connectors and should stay separate.

## Project Configuration

For a new project, copy:

```text
templates/qmx7020_fpga_project.yaml
```

to:

```text
projects/<project>/fpga_project.yaml
```

Then edit the project name, top module, source paths, and script paths.

## Unified Commands

Run from the workspace root:

```powershell
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action validate
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action create
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action sim
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action synth
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action bitstream
powershell -ExecutionPolicy Bypass -File tools/fpga.ps1 -Project projects/led_twinkle -Action gui
```

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
