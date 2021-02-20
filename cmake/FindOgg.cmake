include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_ogg)
    set(Ogg_CANDIDATES ogg libogg)
    if(MSVC)
        if(NOT DEFINED Ogg_ROOT AND NOT DEFINED ENV{Ogg_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            set(pattern "ogg-*")
            file(GLOB match RELATIVE "${program_files}" "${program_files}/${pattern}")
            if(match)
                list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/${match}")
                if(match MATCHES "^ogg-(.*)$")
                    set(PC_Ogg_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
        endif()
    else()
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_Ogg QUIET ogg)
    endif()

    find_path(Ogg_INCLUDE_DIR
        NAMES ogg/ogg.h
        HINTS "${PC_Ogg_INCLUDEDIR}"
        DOC "Directory of libogg headers"
    )
    find_library(Ogg_LIBRARY
        NAMES ${Ogg_CANDIDATES}
        HINTS "${PC_Ogg_LIBDIR}"
        DOC "Path of libogg library file"
    )
    mark_as_advanced(Ogg_INCLUDE_DIR Ogg_LIBRARY)
    set(Ogg_VERSION_ARG)
    if(PC_Ogg_VERSION)
        set(Ogg_VERSION_ARG VERSION_VAR PC_Ogg_VERSION)
    endif()

    find_package_handle_standard_args(Ogg
        REQUIRED_VARS Ogg_LIBRARY Ogg_INCLUDE_DIR
        ${Ogg_VERSION_ARG}
    )

    if(Ogg_FOUND)
        set(Ogg_FOUND "${Ogg_FOUND}" PARENT_SCOPE)
        set(Ogg_INCLUDE_DIRS "${Ogg_INCLUDE_DIR}" PARENT_SCOPE)
        set(Ogg_LIBRARIES "${Ogg_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET Ogg::libogg)
            include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
            add_imported_library(Ogg::libogg "${Ogg_LIBRARY}")
            set_target_properties(Ogg::libogg PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Ogg_INCLUDE_DIR}"
            )
        endif()
        if(DEFINED Ogg_VERSION)
            set(Ogg_VERSION "${Ogg_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_ogg()
