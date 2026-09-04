# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2025 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# common operations for all boards at the end of openwifi.tcl

open_bd_design {./src/system.bd}

if {$BOARD_NAME ne "rfsoc4x2"} {
  set_property CONFIG.FREQ_HZ 40000000 [get_bd_pins /util_ad9361_divclk/clk_out]
}

update_compile_order -fileset sources_1

# Upgrade IP
report_ip_status -name ip_status_before

set ips_to_upgrade [get_ips -quiet -filter {NAME =~ *openwifi_ip*}]

if {[llength $ips_to_upgrade] > 0} {
    puts "INFO: Found [llength $ips_to_upgrade] IP blocks in openwifi_ip to upgrade:"
    foreach ip $ips_to_upgrade { 
        puts "  - $ip" 
    }

    foreach ip $ips_to_upgrade {
        puts "INFO: Upgrading $ip..."
        upgrade_ip $ip -log "${ip}_upgrade.log"
    }
    
    puts "INFO: Upgrade process completed. Individual logs saved for each IP."

    export_ip_user_files -of_objects $ips_to_upgrade -no_script -sync -force -quiet
    
} else {
    puts "WARNING: No IPs found in openwifi_ip to upgrade."
}

report_ip_status -name ip_status_after

save_bd_design
