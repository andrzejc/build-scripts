project(TestFindLAME LANGUAGES C)
find_package(LAME)
# NOTE FindLAME.cmake doesn't support Windows yet
if(LAME_FOUND)
    add_executable(lame-version main.c)
    target_link_libraries(lame-version PRIVATE LAME::libmp3lame)

    set(wd_arg)
    if(WIN32)
        set(wd_arg WORKING_DIRECTORY $<TARGET_PROPERTY:LAME::libmp3lame,DLL_DIRECTORY>)
    endif()

    add_test(NAME lame-found-and-linked
        COMMAND lame-version
        ${wd_arg}
    )
endif()
