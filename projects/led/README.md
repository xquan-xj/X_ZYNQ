# led

Vivado 2020.2 LED blink project generated following the `xilinx-suite` skill workflow.

## Assumptions

- Part: `xc7z020clg400-2`
- Flow: Vivado pure PL project
- Top module: `led`
- Function: blink one LED at 1 Hz from a board clock

Before building a board bitstream, edit:

```text
02_vivado/constraints/led.xdc
```

Fill in the actual clock, reset, and LED package pins from your board schematic/manual.

## Commands

From this folder:

```powershell
vivado -mode batch -source 02_vivado/create_project.tcl -log 02_vivado/output/create_project.log -nojournal
vivado -mode batch -source 02_vivado/sim.tcl -log 02_vivado/output/sim.log -nojournal
vivado -mode batch -source 02_vivado/build.tcl -log 02_vivado/output/build.log -nojournal
```

Expected outputs:

- `02_vivado/build/vivado_project/led.xpr`
- `02_vivado/output/led.bit`
- `02_vivado/reports/post_impl_utilization.rpt`
- `02_vivado/reports/post_impl_timing_summary.rpt`

