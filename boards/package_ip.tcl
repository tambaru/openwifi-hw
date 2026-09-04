# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

proc package_ip {ip_tcl_filename src_dir ip_dir board_name} {
	set current_dir [pwd]

	if {[file exists project_1]} {
		file delete -force project_1
	}
	if {[file exists $ip_dir]} {
		file delete -force $ip_dir
	}

	global argv argc
	set saved_argv $argv
	set saved_argc $argc

	set status [catch {
		cd $src_dir

		set argc 1
		set argv [list $board_name]

		if {![file exists ./$ip_tcl_filename]} {
			error "IP configuration file '$ip_tcl_filename' not found in directory '[pwd]'"
		}
		source ./$ip_tcl_filename

		update_compile_order -fileset sources_1
		update_compile_order -fileset sources_1

		ipx::package_project -root_dir $ip_dir -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
		ipx::unload_core $ip_dir/component.xml
		ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $ip_dir $ip_dir/component.xml

		update_compile_order -fileset sources_1
		set_property core_revision 2 [ipx::current_core]

		ipx::update_source_project_archive -component [ipx::current_core]
		ipx::create_xgui_files [ipx::current_core]
		ipx::update_checksums [ipx::current_core]
		ipx::save_core [ipx::current_core]
		ipx::move_temp_component_back -component [ipx::current_core]

		close_project -delete
		close_project -delete
	} err_msg]

	set argv $saved_argv
	set argc $saved_argc
	cd $current_dir

	if {$status != 0} {
		error "Error inside package_custom_ip while building $ip_tcl_filename: $err_msg"
	}

	return 0
}
