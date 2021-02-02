project(TestFindPortAudio LANGUAGES C)
find_package(PortAudio)
if(PortAudio_FOUND)
    add_executable(portaudio-version main.c)
    target_link_libraries(portaudio-version PRIVATE PortAudio::libportaudio)

    set(wd_arg)
    if(WIN32)
        set(wd_arg WORKING_DIRECTORY $<TARGET_PROPERTY:PortAudio::libportaudio,DLL_DIRECTORIES>)
    endif()

    add_test(NAME portaudio-found-and-linked
        COMMAND portaudio-version
        ${wd_arg}
    )
endif()