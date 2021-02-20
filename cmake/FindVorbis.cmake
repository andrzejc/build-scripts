include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_vorbis)
    set(Vorbis_CANDIDATES vorbis libvorbis)
    set(VorbisEnc_CANDIDATES vorbisenc libvorbisenc)
    if(MSVC)
        if(NOT DEFINED Vorbis_ROOT AND NOT DEFINED ENV{Vorbis_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            set(pattern "vorbis-*")
            file(GLOB match RELATIVE "${program_files}" "${program_files}/${pattern}")
            if(match)
                list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/${match}")
                if(match MATCHES "^vorbis-(.*)$")
                    set(PC_Vorbis_VERSION "${CMAKE_MATCH_1}")
                endif()
            endif()
        endif()
    else()
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_Vorbis QUIET vorbis)
        pkg_check_modules(PC_VorbisEnc QUIET vorbisenc)
    endif()

    find_path(Vorbis_INCLUDE_DIR
        NAMES vorbis/codec.h
        HINTS "${PC_Vorbis_INCLUDEDIR}"
        DOC "Directory of libvorbis headers"
    )
    find_library(Vorbis_LIBRARY
        NAMES ${Vorbis_CANDIDATES}
        HINTS "${PC_Vorbis_LIBDIR}"
        DOC "Path of libvorbis library file"
    )
    find_library(VorbisEnc_LIBRARY
        NAMES ${VorbisEnc_CANDIDATES}
        HINTS "${PC_VorbisEnc_LIBDIR}"
        DOC "Path of libvorbisenc library file"
    )
    mark_as_advanced(Vorbis_INCLUDE_DIR Vorbis_LIBRARY VorbisEnc_LIBRARY)
    set(Vorbis_VERSION_ARG)
    if(PC_Vorbis_VERSION)
        set(Vorbis_VERSION_ARG VERSION_VAR PC_Vorbis_VERSION)
    endif()

    find_package_handle_standard_args(Vorbis
        REQUIRED_VARS Vorbis_LIBRARY VorbisEnc_LIBRARY Vorbis_INCLUDE_DIR
        ${Vorbis_VERSION_ARG}
    )

    if(Vorbis_FOUND)
        set(Vorbis_FOUND "${Vorbis_FOUND}" PARENT_SCOPE)
        set(Vorbis_INCLUDE_DIRS "${Vorbis_INCLUDE_DIR}" PARENT_SCOPE)
        set(Vorbis_LIBRARIES "${Vorbis_LIBRARY}" "${VorbisEnc_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET Vorbis::libvorbis)
            include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
            add_imported_library(Vorbis::libvorbis "${Vorbis_LIBRARY}")
            set_target_properties(Vorbis::libvorbis PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Vorbis_INCLUDE_DIR}"
            )
        endif()
        if(NOT TARGET Vorbis::libvorbisenc)
            include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
            add_imported_library(Vorbis::libvorbisenc "${VorbisEnc_LIBRARY}")
            set_target_properties(Vorbis::libvorbisenc PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Vorbis_INCLUDE_DIR}"
            )
        endif()
        if(DEFINED Vorbis_VERSION)
            set(Vorbis_VERSION "${Vorbis_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_vorbis()
