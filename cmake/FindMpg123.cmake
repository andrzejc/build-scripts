include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_mpg123)
    set(Mpg123_CANDIDATES mpg123 libmpg123)
    set(paths_and_hints)
    if(MSVC)
        list(APPEND Mpg123_CANDIDATES libmpg123-0)
        if(NOT DEFINED Mpg123_ROOT AND NOT DEFINED ENV{Mpg123_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            if(CMAKE_GENERATOR_PLATFORM MATCHES ".*64")
                set(pattern "mpg123-*-x86-64")
            elseif(CMAKE_GENERATOR_PLATFORM MATCHES ".*32")
                set(pattern "mpg123-*-x86")
            endif()
            message(STATUS "pattern: ${pattern}")
            message(STATUS "CMAKE_GENERATOR_PLATFORM: ${CMAKE_GENERATOR_PLATFORM}")
            file(GLOB match RELATIVE "${program_files}" "${program_files}/${pattern}")
            message(STATUS "mpg123 match: ${match}")
            if(match)
                set(paths_and_hints PATHS "${program_files}/${match}")
                if(match MATCHES "^mpg123-(.*)-x86(-64)?$")
                    set(PC_Mpg123_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
        endif()
    else()
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_Mpg123 QUIET libmpg123)
    endif()

    find_path(Mpg123_INCLUDE_DIR
        NAMES mpg123.h
        HINTS "${PC_Mpg123_INCLUDEDIR}"
        ${paths_and_hints}
        DOC "Directory of libmpg123 headers"
    )
    find_library(Mpg123_LIBRARY
        NAMES ${Mpg123_CANDIDATES}
        HINTS "${PC_Mpg123_LIBDIR}"
        ${paths_and_hints}
        DOC "Path of libmpg123 library file"
    )
    mark_as_advanced(Mpg123_INCLUDE_DIR Mpg123_LIBRARY)
    set(Mpg123_VERSION_ARG)
    if(PC_Mpg123_VERSION)
        set(Mpg123_VERSION_ARG VERSION_VAR PC_Mpg123_VERSION)
    endif()

    find_package_handle_standard_args(Mpg123
        REQUIRED_VARS Mpg123_LIBRARY Mpg123_INCLUDE_DIR
        ${Mpg123_VERSION_ARG}
    )

    if(Mpg123_FOUND)
        set(Mpg123_FOUND "${Mpg123_FOUND}" PARENT_SCOPE)
        set(MPG123_FOUND "${Mpg123_FOUND}" PARENT_SCOPE)
        set(Mpg123_INCLUDE_DIRS "${Mpg123_INCLUDE_DIR}" PARENT_SCOPE)
        set(Mpg123_LIBRARIES "${Mpg123_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET Mpg123::libmpg123)
            add_library(Mpg123::libmpg123 UNKNOWN IMPORTED)
            set_target_properties(Mpg123::libmpg123 PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Mpg123_INCLUDE_DIR}"
                IMPORTED_LOCATION "${Mpg123_LIBRARY}"
            )
            if(WIN32)
                include("${CMAKE_CURRENT_LIST_DIR}/GetSidecarDllDirectory.cmake")
                setup_library_dll_directory(Mpg123::libmpg123)
            endif()
        endif()
        if(DEFINED Mpg123_VERSION)
            set(Mpg123_VERSION "${Mpg123_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_mpg123()
