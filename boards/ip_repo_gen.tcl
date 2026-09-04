# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

source ../package_ip.tcl

# Set board specific variables
set BOARD_NAME [lindex [split [exec pwd] /] end]
puts "ip_repo_gen.tcl BOARD_NAME $BOARD_NAME"
source ../../ip/parse_board_name.tcl

# ------------------setup ip_repo directory and board files---------------------
exec rm -f ../../ip/global_config.v
exec rm -rf ip_repo
exec mkdir ip_repo
exec cp ../../ip/board_def.v ./ip_repo/ -f

# ------------------end of setup ip_repo directory and board files--------------

# --------------------------------generate ip repo------------------------------
set ip_name_list "openofdm_rx openofdm_tx rx_intf tx_intf xpu side_ch"
# loop and generate all ip
set i 0
foreach ip_name $ip_name_list {
  puts "$ip_name is item number $i in list ip_name_list"

  if {[file exists project_1]} {
    file delete -force project_1
  }

  set ip_tcl_filename "${ip_name}.tcl"
  set absolute_src [file normalize "../../ip/$ip_name"]
  set absolute_repo [file normalize "ip_repo/$ip_name"]

  if {$ip_name != "openofdm_rx"} {
    set dst_dir "$absolute_src/src"
    if {![file exists $dst_dir]} {
      file mkdir $dst_dir
    }
    file copy -force "./ip_repo/board_def.v" "$dst_dir/"
  }

  package_ip $ip_tcl_filename $absolute_src $absolute_repo $BOARD_NAME

  if {[file exists "./ip_repo/$ip_name/xgui"]} {
    file delete -force "./ip_repo/$ip_name/xgui"
  }

  incr i
}

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

# launch openwifi synth and impl
source ../openwifi.tcl

