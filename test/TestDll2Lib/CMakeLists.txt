if(NOT CMAKE_HOST_WIN32)
    # This works only on Windows platform
    return()
endif()

find_program(DLL2LIB_SCRIPT dll2lib.cmd)
if(NOT DLL2LIB_SCRIPT)
    message(FATAL_ERROR "dll2lib script not found")
endif()

add_executable(dll2lib IMPORTED)
set_target_properties(dll2lib PROPERTIES
    IMPORTED_LOCATION "${DLL2LIB_SCRIPT}"
)

# Donwload PortAudio release for testing dll2lib
find_package(SafeDownload REQUIRED)
set(ARCHIVE_NAME portaudio-binaries-portaudio-19.6.0)
add_custom_command(OUTPUT ${ARCHIVE_NAME}.tar.gz
    COMMAND "${SAFE_DOWNLOAD_SCRIPT}" https://github.com/spatialaudio/portaudio-binaries/archive/portaudio-19.6.0.tar.gz . e288b86e3fa28cf75bc69a4e305112b3feb2e95ffdcfb8cc94bebc81b7ba0cf8
    VERBATIM
)
add_custom_command(OUTPUT ${ARCHIVE_NAME}/libportaudio32bit.dll ${ARCHIVE_NAME}/libportaudio64bit.dll
    COMMAND "${CMAKE_COMMAND}" -E tar xf ${ARCHIVE_NAME}.tar.gz
    DEPENDS ${ARCHIVE_NAME}.tar.gz
    VERBATIM
)
add_custom_target(unpack-archive ALL
    DEPENDS ${ARCHIVE_NAME}/libportaudio32bit.dll ${ARCHIVE_NAME}/libportaudio64bit.dll
)

add_test(dll2lib-x86
    COMMAND "${DLL2LIB_SCRIPT}" ${ARCHIVE_NAME}/libportaudio32bit.dll x86)
add_test(dll2lib-x64
    COMMAND "${DLL2LIB_SCRIPT}" ${ARCHIVE_NAME}/libportaudio64bit.dll x64)
