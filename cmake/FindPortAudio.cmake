# - Try to find portaudio
# Once done this will define
#  PortAudio_FOUND - System has portaudio
#  PortAudio_INCLUDE_DIRS - The portaudio include directories
#  PortAudio_LIBRARIES - The libraries needed to use portaudio
#  PortAudio_DEFINITIONS - Compiler switches required for using portaudio

set(PortAudio_SEARCH_LIBS libportaudio portaudio libportaudio-2 portaudio-2
	libportaudio19 portaudio19 libportaudio-19 portaudio-19 libportaudio2
	portaudio2)
set(PortAudio_SEARCH_HEADERS portaudio.h)

if (MSVC)
	if(NOT DEFINED PortAudio_DIR)
		if(DEFINED PORTAUDIO_ROOT)
			set(PortAudio_DIR ${PORTAUDIO_ROOT})
		elseif(DEFINED ENV{PORTAUDIO_ROOT})
			set(PortAudio_DIR $ENV{PORTAUDIO_ROOT})
		else()
			set(PortAudio_DIR "PortAudio_DIR-NOTFOUND")
		endif()
	endif()
	set(PortAudio_DIR "${PortAudio_DIR}" CACHE
		PATH "Installation folder of portaudio")

	if (CMAKE_CL_64)
		set(_subdirs ${PortAudio_DIR}/x64 ${PortAudio_DIR}/x64/lib
			${PortAudio_DIR}/lib/x64 ${PortAudio_DIR}/lib64
			${PortAudio_DIR}/lib ${PortAudio_DIR})
		set(_suffix _x64)
	else()
		set(_subdirs ${PortAudio_DIR}/x86 ${PortAudio_DIR}/x86/lib
			${PortAudio_DIR}/lib/x86 ${PortAudio_DIR}/lib32
			${PortAudio_DIR}/lib ${PortAudio_DIR})
		set(_suffix _x86)
	endif()

	foreach(_lib ${PortAudio_SEARCH_LIBS})
		list(APPEND _libs ${_lib})
		list(APPEND _libs "${_lib}${_suffix}")
	endforeach()

	find_library(PortAudio_LIBRARY
		NAMES ${_libs}
		PATHS ${_subdirs})

#	message("PortAudio_LIBRARY: ${PortAudio_LIBRARY}")

	find_path(PortAudio_INCLUDE_DIR ${PortAudio_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include)

#	message("PortAudio_INCLUDE_DIR: ${PortAudio_LIBRARY}")

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_PortAudio QUIET portaudio-2.0)
	set(PortAudio_DEFINITIONS ${PC_PortAudio_CFLAGS_OTHER})

	find_path(PortAudio_INCLUDE_DIR ${PortAudio_SEARCH_HEADERS}
		HINTS ${PC_PortAudio_INCLUDEDIR} ${PC_PortAudio_INCLUDE_DIRS})

	find_library(PortAudio_LIBRARY
		NAMES ${PC_PortAudio_LIBRARIES} ${PortAudio_SEARCH_LIBS}
		HINTS ${PC_PortAudio_LIBDIR} ${PC_PortAudio_LIBRARY_DIRS})

	set(PortAudio_VERSION ${PC_PortAudio_VERSION})
endif()

set(PortAudio_LIBRARIES ${PortAudio_LIBRARY})
set(PortAudio_INCLUDE_DIRS ${PortAudio_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set PortAudio_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(PortAudio
	REQUIRED_VARS PortAudio_LIBRARIES PortAudio_INCLUDE_DIRS
	VERSION_VAR PortAudio_VERSION)

mark_as_advanced(PortAudio_INCLUDE_DIRS PortAudio_LIBRARIES
        PortAudio_LIBRARY PortAudio_INCLUDE_DIR)

if(PortAudio_FOUND AND NOT TARGET PortAudio)
    add_library(PortAudio UNKNOWN IMPORTED)
    set_target_properties(PortAudio PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${PortAudio_INCLUDE_DIR}"
            INTERFACE_COMPILE_OPTIONS "${PortAudio_DEFINITIONS}"
            IMPORTED_LINK_INTERFACE_LANGUAGES "C"
            IMPORTED_LOCATION "${PortAudio_LIBRARY}")
endif()
