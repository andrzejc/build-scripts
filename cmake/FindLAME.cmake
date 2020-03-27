include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_lame)
    set(LAME_CANDIDATES mp3lame)
    if(MSVC)
        list(APPEND LAME_CANDIDATES )
        if(NOT DEFINED LAME_ROOT AND NOT DEFINED ENV{LAME_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            if(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64")
                set(pattern "*-x86-64")
            elseif(CMAKE_SYSTEM_PROCESSOR MATCHES ".*86")
                set(pattern "*-x86")
            endif()
            # list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/mp3lame")
        endif()
    endif()

    find_path(LAME_INCLUDE_DIR
        NAMES lame/lame.h
        DOC "Directory of lame/lame.h header"
    )
    find_library(LAME_LIBRARY
        NAMES ${LAME_CANDIDATES}
        HINTS "${PC_LAME_LIBDIR}"
        DOC "Path of libmp3lame file"
    )
    mark_as_advanced(LAME_INCLUDE_DIR LAME_LIBRARY)
    set(LAME_VERSION_ARG)
    if(PC_LAME_VERSION)
        set(LAME_VERSION_ARG VERSION_VAR PC_LAME_VERSION)
    endif()

    find_package_handle_standard_args(LAME
        REQUIRED_VARS LAME_LIBRARY LAME_INCLUDE_DIR
        ${LAME_VERSION_ARG}
    )

    if(LAME_FOUND)
        set(LAME_FOUND "${LAME_FOUND}" PARENT_SCOPE)
        set(LAME_INCLUDE_DIRS "${LAME_INCLUDE_DIR}" PARENT_SCOPE)
        set(LAME_LIBRARIES "${LAME_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET LAME::libmp3lame)
            add_library(LAME::libmp3lame UNKNOWN IMPORTED)
            set_target_properties(LAME::libmp3lame PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${LAME_INCLUDE_DIR}"
                IMPORTED_LOCATION "${LAME_LIBRARY}"
            )
            if(WIN32)
                include("${CMAKE_CURRENT_LIST_DIR}/GetSidecarDllDirectory.cmake")
                setup_library_dll_directory(LAME::libmp3lame)
            endif()
        endif()
        if(DEFINED LAME_VERSION)
            set(LAME_VERSION "${LAME_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_lame()
