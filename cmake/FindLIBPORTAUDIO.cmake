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
	set(LIBPORTAUDIO_ROOT $ENV{LIBPORTAUDIO_ROOT} CACHE
		PATH "Installation folder of portaudio")

	if (CMAKE_CL_64)
		set(_subdirs ${LIBPORTAUDIO_ROOT}/x64 ${LIBPORTAUDIO_ROOT}/x64/lib
			${LIBPORTAUDIO_ROOT}/lib/x64 ${LIBPORTAUDIO_ROOT}/lib64
			${LIBPORTAUDIO_ROOT}/lib ${LIBPORTAUDIO_ROOT})
	else ()
		set(_subdirs ${LIBPORTAUDIO_ROOT}/x86 ${LIBPORTAUDIO_ROOT}/x86/lib
			${LIBPORTAUDIO_ROOT}/lib/x86 ${LIBPORTAUDIO_ROOT}/lib32
			${LIBPORTAUDIO_ROOT}/lib ${LIBPORTAUDIO_ROOT})
	endif()

#	message("LIBPORTAUDIO_DIR: ${LIBPORTAUDIO_DIR}")

	find_library(LIBPORTAUDIO_LIBRARY
		NAMES ${LIBPORTAUDIO_SEARCH_LIBS}
		PATHS ${_subdirs})

#	message("LIBPORTAUDIO_LIBRARY: ${LIBPORTAUDIO_LIBRARY}")

	find_path(LIBPORTAUDIO_INCLUDE_DIR ${LIBPORTAUDIO_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include portaudio include/portaudio)

#	message("LIBPORTAUDIO_INCLUDE_DIR: ${LIBPORTAUDIO_LIBRARY}")

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_LIBPORTAUDIO QUIET portaudio)
	set(LIBPORTAUDIO_DEFINITIONS ${PC_LIBPORTAUDIO_CFLAGS_OTHER})

	find_path(LIBPORTAUDIO_INCLUDE_DIR portaudio.h
		HINTS ${PC_LIBPORTAUDIO_INCLUDEDIR} ${PC_LIBPORTAUDIO_INCLUDE_DIRS}
		PATH_SUFFIXES portaudio)

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
	DEFAULT_MSG
	REQUIRED_VARS LIBPORTAUDIO_LIBRARIES LIBPORTAUDIO_INCLUDE_DIRS
	VERSION_VAR LIBPORTAUDIO_VERSION)

mark_as_advanced(LIBPORTAUDIO_INCLUDE_DIRS LIBPORTAUDIO_LIBRARIES)
