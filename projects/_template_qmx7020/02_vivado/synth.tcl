# ============================================================
# Vivado synthesis script
# Usage:
#   vivado -mode batch -source 02_vivado/synth.tcl -log 02_vivado/output/synth.log -nojournal
# ============================================================

source [file join [file dirname [file normalize [info script]]] "create_project.tcl"]

set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed. Check synth_1 log under $project_dir."
}

open_run synth_1
report_utilization -file [file join $reports_dir "post_synth_utilization.rpt"]
report_timing_summary -delay_type min_max -report_unconstrained -max_paths 10 \
    -file [file join $reports_dir "post_synth_timing_summary.rpt"]

puts "Synthesis finished. Reports are in: $reports_dir"
