# - Try to find portaudio
# Once done this will define
#  LIBPORTAUDIO_FOUND - System has portaudio
#  LIBPORTAUDIO_INCLUDE_DIRS - The portaudio include directories
#  LIBPORTAUDIO_LIBRARIES - The libraries needed to use portaudio
#  LIBPORTAUDIO_DEFINITIONS - Compiler switches required for using portaudio

if (MSVC)
	set(LIBPORTAUDIO_ROOT $ENV{LIBPORTAUDIO_ROOT} CACHE PATH "Installation folder of portaudio")
	if (CMAKE_CL_64)
		set(LIBPORTAUDIO_DIR ${LIBPORTAUDIO_ROOT}/x64)
	else ()
		set(LIBPORTAUDIO_DIR ${LIBPORTAUDIO_ROOT}/x86)
	endif()

#	message("LIBPORTAUDIO_DIR: ${LIBPORTAUDIO_DIR}")

	find_library(LIBPORTAUDIO_LIBRARY NAMES portaudio portaudio19 portaudio2 libportaudio libportaudio19 libportaudio2
		HINTS ${LIBPORTAUDIO_DIR}/lib )

#	message("LIBPORTAUDIO_LIBRARY: ${LIBPORTAUDIO_LIBRARY}")

	find_path(LIBPORTAUDIO_INCLUDE_DIR portaudio.h
		HINTS ${LIBPORTAUDIO_DIR}/include
		PATH_SUFFIXES portaudio )

#	message("LIBPORTAUDIO_INCLUDE_DIR: ${LIBPORTAUDIO_LIBRARY}")

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_LIBPORTAUDIO QUIET portaudio)
	set(LIBPORTAUDIO_DEFINITIONS ${PC_LIBPORTAUDIO_CFLAGS_OTHER})

	find_path(LIBPORTAUDIO_INCLUDE_DIR portaudio.h
          HINTS ${PC_LIBPORTAUDIO_INCLUDEDIR} ${PC_LIBPORTAUDIO_INCLUDE_DIRS}
          PATH_SUFFIXES portaudio )

	find_library(LIBPORTAUDIO_LIBRARY NAMES libportaudio portaudio
             HINTS ${PC_LIBPORTAUDIO_LIBDIR} ${PC_LIBPORTAUDIO_LIBRARY_DIRS} )

endif()

set(LIBPORTAUDIO_LIBRARIES ${LIBPORTAUDIO_LIBRARY} )
set(LIBPORTAUDIO_INCLUDE_DIRS ${LIBPORTAUDIO_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBPORTAUDIO_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(Portaudio  DEFAULT_MSG
                                  LIBPORTAUDIO_LIBRARIES LIBPORTAUDIO_INCLUDE_DIRS)

mark_as_advanced(LIBPORTAUDIO_INCLUDE_DIRS LIBPORTAUDIO_LIBRARIES)
