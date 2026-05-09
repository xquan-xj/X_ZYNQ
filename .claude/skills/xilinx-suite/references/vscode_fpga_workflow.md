# VSCode FPGA Engineering Workflow

This reference captures the project-engineering workflow used in this workspace. It complements the Xilinx-specific references by defining the human-facing design stages, documentation artifacts, VSCode task integration, and checklists that should surround Vivado/Vitis automation.

## Positioning

VSCode is the unified project entry point for editing, documentation, source control, scripts, logs, reports, and task execution. Vendor tools such as Vivado, Vitis, Quartus, ModelSim, QuestaSim, Verilator, and GTKWave still perform synthesis, implementation, simulation, programming, and hardware debug.

For this Xilinx workspace, keep the vendor execution flow in Tcl/batch scripts, and expose repeatable commands through VSCode tasks when practical.

## Stage Flow

Use this stage order for new FPGA projects:

```text
requirements analysis
  -> system design
  -> hardware selection / board facts
  -> architecture diagram
  -> waveform and timing design
  -> RTL implementation
  -> functional simulation
  -> scripted project creation
  -> synthesis
  -> constraints
  -> implementation
  -> bitstream generation
  -> board bring-up and debug
```

Do not jump directly to board testing for non-trivial designs. Prefer a minimal simulated module first, then integrate.

This order is mandatory for project creation, vendor-example reproduction, migration, or feature modification. Do not write RTL, testbench, XDC, or Tcl before the relevant docs are created or updated. If inheriting an existing example, first document what the example does, which pins/interfaces it uses, expected waveform behavior, and acceptance criteria.

## Recommended Project Layout

For single-tool Vivado projects, this compact layout is preferred:

```text
project_name/
├── rtl/
├── tb/
├── constr/ or constraints/
├── scripts/
│   ├── project_config.tcl
│   ├── create_project.tcl
│   ├── sim.tcl
│   ├── synth.tcl
│   ├── build_bit.tcl or build.tcl
│   └── open_gui.tcl
├── sim/
├── reports/
├── build/
├── doc/ or docs/
│   ├── requirements.md
│   ├── system_design.md
│   ├── hardware.md
│   ├── architecture.md
│   ├── waveform.md
│   └── flow_status.md
├── .vscode/
│   ├── tasks.json
│   └── settings.json
├── README.md
└── .gitignore
```

For cross-tool flows, keep the staged Xilinx layout from `SKILL.md`:

```text
project_root/
├── 01_hls/
├── 02_vivado/
├── 03_vitis/
└── 04_petalinux/
```

Inside each stage, still keep source, constraints, scripts, outputs, reports, and docs separated.

## Documentation Before Code

Before generating RTL for a new module or project, create or update the relevant docs:

- `requirements.md`: inputs, outputs, clock frequency, reset style, data flow, control flow, throughput, latency, resource limits, debug needs.
- `system_design.md`: module boundaries, top-level ports, data/control paths, clock domains, reset strategy, debug signals.
- `hardware.md`: part number, board name, IO bank voltage, oscillator/clock source, reset source, LED/key/UART/JTAG pins, external devices.
- `architecture.md`: block diagram in Mermaid or text form.
- `waveform.md`: reset release, enable/valid/ready/data timing, state transitions, CDC assumptions.
- `flow_status.md`: checklist of generated files, simulation status, synthesis/implementation status, and board-test status.

Small learning examples such as a one-module LED blink may use short docs, but should still record the clock, reset, LED output, part, and pin-source assumptions.

For this workspace, every documentation file should have a Chinese counterpart when created or updated:

```text
requirements.md      requirements.zh.md
system_design.md     system_design.zh.md
hardware.md          hardware.zh.md
architecture.md      architecture.zh.md
waveform.md          waveform.zh.md
flow_status.md       flow_status.zh.md
README.md            README.zh.md
```

Preserve commands, paths, signal names, module names, pin names, Tcl/Verilog snippets, and code blocks verbatim unless translation is explicitly requested.

## Waveform Before RTL

`waveform.md` is a design input, not an after-the-fact report. Before RTL or testbench edits, document the expected signal behavior.

Preferred rendering:

- Use WaveDrom for simple digital timing diagrams.
- Use `h` and `l` to draw high/low rail-style levels instead of only numeric `1` and `0`.
- Put time and trigger events either in a dedicated WaveDrom row such as `time/event` or in a table directly below the diagram.
- Avoid arrow/edge labels when they overlap the waveform in Markdown preview.
- Keep a plain text fallback diagram when plugin rendering is uncertain.

Example:

```wavedrom
{
  config: { hscale: 2 },
  signal: [
    { name: "key", wave: "h...l...h...l...", data: ["released", "pressed", "released", "pressed"] },
    { name: "led", wave: "l...h...l...h...", data: ["off", "on", "off", "on"] },
    { name: "time/event", wave: "=...=...=...=...", data: ["0 ns released", "1200 ns press", "1800 ns release", "2800 ns press"] }
  ]
}
```

For complex diagrams that WaveDrom cannot express well, draw.io may be used for architecture or annotated static diagrams, but keep the source file next to the Markdown and include a Markdown-readable summary table.

## VSCode Tasks

When creating a project intended for VSCode use, provide `.vscode/tasks.json` entries for common commands:

- create Vivado project
- run behavioral simulation
- run synthesis
- generate bitstream
- open Vivado GUI
- optionally open Vitis or run programming scripts

Use commands that call checked-in scripts, for example:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Vivado: Create Project",
      "type": "shell",
      "command": "vivado -mode batch -source scripts/create_project.tcl",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Vivado: Run Simulation",
      "type": "shell",
      "command": "vivado -mode batch -source scripts/sim.tcl",
      "group": "test",
      "problemMatcher": []
    }
  ]
}
```

Keep task labels stable and explicit. Avoid VSCode tasks that only work after manual GUI setup.

## Checklists

### Requirements

```text
[ ] Inputs and outputs are defined
[ ] Clock frequency is known
[ ] Reset behavior is known
[ ] Data flow is clear
[ ] Control flow is clear
[ ] Debug interface is planned
```

### RTL

```text
[ ] Syntax is clean
[ ] No unintended latch
[ ] No multi-driver signal
[ ] FSM states and defaults are complete
[ ] Reset logic is intentional
[ ] CDC signals are synchronized or explicitly constrained
```

### Simulation

```text
[ ] Testbench runs
[ ] Reset behavior passes
[ ] Main function passes
[ ] Boundary conditions are covered
[ ] Expected waveform was written before RTL/testbench implementation
[ ] Waveform matches the expected timing
```

### Constraints

```text
[ ] All external IO pins are assigned
[ ] IO standards match board voltage
[ ] Primary clocks have create_clock
[ ] No large set of unconstrained paths remains
[ ] False paths and multicycle paths are justified
```

### Implementation

```text
[ ] Synthesis completes
[ ] Implementation completes
[ ] Timing passes or violations are explained
[ ] Resource usage is reasonable
[ ] Critical warnings are reviewed
```

### Board Bring-Up

```text
[ ] Power rails are checked
[ ] JTAG detects the device
[ ] Minimal LED design downloads
[ ] Clock is verified
[ ] Reset is verified
[ ] Single IO is verified before complex interfaces
[ ] Core function is validated incrementally
```

## Version Control

Track:

```text
rtl/
tb/
constr/ or constraints/
scripts/
doc/ or docs/
.vscode/tasks.json
README.md
.gitignore
```

Usually ignore generated directories and logs:

```text
build/
runs/
.cache/
*.jou
*.log
*.bit
*.sof
*.rpt
*.wdb
```

For formal releases, archive the final bitstream, timing report, utilization report, source revision, and release notes separately.

## Working Habits

Use these defaults unless the user asks otherwise:

```text
document before code
waveform before testbench
module before system
simulation before board
minimal feature before complete feature
warnings before results
signals before peripherals
scripts before manual GUI
```
