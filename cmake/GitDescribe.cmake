if(GIT_DESCRIBE_CHECK_RECONFIGURE)
	execute_process(COMMAND "${GIT_EXECUTABLE}" describe --always --long --dirty --abbrev=40
		WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}"
		OUTPUT_FILE "${gd_STAMP_FILE}.tmp"
		OUTPUT_STRIP_TRAILING_WHITESPACE)
	execute_process(COMMAND "${CMAKE_COMMAND}" -E compare_files
			"${gd_STAMP_FILE}.tmp" "${gd_STAMP_FILE}"
		WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}"
		RESULT_VARIABLE stamps_differ
		ERROR_QUIET)
	execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_if_different
			"${gd_STAMP_FILE}.tmp" "${gd_STAMP_FILE}"
		WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}")
	# don't remove the stamp .tmp, really. less frequent rebuilds
	# execute_process(COMMAND "${CMAKE_COMMAND}" -E remove "${gd_STAMP_FILE}.tmp"
	# 	WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}")
	if(NOT gd_ALWAYS)
		# mark date of last check to avoid checking endlessly due to obsolete file level dependendcy
		execute_process(COMMAND "${CMAKE_COMMAND}" -E touch "${gd_STAMP_FILE}")
	endif()
	if(stamps_differ AND gd_FORCE_RECONFIGURE)
		# force reconfigure by touching yourself
		execute_process(COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_SCRIPT_MODE_FILE}")
		# leave the mark
		execute_process(COMMAND "${CMAKE_COMMAND}" -E touch "${gd_STAMP_FILE}.force_reconfigure")
	endif()
endif(GIT_DESCRIBE_CHECK_RECONFIGURE)
if(GIT_DESCRIBE_FORCE_RECONFIGURE)
	if(EXISTS "${gd_STAMP_FILE}.force_reconfigure")
		execute_process(COMMAND "${CMAKE_COMMAND}" -E remove -f "${gd_STAMP_FILE}.force_reconfigure"
			WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}")
		message(FATAL_ERROR "aborting build due to FORCE_RECONFIGURE; tl;dr: just re-run build again; this is due to cyclic dependency in the configure/build process")
	endif()
endif(GIT_DESCRIBE_FORCE_RECONFIGURE)

set(GIT_DESCRIBE_MODULE_PATH "${CMAKE_CURRENT_LIST_FILE}")

include(CMakeParseArguments)

# QUIET -             don't print any output
# FORCE_RECONFIGURE - add target checking if git index changed, which will force cmake
#                     reconfigure change detected (so that git-derived VERSION variables
#                     are updated)
# ALWAYS -            ignore last mod time of .git/index file, always run git-describe
#                     to make sure you never miss any change (is that even possible?)
function(git_describe prefix)
	cmake_parse_arguments(gd "QUIET;FORCE_RECONFIGURE;ALWAYS" "WORKING_DIRECTORY" "OPTIONS" ${ARGN})
	if(gd_QUIET)
		find_package(Git QUIET)
	else()
		find_package(Git)
	endif()

	if(NOT gd_WORKING_DIRECTORY)
		set(gd_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()

	set(out_var "${prefix}_GIT_DESCRIBE")
	if(Git_FOUND)
		execute_process(COMMAND "${GIT_EXECUTABLE}" describe --always --long --dirty --abbrev=40 ${gd_OPTIONS}
			WORKING_DIRECTORY "${gd_WORKING_DIRECTORY}"
			OUTPUT_VARIABLE git_out
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	endif(Git_FOUND)
	set(${out_var} "${git_out}" PARENT_SCOPE)
	if(Git_FOUND AND (${git_out} MATCHES "^(.*)-([0-9]+)-g([0-9a-fA-F]+)(-dirty)?\$"))
		if(NOT gd_QUIET)
			message(STATUS "Building ${prefix} from commit: ${git_out}")
		endif()
		set(git_last_tag "${CMAKE_MATCH_1}")
		set("${prefix}_GIT_LAST_TAG" "${git_last_tag}" PARENT_SCOPE)
		set("${prefix}_GIT_COMMIT_PAST_TAG" "${CMAKE_MATCH_2}" PARENT_SCOPE)
		set("${prefix}_GIT_COMMIT_FULL" "${CMAKE_MATCH_3}" PARENT_SCOPE)
		string(SUBSTRING "${CMAKE_MATCH_3}" 0 7 hash_short)
		set("${prefix}_GIT_COMMIT" "${hash_short}" PARENT_SCOPE)
		set("${prefix}_GIT_DIRTY" "${CMAKE_MATCH_4}" PARENT_SCOPE)
		if("${CMAKE_MATCH_2}" EQUAL 0)
			set("${prefix}_GIT_TAG" "${CMAKE_MATCH_1}" PARENT_SCOPE)
		endif()
	else()
		if(NOT gd_QUIET)
			if(Git_FOUND)
				message(WARNING "Unable to parse git describe output: ${git_out}")
			else()
				message(WARNING "GitDescribe: unable to find Git executable")
			endif()
		endif()
		set("${prefix}_GIT_LAST_TAG" "${prefix}_GIT_LAST_TAG-NOTFOUD" PARENT_SCOPE)
		set("${prefix}_GIT_COMMIT_PAST_TAG" "${prefix}_GIT_COMMIT_PAST_TAG-NOTFOUD" PARENT_SCOPE)
		set("${prefix}_GIT_COMMIT_FULL" "${prefix}_GIT_COMMIT_FULL-NOTFOUD" PARENT_SCOPE)
		set("${prefix}_GIT_COMMIT" "${prefix}_GIT_COMMIT-NOTFOUD" PARENT_SCOPE)
		set("${prefix}_GIT_DIRTY" "${prefix}_GIT_DIRTY-NOTFOUD" PARENT_SCOPE)
	endif()
	if("${git_last_tag}" MATCHES "^([a-zA-Z0-9_-]+-|v)?(([0-9]+(\\.[0-9]+(\\.[0-9]+(\\.[0-9]+)?)?)?)(-([a-zA-Z0-9_.+]+))?)\$")
		set("${prefix}_GIT_TAG_STEM" "${CMAKE_MATCH_1}" PARENT_SCOPE)
		set("${prefix}_VERSION_FULL" "${CMAKE_MATCH_2}" PARENT_SCOPE)
		set(version "${CMAKE_MATCH_3}")
		set("${prefix}_VERSION" "${version}" PARENT_SCOPE)
		set("${prefix}_VERSION_LABEL" "${CMAKE_MATCH_8}" PARENT_SCOPE)
		if(NOT gd_QUIET)
			message(STATUS "Inferring ${prefix}_VERSION_FULL from Git: ${CMAKE_MATCH_2}")
		endif()
		string(REGEX MATCH "([0-9]+)(\\.([0-9]+)(\\.([0-9]+)(\\.([0-9]+))?)?)?" ignore "${version}")
		set("${prefix}_VERSION_MAJOR" "${CMAKE_MATCH_1}" PARENT_SCOPE)
		if(CMAKE_MATCH_3 MATCHES "[0-9]+")
			set("${prefix}_VERSION_MINOR" "${CMAKE_MATCH_3}" PARENT_SCOPE)
		endif()
		if(CMAKE_MATCH_5 MATCHES "[0-9]+")
			set("${prefix}_VERSION_PATCH" "${CMAKE_MATCH_5}" PARENT_SCOPE)
		endif()
		if(CMAKE_MATCH_7 MATCHES "[0-9]+")
			set("${prefix}_VERSION_TWEAK" "${CMAKE_MATCH_7}" PARENT_SCOPE)
		endif()
	endif()

	if(gd_FORCE_RECONFIGURE OR gd_ALWAYS)
		set(out_path ".git_describe.${prefix}")
		add_custom_command(OUTPUT "${out_path}"
			COMMAND "${CMAKE_COMMAND}"
				-DGIT_DESCRIBE_CHECK_RECONFIGURE=1
				"-DGIT_EXECUTABLE=${GIT_EXECUTABLE}"
				"-Dgd_WORKING_DIRECTORY=${gd_WORKING_DIRECTORY}"
				"-Dgd_STAMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/${out_path}"
				"-Dgd_ALWAYS=${gd_ALWAYS}"
				"-Dgd_FORCE_RECONFIGURE=${gd_FORCE_RECONFIGURE}"
				-P "${GIT_DESCRIBE_MODULE_PATH}"
			DEPENDS "${gd_WORKING_DIRECTORY}/.git/index"
				"${gd_WORKING_DIRECTORY}/.git/HEAD"
				"${gd_WORKING_DIRECTORY}/.git/logs/HEAD"
			BYPRODUCTS "${out_path}.force_reconfigure"
			COMMENT "Querying git-describe in '${gd_WORKING_DIRECTORY}' for project ${prefix} due to Git index change "
			VERBATIM)
		add_custom_command(OUTPUT "${out_path}.force_reconfigure.PHONY"
			COMMAND "${CMAKE_COMMAND}"
				-DGIT_DESCRIBE_FORCE_RECONFIGURE=1
				"-Dgd_WORKING_DIRECTORY=${gd_WORKING_DIRECTORY}"
				"-Dgd_STAMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/${out_path}"
				-P "${GIT_DESCRIBE_MODULE_PATH}"
			DEPENDS "${out_path}"
			COMMENT "Checking if should report build error for project ${prefix} on git-describe output change")
		set_source_files_properties("${out_path}.force_reconfigure.PHONY" PROPERTIES SYMBOLIC ON)
		add_custom_target("${prefix}-git-describe" ALL
			DEPENDS "${out_path}" "${out_path}.force_reconfigure.PHONY"
			COMMENT "Checked git-describe information for project ${prefix}")
	endif(gd_FORCE_RECONFIGURE OR gd_ALWAYS)
endfunction(git_describe)