# Common Vivado IP Cores Used In This Workspace

Scope: IP cores found in the current `_ip` projects: `clk_wiz` v6.0, `blk_mem_gen` v8.4, `fifo_generator` v13.2, `ila` v6.2, `cordic` v6.0, `xfft` v9.1, and `fir_compiler` v7.2.

Use this file as a fast engineering guide. For final sign-off, inspect the actual `.xci`, run Vivado validation/DRC, read synthesis/implementation/timing reports, and check the relevant official Product Guide.

## Workspace IP Map

| Core | Modules seen | Used for |
| --- | --- | --- |
| `clk_wiz` | `clk_wiz_0`, `pll`, `pll_100m` | MMCM/PLL-based clock generation and frequency conversion |
| `blk_mem_gen` | `blk_mem_gen_0`, `ram_256x8`, `rom_*` | BRAM-backed RAM/ROM, waveform tables, LCD font/axis tables |
| `fifo_generator` | `fifo_generator_0`, `fifo_512x8` | Buffered streaming or clock-domain decoupling |
| `ila` | `ila_0`, `ila_1` | On-chip signal capture/debug |
| `cordic` | `cordic_0` | Coordinate/vector math, magnitude/phase or trig-style fixed-point computation |
| `xfft` | `xfft_0` | AXI4-Stream FFT processing |
| `fir_compiler` | `fir_lowpass` | FIR filtering with generated coefficients |

## `clk_wiz` v6.0

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Input clock frequency | Real board/PS clock entering the IP | Wrong value gives wrong generated clocks and timing constraints |
| Output clock frequency | Requested PL clock rate | Must be achievable by MMCM/PLL divider ranges |
| Phase and duty cycle | Output waveform alignment | Useful for video/ADC/DAC timing, but phase closure is not magic |
| Reset polarity | How the clocking block is reset | Must match RTL reset logic |
| `locked` output | Clock network stable indicator | Downstream logic should often wait for it |

Limits and traps:

- Valid frequencies are limited by MMCM/PLL VCO and divider ranges.
- Generated clocks must be constrained once, not duplicated with conflicting XDC.
- `locked` does not solve clock-domain crossing; CDC logic is still required.
- Changing an output clock changes downstream timing, sample rates, UART/video timing, and IP OOC constraints.

## `blk_mem_gen` v8.4

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Memory type | Single-port RAM, simple dual-port RAM, true dual-port RAM, ROM | Determines read/write concurrency and port set |
| Width and depth | Data bits per word and address range | Maps to BRAM/LUTRAM usage and address width |
| Read/write mode | Write-first, read-first, no-change | Defines same-address read/write behavior |
| Output register | Adds registered output | Improves timing but adds read latency |
| Initialization file | `.coe` content for ROM/table startup values | Path and radix must match generated IP settings |

Limits and traps:

- BRAM reads are normally synchronous; expect one or more cycles of latency.
- Same-address read/write behavior is mode-dependent and easy to misread in simulation.
- COE paths are fragile when projects are copied; keep init files near the IP or rewrite paths reproducibly.
- Small memories may map to LUTRAM depending on configuration and synthesis decisions.

## `fifo_generator` v13.2

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Common vs independent clocks | Synchronous FIFO or asynchronous CDC FIFO | Determines whether it can cross clock domains |
| Data width and depth | Payload width and buffering capacity | Controls BRAM/LUT cost and burst tolerance |
| FWFT | First-word fall-through mode | Changes empty/read timing semantics |
| Almost full/empty | Early warning thresholds | Useful for flow control before hard full/empty |
| Reset behavior | Reset polarity and busy signals | Must be sequenced carefully, especially for async FIFOs |

Limits and traps:

- Async FIFO is for data CDC, not arbitrary control CDC.
- Full/empty flags have latency; do not assume zero-cycle response.
- FWFT changes how `empty` and `dout` are interpreted.
- Reset must satisfy IP requirements for both clocks.

## `ila` v6.2

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Probe count | Number of independent signals/groups | More probes increase routing and debug complexity |
| Probe width | Bits captured per probe | Wider probes consume more BRAM and routing |
| Sample depth | Number of samples stored | Directly consumes BRAM |
| Capture clock | Clock domain sampled by the ILA | Only signals synchronous to this clock are cleanly observed |
| Trigger settings | Conditions for capture | Bad triggers make hardware debug misleading |

Limits and traps:

- ILA observes one clock domain per core; cross-domain signals need synchronizers or separate ILAs.
- Large ILA cores can hurt implementation timing and placement.
- ILA changes the design enough to mask or expose timing issues.
- Captured samples are after synthesis/implementation optimization; use `mark_debug` intentionally.

## `cordic` v6.0

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Functional mode | Rotate, translate, sin/cos, atan, square root, etc. | Defines ports, latency, and numeric interpretation |
| Data format | Signed fraction/integer style and width | Sets precision, dynamic range, and overflow behavior |
| Iterations/precision | Internal iteration depth | Trades resource and latency for accuracy |
| Pipelining | Throughput architecture | More pipeline stages improve Fmax but increase latency |
| AXI4-Stream options | Handshake and sideband behavior | Must match surrounding stream logic |

Limits and traps:

- Fixed-point scaling must be documented; a correct waveform can still have the wrong numeric scale.
- Latency is part of the algorithm and must be aligned with parallel paths.
- Wider inputs cost more LUT/FF/DSP resources.
- Overflow and rounding settings affect spectral/math accuracy.

## `xfft` v9.1

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Transform length | Number of FFT points | Dominates latency, memory, and frequency resolution |
| Input/output width | Fixed-point precision | Controls noise floor, overflow risk, and resource usage |
| Scaling schedule | Per-stage downscaling | Prevents overflow but changes amplitude |
| Architecture | Pipelined/streaming/burst style | Trades throughput, latency, and resources |
| Output ordering | Natural or bit/digit reversed | Affects downstream bin indexing |
| AXI4-Stream config/data/status | Runtime control and event reporting | Handshake correctness is mandatory |

Limits and traps:

- Scaling is the biggest source of "looks right but value wrong" errors.
- `tvalid`, `tready`, `tlast`, and config channel timing must match the Product Guide.
- FFT latency must be handled explicitly in display/control paths.
- Overflow event signals should be observed during bring-up.

## `fir_compiler` v7.2

Common parameters:

| Parameter area | Meaning | Engineering impact |
| --- | --- | --- |
| Coefficients | Filter taps, often from `.coe` | Define frequency response and resource cost |
| Sample rate / clock rate | Throughput relationship | Determines whether one sample per clock is possible |
| Data and coefficient width | Numeric precision | Affects quantization noise, overflow, and DSP use |
| Decimation/interpolation | Rate conversion | Changes stream rate and timing assumptions |
| Rounding/saturation | Output arithmetic behavior | Controls clipping and bias |

Limits and traps:

- Coefficient quantization changes the ideal filter response.
- Long filters consume DSP/BRAM and add latency.
- Output growth must be accounted for; do not blindly truncate.
- Rate-change modes alter sample timing and downstream valid expectations.

## Practical Verification Checklist

- Extract actual settings from `.xci`, not from memory.
- Generate IP output products and check Vivado messages.
- Run synthesis and inspect black boxes, warnings, and timing constraints.
- For stream IP, simulate handshake and `tlast` behavior.
- For numeric IP, compare against a known software model.
- For debug IP, confirm the ILA clock matches the signal domain.
