# Waveform And Timing

## Reset Release

```text
sys_clk     _-_-_-_-_-_-_-_-_-_-_-_
sys_rst_n   ____-------------------
led[0]      0000----toggle later---
led[1]      0000----inverse later--
```

## Simulation Scaling

The testbench overrides `CLK_FREQ_HZ` and `HEARTBEAT_HZ` so simulation finishes quickly. Keep these parameters overridable when extending the design.

## Timing Constraints

- Primary clock constraint: `create_clock -period 20.000 -name sys_clk [get_ports sys_clk]`
- External IO constraints are limited to clock/reset/LEDs in the base template.
- Add input/output delays when real external synchronous interfaces are introduced.
