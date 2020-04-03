include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_lame)
    set(LAME_CANDIDATES mp3lame)
    if(MSVC)
        list(APPEND LAME_CANDIDATES lame_enc)
        if(NOT DEFINED LAME_ROOT AND NOT DEFINED ENV{LAME_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            file(GLOB match RELATIVE "${program_files}" "${program_files}/lame-*")
            if(match)
                list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/${match}")
                if(match MATCHES "^lame-(.*)$")
                    set(PC_LAME_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
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

    if(LAME_LIBRARY AND LAME_INCLUDE_DIR)
        project(_FindLAME_get_lame_version C)
        try_run(run_res compile_ok
            "${CMAKE_CURRENT_BINARY_DIR}/FindLAME"
            "${CMAKE_CURRENT_LIST_DIR}/get_lame_version.c"
            CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${LAME_INCLUDE_DIR}"
            LINK_LIBRARIES "${LAME_LIBRARY}"
            COMPILE_OUTPUT_VARIABLE compile_out
            RUN_OUTPUT_VARIABLE version_str
        )
        # message(STATUS "run_res: ${run_res}; compile_ok: ${compile_ok}; compile_out: ${compile_out}; version_str: ${version_str}")
        if(compile_ok AND (run_res EQUAL 0))
            string(STRIP "${version_str}" version_str)
            set(LAME_VERSION "${version_str}")
            set(LAME_VERSION_ARG VERSION_VAR LAME_VERSION)
        else()
            message(WARNING "Failed to compile or run simple libmp3lame client")
        endif()
    endif()

    find_package_handle_standard_args(LAME
        REQUIRED_VARS LAME_LIBRARY LAME_INCLUDE_DIR
        ${LAME_VERSION_ARG}
    )

    if(LAME_FOUND)
        set(LAME_FOUND "${LAME_FOUND}" PARENT_SCOPE)
        set(LAME_INCLUDE_DIRS "${LAME_INCLUDE_DIR}" PARENT_SCOPE)
        set(LAME_LIBRARIES "${LAME_LIBRARY}" PARENT_SCOPE)
        if(DEFINED LAME_VERSION)
            set(LAME_VERSION "${LAME_VERSIO}" PARENT_SCOPE)
        endif()
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
