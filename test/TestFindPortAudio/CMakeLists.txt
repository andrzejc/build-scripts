project(TestFindPortAudio LANGUAGES C)
find_package(PortAudio REQUIRED)
add_executable(portaudio-version main.c)
target_link_libraries(portaudio-version PRIVATE PortAudio::libportaudio)

add_test(NAME portaudio-version
    COMMAND portaudio-version
    # Make sure we find the dll on Windows
    WORKING_DIRECTORY "${PortAudio_ROOT}/bin"
)
