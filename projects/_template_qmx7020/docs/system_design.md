# System Design

## Top Module

`qmx7020_base_top`

```text
sys_clk    -> heartbeat counter -> led[0]
sys_rst_n  -> reset logic       -> led[1]
```

## Clocking

- Primary PL clock: `sys_clk`
- Frequency: 50 MHz
- XDC period: 20.000 ns

## Reset

- Reset input: `sys_rst_n`
- Active level: low
- Synchronous logic is reset asynchronously and released on the clock edge.

## Extension Points

- Replace `qmx7020_base_top` with the project top, or instantiate new modules under it.
- Add IP and Block Design scripts under `02_vivado/` when the design needs PS/AXI.
- Add software under `03_vitis/` only after a hardware handoff exists.
