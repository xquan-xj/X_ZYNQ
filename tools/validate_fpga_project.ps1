param(
    [string]$Project = "."
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path $Project).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Error($message) { $errors.Add($message) | Out-Null }
function Add-Warning($message) { $warnings.Add($message) | Out-Null }

function Test-AnyPath {
    param([string[]]$Paths)
    foreach ($path in $Paths) {
        if (Test-Path (Join-Path $root $path)) {
            return $true
        }
    }
    return $false
}

function Read-TextIfExists {
    param([string]$Path)
    if (Test-Path $Path) {
        return Get-Content -Raw $Path
    }
    return ""
}

$configPath = Join-Path $root "fpga_project.yaml"
if (-not (Test-Path $configPath)) {
    Add-Warning "fpga_project.yaml not found. Use templates/qmx7020_fpga_project.yaml as a starting point."
} else {
    $configText = Get-Content -Raw $configPath
    if ($configText -notmatch "xc7z020clg400-2") {
        Add-Warning "Config does not mention expected default part xc7z020clg400-2."
    }
    if ($configText -notmatch "2020\.2") {
        Add-Warning "Config does not mention expected Vivado/Vitis version 2020.2."
    }
    if ($configText -notmatch "启明星|qmx7020|ZYNQ 7020") {
        Add-Warning "Config does not mention the QMX/启明星 ZYNQ 7020 board context."
    }
}

if (-not (Test-AnyPath @("rtl", "02_vivado\rtl", "src\hdl"))) {
    Add-Error "No RTL directory found. Expected rtl/, 02_vivado/rtl/, or src/hdl/."
}

if (-not (Test-AnyPath @("tb", "02_vivado\tb", "tests"))) {
    Add-Warning "No testbench/tests directory found."
}

if (-not (Test-AnyPath @("constr", "constraints", "02_vivado\constraints", "src\constraints"))) {
    Add-Warning "No constraints directory found."
}

if (-not (Test-AnyPath @("scripts\create_project.tcl", "02_vivado\create_project.tcl"))) {
    Add-Error "No create_project.tcl found under scripts/ or 02_vivado/."
}

if (-not (Test-AnyPath @("scripts\sim.tcl", "02_vivado\sim.tcl"))) {
    Add-Warning "No sim.tcl found."
}

$xdcFiles = @()
foreach ($dir in @("constr", "constraints", "02_vivado\constraints", "src\constraints")) {
    $full = Join-Path $root $dir
    if (Test-Path $full) {
        $xdcFiles += Get-ChildItem -Path $full -Filter "*.xdc" -File -ErrorAction SilentlyContinue
    }
}

if ($xdcFiles.Count -eq 0) {
    Add-Warning "No XDC file found."
} else {
    foreach ($xdc in $xdcFiles) {
        $text = Read-TextIfExists $xdc.FullName
        if ($text -match "<.*PIN.*>") {
            Add-Warning "$($xdc.FullName) still contains placeholder pins."
        }
        if ($text -notmatch "create_clock") {
            Add-Warning "$($xdc.FullName) has no create_clock constraint."
        }
        if ($text -notmatch "IOSTANDARD") {
            Add-Warning "$($xdc.FullName) has no IOSTANDARD constraints."
        }
    }
}

function Find-AssetRoot {
    param([string]$Start)

    $current = (Resolve-Path $Start).Path
    while ($current) {
        $candidate = Join-Path $current "assets"
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }

        $parent = Split-Path $current -Parent
        if (-not $parent -or $parent -eq $current) {
            break
        }
        $current = $parent
    }

    return $null
}

$assetRoot = Find-AssetRoot $root

foreach ($asset in @("qmx7020_pin_index.csv", "qmx7020_pin_index.md", "qmx7020_schematic_index.md")) {
    if (-not $assetRoot -or -not (Test-Path (Join-Path $assetRoot $asset))) {
        Add-Warning "Board asset index not found near project: $asset"
    }
}

Write-Host "Validation result for: $root"
if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings:"
    foreach ($warning in $warnings) {
        Write-Host "  - $warning"
    }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors:"
    foreach ($errorItem in $errors) {
        Write-Host "  - $errorItem"
    }
    exit 1
}

Write-Host ""
Write-Host "OK: no blocking validation errors."
