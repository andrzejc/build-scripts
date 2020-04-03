include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_portaudio)
    set(PortAudio_CANDIDATES portaudio libportaudio)
    if(MSVC)
        if(NOT DEFINED PortAudio_ROOT AND NOT DEFINED ENV{PortAudio_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            # This will cause ./lib and ./include to be searched
            list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/PortAudio")
        endif()
        # Suffixes added by CMake-built release
        if(CMAKE_GENERATOR_PLATFORM MATCHES ".*64")
            list(APPEND PortAudio_CANDIDATES portaudio_x64)
        elseif(CMAKE_GENERATOR_PLATFORM MATCHES ".*32")
            list(APPEND PortAudio_CANDIDATES portaudio_x86)
        endif()
    endif()

    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_PortAudio QUIET portaudio-2.0)

    find_path(PortAudio_INCLUDE_DIR
        NAMES portaudio.h
        HINTS "${PC_PortAudio_INCLUDEDIR}"
        DOC "Directory of portaudio headers"
    )
    find_library(PortAudio_LIBRARY
        NAMES ${PortAudio_CANDIDATES}
        HINTS "${PC_PortAudio_LIBDIR}"
        DOC "Path of portaudio library file"
    )
    mark_as_advanced(PortAudio_INCLUDE_DIR PortAudio_LIBRARY)
    set(PortAudio_VERSION_ARG)
    if(PC_PortAudio_VERSION)
        set(PortAudio_VERSION_ARG VERSION_VAR PC_PortAudio_VERSION)
    endif()

    find_package_handle_standard_args(PortAudio
        REQUIRED_VARS PortAudio_LIBRARY PortAudio_INCLUDE_DIR
        ${PortAudio_VERSION_ARG}
    )

    if(PortAudio_FOUND)
        set(PortAudio_FOUND "${PortAudio_FOUND}" PARENT_SCOPE)
        set(PORTAUDIO_FOUND "${PORTAUDIO_FOUND}" PARENT_SCOPE)
        set(PortAudio_INCLUDE_DIRS "${PortAudio_INCLUDE_DIR}" PARENT_SCOPE)
        set(PortAudio_LIBRARIES "${PortAudio_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET PortAudio::libportaudio)
            add_library(PortAudio::libportaudio UNKNOWN IMPORTED)
            set_target_properties(PortAudio::libportaudio PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${PortAudio_INCLUDE_DIR}"
                IMPORTED_LOCATION "${PortAudio_LIBRARY}"
            )
            if(WIN32)
                include("${CMAKE_CURRENT_LIST_DIR}/GetSidecarDllDirectory.cmake")
                setup_library_dll_directory(PortAudio::libportaudio)
            endif()
        endif()
        if(DEFINED PortAudio_VERSION)
            set(PortAudio_VERSION "${PortAudio_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_portaudio()
