# FPGA-ZYNQ Development Workspace

## Environment

- **Board/Device**: 正点原子启明星 ZYNQ 7020, Zynq-7000 (xc7z020clg400-2), PL-only or PS+PL designs
- **Vivado**: 2020.2 (installed at `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`)
- **Vitis** (optional): 2020.2 (installed at `D:\Xilinx\Vitis\2020.2\bin\vitis.bat`)
- **Host OS**: Windows 10
- **VSCode**: Primary editor, tasks defined in `.vscode/tasks.json`
- **Board docs**: schematic/manual/pin table are under `assets/`; use `assets/qmx7020_pin_index.md` or `assets/qmx7020_pin_index.csv` first for XDC pins, and `assets/qmx7020_schematic_index.md` for schematic-level notes, reuse/conflict warnings, boot/JTAG/PS peripheral context, and IO bank/electrical reminders.
- **Project layout**: concrete FPGA projects live under `projects/`; root-level `assets/`, `tools/`, `templates/`, `.codex/`, `.claude/`, and `.mcp/` are shared workspace resources.

## Skill: Xilinx Suite

When the user asks about **any** Xilinx/AMD FPGA task — Vivado, Vitis, HLS, PetaLinux, Block Design, XDC constraints, AXI IP, Zynq, or bitstream — load the xilinx-suite skill:

```
Skill("xilinx-suite")
```

The skill provides step-by-step guidance and reference docs for the full toolchain. Always verify requirements (device, version, design goal) before generating scripts.

Key reference files (in `.claude/skills/xilinx-suite/references/`):
- `vivado_guide.md` — project creation, Block Design, synthesis, implementation, XSA export
- `tcl_commands.md` — Vivado Tcl command quick reference
- `xdc_constraints.md` / `xdc_guide.md` — XDC timing and IO constraints
- `mpsoc_ps_config.md` — PS configuration (for MPSoC; for Zynq-7000 PS use `processing_system7` IP)
- `hls_guide.md` — Vitis HLS C/C++ to IP flow
- `vitis_unified_guide.md` — Vitis Unified embedded software
- `petalinux_guide.md` — PetaLinux build flow
- `jesd204b_to_c_migration.md` — JESD204B→C migration

## Project Structure Convention

All projects follow this layout:

```
<project_name>/
├── rtl/                 # RTL sources (.v, .sv, .vhd)
├── tb/                  # Testbench files
├── constr/              # XDC constraints
├── scripts/             # Tcl automation scripts
│   ├── project_config.tcl   # Central config (paths, device, top name)
│   ├── create_project.tcl   # Create Vivado project
│   ├── sim.tcl              # Run simulation
│   ├── synth.tcl            # Run synthesis
│   ├── build_bit.tcl        # Full synthesis + implementation + bitstream
│   └── open_gui.tcl         # Open Vivado GUI
├── sim/                 # Simulation outputs
├── reports/             # Synthesis/implementation/timing reports
├── build/               # Vivado project files (git-ignored)
├── doc/                 # Requirements, architecture, waveform docs
├── .vscode/
│   ├── tasks.json       # VSCode build tasks
│   └── settings.json    # File associations, linting
├── README.md
└── .gitignore
```

## Workflow Principles

1. **Document before code**: requirements → system design → hardware → architecture → waveform → RTL
2. **Module before system**: design and simulate individual modules before integration
3. **Simulation before board**: always run testbench before synthesis; never go straight to board
4. **Script everything**: use Tcl scripts (not GUI clicks) for reproducible builds
5. **Check warnings**: Vivado warnings often predict board failures
6. **Use local lightweight automation**: prefer `tools/fpga.ps1`, `templates/qmx7020_fpga_project.yaml`, and `tools/validate_fpga_project.ps1` for unified commands/config/checks instead of a generic global FPGA framework.

## VSCode Tasks

Run via `Ctrl+Shift+P` → `Tasks: Run Task`:
- `Vivado: Create Project` — creates `.xpr` from Tcl
- `Vivado: Run Simulation` — runs xsim with testbench
- `Vivado: Synthesis` — runs synth_1
- `Vivado: Generate Bitstream` — full synth+impl+bitstream
- `Vivado: Open GUI` — opens Vivado GUI on the project
- `Vitis: Open` — opens Vitis workspace

## Zynq-7000 Notes

- **PS IP**: `xilinx.com:ip:processing_system7:5.5` (NOT `zynq_ultra_ps_e` which is MPSoC-only)
- **AXI GP ports**: PS has M_AXI_GP0 (master) and S_AXI_GP0 (slave) for PL communication
- **PL clock**: typically from PS FCLK_CLK0 (FCLK0), configurable 10–250 MHz
- **MIO pins**: bank 0/1 voltage must match board (often 3.3V for Zynq-7000, not 1.8V)
- **UART**: default debug UART on MIO 14-15
- **JTAG**: via USB cable to PC
- Reference: UG585 (Zynq-7000 TRM), DS190 (Zynq-7000 Data Sheet)
