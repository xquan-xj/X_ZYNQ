param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[A-Za-z][A-Za-z0-9_\\-]*$")]
    [string]$Name,

    [string]$Template = "projects\_template_qmx7020",

    [string]$DestinationRoot = "projects"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path $PSScriptRoot -Parent
$templatePath = Join-Path $repoRoot $Template
$destinationRootPath = Join-Path $repoRoot $DestinationRoot
$destinationPath = Join-Path $destinationRootPath $Name

if (-not (Test-Path $templatePath)) {
    throw "Template not found: $templatePath"
}

if (Test-Path $destinationPath) {
    throw "Destination project already exists: $destinationPath"
}

New-Item -ItemType Directory -Force -Path $destinationRootPath | Out-Null
Copy-Item -Path $templatePath -Destination $destinationPath -Recurse

$safeModule = ($Name -replace "[^A-Za-z0-9_]", "_")
$files = Get-ChildItem -Path $destinationPath -Recurse -File -Include *.md,*.yaml,*.tcl,*.v,*.sv,*.xdc,*.json

foreach ($file in $files) {
    $text = Get-Content -Raw -Path $file.FullName
    $text = $text.Replace("qmx7020_base", $safeModule)
    $text = $text.Replace("QMX ZYNQ 7020 FPGA Project Template", "$Name FPGA Project")
    Set-Content -Path $file.FullName -Value $text -Encoding UTF8
}

$oldTop = Join-Path $destinationPath "02_vivado\rtl\qmx7020_base_top.v"
$oldTb = Join-Path $destinationPath "02_vivado\tb\tb_qmx7020_base_top.v"
$oldXdc = Join-Path $destinationPath "02_vivado\constraints\qmx7020_base.xdc"

if (Test-Path $oldTop) {
    Move-Item -Path $oldTop -Destination (Join-Path $destinationPath "02_vivado\rtl\$($safeModule)_top.v")
}
if (Test-Path $oldTb) {
    Move-Item -Path $oldTb -Destination (Join-Path $destinationPath "02_vivado\tb\tb_$($safeModule)_top.v")
}
if (Test-Path $oldXdc) {
    Move-Item -Path $oldXdc -Destination (Join-Path $destinationPath "02_vivado\constraints\$safeModule.xdc")
}

Write-Host "Created FPGA project: $destinationPath"
Write-Host "Next: update docs/requirements.md, RTL, and constraints before implementation."
