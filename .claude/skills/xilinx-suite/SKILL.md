---
name: xilinx-suite
description: >
  Xilinx 全工具链综合助手，覆盖从零到一的完整 FPGA/MPSoC 工程构建，包括：
  - Vivado：硬件设计、Block Design、IP 配置、XDC 约束、综合实现、比特流生成
  - Vitis HLS：C/C++ 高层次综合，生成自定义 IP 核
  - Vitis Unified IDE（2022.x+）：嵌入式软件开发，Platform/Domain/Application 创建，XSCT 脚本
  - PetaLinux：嵌入式 Linux 系统构建，BSP 配置，内核/rootfs 定制，启动镜像生成
  - 器件支持：Zynq-7000（xc7zxxx）、Zynq UltraScale+ MPSoC（EG/EV 全系及 ZCU10x 评估板）、Versal、纯 FPGA（UltraScale+/UltraScale/7 系列）
  - 本环境：Zynq-7000 xc7z020clg400-2, Vivado/Vitis 2020.2, Windows 10
  只要用户提到以下任何内容，请立即使用本 skill：
  vivado、vitis、hls、高层次综合、vitis_hls、petalinux、zynq、ultrascale、fpga、mpsoc、xsa、比特流、
  block design、综合、实现、xdc、约束、IP核、AXI、嵌入式软件、裸机程序、linux镜像、bsp、设备树、
  jesd204、jesd204b、jesd204c、204b升级204c、204b迁移、高速串行、DAC、ADC、AD9144、AD9250、AD9680、
  grpc、protobuf、rpc、远程调用、上位机通信、petalinux grpc、嵌入式 rpc、zmq 迁移 grpc、udmabuf、axi dma 上位机
  请在用户描述任何 Xilinx/AMD FPGA 硬件或软件设计任务时主动使用本 skill。
---

# Xilinx 全工具链 Skill

本 skill 帮助你完成 Xilinx（AMD）完整设计流程，生成可直接运行的脚本和文件。

---

## 第一步：判断工具和流程

**收到任何 Xilinx 相关请求时，首先确定用户处于哪个阶段，然后加载对应参考文件。**

### 完整设计流程总览

```
[可选] Vitis HLS        →    Vivado          →    Vitis Unified / PetaLinux
C/C++ 算法 → IP 核        硬件平台设计           软件开发 / Linux 系统
  hls_guide.md              vivado_guide.md      vitis_unified_guide.md
                          + mpsoc_ps_config.md    petalinux_guide.md
                          + xdc_constraints.md
```

### 工具路由表

| 用户描述的任务 | 需要的工具 | 加载的参考文件 |
|--------------|-----------|--------------|
| C/C++ 算法加速、pragma 优化、生成 IP | Vitis HLS | `./references/hls_guide.md` |
| 创建工程、Block Design、配置 PS/IP、XDC、比特流 | Vivado | `./references/vivado_guide.md` + 按需加载 |
| PS 详细配置 — MPSoC（ZU+系列 DDR、MIO、时钟）| Vivado | `./references/mpsoc_ps_config.md` |
| PS 详细配置 — Zynq-7000（xc7zxxx DDR、MIO、FCLK）| Vivado | `./references/zynq7_ps_config.md` |
| IO 引脚约束、时序约束 | Vivado | `./references/xdc_constraints.md` |
| JESD204B→C 迁移、高速串行 ADC/DAC 接口 | Vivado | `./references/jesd204b_to_c_migration.md` |
| 嵌入式软件、裸机程序、RTOS、platform/domain | Vitis Unified | `./references/vitis_unified_guide.md` |
| 嵌入式 Linux、kernel 配置、rootfs、启动镜像 | PetaLinux | `./references/petalinux_guide.md` |
| PetaLinux 上跑 gRPC C++ 服务端 / Python 客户端、ZMQ→gRPC 迁移、udmabuf+AXI DMA 暴露 RPC | PetaLinux | `./references/grpc_on_petalinux.md` |
| 查找官方文档编号、UG/PG/DS 编号查询、文档用途说明 | 通用 | `./references/official-docs/index.md` |
| 新建工程、VSCode 工程化、目录组织、文档产物、检查清单 | 通用工程流程 | `./references/vscode_fpga_workflow.md` |

---

## 第二步：需求确认（必须先做）

在生成任何脚本之前，确认以下信息（没有明确答案的项主动提问）：

### 所有工程必须确认
1. **目标器件/开发板**：完整 part number 或板型（由用户提供）
2. **Vivado/Vitis 版本**（如 2023.2、2024.1）
3. **设计目标**：这个工程要实现什么功能？

### HLS 工程额外确认
4. **算法描述**：C/C++ 函数的输入输出和功能
5. **性能目标**：目标时钟频率、延迟、吞吐量要求
6. **接口类型**：AXI4-Lite（控制）、AXI4-Stream（数据）、AXI4-Master（存储器访问）

### Vivado 工程额外确认（MPSoC 类）
4. **PS 配置**：DDR 类型和容量、MIO 外设（UART、Ethernet、USB、SD 等）
5. **PL IP 需求**：需要哪些 AXI IP，是否有自定义 HDL 模块
6. **时钟要求**：PL 时钟频率（pl0_ref_clk）

### Vitis 工程额外确认
4. **运行环境**：裸机（standalone）、FreeRTOS、还是 Linux 用户态
5. **处理器核**：A53、R5、MicroBlaze
6. **XSA 文件路径**：从 Vivado 导出的硬件描述文件

### PetaLinux 工程额外确认
4. **BSP 或 XSA**：是否有厂商 BSP？或者直接使用 Vivado 导出的 XSA？
5. **自定义需求**：是否需要添加驱动/应用程序/设备树覆盖

---

## 第二点五步：工程化文档门禁（必须先做）

对任何 FPGA 工程的新建、复现、移植、改造、调试闭环任务，必须先读取 `./references/vscode_fpga_workflow.md`，并在写 RTL/TB/XDC/Tcl 之前创建或更新工程文档。不得只写代码然后事后补文档。

最小文档闭环：

1. `requirements.md` / `requirements.zh.md`：目标、输入输出、非目标、验收标准
2. `system_design.md` / `system_design.zh.md`：模块边界、数据/控制路径、时钟复位、调试信号
3. `hardware.md` / `hardware.zh.md`：板卡、part、管脚来源、IOSTANDARD、冲突/复用风险
4. `architecture.md` / `architecture.zh.md`：Mermaid 或文字框图
5. `waveform.md` / `waveform.zh.md`：先画预期波形，再写 testbench/RTL；优先使用 WaveDrom 高低电平 `h/l`，事件/时间标注放入图中或图下表格，避免遮挡
6. `flow_status.md` / `flow_status.zh.md`：需求、RTL、仿真、约束、实现、bitstream、上板状态 checklist

如果用户要求“复现某个例程”，也必须先把例程目标、接口、管脚、预期波形和验收标准落到 docs，再修改 RTL/TB/XDC。

README 双语规则：创建或更新任意 `README.md` 时，必须同步创建或更新同目录 `README.zh.md`；命令、路径、信号名、模块名、管脚名、Tcl/Verilog 代码块保持原样。

## 第三步：按工具流程执行

确认需求后，加载对应参考文件并按步骤生成脚本。

### 加载参考文件的时机

**始终在生成脚本之前先读取参考文件**，不要凭记忆生成 Tcl/XSCT/命令，因为不同 Vivado/Vitis 版本的 API 有差异。

```
新建/复现/修改 FPGA 工程 → 先读 ./references/vscode_fpga_workflow.md
                → 再按工具类型读取 Vivado/HLS/Vitis/PetaLinux 参考

Vivado 工程  → 先读 ./references/vivado_guide.md
              → 如有 PS（Zynq-7000）→ 再读 ./references/zynq7_ps_config.md
              → 如有 PS（MPSoC ZU+）→ 再读 ./references/mpsoc_ps_config.md
              → 如有 IO  → 再读 ./references/xdc_constraints.md
              → 如涉及常用 IP 参数含义/局限 → 再读 ./references/ip_cores/common_ip_cores.zh.md
              → 如有 JESD204 → 再读 ./references/jesd204b_to_c_migration.md

HLS 工程     → 先读 ./references/hls_guide.md

Vitis 工程   → 先读 ./references/vitis_unified_guide.md

PetaLinux    → 先读 ./references/petalinux_guide.md
              → 如需 gRPC（C++ server / Python client、ZMQ 迁移）→ 再读 ./references/grpc_on_petalinux.md
```

---

## 输出规范

每次生成脚本时，必须提供：

1. **完整可运行的脚本文件**（`.tcl`、`.xdc`、`.py`、shell 脚本等）
2. **运行命令**：如何在命令行或 GUI 中执行
3. **预期输出**：脚本运行成功后会产生哪些文件
4. **下一步提示**：完成本阶段后应该做什么
5. **工程文档产物**：新建、复现、修改工程时参考 `vscode_fpga_workflow.md`，先生成或更新 `requirements.md`、`system_design.md`、`hardware.md`、`architecture.md`、`waveform.md`、`flow_status.md` 及对应 `.zh.md`，再写 RTL/TB/XDC/Tcl
6. **VSCode 任务入口**：面向 VSCode 使用的工程应提供 `.vscode/tasks.json`，覆盖工程创建、仿真、综合、bitstream、打开 GUI 等常用命令
7. **阶段检查清单**：在文档或 README 中记录需求、RTL、仿真、约束、实现、上板验证 checklist 的当前状态

### 文件组织规范

```
project_root/
├── 01_hls/                  ← Vitis HLS 工程（可选）
│   ├── hls_create.tcl
│   └── src/*.cpp / *.h
│
├── 02_vivado/               ← Vivado 硬件工程
│   ├── create_project.tcl
│   ├── create_bd.tcl
│   ├── add_sources.tcl
│   ├── constraints/design.xdc
│   ├── build.tcl
│   └── output/
│       ├── design.bit
│       └── design_fixed.xsa
│
├── 03_vitis/                ← Vitis 软件工程
│   ├── create_platform.tcl  (XSCT 脚本)
│   ├── create_app.tcl
│   └── src/*.c / *.h
│
└── 04_petalinux/            ← PetaLinux（可选）
    ├── build.sh
    └── config/
```

---

## 跨工具数据流

```
Vitis HLS                    Vivado                    Vitis / PetaLinux
─────────────────────────────────────────────────────────────────────────
hls_ip/                  →   IP Catalog
  solution/impl/ip       →   (add_files / ip_repo)
                             ↓
                         project.xsa         →        平台/BSP/Linux BSP
                         design.bit          →        boot/BOOT.BIN
```

---

## 常见错误和注意事项

1. **版本兼容性**：Vivado 2020.2 使用 `write_sysdef` 导出硬件描述（非 `write_hw_platform`，后者在 2021.x+ 引入）；Vitis 2020.2 为 Classic 版本（非 Unified），使用 `sdk` Tcl 命名空间
2. **Vivado 2020.2 导出 XSA**：`write_sysdef -hw -bitfile system.bit -file system.hdf`；而 Vivado 2021.x+ 使用 `write_hw_platform -fixed -include_bit -file design.xsa`
3. **HLS IP 导入 Vivado**：需要在 Vivado 工程中添加 HLS IP 仓库路径，并刷新 IP 目录
4. **PetaLinux 版本匹配**：PetaLinux 版本必须与 Vivado 版本一致（例如都用 2020.2）
5. **器件系列判断**：`xc7z` 开头 → Zynq-7000（PS 用 `processing_system7` IP）；`xczu` 开头 → MPSoC（PS 用 `zynq_ultra_ps_e` IP）；`vu`/`ku`/`xc7` → 纯 FPGA；`xcvc` → Versal
6. **本环境**：Windows 10, Vivado 2020.2 路径 `D:\Xilinx\Vivado\2020.2`, 器件 xc7z020clg400-2
7. **Vivado Tcl BOM 编码陷阱**：Vivado 2020.2 会把 Tcl 文件开头的 UTF-8 BOM 解析成命令，典型报错是 `invalid command name "ďť?#"` 或 `invalid command name "ï»¿#"`。在 Windows/PowerShell 生成 `.tcl` 时不要使用会写入 BOM 的编码；优先写 ASCII 或 UTF-8 no BOM。若已出现该错误，先把工程内 `*.tcl` 转为无 BOM，再重新运行 `tools\fpga sim/create/synth`。
8. **IP 核配置准确性边界**：不要把“工程能创建/能综合”当成“IP 参数必然正确”。IP 配置必须以 `.xci` 实际参数、Vivado validation/DRC、综合/实现报告、官方 Product Guide，以及必要时的仿真和上板观测共同确认；不确定的高级参数必须标注假设并回查官方文档。

---

## 参考文件

- `./references/vivado_guide.md`：Vivado 工程创建、Block Design、综合实现、报告分析
- `./references/ip_cores/common_ip_cores.zh.md`：本项目已用常见 IP 核参数含义、局限和验证边界
- `./references/mpsoc_ps_config.md`：Zynq UltraScale+ PS 详细配置（DDR、MIO、时钟参数）
- `./references/xdc_constraints.md`：XDC 约束完整指南（时序、IO、例外约束）
- `./references/hls_guide.md`：Vitis HLS 工程流程（C/C++ → IP）
- `./references/vitis_unified_guide.md`：Vitis Unified IDE 2022.x+ 工程流程
- `./references/petalinux_guide.md`：PetaLinux 系统构建流程
- `./references/jesd204b_to_c_migration.md`：JESD204B→C IP 迁移指南（端口映射、数据位宽、AXI 寄存器、常见陷阱）
- `./references/grpc_on_petalinux.md`：PetaLinux + gRPC 端到端部署指南（rootfs 配置、libutf8_range 软链、VM 预生成 .pb.cc + 板上 g++、udmabuf/AXI DMA RPC 暴露、ZMQ→gRPC 迁移、常见 RCU stall 等陷阱）
- `./references/official-docs/index.md`：Xilinx/AMD 官方文档索引（UG/PG/DS/XAPP 编号、标题、用途、与本仓库参考指南的对应关系）
- `./references/vscode_fpga_workflow.md`：VSCode FPGA 工程化流程（需求→设计→文档→RTL→仿真→综合实现→上板、目录规范、tasks.json、checklist）
