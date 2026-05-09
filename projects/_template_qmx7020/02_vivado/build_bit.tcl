# ============================================================
# Vivado synthesis, implementation, reports, and bitstream script
# Usage:
#   vivado -mode batch -source 02_vivado/build_bit.tcl -log 02_vivado/output/build_bit.log -nojournal
# ============================================================

source [file join [file dirname [file normalize [info script]]] "create_project.tcl"]

set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed. Check synth_1 log under $project_dir."
}

set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed. Check impl_1 log under $project_dir."
}

open_run impl_1
report_utilization -file [file join $reports_dir "post_impl_utilization.rpt"]
report_timing_summary -delay_type min_max -report_unconstrained -max_paths 10 \
    -file [file join $reports_dir "post_impl_timing_summary.rpt"]

set bit_files [glob -nocomplain [file join $project_dir "${project_name}.runs" "impl_1" "*.bit"]]
foreach bit_file $bit_files {
    file copy -force $bit_file [file join $output_dir [file tail $bit_file]]
}

puts "Bitstream flow finished. Outputs are in: $output_dir"
