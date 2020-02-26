include(FindPackageHandleStandardArgs)

# Create function scope to avoid polluting global namespace
function(_find_libsndfile)
    set(Sndfile_CANDIDATES sndfile libsndfile)
    if(MSVC)
        if(NOT DEFINED Sndfile_ROOT AND NOT DEFINED ENV{Sndfile_ROOT})
            include("${CMAKE_CURRENT_LIST_DIR}/GetWindowsProgramFilesDir.cmake")
            # Check default installation of http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe & w32 version.
            get_windows_program_files_dir(program_files)
            list(INSERT CMAKE_PREFIX_PATH 0 "${program_files}/Mega-Nerd/libsndfile")
        endif()
        list(INSERT Sndfile_CANDIDATES 0 libsndfile-1)
    endif()

    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_Sndfile QUIET sndfile)

    find_path(Sndfile_INCLUDE_DIR
        NAMES sndfile.h
        HINTS ${PC_Sndfile_INCLUDEDIR}
        DOC "Directory of libsndfile headers"
    )
    find_library(Sndfile_LIBRARY
        NAMES ${PC_Sndfile_LIBRARIES} ${Sndfile_CANDIDATES}
        HINTS ${PC_Sndfile_LIBDIR}
        DOC "Directory of libsndfile library file"
    )
    mark_as_advanced(Sndfile_INCLUDE_DIR Sndfile_LIBRARY)
    set(Sndfile_VERSION_ARG)
    if(PC_Sndfile_VERSION)
        set(Sndfile_VERSION_ARG VERSION_VAR PC_Sndfile_VERSION)
    endif()

    find_package_handle_standard_args(Sndfile REQUIRED_VARS Sndfile_LIBRARY Sndfile_INCLUDE_DIR ${Sndfile_VERSION_ARG})

    if(Sndfile_FOUND)
        set(Sndfile_FOUND "${Sndfile_FOUND}" PARENT_SCOPE)
        set(SNDFILE_FOUND "${SNDFILE_FOUND}" PARENT_SCOPE)
        set(Sndfile_INCLUDE_DIRS "${Sndfile_INCLUDE_DIR}" PARENT_SCOPE)
        set(Sndfile_LIBRARIES "${Sndfile_LIBRARY}" PARENT_SCOPE)
        if(NOT TARGET Sndfile::libsndfile)
            add_library(Sndfile::libsndfile UNKNOWN IMPORTED)
            set_target_properties(Sndfile::libsndfile PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                INTERFACE_INCLUDE_DIRECTORIES "${Sndfile_INCLUDE_DIR}"
                IMPORTED_LOCATION "${Sndfile_LIBRARY}"
            )
            if(WIN32)
                include("${CMAKE_CURRENT_LIST_DIR}/GetSidecarDllDirectory.cmake")
                setup_library_dll_directory(Sndfile::libsndfile)
            endif()
        endif()
        if(DEFINED Sndfile_VERSION)
            set(Sndfile_VERSION "${Sndfile_VERSION}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED Sndfile_ROOT)
            if(DEFINED ENV{Sndfile_ROOT})
                file(TO_CMAKE_PATH "$ENV{Sndfile_ROOT}" Sndfile_ROOT)
            else()
                get_filename_component(Sndfile_ROOT "${Sndfile_INCLUDE_DIR}" DIRECTORY)
            endif()
            set(Sndfile_ROOT "${Sndfile_ROOT}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

_find_libsndfile()
