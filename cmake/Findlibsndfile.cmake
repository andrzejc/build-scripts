# - Try to find libsndfile
# Once done this will define
#  libsndfile_FOUND - System has libsndfile
#  libsndfile_INCLUDE_DIRS - The libsndfile include directories
#  libsndfile_LIBRARIES - The libraries needed to use libsndfile
#  libsndfile_DEFINITIONS - Compiler switches required for using libsndfile

set(libsndfile_SEARCH_LIBS libsndfile sndfile libsndfile-1 sndfile-1
	libsndfile1 sndfile1)
set(libsndfile_SEARCH_HEADERS sndfile.h)

if (MSVC)
	if(NOT DEFINED libsndfile_DIR)
		if(DEFINED LIBSNDFILE_ROOT)
			set(libsndfile_DIR ${LIBSNDFILE_ROOT})
		elseif(DEFINED ENV{LIBSNDFILE_ROOT})
			set(libsndfile_DIR $ENV{LIBSNDFILE_ROOT})
		else()
			set(libsndfile_DIR "libsndfile_DIR-NOTFOUND")
		endif()
	endif()
	set(libsndfile_DIR "${libsndfile_DIR}" CACHE
		PATH "Installation folder of libsndfile")

	if (CMAKE_CL_64)
		set(_subdirs ${libsndfile_DIR}/x64 ${libsndfile_DIR}/x64/lib
			${libsndfile_DIR}/lib/x64 ${libsndfile_DIR}/lib64
			${libsndfile_DIR}/lib ${libsndfile_DIR})
	else ()
		set(_subdirs ${libsndfile_DIR}/x86 ${libsndfile_DIR}/x86/lib
			${libsndfile_DIR}/lib/x86 ${libsndfile_DIR}/lib32
			${libsndfile_DIR}/lib ${libsndfile_DIR})
	endif()

	find_library(libsndfile_LIBRARY
		NAMES ${libsndfile_SEARCH_LIBS}
		PATHS ${_subdirs})

	find_path(libsndfile_INCLUDE_DIR ${libsndfile_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include)

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_libsndfile QUIET sndfile)
	set(libsndfile_DEFINITIONS ${PC_libsndfile_CFLAGS_OTHER})

	find_library(libsndfile_LIBRARY
		NAMES ${PC_libsndfile_LIBRARIES} ${libsndfile_SEARCH_LIBS}
		HINTS ${PC_libsndfile_LIBDIR} ${PC_libsndfile_LIBRARY_DIRS})

	find_path(libsndfile_INCLUDE_DIR ${libsndfile_SEARCH_HEADERS}
		HINTS ${PC_libsndfile_INCLUDEDIR} ${PC_libsndfile_INCLUDE_DIRS})

	set(libsndfile_VERSION ${PC_libsndfile_VERSION})
endif()

set(libsndfile_LIBRARIES ${libsndfile_LIBRARY})
set(libsndfile_INCLUDE_DIRS ${libsndfile_INCLUDE_DIR})


include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set libsndfile_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(libsndfile
	REQUIRED_VARS libsndfile_LIBRARIES libsndfile_INCLUDE_DIRS
	VERSION_VAR libsndfile_VERSION)

mark_as_advanced(libsndfile_INCLUDE_DIRS libsndfile_LIBRARIES)
