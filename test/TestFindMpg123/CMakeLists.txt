project(TestFindMpg123 LANGUAGES C)
find_package(Mpg123)
# NOTE FindMpg123.cmake doesn't support Windows yet
if(Mpg123_FOUND)
    add_executable(mpg123-version main.c)
    target_link_libraries(mpg123-version PRIVATE Mpg123::libmpg123)

    set(wd_arg)
    if(WIN32)
        set(wd_arg WORKING_DIRECTORY $<TARGET_PROPERTY:Mpg123::libmpg123,DLL_DIRECTORY>)
    endif()

    add_test(NAME mpg123-found-and-linked
        COMMAND mpg123-version
        ${wd_arg}
    )
endif()
