# - Try to find portaudio
# Once done this will define
#  LIBPORTAUDIO_FOUND - System has portaudio
#  LIBPORTAUDIO_INCLUDE_DIRS - The portaudio include directories
#  LIBPORTAUDIO_LIBRARIES - The libraries needed to use portaudio
#  LIBPORTAUDIO_DEFINITIONS - Compiler switches required for using portaudio

set(LIBPORTAUDIO_SEARCH_LIBS libportaudio portaudio libportaudio-2 portaudio-2
	libportaudio19 portaudio19 libportaudio-19 portaudio-19 libportaudio2
	portaudio2)
set(LIBPORTAUDIO_SEARCH_HEADERS portaudio.h)

if (MSVC)
	if(NOT LIBPORTAUDIO_DIR)
		if(LIBPORTAUDIO_ROOT)
			set(LIBPORTAUDIO_DIR ${LIBPORTAUDIO_ROOT})
		elseif($ENV{LIBPORTAUDIO_ROOT})
			set(LIBPORTAUDIO_DIR $ENV{LIBPORTAUDIO_ROOT})
		endif()
	endif()
	set(LIBPORTAUDIO_DIR ${LIBPORTAUDIO_DIR} CACHE
		PATH "Installation folder of portaudio")

	if (CMAKE_CL_64)
		set(_subdirs ${LIBPORTAUDIO_DIR}/x64 ${LIBPORTAUDIO_DIR}/x64/lib
			${LIBPORTAUDIO_DIR}/lib/x64 ${LIBPORTAUDIO_DIR}/lib64
			${LIBPORTAUDIO_DIR}/lib ${LIBPORTAUDIO_DIR})
		set(_suffix _x64)
	else()
		set(_subdirs ${LIBPORTAUDIO_DIR}/x86 ${LIBPORTAUDIO_DIR}/x86/lib
			${LIBPORTAUDIO_DIR}/lib/x86 ${LIBPORTAUDIO_DIR}/lib32
			${LIBPORTAUDIO_DIR}/lib ${LIBPORTAUDIO_DIR})
		set(_suffix _x86)
	endif()

	foreach(_lib ${LIBPORTAUDIO_SEARCH_LIBS})
		list(APPEND _libs ${_lib})
		list(APPEND _libs "${_lib}${_suffix}")
	endforeach()

	find_library(LIBPORTAUDIO_LIBRARY
		NAMES ${_libs}
		PATHS ${_subdirs})

#	message("LIBPORTAUDIO_LIBRARY: ${LIBPORTAUDIO_LIBRARY}")

	find_path(LIBPORTAUDIO_INCLUDE_DIR ${LIBPORTAUDIO_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include)

#	message("LIBPORTAUDIO_INCLUDE_DIR: ${LIBPORTAUDIO_LIBRARY}")

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_LIBPORTAUDIO QUIET portaudio)
	set(LIBPORTAUDIO_DEFINITIONS ${PC_LIBPORTAUDIO_CFLAGS_OTHER})

	find_path(LIBPORTAUDIO_INCLUDE_DIR portaudio.h
		HINTS ${PC_LIBPORTAUDIO_INCLUDEDIR} ${PC_LIBPORTAUDIO_INCLUDE_DIRS})

	find_library(LIBPORTAUDIO_LIBRARY NAMES libportaudio portaudio
		HINTS ${PC_LIBPORTAUDIO_LIBDIR} ${PC_LIBPORTAUDIO_LIBRARY_DIRS})

	set(LIBPORTAUDIO_VERSION ${PC_LIBPORTAUDIO_VERSION})
endif()

set(LIBPORTAUDIO_LIBRARIES ${LIBPORTAUDIO_LIBRARY})
set(LIBPORTAUDIO_INCLUDE_DIRS ${LIBPORTAUDIO_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBPORTAUDIO_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(LIBPORTAUDIO
	REQUIRED_VARS LIBPORTAUDIO_LIBRARIES LIBPORTAUDIO_INCLUDE_DIRS
	VERSION_VAR LIBPORTAUDIO_VERSION)

mark_as_advanced(LIBPORTAUDIO_INCLUDE_DIRS LIBPORTAUDIO_LIBRARIES)
