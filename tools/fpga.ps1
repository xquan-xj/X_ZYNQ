param(
    [ValidateSet("validate", "create", "sim", "synth", "bitstream", "gui", "wave", "inspect", "program", "close-save", "close-discard", "clean")]
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
    $pidFile = Join-Path $Root "build\gui\vivado_gui.pid"
    if (Test-Path $pidFile) {
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    }
    $launchTime = Get-Date
    $process = Start-Process -FilePath $Vivado `
        -ArgumentList @("-mode", "gui", "-source", $Script) `
        -WorkingDirectory $Root `
        -WindowStyle Normal `
        -PassThru
    Write-Host "Vivado GUI launched in background. Launcher PID: $($process.Id)"
    Register-VivadoGuiProcess $Root $launchTime
}

function Find-VivadoGuiProcess {
    param([string]$Root)

    $pidFile = Join-Path $Root "build\gui\vivado_gui.pid"
    if (Test-Path $pidFile) {
        $pidText = (Get-Content -Path $pidFile -TotalCount 1).Trim()
        $processId = 0
        if ([int]::TryParse($pidText, [ref]$processId)) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                $process.Refresh()
                return $process
            }
        }
    }

    $projectName = Split-Path $Root -Leaf
    $vivadoProcesses = @(Get-Process -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ProcessName -like "vivado*"
        })

    if ($vivadoProcesses.Count -eq 0) {
        throw "No Vivado GUI process found."
    }

    $escapedProject = [regex]::Escape($projectName)
    $matched = @($vivadoProcesses | Where-Object {
        $_.MainWindowTitle -match "(^|[\\/\[\]\s-])$escapedProject([\\/\]\s.]|$)"
    })

    if ($matched.Count -eq 1) {
        return $matched[0]
    }

    if ($matched.Count -gt 1) {
        $titles = ($matched | ForEach-Object { "$($_.Id): $($_.MainWindowTitle)" }) -join "; "
        throw "Multiple Vivado GUI windows matched project '$projectName': $titles"
    }

    $allTitles = ($vivadoProcesses | ForEach-Object { "$($_.Id): $($_.MainWindowTitle)" }) -join "; "
    throw "No Vivado GUI window clearly matches project '$projectName'. Open windows: $allTitles"
}

function Register-VivadoGuiProcess {
    param(
        [string]$Root,
        [datetime]$LaunchTime
    )

    $logPath = Join-Path $Root "vivado.log"
    $pidDir = Join-Path $Root "build\gui"
    $pidFile = Join-Path $pidDir "vivado_gui.pid"
    New-Item -ItemType Directory -Force -Path $pidDir | Out-Null

    for ($i = 0; $i -lt 30; $i++) {
        if (Test-Path $logPath) {
            $logItem = Get-Item -LiteralPath $logPath -ErrorAction SilentlyContinue
            if ($logItem -and $logItem.LastWriteTime -ge $LaunchTime.AddSeconds(-2)) {
                $logText = Get-Content -Path $logPath -Raw -ErrorAction SilentlyContinue
                if ($logText -match "Process ID:\s+(\d+)") {
                    Set-Content -Path $pidFile -Value $Matches[1] -Encoding ASCII
                    Write-Host "Vivado GUI PID: $($Matches[1])"
                    return
                }
            }
        }
        Start-Sleep -Milliseconds 500
    }

    Write-Warning "Could not record Vivado GUI PID from $logPath yet. close-save/close-discard may need a visible window title fallback."
}

function Invoke-CloseVivadoGui {
    param(
        [string]$Root,
        [ValidateSet("save", "discard")]
        [string]$Mode
    )

    $process = Find-VivadoGuiProcess $Root
    $process.Refresh()
    Write-Host "Vivado GUI process: $($process.Id) $($process.MainWindowTitle)"

    if ($Mode -eq "save") {
        $shell = New-Object -ComObject WScript.Shell
        $activated = $false
        if ($process.MainWindowTitle) {
            $activated = $shell.AppActivate($process.MainWindowTitle)
        }
        if (-not $activated) {
            $activated = $shell.AppActivate($process.Id)
        }
        if (-not $activated) {
            throw "Could not activate Vivado process $($process.Id). Use Vivado Tcl Console: save_project; exit, or use close-discard."
        }
        Start-Sleep -Milliseconds 500
        $shell.SendKeys("^s")
        Start-Sleep -Seconds 2

        Write-Host "Sent Ctrl+S to Vivado. Sending Alt+F4..."
        $shell.SendKeys("%{F4}")
        if (-not $process.WaitForExit(30000)) {
            throw "Vivado did not close within 30 seconds. Check for an open confirmation dialog."
        }
        Remove-HdiWriteTests $Root
    } else {
        Write-Host "Closing without saving by terminating Vivado process."
        Stop-Process -Id $process.Id -Force
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

function Find-LatestVivadoProject {
    param([string]$Root)

    $preferredDirs = @(
        (Join-Path $Root "02_vivado\build"),
        (Join-Path $Root "build")
    )

    foreach ($dir in $preferredDirs) {
        if (Test-Path $dir) {
            $xprFiles = @(Get-ChildItem -LiteralPath $dir -Recurse -Force -Filter "*.xpr" -File -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending)
            if ($xprFiles.Count -gt 0) {
                return $xprFiles[0].FullName
            }
        }
    }

    $allXprFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter "*.xpr" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending)
    if ($allXprFiles.Count -eq 0) {
        return $null
    }

    return $allXprFiles[0].FullName
}

function Find-LatestBitstream {
    param([string]$Root)

    $preferredDirs = @(
        (Join-Path $Root "02_vivado\output"),
        (Join-Path $Root "output"),
        (Join-Path $Root "build")
    )

    foreach ($dir in $preferredDirs) {
        if (Test-Path $dir) {
            $bitFiles = @(Get-ChildItem -LiteralPath $dir -Recurse -Force -Filter "*.bit" -File -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending)
            if ($bitFiles.Count -gt 0) {
                return $bitFiles[0].FullName
            }
        }
    }

    $bitFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter "*.bit" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending)

    if ($bitFiles.Count -eq 0) {
        return $null
    }

    return $bitFiles[0].FullName
}

function Find-ReportFiles {
    param([string]$Root)

    $preferredDirs = @(
        (Join-Path $Root "02_vivado\reports"),
        (Join-Path $Root "reports")
    )
    $reports = @()

    foreach ($dir in $preferredDirs) {
        if (Test-Path $dir) {
            $reports += @(Get-ChildItem -LiteralPath $dir -Recurse -Force -Include "*.rpt", "*.txt" -File -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending)
        }
    }

    return @($reports | Select-Object -First 8)
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

    Invoke-VivadoGui $Root $waveScript
}

function Invoke-InspectGui {
    param([string]$Root)

    if (-not (Test-Path $Vivado)) {
        throw "Vivado executable not found: $Vivado"
    }

    $xprPath = Find-LatestVivadoProject $Root
    $openScript = Find-ProjectScript $Root @("open_gui.tcl", "create_project.tcl")
    if (-not $xprPath -and -not $openScript) {
        throw "No .xpr, open_gui.tcl, or create_project.tcl found. Run 'fpga create $Root' first."
    }

    $wdbPath = Find-LatestWaveDatabase $Root
    $bitPath = Find-LatestBitstream $Root
    $reports = Find-ReportFiles $Root

    $inspectDir = Join-Path $Root "build\inspect"
    New-Item -ItemType Directory -Force -Path $inspectDir | Out-Null
    $inspectScript = Join-Path $inspectDir "inspect_results.tcl"

    $tcl = @()
    $tcl += "puts `"FPGA inspect: opening project and available results.`""
    if ($xprPath) {
        $tclXprPath = Convert-ToTclPath $xprPath
        $tcl += "open_project {$tclXprPath}"
        $tcl += "puts `"Opened Vivado project: $tclXprPath`""
    } else {
        $tclOpenScript = Convert-ToTclPath $openScript
        $tcl += "source {$tclOpenScript}"
    }

    $tcl += 'update_compile_order -fileset sources_1'
    $tcl += 'foreach run_name {synth_1 impl_1} {'
    $tcl += '    set runs [get_runs -quiet $run_name]'
    $tcl += '    if {[llength $runs] > 0 && [get_property PROGRESS $runs] eq "100%"} {'
    $tcl += '        if {[catch {open_run $run_name -name $run_name} msg]} {'
    $tcl += '            puts "INFO: could not open $run_name: $msg"'
    $tcl += '        } else {'
    $tcl += '            puts "Opened run: $run_name"'
    $tcl += '            catch {show_schematic [get_cells -hierarchical]} msg'
    $tcl += '        }'
    $tcl += '    } else {'
    $tcl += '        puts "INFO: $run_name is not available or not complete."'
    $tcl += '    }'
    $tcl += '}'

    if ($wdbPath) {
        $tclWdbPath = Convert-ToTclPath $wdbPath
        $tcl += "if {[catch {open_wave_database {$tclWdbPath}} msg]} {"
        $tcl += '    puts "INFO: could not open wave database: $msg"'
        $tcl += '} else {'
        $tcl += '    catch {create_wave_config}'
        $tcl += '    catch {add_wave -r /*}'
        $tcl += "    puts `"Opened wave database: $tclWdbPath`""
        $tcl += '}'
    } else {
        $tcl += 'puts "INFO: no waveform database found. Run fpga sim first to add wave results."'
    }

    if ($bitPath) {
        $tclBitPath = Convert-ToTclPath $bitPath
        $tcl += "puts `"Latest bitstream: $tclBitPath`""
    } else {
        $tcl += 'puts "INFO: no bitstream found. Run fpga bitstream first to add bitstream output."'
    }

    foreach ($report in $reports) {
        $tclReportPath = Convert-ToTclPath $report.FullName
        $tcl += "if {[catch {open_report {$tclReportPath}} msg]} { puts `"Report file: $tclReportPath`" }"
    }

    $tcl += 'puts "FPGA inspect setup finished. Check Wave, Schematic, Reports, and Messages views."'
    Set-Content -Path $inspectScript -Value $tcl -Encoding ASCII

    Write-Host "Inspect script: $inspectScript"
    if ($xprPath) { Write-Host "Vivado project: $xprPath" }
    if ($wdbPath) { Write-Host "Wave database:  $wdbPath" }
    if ($bitPath) { Write-Host "Bitstream:      $bitPath" }
    foreach ($report in $reports) {
        Write-Host "Report:         $($report.FullName)"
    }

    Invoke-VivadoGui $Root $inspectScript
}

function Invoke-ProgramDevice {
    param([string]$Root)

    if (-not (Test-Path $Vivado)) {
        throw "Vivado executable not found: $Vivado"
    }

    $bitPath = Find-LatestBitstream $Root
    if (-not $bitPath) {
        throw "No .bit bitstream found under project. Run 'fpga bitstream $Root' first."
    }

    $programDir = Join-Path $Root "build\program"
    New-Item -ItemType Directory -Force -Path $programDir | Out-Null
    $programScript = Join-Path $programDir "program_device.tcl"
    $tclBitPath = Convert-ToTclPath $bitPath

    $tcl = @(
        "open_hw_manager",
        "connect_hw_server",
        "open_hw_target",
        "set hw_devices [get_hw_devices]",
        "if {[llength `$hw_devices] == 0} { error `"No hardware devices found. Check USB-JTAG connection and board power.`" }",
        "set target_device [lindex [get_hw_devices xc7z020*] 0]",
        "if {`$target_device eq `"`"} { set target_device [lindex `$hw_devices 0] }",
        "current_hw_device `$target_device",
        "refresh_hw_device -update_hw_probes false `$target_device",
        "set_property PROGRAM.FILE {$tclBitPath} `$target_device",
        "program_hw_devices `$target_device",
        "refresh_hw_device `$target_device",
        "puts `"Programmed bitstream: $tclBitPath`""
    )
    Set-Content -Path $programScript -Value $tcl -Encoding ASCII

    Write-Host "Bitstream:      $bitPath"
    Write-Host "Program script: $programScript"

    Invoke-VivadoBatch $Root $programScript "program.log"
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
    "inspect" {
        Invoke-Hook $root "pre_inspect"
        Invoke-InspectGui $root
        Invoke-Hook $root "post_inspect"
    }
    "program" {
        Invoke-Hook $root "pre_program"
        Invoke-ProgramDevice $root
        Invoke-Hook $root "post_program"
    }
    "close-save" {
        Invoke-Hook $root "pre_close_save"
        Invoke-CloseVivadoGui $root "save"
        Invoke-Hook $root "post_close_save"
    }
    "close-discard" {
        Invoke-Hook $root "pre_close_discard"
        Invoke-CloseVivadoGui $root "discard"
        Invoke-Hook $root "post_close_discard"
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
