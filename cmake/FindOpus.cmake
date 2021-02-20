include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_opus)
    set(Opus_CANDIDATES opus libopus)
    if(MSVC)
        if(NOT DEFINED Opus_ROOT AND NOT DEFINED ENV{Opus_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            set(pattern "opus-*")
            file(GLOB match RELATIVE "${program_files}" "${program_files}/${pattern}")
            if(match)
                list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/${match}")
                if(match MATCHES "^opus-(.*)$")
                    set(PC_Opus_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
        endif()
    else()
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_Opus QUIET opus)
    endif()

    find_path(Opus_INCLUDE_DIR
        NAMES opus/opus.h
        HINTS "${PC_Opus_INCLUDEDIR}"
        DOC "Directory of libopus headers"
    )
    find_library(Opus_LIBRARY
        NAMES ${Opus_CANDIDATES}
        HINTS "${PC_Opus_LIBDIR}"
        DOC "Path of libopus library file"
    )
    mark_as_advanced(Opus_INCLUDE_DIR Opus_LIBRARY)
    set(Opus_VERSION_ARG)
    if(PC_Opus_VERSION)
        set(Opus_VERSION_ARG VERSION_VAR PC_Opus_VERSION)
    endif()

    find_package_handle_standard_args(Opus
        REQUIRED_VARS Opus_LIBRARY Opus_INCLUDE_DIR
        ${Opus_VERSION_ARG}
    )

    if(Opus_FOUND)
        set(Opus_FOUND "${Opus_FOUND}" PARENT_SCOPE)
        set(Opus_INCLUDE_DIRS "${Opus_INCLUDE_DIR}" PARENT_SCOPE)
        set(Opus_LIBRARIES "${Opus_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET Opus::libopus)
            include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
            add_imported_library(Opus::libopus "${Opus_LIBRARY}")
            set_target_properties(Opus::libopus PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Opus_INCLUDE_DIR}"
            )
        endif()
        if(DEFINED Opus_VERSION)
            set(Opus_VERSION "${Opus_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_opus()
