# ============================================================
# Vivado 2020.2 project creation script
# Usage:
#   vivado -mode batch -source 02_vivado/create_project.tcl -log 02_vivado/output/create_project.log -nojournal
# ============================================================

source [file join [file dirname [file normalize [info script]]] "project_config.tcl"]

create_project -force $project_name $project_dir -part $part_name
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]

if {[llength $rtl_files] > 0} {
    add_files -fileset sources_1 $rtl_files
}
if {[llength $sv_files] > 0} {
    add_files -fileset sources_1 $sv_files
}
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 $tb_files
}
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 $xdc_files
}

set_property top $top_name [get_filesets sources_1]
set_property top $tb_top_name [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Vivado project created: $project_dir/$project_name.xpr"

