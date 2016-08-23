# - Try to find portaudio
# Once done this will define
#  PORTAUDIO_FOUND - System has portaudio
#  PORTAUDIO_INCLUDE_DIRS - The portaudio include directories
#  PORTAUDIO_LIBRARIES - The libraries needed to use portaudio
#  PORTAUDIO_DEFINITIONS - Compiler switches required for using portaudio

set(PORTAUDIO_SEARCH_LIBS libportaudio portaudio libportaudio-2 portaudio-2
	libportaudio19 portaudio19 libportaudio-19 portaudio-19 libportaudio2
	portaudio2)
set(PORTAUDIO_SEARCH_HEADERS portaudio.h)

if (MSVC)
	if(NOT DEFINED PORTAUDIO_DIR)
		if(DEFINED PORTAUDIO_ROOT)
			set(PORTAUDIO_DIR ${PORTAUDIO_ROOT})
		elseif(DEFINED ENV{PORTAUDIO_ROOT})
			set(PORTAUDIO_DIR $ENV{PORTAUDIO_ROOT})
		endif()
	endif()
	set(PORTAUDIO_DIR ${PORTAUDIO_DIR} CACHE
		PATH "Installation folder of portaudio")

	if (CMAKE_CL_64)
		set(_subdirs ${PORTAUDIO_DIR}/x64 ${PORTAUDIO_DIR}/x64/lib
			${PORTAUDIO_DIR}/lib/x64 ${PORTAUDIO_DIR}/lib64
			${PORTAUDIO_DIR}/lib ${PORTAUDIO_DIR})
		set(_suffix _x64)
	else()
		set(_subdirs ${PORTAUDIO_DIR}/x86 ${PORTAUDIO_DIR}/x86/lib
			${PORTAUDIO_DIR}/lib/x86 ${PORTAUDIO_DIR}/lib32
			${PORTAUDIO_DIR}/lib ${PORTAUDIO_DIR})
		set(_suffix _x86)
	endif()

	foreach(_lib ${PORTAUDIO_SEARCH_LIBS})
		list(APPEND _libs ${_lib})
		list(APPEND _libs "${_lib}${_suffix}")
	endforeach()

	find_library(PORTAUDIO_LIBRARY
		NAMES ${_libs}
		PATHS ${_subdirs})

#	message("PORTAUDIO_LIBRARY: ${PORTAUDIO_LIBRARY}")

	find_path(PORTAUDIO_INCLUDE_DIR ${PORTAUDIO_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include)

#	message("PORTAUDIO_INCLUDE_DIR: ${PORTAUDIO_LIBRARY}")

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_PORTAUDIO QUIET portaudio)
	set(PORTAUDIO_DEFINITIONS ${PC_PORTAUDIO_CFLAGS_OTHER})

	find_path(PORTAUDIO_INCLUDE_DIR portaudio.h
		HINTS ${PC_PORTAUDIO_INCLUDEDIR} ${PC_PORTAUDIO_INCLUDE_DIRS})

	find_library(PORTAUDIO_LIBRARY NAMES libportaudio portaudio
		HINTS ${PC_PORTAUDIO_LIBDIR} ${PC_PORTAUDIO_LIBRARY_DIRS})

	set(PORTAUDIO_VERSION ${PC_PORTAUDIO_VERSION})
endif()

set(PORTAUDIO_LIBRARIES ${PORTAUDIO_LIBRARY})
set(PORTAUDIO_INCLUDE_DIRS ${PORTAUDIO_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set PORTAUDIO_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(PORTAUDIO
	REQUIRED_VARS PORTAUDIO_LIBRARIES PORTAUDIO_INCLUDE_DIRS
	VERSION_VAR PORTAUDIO_VERSION)

mark_as_advanced(PORTAUDIO_INCLUDE_DIRS PORTAUDIO_LIBRARIES)
