project(TestFindPortAudio LANGUAGES C)
find_package(PortAudio REQUIRED)
add_executable(portaudio-version main.c)
target_link_libraries(portaudio-version PRIVATE PortAudio::libportaudio)

set(wd_arg)
if(WIN32)
    set(wd_arg WORKING_DIRECTORY "${PortAudio_ROOT}/bin")
endif()

add_test(NAME portaudio-found-and-linked
    COMMAND portaudio-version
    ${wd_arg}
)
