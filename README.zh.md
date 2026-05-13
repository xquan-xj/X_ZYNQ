# ZYNQ FPGA 工作区

这个工作区面向 **正点原子启明星 ZYNQ 7020**，默认工具链为 **Vivado/Vitis 2020.2**。目标不是做一个泛用 FPGA 框架，而是把板级资料、AI skill、Vivado Tcl 脚本、VSCode 工作流和项目验证组织成一套稳定的本地开发环境。

## 当前架构

```text
D:\FPGA\ZYNQ\
├── AGENTS.md                         # Codex 项目级规则
├── CLAUDE.md                         # Claude 项目级规则
├── README.md                         # 英文/简版说明
├── README.zh.md                      # 中文说明
├── assets/                           # 启明星 7020 板级资料与索引
├── .codex/skills/xilinx-suite/       # Codex 本地 Xilinx skill
├── .claude/skills/xilinx-suite/      # Claude 本地 Xilinx skill
├── tools/                            # 本地轻量自动化工具
├── templates/                        # 工程配置模板
└── projects/                         # 具体 FPGA 工程
    ├── _template_qmx7020/             # 启明星 7020 通用工程母版
    └── led/
```

## 板级资料

日常生成 XDC 或查板级连接时，优先使用：

```text
assets/qmx7020_pin_index.csv
assets/qmx7020_pin_index.md
assets/qmx7020_schematic_index.md
```

需要全文检索原理图时使用：

```text
assets/qmx7020_base_schematic.txt
assets/qmx7020_core_schematic.txt
```

最终硬件复核仍以原始 PDF / xlsx 为准。

常用 PL 管脚：

```text
sys_clk    U18   50 MHz
sys_rst_n  N16   低有效
led[0]     H15   底板 PL_LED0
led[1]     L15   底板 PL_LED1
led        J16   核心板 PL_LED
key[0]     L14
key[1]     K16
uart_rxd   T19
uart_txd   J15
```

## 工程放在哪里

建议把所有 **启明星 ZYNQ 7020 相关工程** 都放在 `projects/` 下：

```text
D:\FPGA\ZYNQ\
├── assets/
├── tools/
├── templates/
└── projects/
    ├── led/
    ├── uart_loopback/
    ├── ps_pl_led/
    ├── axi_gpio_demo/
    └── camera_lcd_demo/
```

这样做更合适，因为这些项目可以共享：

- `assets/` 里的启明星 7020 管脚表、原理图索引、手册资料
- `.codex/skills/xilinx-suite/` 和 `.claude/skills/xilinx-suite/`
- `fpga.cmd` 根目录命令入口和 `tools/fpga.ps1` 实现脚本
- `templates/qmx7020_fpga_project.yaml` 工程配置模板
- `AGENTS.md` / `CLAUDE.md` 中的默认板卡、器件、Vivado 版本规则

不建议每个小工程都复制一份板级资料和 skill。那样容易出现多个版本的管脚表、多个版本的规则，后面维护会变乱。

`tools/` 和 `.mcp/` 不一样：

- `tools/`：本工作区自己的辅助脚本，例如统一命令入口、验证器、索引生成器、报告整理脚本。
- `.mcp/`：MCP server 或连接器相关内容，用于外部工具/服务集成。

所以 `.mcp/` 不应该放进 `tools/`，也不建议把普通构建脚本放进 `.mcp/`。

## 推荐单工程结构

本工作区现在优先使用 `projects/_template_qmx7020/` 作为新工程母版。它采用分阶段结构，同时包含一个最小可仿真、可综合、可上板点灯的 PL 基础设计：

```text
project_name/
├── fpga_project.yaml
├── 01_hls/            # 可选 HLS
├── 02_vivado/         # RTL / TB / XDC / Vivado Tcl / output
├── 03_vitis/          # 可选 Vitis 2020.2 软件
├── 04_petalinux/      # 可选 PetaLinux 2020.2
├── docs/              # 需求、系统设计、硬件、架构、波形、流程状态
├── hooks/
├── .vscode/
├── README.md
└── .gitignore
```

普通 PL-only 工程也可以只使用其中的 `02_vivado/`，暂时保留其他阶段目录作为后续扩展入口。

## 从母版创建新工程

通过根目录命令入口创建派生工程：

```powershell
fpga new uart_loopback
```

这会从 `projects/_template_qmx7020/` 复制出：

```text
projects/uart_loopback/
```

然后优先修改：

- `projects/uart_loopback/fpga_project.yaml`
- `projects/uart_loopback/docs/requirements.md`
- `projects/uart_loopback/docs/system_design.md`
- `projects/uart_loopback/02_vivado/rtl/`
- `projects/uart_loopback/02_vivado/constraints/`

## 统一命令

可以传入 `projects/` 下的工程名，也可以传入具体项目路径。封装脚本会在启动 Vivado 前把 Vivado 进程工作目录切到该项目目录：

```powershell
fpga validate _template_qmx7020
fpga create _template_qmx7020
fpga sim _template_qmx7020
fpga synth _template_qmx7020
fpga bitstream _template_qmx7020
fpga gui _template_qmx7020
fpga wave _template_qmx7020
fpga inspect _template_qmx7020
fpga program _template_qmx7020
fpga close-save _template_qmx7020
fpga close-discard _template_qmx7020
```

`wave` 用于在 `sim` 之后用 Vivado GUI 打开最新的 `.wdb` 波形数据库。
`inspect` 用于在同一个 Vivado GUI 会话中打开工程，并尽量展示已有 waveform、schematic、reports 和输出产物路径。
`program` 用于在 `bitstream` 之后，通过 Vivado Hardware Manager batch 模式把最新的 `.bit` 文件经 USB-JTAG 下载到板卡。
`close-save` 用于向匹配的 Vivado GUI 窗口发送 `Ctrl+S` 并正常关闭；`close-discard` 用于不保存并强制结束匹配的 Vivado GUI 窗口。
GUI 类命令（`gui`、`wave`、`inspect`）会在后台启动 Vivado，因此终端会立即返回，可以继续输入关闭或其他命令。

如果在 PowerShell 中当前目录不在 `PATH`，请使用 `.\fpga ...`。

严禁直接从工作区根目录、`.codex/` 或 `.claude/` 启动 Vivado。

`tools/fpga.ps1` 会在项目内查找：

```text
scripts/
02_vivado/
```

所以老式单工程结构和分阶段结构都能兼容。

## 工程配置模板

轻量配置文件模板仍保留在：

```text
templates/qmx7020_fpga_project.yaml
```

但完整新工程建议直接从：

```text
projects/_template_qmx7020/
```

派生，因为它已经包含 docs、VSCode tasks、Vivado Tcl、仿真 testbench 和基础 XDC。

派生后至少修改工程名、顶层模块名、RTL/testbench/XDC 和需求文档。

## Hooks

每个工程可以按需添加：

```text
hooks/pre_create.ps1
hooks/post_create.ps1
hooks/pre_sim.ps1
hooks/post_sim.ps1
hooks/pre_synth.ps1
hooks/post_synth.ps1
hooks/pre_bitstream.ps1
hooks/post_bitstream.ps1
hooks/pre_gui.ps1
hooks/post_gui.ps1
hooks/pre_wave.ps1
hooks/post_wave.ps1
hooks/pre_inspect.ps1
hooks/post_inspect.ps1
hooks/pre_program.ps1
hooks/post_program.ps1
hooks/pre_close_save.ps1
hooks/post_close_save.ps1
hooks/pre_close_discard.ps1
hooks/post_close_discard.ps1
```

适合做：

- 自动复制 bitstream
- 保存 timing/utilization 报告
- 生成版本记录
- 计算文件 hash
- 打包发布产物

## 验证器

运行：

```powershell
powershell -ExecutionPolicy Bypass -File tools\validate_fpga_project.ps1 -Project projects\_template_qmx7020
```

会检查：

- 是否有 `fpga_project.yaml`
- 是否匹配启明星 ZYNQ 7020 / Vivado 2020.2 上下文
- 是否有 RTL、testbench、XDC、Tcl 脚本
- XDC 是否仍有占位管脚
- 是否有 `create_clock`
- 是否有 `IOSTANDARD`
- 板级索引文件是否可用

这个验证器只负责抓常见遗漏，不代替 Vivado DRC、时序分析和上板验证。

## 和 FPGABuilder 的关系

本工作区借鉴了 FPGABuilder 的几个好想法：

- YAML 配置驱动
- 统一命令入口
- hooks 机制
- 构建产物目录规范
- 配置/工程验证

但没有直接采用完整 FPGABuilder 框架。原因是本工作区更重视启明星 ZYNQ 7020 的板级正确性，包括真实管脚、原理图索引、Vivado 2020.2 细节和 Xilinx/Zynq 专用流程。

## 推荐工作流

```text
需求分析
  -> 系统设计
  -> 硬件/管脚确认
  -> 架构和波形文档
  -> RTL
  -> testbench 仿真
  -> Vivado 工程创建
  -> 综合
  -> 实现
  -> bitstream
  -> 最小功能上板
  -> 逐步扩展功能
```

基本原则：

```text
先文档，再代码
先模块，再系统
先仿真，再上板
先最小功能，再复杂系统
先查板级索引，再写 XDC
```
111