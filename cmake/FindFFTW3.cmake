# - Try to find FFTW3 libraries
# Once done this will define
#  FFTW3_FOUND - System has libsndfile
#  FFTW3_INCLUDE_DIRS - The libsndfile include directories
#  FFTW3_LIBRARIES - The libraries needed to use libsndfile
#  FFTW3_DEFINITIONS - Compiler switches required for using libsndfile

if (MSVC)
	set(FFTW3_ROOT $ENV{FFTW3_ROOT} CACHE PATH "Installation folder of FFTW3")
	foreach(_subdir x64 x86 x64/lib x86/lib lib/x64 lib/x86 lib32 lib64 lib "")
#        message(status " FFTW3: Checking in ${FFTW3_ROOT}/${_subdir}")
		file(GLOB _matches
			"${FFTW3_ROOT}/${_subdir}/*${CMAKE_IMPORT_LIBRARY_SUFFIX}")
#        message(status " FFTW3: Possible matches ${_matches}")
		foreach(_match ${_matches})
			get_filename_component(_name ${_match} NAME_WE)
#            message(status " Checking file ${_name}")
			if(${_name} MATCHES "^libfftw3-([0-9]+)")
				set(FFTW3_VERSION_MINOR ${CMAKE_MATCH_1})
#                message(status " FFTW3: Found ${_name}, assuming minor version ${FFTW3_VERSION_MINOR}")
				break()
			endif()
		endforeach()
		if(NOT "${FFTW3_VERSION_MINOR}" STREQUAL "")
			break()
		endif()
	endforeach()

	if (CMAKE_CL_64)
		set(_subdirs ${FFTW3_ROOT}/x64 ${FFTW3_ROOT}/x64/lib
			${FFTW3_ROOT}/lib/x64 ${FFTW3_ROOT}/lib64 ${FFTW3_ROOT}/lib
			${FFTW3_ROOT})
	else ()
		set(_subdirs ${FFTW3_ROOT}/x86 ${FFTW3_ROOT}/x86/lib
			${FFTW3_ROOT}/lib/x86 ${FFTW3_ROOT}/lib32 ${FFTW3_ROOT}/lib
			${FFTW3_ROOT})
	endif()

	find_library(FFTW3D_LIBRARY
		NAMES "libfftw3-${FFTW3_VERSION_MINOR}"
		PATHS ${_subdirs})

	find_library(FFTW3F_LIBRARY
		NAMES "libfftw3f-${FFTW3_VERSION_MINOR}"
		PATHS ${_subdirs})

	find_library(FFTW3L_LIBRARY
		NAMES "libfftw3l-${FFTW3_VERSION_MINOR}"
		PATHS ${_subdirs})

	list(APPEND FFTW3_LIBRARY ${FFTW3F_LIBRARY}
		${FFTW3D_LIBRARY} ${FFTW3L_LIBRARY})

	find_path(FFTW3_INCLUDE_DIR fftw3.h
		PATHS ${_subdirs}
		PATH_SUFFIXES include fftw3 include/fftw3)

else ()
	find_package(PkgConfig)
	pkg_check_modules(PC_FFTW3F QUIET fftw3f)

	find_library(FFTW3F_LIBRARY
		NAMES fftw3f libfftw3f
		HINTS ${PC_FFTW3F_LIBDIR} ${PC_FFTW3F_LIBRARY_DIRS})
	find_library(FFTW3F_THREADS_LIBRARY
		NAMES fftw3f_threads libfftw3f_threads
		HINTS ${PC_FFTW3F_LIBDIR} ${PC_FFTW3F_LIBRARY_DIRS})
	if(FFTW3F_THREADS_LIBRARY)
		list(APPEND FFTW3F_LIBRARY ${FFTW3F_THREADS_LIBRARY})
	endif()
	set(FFTW3F_DEFINITIONS ${PC_FFTW3F_CFLAGS_OTHER})

	pkg_check_modules(PC_FFTW3D QUIET fftw3)
	find_library(FFTW3D_LIBRARY
		NAMES fftw3 libfftw3
		HINTS ${PC_FFTW3D_LIBDIR} ${PC_FFTW3D_LIBRARY_DIRS})
	find_library(FFTW3D_THREADS_LIBRARY
		NAMES fftw3_threads libfftw3_threads
		HINTS ${PC_FFTW3D_LIBDIR} ${PC_FFTW3D_LIBRARY_DIRS})
	if(FFTW3D_THREADS_LIBRARY)
		list(APPEND FFTW3D_LIBRARY ${FFTW3D_THREADS_LIBRARY})
	endif()
	set(FFTW3D_DEFINITIONS ${PC_FFTW3D_CFLAGS_OTHER})

	pkg_check_modules(PC_FFTW3L QUIET fftw3l)
	find_library(FFTW3L_LIBRARY
		NAMES fftw3l libfftw3l
		HINTS ${PC_FFTW3L_LIBDIR} ${PC_FFTW3L_LIBRARY_DIRS})
	find_library(FFTW3L_THREADS_LIBRARY
		NAMES fftw3l_threads libfftw3l_threads
		HINTS ${PC_FFTW3L_LIBDIR} ${PC_FFTW3L_LIBRARY_DIRS})
	if(FFTW3L_THREADS_LIBRARY)
		list(APPEND FFTW3L_LIBRARY ${FFTW3L_THREADS_LIBRARY})
	endif()
	set(FFTW3L_DEFINITIONS ${PC_FFTW3L_CFLAGS_OTHER})

	list(APPEND FFTW3_LIBRARY ${FFTW3F_LIBRARY}
		${FFTW3D_LIBRARY} ${FFTW3L_LIBRARY})

	find_path(FFTW3_INCLUDE_DIR fftw3.h
		HINTS ${PC_FFTW3F_INCLUDEDIR} ${PC_FFTW3F_INCLUDE_DIRS}
			${PC_FFTW3D_INCLUDEDIR} ${PC_FFTW3D_INCLUDE_DIRS}
			${PC_FFTW3L_INCLUDEDIR} ${PC_FFTW3L_INCLUDE_DIRS}
		PATH_SUFFIXES fftw3)

	set(FFTW3_VERSION ${PC_FFTW3D_VERSION})
endif()

set(FFTW3_LIBRARIES ${FFTW3_LIBRARY})
set(FFTW3_INCLUDE_DIRS ${FFTW3_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FFTW3
	REQUIRED_VARS FFTW3_LIBRARIES FFTW3_INCLUDE_DIRS
	VERSION_VAR FFTW3_VERSION)

mark_as_advanced(FFTW3_INCLUDE_DIRS FFTW3_LIBRARIES)
