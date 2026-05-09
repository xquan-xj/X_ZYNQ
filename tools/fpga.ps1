param(
    [ValidateSet("validate", "create", "sim", "synth", "bitstream", "gui", "wave", "clean")]
    [string]$Action = "validate",

    [string]$Project = ".",

    [string]$Vivado = "D:\Xilinx\Vivado\2020.2\bin\vivado.bat"
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectRoot {
    param([string]$Path)

    if (Test-Path $Path) {
        return (Resolve-Path $Path).Path
    }

    $repoRoot = Split-Path $PSScriptRoot -Parent
    $projectByName = Join-Path (Join-Path $repoRoot "projects") $Path
    if (Test-Path $projectByName) {
        return (Resolve-Path $projectByName).Path
    }

    throw "Project not found: $Path. Pass a project path or a name under projects/."
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

    Remove-HdiWriteTests $Root
    Push-Location $Root
    try {
        & $Vivado -mode batch -source $Script -log $logPath -nojournal
        if ($LASTEXITCODE -ne 0) {
            throw "Vivado failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
        Remove-HdiWriteTests $Root
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
    Remove-HdiWriteTests $Root
    Push-Location $Root
    try {
        & $Vivado -mode gui -source $Script
    } finally {
        Pop-Location
        Remove-HdiWriteTests $Root
    }
}

function Find-LatestWaveDatabase {
    param([string]$Root)

    $wdbFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter "*.wdb" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending)

    if ($wdbFiles.Count -eq 0) {
        return $null
    }

    return $wdbFiles[0].FullName
}

function Convert-ToTclPath {
    param([string]$Path)
    return ($Path -replace "\\", "/")
}

function Invoke-WaveGui {
    param([string]$Root)

    if (-not (Test-Path $Vivado)) {
        throw "Vivado executable not found: $Vivado"
    }

    $wdbPath = Find-LatestWaveDatabase $Root
    if (-not $wdbPath) {
        throw "No .wdb waveform database found under project. Run 'fpga sim $Root' first."
    }

    $waveDir = Join-Path $Root "build\wave"
    New-Item -ItemType Directory -Force -Path $waveDir | Out-Null
    $waveScript = Join-Path $waveDir "open_wave.tcl"
    $tclWdbPath = Convert-ToTclPath $wdbPath

    $tcl = @(
        "open_wave_database {$tclWdbPath}",
        "create_wave_config",
        "add_wave -r /*"
    )
    Set-Content -Path $waveScript -Value $tcl -Encoding ASCII

    Write-Host "Wave database: $wdbPath"
    Write-Host "Wave script:   $waveScript"

    Remove-HdiWriteTests $Root
    Push-Location $Root
    try {
        & $Vivado -mode gui -source $waveScript
        if ($LASTEXITCODE -ne 0) {
            throw "Vivado failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
        Remove-HdiWriteTests $Root
    }
}

function Remove-HdiWriteTests {
    param([string]$Root)

    for ($i = 0; $i -lt 5; $i++) {
        $files = @(Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter ".hdi.isWriteableTest.*.tmp" -ErrorAction SilentlyContinue)
        if ($files.Count -eq 0) {
            return
        }

        foreach ($file in $files) {
            if ($file.FullName.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
                Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
            }
        }

        Start-Sleep -Milliseconds 200
    }

    $remaining = @(Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter ".hdi.isWriteableTest.*.tmp" -ErrorAction SilentlyContinue)
    if ($remaining.Count -gt 0) {
        Write-Warning "Vivado write-test tmp files remain under project: $Root"
    }
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
    "wave" {
        Invoke-Hook $root "pre_wave"
        Invoke-WaveGui $root
        Invoke-Hook $root "post_wave"
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
