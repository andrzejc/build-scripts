include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_fdk_aac)
    set(FdkAac_CANDIDATES fdk-aac libfdk-aac)
    if(MSVC)
        # list(APPEND FdkAac_CANDIDATES libfdk-aac-0)
        if(NOT DEFINED FdkAac_ROOT AND NOT DEFINED ENV{FdkAac_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            get_windows_program_files_dir(program_files)
            # if(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64")
            #     set(pattern "fdk-aac-*-x86-64")
            # elseif(CMAKE_SYSTEM_PROCESSOR MATCHES ".*86")
            #     set(pattern "fdk-aac-*-x86")
            # endif()
            # list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/fdk-aac")
        endif()
    endif()

    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_FdkAac QUIET fdk-aac)

    find_path(FdkAac_INCLUDE_DIR
        NAMES fdk-aac/aacenc_lib.h
        HINTS "${PC_FdkAac_INCLUDEDIR}"
        DOC "Directory of libfdk-aac headers"
    )
    find_library(FdkAac_LIBRARY
        NAMES ${FdkAac_CANDIDATES}
        HINTS "${PC_FdkAac_LIBDIR}"
        DOC "Path of libfdk-aac library file"
    )
    mark_as_advanced(FdkAac_INCLUDE_DIR FdkAac_LIBRARY)
    set(FdkAac_VERSION_ARG)
    if(PC_FdkAac_VERSION)
        set(FdkAac_VERSION_ARG VERSION_VAR PC_FdkAac_VERSION)
    endif()

    find_package_handle_standard_args(FdkAac
        REQUIRED_VARS FdkAac_LIBRARY FdkAac_INCLUDE_DIR
        ${FdkAac_VERSION_ARG}
    )

    if(FdkAac_FOUND)
        set(FdkAac_FOUND "${FdkAac_FOUND}" PARENT_SCOPE)
        set(FDKAAC_FOUND "${FdkAac_FOUND}" PARENT_SCOPE)
        set(FdkAac_INCLUDE_DIRS "${FdkAac_INCLUDE_DIR}" PARENT_SCOPE)
        set(FdkAac_LIBRARIES "${FdkAac_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET FdkAac::libfdk-aac)
            add_library(FdkAac::libfdk-aac UNKNOWN IMPORTED)
            set_target_properties(FdkAac::libfdk-aac PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${FdkAac_INCLUDE_DIR}"
                IMPORTED_LOCATION "${FdkAac_LIBRARY}"
            )
            if(WIN32)
                include("${CMAKE_CURRENT_LIST_DIR}/SetupSidecarDll.cmake")
                setup_sidecar_dll(FdkAac::libfdk-aac)
            endif()
        endif()
        if(DEFINED FdkAac_VERSION)
            set(FdkAac_VERSION "${FdkAac_VERSION}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_fdk_aac()
