# Requirements

## Goal

Provide a minimal, simulated, synthesizable PL design for the 启明星 ZYNQ 7020 board. New projects should replace or extend this base after the requirements are written down.

## Interfaces

| Signal | Direction | Description |
| --- | --- | --- |
| `sys_clk` | input | 50 MHz PL clock from board oscillator, pin `U18` |
| `sys_rst_n` | input | Active-low reset, pin `N16` |
| `led[1:0]` | output | Board PL LEDs, pins `H15` and `L15` |

## Default Behavior

- After reset releases, `led[0]` toggles at the configured heartbeat rate.
- `led[1]` mirrors the inverse heartbeat state.
- No PS, AXI, CDC, or external peripheral logic is included in this base.

## Open Items For Derived Projects

- [ ] Define the user-visible function.
- [ ] Define all inputs and outputs.
- [ ] Define clock frequency and clock domains.
- [ ] Define reset style and reset release timing.
- [ ] Define debug signals and board bring-up method.
