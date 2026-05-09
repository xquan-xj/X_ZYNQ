set script_dir [file dirname [file normalize [info script]]]
set root_dir [file normalize $script_dir]

set project_name "qmx7020_base"
set part_name "xc7z020clg400-2"
set top_name "qmx7020_base_top"
set tb_top_name "tb_qmx7020_base_top"

set build_dir [file join $root_dir "build"]
set reports_dir [file join $root_dir "reports"]
set output_dir [file join $root_dir "output"]
set sim_dir [file join $root_dir "sim"]
set project_dir [file join $build_dir "vivado_project"]

file mkdir $build_dir
file mkdir $reports_dir
file mkdir $output_dir
file mkdir $sim_dir

set rtl_files [glob -nocomplain [file join $root_dir "rtl" "*.v"]]
set sv_files [glob -nocomplain [file join $root_dir "rtl" "*.sv"]]
set tb_files [concat \
    [glob -nocomplain [file join $root_dir "tb" "*.v"]] \
    [glob -nocomplain [file join $root_dir "tb" "*.sv"]] \
]
set xdc_files [glob -nocomplain [file join $root_dir "constraints" "*.xdc"]]
