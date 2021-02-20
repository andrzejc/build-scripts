include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_flac)
    set(FLAC_CANDIDATES FLAC libFLAC)
    if(MSVC)
        if(NOT DEFINED FLAC_ROOT AND NOT DEFINED ENV{FLAC_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            file(GLOB match RELATIVE "${program_files}" "${program_files}/flac-*")
            if(match)
                list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/${match}")
                if(match MATCHES "^flac-(.*)$")
                    set(PC_FLAC_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
        endif()
    else()
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_FLAC QUIET flac)
    endif()

    find_path(FLAC_INCLUDE_DIR
        NAMES FLAC/all.h
        HINTS "${PC_FLAC_INCLUDEDIR}"
        DOC "Directory of FLAC/all.h header"
    )
    find_library(FLAC_LIBRARY
        NAMES ${FLAC_CANDIDATES}
        HINTS "${PC_FLAC_LIBDIR}"
        DOC "Path of libFLAC file"
    )
    mark_as_advanced(FLAC_INCLUDE_DIR FLAC_LIBRARY)
    set(FLAC_VERSION_ARG)
    if(PC_FLAC_VERSION)
        set(FLAC_VERSION_ARG VERSION_VAR PC_FLAC_VERSION)
    endif()

    # if(FLAC_LIBRARY AND FLAC_INCLUDE_DIR AND NOT PC_FLAC_VERSION AND NOT CMAKE_CROSSCOMPILING)
    #     project(_FindFLAC_get_flac_version C)
    #     try_run(run_res compile_ok
    #         "${CMAKE_CURRENT_BINARY_DIR}/FindFLAC"
    #         "${CMAKE_CURRENT_LIST_DIR}/get_flac_version.c"
    #         CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${FLAC_INCLUDE_DIR}"
    #         LINK_LIBRARIES "${FLAC_LIBRARY}"
    #         COMPILE_OUTPUT_VARIABLE compile_out
    #         RUN_OUTPUT_VARIABLE version_str
    #     )
    #     # message(STATUS "run_res: ${run_res}; compile_ok: ${compile_ok}; compile_out: ${compile_out}; version_str: ${version_str}")
    #     if(compile_ok AND (run_res EQUAL 0))
    #         string(STRIP "${version_str}" version_str)
    #         set(FLAC_VERSION "${version_str}")
    #         set(FLAC_VERSION_ARG VERSION_VAR FLAC_VERSION)
    #     else()
    #         message(WARNING "Failed to compile or run simple libmp3flac client")
    #     endif()
    # endif()

    find_package_handle_standard_args(FLAC
        REQUIRED_VARS FLAC_LIBRARY FLAC_INCLUDE_DIR
        ${FLAC_VERSION_ARG}
    )

    if(FLAC_FOUND)
        set(FLAC_FOUND "${FLAC_FOUND}" PARENT_SCOPE)
        set(FLAC_INCLUDE_DIRS "${FLAC_INCLUDE_DIR}" PARENT_SCOPE)
        set(FLAC_LIBRARIES "${FLAC_LIBRARY}" PARENT_SCOPE)
        if(DEFINED FLAC_VERSION)
            set(FLAC_VERSION "${FLAC_VERSIO}" PARENT_SCOPE)
        endif()
        if(NOT TARGET FLAC::libFLAC)
            include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
            add_imported_library(FLAC::libFLAC "${FLAC_LIBRARY}")
            set_target_properties(FLAC::libFLAC PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${FLAC_INCLUDE_DIR}"
            )
        endif()
        if(DEFINED FLAC_VERSION)
            set(FLAC_VERSION "${FLAC_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_flac()
