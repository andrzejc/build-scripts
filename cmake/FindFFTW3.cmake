# - Try to find FFTW3 libraries
# Once done this will define
#  FFTW3_FOUND - System has libsndfile
#  FFTW3_INCLUDE_DIRS - The libsndfile include directories
#  FFTW3_LIBRARIES - The libraries needed to use libsndfile
#  FFTW3_DEFINITIONS - Compiler switches required for using libsndfile

if (MSVC)
    if(NOT DEFINED FFTW3_DIR)
        if(DEFINED FFTW3_ROOT)
            set(FFTW3_DIR ${FFTW3_ROOT})
        elseif(DEFINED ENV{FFTW3_ROOT})
            set(FFTW3_DIR $ENV{FFTW3_ROOT})
        else()
            set(FFTW3_DIR "FFTW3_DIR-NOTFOUND")
        endif()
    endif()
    set(FFTW3_DIR "${FFTW3_DIR}" CACHE PATH "Installation folder of FFTW3")

    # Parse import library name to get FFTW3 minor version number
    foreach(_subdir x64 x86 x64/lib x86/lib lib/x64 lib/x86 lib32 lib64 lib "")
        file(GLOB _matches
            "${FFTW3_DIR}/${_subdir}/*${CMAKE_IMPORT_LIBRARY_SUFFIX}")
        foreach(_match ${_matches})
            get_filename_component(_name ${_match} NAME_WE)
            if(${_name} MATCHES "^(lib)?fftw3[flq]?-([0-9]+)")
                set(FFTW3_VERSION_MINOR ${CMAKE_MATCH_2})
                break()
            endif()
        endforeach()
        if(NOT "${FFTW3_VERSION_MINOR}" STREQUAL "")
            break()
        endif()
    endforeach()

    if (CMAKE_CL_64)
        set(_subdirs ${FFTW3_DIR}/x64 ${FFTW3_DIR}/x64/lib
            ${FFTW3_DIR}/lib/x64 ${FFTW3_DIR}/lib64 ${FFTW3_DIR}/lib
            ${FFTW3_DIR})
    else ()
        set(_subdirs ${FFTW3_DIR}/x86 ${FFTW3_DIR}/x86/lib
            ${FFTW3_DIR}/lib/x86 ${FFTW3_DIR}/lib32 ${FFTW3_DIR}/lib
            ${FFTW3_DIR})
    endif()

    macro(_fftw3_lib _SUFFIXV _SUFFIXF)
        find_library("FFTW3${_SUFFIXV}_LIBRARY"
                NAMES
                    "libfftw3${_SUFFIXF}-${FFTW3_VERSION_MINOR}"
                    "fftw3${_SUFFIXF}-${FFTW3_VERSION_MINOR}"
                PATHS ${_subdirs})
        # message(STATUS "FFTW3${_SUFFIXV}_LIBRARY: ${FFTW3${_SUFFIXV}_LIBRARY}")
        if (FFTW3${_SUFFIXV}_LIBRARY)
            list(APPEND FFTW3_LIBRARIES "${FFTW3${_SUFFIXV}_LIBRARY}")
            # message(STATUS "FFTW3_LIBRARIES: ${FFTW3_LIBRARIES}")
        endif()
    endmacro()

    _fftw3_lib(D "")
    _fftw3_lib(F f)
    _fftw3_lib(L l)
    _fftw3_lib(Q q)

    find_path(FFTW3_INCLUDE_DIR fftw3.h
        PATHS ${_subdirs}
        PATH_SUFFIXES include)

    set(FFTW3_VERSION "3.${FFTW3_VERSION_MINOR}")
else ()
    set(FFT3_DEFINITIONS "")
    find_package(PkgConfig)

    macro(_fftw3_lib _SUFFIXV _SUFFIXF)
        set(_stem "FFTW3${_SUFFIXV}")
        set(_threads_library "${_stem}_THREADS_LIBRARY")
        set(_library "${_stem}_LIBRARY")
        set(_fstem "fftw3${_SUFFIXF}")

        if(PkgConfig_FOUND)
            pkg_check_modules("PC_${_stem}" QUIET ${_fstem})
        endif()

        find_library(${_library}
            NAMES
                "${_fstem}"
                "lib${_fstem}"
            HINTS "${PC_${_stem}_LIBRARY_DIRS}")

        if(${_library})
#            message(STATUS "found: ${${_library}}")
            list(APPEND FFTW3_LIBRARIES "${${_library}}")

            find_library(${_threads_library}
                NAMES
                    "${_fstem}_threads"
                    "lib${_fstem}_threads"
                HINTS "${PC_${_stem}_LIBRARY_DIRS}")

            if(${_threads_library})
#                message(STATUS "found: ${${_threads_library}}")
                list(APPEND FFTW3_LIBRARIES "${${_threads_library}}")
            endif()

            set("${_stem}_DEFINITIONS"
                    "${PC_${_stem}_CFLAGS_OTHER}")
            list(APPEND FFTW3_DEFINITIONS "${${_stem}_DEFINITIONS}")
        endif()
    endmacro()

    #    if(FFTW3_FIND_COMPONENTS)
    #        foreach(_comp ${FFTW3_FIND_COMPONENTS})
    #            if(_comp STREQUAL "fftw3")
    #                _fftw3_lib(D "")

    _fftw3_lib(D "")
    _fftw3_lib(F f)
    _fftw3_lib(L l)
    _fftw3_lib(Q q)

    find_path(FFTW3_INCLUDE_DIR fftw3.h
        HINTS
            ${PC_FFTW3F_INCLUDE_DIRS}
            ${PC_FFTW3D_INCLUDE_DIRS}
            ${PC_FFTW3L_INCLUDE_DIRS}
            ${PC_FFTW3Q_INCLUDE_DIRS})

    list(REMOVE_DUPLICATES FFTW3_DEFINITIONS)
    set(FFTW3_VERSION ${PC_FFTW3D_VERSION})
endif()

if(NOT FFTW3_LIBRARIES)
    set(FFTW3_LIBRARIES "FFTW3_LIBRARIES-NOTFOUND")
endif()

set(FFTW3_INCLUDE_DIRS ${FFTW3_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FFTW3
    REQUIRED_VARS FFTW3_LIBRARIES FFTW3_INCLUDE_DIRS
    VERSION_VAR FFTW3_VERSION)

mark_as_advanced(FFTW3_INCLUDE_DIRS FFTW3_LIBRARIES
    FFTW3F_LIBRARY FFTW3F_THREADS_LIBRARY
    FFTW3D_LIBRARY FFTW3D_THREADS_LIBRARY
    FFTW3L_LIBRARY FFTW3L_THREADS_LIBRARY
    FFTW3Q_LIBRARY FFTW3Q_THREADS_LIBRARY
    FFTW3_INCLUDE_DIR)

if(FFTW3_FOUND AND NOT TARGET fftw3)
    macro(_fftw3_component_target _SUFFIXV _SUFFIXF)
        set(_stem "FFTW3${_SUFFIXV}")
        set(_threads_library "${_stem}_THREADS_LIBRARY")
        set(_library "${_stem}_LIBRARY")
        set(_fstem "fftw3${_SUFFIXF}")
#        message(STATUS "_fftw3_component_target ${_SUFFIX}")
        if(${_library})
            add_library(${_fstem} UNKNOWN IMPORTED)
#            message(STATUS "add_library(${_fstem})")
            set_target_properties(${_fstem} PROPERTIES
                    IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                    IMPORTED_LOCATION "${${_library}}"
                    INTERFACE_COMPILE_OPTIONS "${${_stem}_DEFINITIONS}"
                    INTERFACE_INCLUDE_DIRECTORIES ${FFTW3_INCLUDE_DIR})
#            message(STATUS "IMPORTED_LOCATION ${${_library}}")
#            message(STATUS "INTERFACE_INCLUDE_DIRECTORIES ${FFTW3_INCLUDE_DIR}")
            if(${_threads_library})
                add_library("${_fstem}_threads" UNKNOWN IMPORTED)
#                message(STATUS "add_library(${_fstem}_threads)")
                set_target_properties("${_fstem}_threads" PROPERTIES
                        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                        IMPORTED_LOCATION "${${_threads_library}}")
#                message(STATUS "IMPORTED_LOCATION ${${_threads_library}}")
                set_target_properties(${_fstem} PROPERTIES
                        INTERFACE_LINK_LIBRARIES "${_fstem}_threads")
            endif()
        endif()
    endmacro()

    _fftw3_component_target(D "")
    _fftw3_component_target(F f)
    _fftw3_component_target(L l)
    _fftw3_component_target(Q q)
endif()
