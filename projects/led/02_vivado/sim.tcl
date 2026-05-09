# ============================================================
# Vivado behavioral simulation script
# Usage:
#   vivado -mode batch -source 02_vivado/sim.tcl -log 02_vivado/output/sim.log -nojournal
# ============================================================

source [file join [file dirname [file normalize [info script]]] "create_project.tcl"]

launch_simulation
run 5 us
close_sim

set wdb_files [glob -nocomplain [file join $project_dir "${project_name}.sim" "sim_1" "behav" "xsim" "*.wdb"]]
foreach wdb_file $wdb_files {
    file copy -force $wdb_file [file join $sim_dir [file tail $wdb_file]]
}

puts "Behavioral simulation finished. Outputs are in: $sim_dir"

