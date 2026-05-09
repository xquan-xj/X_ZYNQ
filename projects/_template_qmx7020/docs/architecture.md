# Architecture

```mermaid
flowchart LR
    CLK[sys_clk 50 MHz] --> TOP[qmx7020_base_top]
    RST[sys_rst_n] --> TOP
    TOP --> LED0[led0 heartbeat]
    TOP --> LED1[led1 inverse]
```

## Module Boundaries

- `qmx7020_base_top`: board-facing top-level ports and heartbeat logic.
- Future project modules should be added under `02_vivado/rtl/` and instantiated from the top module.

## Design Rule

Keep the first bring-up path small. Add one feature, simulate it, then integrate it into the board-level top.
