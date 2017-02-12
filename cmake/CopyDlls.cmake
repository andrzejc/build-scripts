# Copy .dll files accompanying .libs listed as an input to specified DESTINATION
# (defaults to $<TARGET_FILE_DIR:${TARGET}>). This allows the Windows executable
# targets to run directly from the build location (e.g. the tests).
# The first param must be the name of existing TARGET. Remaining params are the
# names of import libraries in a format accepted by target_link_libraries()
# (possibly intermingled with debug/optimized/general keywords). To copy dlls to
# another location add named param DESTINATION to the list. Some heuristics are
# used to search for .dlls given the .lib name: the same directory, parent
# directory and bin subdirectory of parent. The base name of dll must match the
# lib. This is a no-op on non-Windows systems.
#
# include(CopyDlls)
# copy_dlls(my-exe-target ${LIBRARIES} DESTINATION ${PROJECT_BINARY_DIR})
function(copy_dlls TARGET)
if(WIN32)
	set(_copy_dll_next "general")
	set(_destination $<TARGET_FILE_DIR:${TARGET}>)
	foreach(_arg ${ARGN})
		if (_next_arg_destination)
			set(_destination ${_arg})
			set(_next_arg_destination 0)
		elseif (${_arg} MATCHES "destination")
			set(_next_arg_destination 1)
		elseif (${_arg} MATCHES "debug|general|optimized")
			set(_copy_dll_next ${_arg})
		elseif (TARGET ${_arg})
			# TODO read LOCATION or LOCATION_$<CONFIG> property
			set(_location_config $<TARGET_PROPERTY:${_arg},LOCATION_$<CONFIG>>)
			set(_location $<TARGET_PROPERTY:${_arg},LOCATION>)
			message(WARNING "copy_dlls(): linked targets not supported yet")
		elseif (${_arg} MATCHES ".*\\${CMAKE_IMPORT_LIBRARY_SUFFIX}$" AND
			   EXISTS ${_arg})

			string(REGEX REPLACE "\\${CMAKE_IMPORT_LIBRARY_SUFFIX}$"
				${CMAKE_SHARED_LIBRARY_SUFFIX} _dll_name ${_arg})

			if (NOT EXISTS ${_dll_name})
				get_filename_component(_dir ${_dll_name} DIRECTORY)
				get_filename_component(_file ${_dll_name} NAME)
				if (EXISTS "${_dir}/../${_file}")
					set(_dll_name "${_dir}/../${_file}")
				elseif (EXISTS "${_dir}/../bin/${_file}")
					set(_dll_name "${_dir}/../bin/${_file}")
				endif()
			endif()

			if (EXISTS ${_dll_name})
				file(TO_NATIVE_PATH ${_dll_name} _dll_name)
				if (${_copy_dll_next} MATCHES "optimized|general")
					set(_opt_dlls "${_opt_dlls}\n${_dll_name}")
				endif()
				if (${_copy_dll_next} MATCHES "debug|general")
					set(_deb_dlls "${_deb_dlls}\n${_dll_name}")
				endif()
			else ()
				message(WARNING "copy_dlls(): can't find .dll for import library: ${arg}")
			endif()
			set(_copy_dll_next "general")
		endif()
	endforeach()

	set(_copy_dlls_name "copy_dlls-${TARGET}-$<CONFIG>")
	set(_list_file "${_copy_dlls_name}.list")
	set(_cmd_file "${_copy_dlls_name}.cmd")
	file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${_list_file}"
		CONTENT "${_deb_dlls}" CONDITION $<CONFIG:Debug>)
	file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${_list_file}"
		CONTENT "${_opt_dlls}" CONDITION $<NOT:$<CONFIG:Debug>>)
	file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${_cmd_file}"
		CONTENT "for /f \"tokens=*\" %%i in (${_list_file}) do (xcopy /Y /D \"%%i\" \"${_destination}\")")

	add_custom_command(
		TARGET ${TARGET}
		POST_BUILD
		COMMAND $ENV{COMSPEC} /c ${_cmd_file}
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM)

endif(WIN32)
endfunction()
