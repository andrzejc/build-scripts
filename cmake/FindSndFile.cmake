# - Try to find libsndfile
# Once done this will define
#  SndFile_FOUND - System has libsndfile
#  SndFile_INCLUDE_DIRS - The libsndfile include directories
#  SndFile_LIBRARIES - The libraries needed to use libsndfile
#  SndFile_DEFINITIONS - Compiler switches required for using libsndfile

set(SndFile_SEARCH_LIBS libsndfile sndfile libsndfile-1 sndfile-1
	libsndfile1 sndfile1)
set(SndFile_SEARCH_HEADERS sndfile.h)

if (MSVC)
	if(NOT DEFINED SndFile_DIR)
		if(DEFINED SndFile_ROOT)
			set(SndFile_DIR ${SndFile_ROOT})
		elseif(DEFINED ENV{LIBSNDFILE_ROOT})
			set(SndFile_DIR $ENV{LIBSNDFILE_ROOT})
		else()
			set(SndFile_DIR "SndFile_DIR-NOTFOUND")
		endif()
	endif()
	set(SndFile_DIR "${SndFile_DIR}" CACHE
		PATH "Installation folder of libsndfile")

	if (CMAKE_CL_64)
		set(_subdirs ${SndFile_DIR}/x64 ${SndFile_DIR}/x64/lib
			${SndFile_DIR}/lib/x64 ${SndFile_DIR}/lib64
			${SndFile_DIR}/lib ${SndFile_DIR})
	else ()
		set(_subdirs ${SndFile_DIR}/x86 ${SndFile_DIR}/x86/lib
			${SndFile_DIR}/lib/x86 ${SndFile_DIR}/lib32
			${SndFile_DIR}/lib ${SndFile_DIR})
	endif()

	find_library(SndFile_LIBRARY
		NAMES ${SndFile_SEARCH_LIBS}
		PATHS ${_subdirs})

	find_path(SndFile_INCLUDE_DIR ${SndFile_SEARCH_HEADERS}
		PATHS ${_subdirs}
		PATH_SUFFIXES include)

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_SndFile QUIET sndfile)
	set(SndFile_DEFINITIONS ${PC_SndFile_CFLAGS_OTHER})

	find_library(SndFile_LIBRARY
		NAMES ${PC_SndFile_LIBRARIES} ${SndFile_SEARCH_LIBS}
		HINTS ${PC_SndFile_LIBDIR} ${PC_SndFile_LIBRARY_DIRS})

	find_path(SndFile_INCLUDE_DIR ${SndFile_SEARCH_HEADERS}
		HINTS ${PC_SndFile_INCLUDEDIR} ${PC_SndFile_INCLUDE_DIRS})

	set(SndFile_VERSION ${PC_SndFile_VERSION})
endif()

set(SndFile_LIBRARIES ${SndFile_LIBRARY})
set(SndFile_INCLUDE_DIRS ${SndFile_INCLUDE_DIR})


include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set SndFile_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(SndFile
	REQUIRED_VARS SndFile_LIBRARIES SndFile_INCLUDE_DIRS
	VERSION_VAR SndFile_VERSION)

mark_as_advanced(SndFile_INCLUDE_DIRS SndFile_LIBRARIES
	SndFile_LIBRARY SndFile_INCLUDE_DIR)

if(SndFile_FOUND AND NOT TARGET sndfile)
	add_library(sndfile UNKNOWN IMPORTED)
	set_target_properties(sndfile PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${SndFile_INCLUDE_DIR}"
			INTERFACE_COMPILE_OPTIONS "${SndFile_DEFINITIONS}"
			IMPORTED_LINK_INTERFACE_LANGUAGES "C"
			IMPORTED_LOCATION "${SndFile_LIBRARY}")
endif()
