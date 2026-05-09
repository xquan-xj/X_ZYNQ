# ============================================================
# Open or create the Vivado GUI project
# Usage:
#   vivado -mode gui -source 02_vivado/open_gui.tcl
# ============================================================

source [file join [file dirname [file normalize [info script]]] "project_config.tcl"]

set xpr_file [file join $project_dir "${project_name}.xpr"]
if {[file exists $xpr_file]} {
    open_project $xpr_file
    puts "Opened existing Vivado project: $xpr_file"
} else {
    source [file join $root_dir "create_project.tcl"]
}
