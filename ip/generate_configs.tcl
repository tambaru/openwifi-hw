proc generate_system_configs {module_name board_name num_clk fpga_size define_args {output_path "./src"}} {
    set global_path [file normalize "../global_config.v"]

    # =========================================================================
    # 1. Generate global config
    # =========================================================================
    if {![file exists $global_path]} {
        set gfd [open $global_path "w"]

        set global_guard "GLOBAL_CONFIG_V"

        puts $gfd "// ========================================================="
        puts $gfd "// GLOBAL HARDWARE DEFINITIONS (Shared across all modules)"
        puts $gfd "// ========================================================="
        puts $gfd "\`ifndef $global_guard"
        puts $gfd "\`define $global_guard"
        puts $gfd ""
        puts $gfd "\`define $board_name"
        puts $gfd "\`define NUM_CLK_PER_US $num_clk"
        
        if {$fpga_size == 0} {
            puts $gfd "`define SMALL_FPGA 1"
        }
        
        puts $gfd "`define HAS_SIDE_CH 1"

        set git_script [file normalize "../../get_git_rev.sh"]
        if {[file exists $git_script]} {
            if {[catch {exec bash $git_script} raw_hash]} {
                puts "\[CONF_GEN\] WARNING: Git script execution failed. Using default ffffffff."
                set HASHCODE "ffffffff"
            } else {
                set HASHCODE [string trim $raw_hash]
            }
            puts $gfd "`define OPENWIFI_HW_GIT_REV (32'h$HASHCODE)"
        } else {
            puts "\[CONF_GEN\] WARNING: get_git_rev.sh not found! Using default ffffffff."
            puts $gfd "`define OPENWIFI_HW_GIT_REV (32'hffffffff)"
        }
        
        puts $gfd ""
        puts $gfd "\`endif // $global_guard"
        
        close $gfd
        puts "\[CONF_GEN\] Created GLOBAL config: [file normalize $global_path]"
    } else {
        puts "\[CONF_GEN\] Global config already exists, skipping overwrite to preserve state."
    }

    # =========================================================================
    # 2. Generate local config
    # =========================================================================
    file mkdir $output_path
    set local_file_name [string tolower "${module_name}_pre_def.v"]
    set local_full_path [file normalize [file join $output_path $local_file_name]]
    
    set lfd [open $local_full_path "w"]
    
    set local_guard [string toupper "${module_name}_pre_def_v"]
    
    puts $lfd "// ========================================================="
    puts $lfd "// LOCAL DEFINITIONS FOR MODULE: $module_name"
    puts $lfd "// ========================================================="
    puts $lfd "\`ifndef $local_guard"
    puts $lfd "\`define $local_guard"
    puts $lfd ""
    
    foreach arg $define_args {
        if {$arg eq ""} continue

        if {[llength $arg] > 1 || [string match "*_*" $arg] || [string is upper $arg]} {
            puts $lfd "`define $arg"
        } else {
            puts $lfd "`define ${module_name}_$arg"
        }
    }

    puts $lfd ""
    puts $lfd "\`endif // $local_guard"
    close $lfd
    
    puts "\[CONF_GEN\] Generated LOCAL config: [file normalize $local_full_path]"
    foreach arg $define_args {
        if {$arg ne ""} { puts "            -> Active Define: ${module_name}_$arg" }
    }

    return [list $global_path $local_full_path]
}