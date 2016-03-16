# - Try to find libsndfile
# Once done this will define
#  LIBSNDFILE_FOUND - System has libsndfile
#  LIBSNDFILE_INCLUDE_DIRS - The libsndfile include directories
#  LIBSNDFILE_LIBRARIES - The libraries needed to use libsndfile
#  LIBSNDFILE_DEFINITIONS - Compiler switches required for using libsndfile

set(LIBSNDFILE_SEARCH_LIBS libsndfile sndfile libsndfile-1 sndfile-1
	libsndfile1 sndfile1)
set(LIBSNDFILE_SEARCH_HEADERS sndfile.h)

if (MSVC)
	set(LIBSNDFILE_ROOT $ENV{LIBSNDFILE_ROOT} CACHE
		PATH "Installation folder of libsndfile")

	if (CMAKE_CL_64)
		set(_subdirs ${LIBSNDFILE_ROOT}/x64 ${LIBSNDFILE_ROOT}/x64/lib
			${LIBSNDFILE_ROOT}/lib/x64 ${LIBSNDFILE_ROOT}/lib64
			${LIBSNDFILE_ROOT}/lib ${LIBSNDFILE_ROOT})
	else ()
		set(_subdirs ${LIBSNDFILE_ROOT}/x86 ${LIBSNDFILE_ROOT}/x86/lib
			${LIBSNDFILE_ROOT}/lib/x86 ${LIBSNDFILE_ROOT}/lib32
			${LIBSNDFILE_ROOT}/lib ${LIBSNDFILE_ROOT})
	endif()

	find_library(LIBSNDFILE_LIBRARY
		NAMES ${LIBSNDFILE_SEARCH_LIBS}
		PATHS ${_subdirs})

	find_path(LIBSNDFILE_INCLUDE_DIR ${LIBSNDFILE_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include sndfile include/sndfile)

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_LIBSNDFILE QUIET sndfile)
	set(LIBSNDFILE_DEFINITIONS ${PC_LIBSNDFILE_CFLAGS_OTHER})

	find_library(LIBSNDFILE_LIBRARY
		NAMES PL_LIBSNDFILE_LIBRARIES ${LIBSNDFILE_SEARCH_LIBS}
		HINTS ${PC_LIBSNDFILE_LIBDIR} ${PC_LIBSNDFILE_LIBRARY_DIRS})

	find_path(LIBSNDFILE_INCLUDE_DIR ${LIBSNDFILE_SEARCH_HEADERS}
		HINTS ${PC_LIBSNDFILE_INCLUDEDIR} ${PC_LIBSNDFILE_INCLUDE_DIRS}
		PATH_SUFFIXES sndfile)

	set(LIBSNDFILE_VERSION ${PC_LIBSNDFILE_VERSION})
endif()

set(LIBSNDFILE_LIBRARIES ${LIBSNDFILE_LIBRARY})
set(LIBSNDFILE_INCLUDE_DIRS ${LIBSNDFILE_INCLUDE_DIR})


include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBSNDFILE_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(LIBSNDFILE  DEFAULT_MSG
                                  LIBSNDFILE_LIBRARIES LIBSNDFILE_INCLUDE_DIRS
                                  VERSION_VAR LIBSNDFILE_VERSION)

mark_as_advanced(LIBSNDFILE_INCLUDE_DIRS LIBSNDFILE_LIBRARIES)
