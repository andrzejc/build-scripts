if (POLICY CMP0042)
	cmake_policy(SET CMP0042 NEW)
endif()
if (POLICY CMP0063)
	# Honor visibility properties for all target types.
	cmake_policy(SET CMP0063 NEW)
endif()
if (POLICY CMP0028)
	# recognize target names which use double colon as IMPORTED or ALIAS
	cmake_policy(SET CMP0028 NEW)
endif()

if (NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin CACHE
		PATH "Directory where .exe and .dll files are dumped.")
	mark_as_advanced(CMAKE_RUNTIME_OUTPUT_DIRECTORY)
endif()

if(${CMAKE_VERSION} VERSION_LESS 2.8.11)

include(CMakeParseArguments)

macro(_set_target_interface_defs _TARGET _DEFS)
	if(DEFINED ${_DEFS})
#		message(STATUS " _set ${_TARGET} ${_DEFS}")
		set_property(TARGET ${_TARGET}
			APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
			${${_DEFS}})
	endif()
endmacro()

macro(_set_target_defs _TARGET _DEFS)
	if(DEFINED ${_DEFS})
#		message(STATUS " _set ${_TARGET} ${_DEFS}")
		set_property(TARGET ${_TARGET}
			APPEND PROPERTY COMPILE_DEFINITIONS
			${${_DEFS}})
	endif()
endmacro()

function(target_compile_definitions _TARGET)
	cmake_parse_arguments(_defs
		""
		""
		"INTERFACE;PUBLIC;PRIVATE"
		${ARGN}
	)
	_set_target_interface_defs(${_TARGET} _defs_INTERFACE)
	_set_target_interface_defs(${_TARGET} _defs_PUBLIC)
	_set_target_defs(${_TARGET} _defs_PUBLIC)
	_set_target_defs(${_TARGET} _defs_PRIVATE)
endfunction()
endif()

