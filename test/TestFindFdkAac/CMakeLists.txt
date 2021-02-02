project(TestFindFdkAac LANGUAGES C)
find_package(FdkAac)
# NOTE FindFdkAac.cmake doesn't support Windows yet
if(FdkAac_FOUND)
    add_executable(fdk-aac-version main.c)
    target_link_libraries(fdk-aac-version PRIVATE FdkAac::libfdk-aac)

    set(wd_arg)
    if(WIN32)
        set(wd_arg WORKING_DIRECTORY $<TARGET_PROPERTY:FdkAac::libfdk-aac,DLL_DIRECTORIES>)
    endif()

    add_test(NAME fdk-aac-found-and-linked
        COMMAND fdk-aac-version
        ${wd_arg}
    )
endif()
