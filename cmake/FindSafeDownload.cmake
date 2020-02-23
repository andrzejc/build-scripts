if(CMAKE_HOST_WIN32)
    set(suffix .cmd)
else()
    set(suffix)
endif()

find_program(SAFE_DOWNLOAD_SCRIPT safe-download${suffix} DOC "safe-download script path")
mark_as_advanced(SAFE_DOWNLOAD_SCRIPT)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SafeDownload REQUIRED_VARS SAFE_DOWNLOAD_SCRIPT)

if(SafeDownload_FOUND AND NOT TARGET SafeDownload::Script)
    add_executable(SafeDownload::Script IMPORTED)
    set_target_properties(SafeDownload::Script PROPERTIES
        IMPORTED_LOCATION "${SAFE_DOWNLOAD_SCRIPT}"
    )
endif()
