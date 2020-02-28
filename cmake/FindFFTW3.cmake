include(FindPackageHandleStandardArgs)
include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/GetSidecarDllDirectory.cmake")

if(NOT DEFINED FFTW3_USE_THREAD_LIBS)
    set(FFTW3_USE_THREAD_LIBS ON)
endif()

function(_find_fftw3_include_dir)
    set(paths_and_hints)
    if(MSVC)
        if(NOT DEFINED FFTW3_ROOT AND NOT DEFINED ENV{FFTW3_ROOT})
            get_windows_program_files_dir(program_files)
            # This will cause ./include to be searched
            list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/FFTW3")
            # This will search ./ dir too
            set(paths_and_hints PATHS "${program_files}/FFTW3")
        elseif(DEFINED FFTW3_ROOT)
            set(paths_and_hints HINTS "${FFTW3_ROOT}")
        else()
            file(TO_CMAKE_PATH "$ENV{FFTW3_ROOT}" root)
            set(paths_and_hints HINTS "${root}")
        endif()
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64")
            list(APPEND paths_and_hints PATH_SUFFIXES x64 Win64 x64/include Win64/include)
        elseif(CMAKE_SYSTEM_PROCESSOR MATCHES ".*86")
            list(APPEND paths_and_hints PATH_SUFFIXES x86 Win32 x86/include Win32/include)
        endif()
    endif()

    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_FFTW3 QUIET fftw3)

    find_path(FFTW3_INCLUDE_DIR
        NAMES fftw3.h
        HINTS "${PC_FFTW3_INCLUDEDIR}"
        ${paths_and_hints}
        DOC "Directory of fftw3 headers"
    )
    mark_as_advanced(FFTW3_INCLUDE_DIR)
endfunction()

_find_fftw3_include_dir()

function(_find_fftw3_library variant)
    set(paths_and_hints)
    set(candidates "fftw3${variant}" "libfftw3${variant}")
    if(MSVC)
        # Prebuilt binaries from fftw.org have minor version number embedded
        # in library name, try searching for them relative to FFTW3_INCLUDE_DIR or FFTW3_ROOT vars,
        # so that we can setup library name for find_library properly
        if(NOT FFTW3_INCLUDE_DIR)
            return()
        endif()
        set(root "${FFTW3_INCLUDE_DIR}")
        get_filename_component(last_component "${root}" NAME)
        string(TOLOWER "${last_component}" last_component)
        if(last_component MATCHES "include")
            get_filename_component(root "${root}" DIRECTORY)
        endif()
        set(paths_and_hints PATHS "${root}")

        file(GLOB_RECURSE matches RELATIVE "${root}" "${root}/*fftw3${variant}*${CMAKE_IMPORT_LIBRARY_SUFFIX}")
        foreach(match IN LISTS matches)
            get_filename_component(match "${match}" NAME)
            if(match MATCHES "^(lib)?fftw3${variant}-([0-9]+)")
                list(INSERT candidates 0
                    "fftw3${variant}-${CMAKE_MATCH_2}"
                    "libfftw3${variant}-${CMAKE_MATCH_2}"
                )
                set(FFTW3_VERSION "3.${CMAKE_MATCH_2}" PARENT_SCOPE)
                break()
            endif()
        endforeach(match)

        if(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64")
            list(APPEND paths_and_hints PATH_SUFFIXES x64 Win64 x64/lib Win64/lib)
        elseif(CMAKE_SYSTEM_PROCESSOR MATCHES ".*86")
            list(APPEND paths_and_hints PATH_SUFFIXES x86 Win32 x86/lib Win32/lib)
        endif()
    endif()

    find_package(PkgConfig QUIET)
    pkg_check_modules("PC_FFTW3${variant}" QUIET "fftw3${variant}")

    find_library("FFTW3_libfftw3${variant}_LIBRARY"
        NAMES ${candidates}
        HINTS "${PC_FFTW3${variant}_LIBDIR}"
        ${paths_and_hints}
        DOC "Path of fftw3${variant} library file"
    )
    mark_as_advanced("FFTW3_libfftw3${variant}_LIBRARY")

    if(FFTW3_USE_THREAD_LIBS)
        set(thread_cands)
        foreach(cand IN LISTS candidates)
            list(APPEND thread_cands "${cand}_threads")
        endforeach()
        find_library("FFTW3_libfftw3${variant}_threads_LIBRARY"
            NAMES ${thread_cands}
            HINTS "${PC_FFTW3${variant}_LIBDIR}"
            ${paths_and_hints}
            DOC "Path of fftw3${variant}_threads library file"
        )
        mark_as_advanced("FFTW3_libfftw3${variant}_threads_LIBRARY")
    endif()
endfunction()

if(NOT FFTW3_FIND_COMPONENTS)
    set(FFTW3_FIND_COMPONENTS libfftw3)
    set(FFTW3_FIND_REQUIRED_libfftw3 TRUE)
endif()

set(FFTW3_LIBRARIES)
foreach(comp IN LISTS FFTW3_FIND_COMPONENTS)
    set("FFTW3_${comp}_FOUND" FALSE)
    if(NOT comp MATCHES "^libfftw3([flq]?)$")
        message(FATAL_ERROR "FFTW3: Unknown component ${comp}")
    endif()
    _find_fftw3_library("${CMAKE_MATCH_1}")
    if(FFTW3_${comp}_LIBRARY)
        set("FFTW3_${comp}_FOUND" TRUE)
        list(APPEND FFTW3_LIBRARIES "${FFTW3_${comp}_LIBRARY}")
        if(FFTW3_libfftw3${variant}_threads_LIBRARY)
            list(APPEND FFTW3_LIBRARIES "${FFTW3_libfftw3${variant}_threads_LIBRARY}")
        endif()
    endif()
endforeach(comp)

if(PC_FFTW3_VERSION)
    set(FFTW3_VERSION "${PC_FFTW3_VERSION}")
endif()
set(_FFTW3_VERSION_VARS)
if(DEFINED FFTW3_VERSION)
    set(_FFTW3_VERSION_VARS VERSION_VAR FFTW3_VERSION)
endif()

find_package_handle_standard_args(FFTW3
    REQUIRED_VARS FFTW3_LIBRARIES FFTW3_INCLUDE_DIR
    ${_FFTW3_VERSION_VARS}
    HANDLE_COMPONENTS
)

if(FFTW3_FOUND)
    set(FFTW3_INCLUDE_DIRS "${FFTW3_INCLUDE_DIR}")
    foreach(comp IN LISTS FFTW3_FIND_COMPONENTS)
        if(NOT TARGET "FFTW3::${comp}")
            add_library("FFTW3::${comp}" UNKNOWN IMPORTED)
            set_target_properties("FFTW3::${comp}" PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}"
                IMPORTED_LOCATION "${FFTW3_${comp}_LIBRARY}"
            )
            setup_library_dll_directory("FFTW3::${comp}")
        endif()
        if(NOT TARGET "FFTW3::${comp}_threads" AND FFTW3_libfftw3${comp}_threads_LIBRARY)
            add_library("FFTW3::${comp}_threads" UNKNOWN IMPORTED)
            set_target_properties("FFTW3::${comp}_threads" PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}"
                IMPORTED_LOCATION "${FFTW3_libfftw3${comp}_threads_LIBRARY}"
            )
            setup_library_dll_directory("FFTW3::${comp}_threads")
            set_property(TARGET "FFTW3::${comp}" APPEND PROPERTY
                INTERFACE_LINK_LIBRARIES "FFTW3::${comp}_threads"
            )
        endif()
    endforeach()
endif()
