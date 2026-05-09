param(
    [ValidateSet("validate", "create", "sim", "synth", "bitstream", "gui", "clean")]
    [string]$Action = "validate",

    [string]$Project = ".",

    [string]$Vivado = "D:\Xilinx\Vivado\2020.2\bin\vivado.bat"
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectRoot {
    param([string]$Path)
    return (Resolve-Path $Path).Path
}

function Find-ProjectScript {
    param(
        [string]$Root,
        [string[]]$Names
    )

    $dirs = @(
        (Join-Path $Root "scripts"),
        (Join-Path $Root "02_vivado")
    )

    foreach ($dir in $dirs) {
        foreach ($name in $Names) {
            $candidate = Join-Path $dir $name
            if (Test-Path $candidate) {
                return (Resolve-Path $candidate).Path
            }
        }
    }

    return $null
}

function Invoke-Hook {
    param(
        [string]$Root,
        [string]$Name
    )

    $hookDir = Join-Path $Root "hooks"
    if (-not (Test-Path $hookDir)) {
        return
    }

    $psHook = Join-Path $hookDir "$Name.ps1"
    $cmdHook = Join-Path $hookDir "$Name.cmd"
    $batHook = Join-Path $hookDir "$Name.bat"

    if (Test-Path $psHook) {
        Write-Host "Running hook: hooks/$Name.ps1"
        & powershell -ExecutionPolicy Bypass -File $psHook
    } elseif (Test-Path $cmdHook) {
        Write-Host "Running hook: hooks/$Name.cmd"
        & $cmdHook
    } elseif (Test-Path $batHook) {
        Write-Host "Running hook: hooks/$Name.bat"
        & $batHook
    }
}

function Invoke-VivadoBatch {
    param(
        [string]$Root,
        [string]$Script,
        [string]$LogName
    )

    if (-not (Test-Path $Vivado)) {
        throw "Vivado executable not found: $Vivado"
    }

    $logDir = Join-Path $Root "build\logs"
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logPath = Join-Path $logDir $LogName

    Write-Host "Vivado script: $Script"
    Write-Host "Vivado log:    $logPath"
    & $Vivado -mode batch -source $Script -log $logPath -nojournal
    if ($LASTEXITCODE -ne 0) {
        throw "Vivado failed with exit code $LASTEXITCODE"
    }
}

function Invoke-VivadoGui {
    param(
        [string]$Root,
        [string]$Script
    )

    if (-not (Test-Path $Vivado)) {
        throw "Vivado executable not found: $Vivado"
    }

    Write-Host "Opening Vivado GUI with: $Script"
    & $Vivado -mode gui -source $Script
}

$root = Resolve-ProjectRoot $Project
Write-Host "Project: $root"

switch ($Action) {
    "validate" {
        $validator = Join-Path (Split-Path $PSScriptRoot -Parent) "tools\validate_fpga_project.ps1"
        & powershell -ExecutionPolicy Bypass -File $validator -Project $root
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }
    "create" {
        $script = Find-ProjectScript $root @("create_project.tcl")
        if (-not $script) { throw "create_project.tcl not found under scripts/ or 02_vivado/" }
        Invoke-Hook $root "pre_create"
        Invoke-VivadoBatch $root $script "create_project.log"
        Invoke-Hook $root "post_create"
    }
    "sim" {
        $script = Find-ProjectScript $root @("sim.tcl")
        if (-not $script) { throw "sim.tcl not found under scripts/ or 02_vivado/" }
        Invoke-Hook $root "pre_sim"
        Invoke-VivadoBatch $root $script "sim.log"
        Invoke-Hook $root "post_sim"
    }
    "synth" {
        $script = Find-ProjectScript $root @("synth.tcl")
        if (-not $script) { throw "synth.tcl not found under scripts/ or 02_vivado/" }
        Invoke-Hook $root "pre_synth"
        Invoke-VivadoBatch $root $script "synth.log"
        Invoke-Hook $root "post_synth"
    }
    "bitstream" {
        $script = Find-ProjectScript $root @("build_bit.tcl", "build.tcl")
        if (-not $script) { throw "build_bit.tcl or build.tcl not found under scripts/ or 02_vivado/" }
        Invoke-Hook $root "pre_bitstream"
        Invoke-VivadoBatch $root $script "bitstream.log"
        Invoke-Hook $root "post_bitstream"
    }
    "gui" {
        $script = Find-ProjectScript $root @("open_gui.tcl", "create_project.tcl")
        if (-not $script) { throw "open_gui.tcl or create_project.tcl not found under scripts/ or 02_vivado/" }
        Invoke-Hook $root "pre_gui"
        Invoke-VivadoGui $root $script
        Invoke-Hook $root "post_gui"
    }
    "clean" {
        $targets = @(
            (Join-Path $root "build"),
            (Join-Path $root "reports"),
            (Join-Path $root "sim"),
            (Join-Path $root "02_vivado\build"),
            (Join-Path $root "02_vivado\reports"),
            (Join-Path $root "02_vivado\sim"),
            (Join-Path $root "02_vivado\output")
        )

        foreach ($target in $targets) {
            if (Test-Path $target) {
                $resolved = (Resolve-Path $target).Path
                if ($resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
                    Write-Host "Removing $resolved"
                    Remove-Item -LiteralPath $resolved -Recurse -Force
                } else {
                    throw "Refusing to remove path outside project: $resolved"
                }
            }
        }
    }
}

