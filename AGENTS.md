# Zynq Workspace Instructions

## Project-Local Xilinx Skill

For Xilinx/AMD FPGA tasks in this workspace, use the project-local skill:

```text
.codex/skills/xilinx-suite/SKILL.md
```

Load only the reference files needed for the current task from:

```text
.codex/skills/xilinx-suite/references/
```

This workspace also keeps the Claude-compatible copy at:

```text
.claude/skills/xilinx-suite/
```

Do not rely on a user-global Xilinx skill for this project.

## Local Defaults

- Board context: 正点原子启明星 ZYNQ 7020 unless the task says otherwise.
- Device context: Zynq-7000, known part `xc7z020clg400-2`.
- Project layout: keep concrete FPGA projects under `projects/`; keep workspace-level assets, tools, templates, skills, and MCP config at the root.
- Board documents are stored under `assets/`:
  - `assets/qmx7020_pin_index.md` (preferred human-readable pin index extracted from the IO table)
  - `assets/qmx7020_pin_index.csv` (preferred machine-readable pin index extracted from the IO table)
  - `assets/qmx7020_schematic_index.md` (preferred board/schematic engineering index)
  - `assets/qmx7020_base_schematic.txt` and `assets/qmx7020_core_schematic.txt` (searchable text extracted from schematic PDFs)
  - `assets/1_【正点原子】启明星ZYNQ之FPGA开发指南V3.2.pdf`
  - `assets/启明星ZYNQ底板原理图_V2.3.2.pdf`
  - `assets/启明星ZYNQ开发板+IO引脚分配总表.xlsx` (source table)
  - `assets/ZYNQ7010_7020核心板原理图_2V5.pdf`
- Vivado/Vitis version: `2020.2`.
- Confirm device/board, tool version, and design goal before generating new scripts.
- For XDC and board-level decisions, clock/reset/LED/key/UART and other board IO pins must come from `assets/qmx7020_pin_index.md` or `assets/qmx7020_pin_index.csv` first. Use `assets/qmx7020_schematic_index.md` for schematic-level notes, reuse/conflict warnings, boot/JTAG/PS peripheral context, and IO bank/electrical reminders. Cross-check against source PDFs when needed. Do not use memory for board pins.
- Prefer reproducible Tcl/batch flows over GUI-only steps.
- For local automation inspired by FPGABuilder, prefer the lightweight workspace wrapper `tools/fpga.ps1`, the template `templates/qmx7020_fpga_project.yaml`, and validation script `tools/validate_fpga_project.ps1` over installing a generic global framework.
- Never run Vivado from the workspace root, `.codex/`, or `.claude/`. Vivado must run with the concrete project directory as the process working directory so `.Xil/`, `.hdi.isWriteableTest.*.tmp`, logs, and generated files stay inside that project or its ignored build folders.
- Keep root clean. Do not add root-level command wrappers or generated tool files unless the user explicitly asks for root-level files. Put helper entry points under `tools/`.
- After any Vivado run, remove leftover `.hdi.isWriteableTest.*.tmp` files from the project tree.
- Simulate before synthesis/implementation when practical.
- Do not infer board IO pins from the part number; require schematic/manual pins for XDC.
