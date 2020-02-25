project(TestFindSndfile LANGUAGES C)
find_package(Sndfile REQUIRED)
add_executable(sndfile-version main.c)
target_link_libraries(sndfile-version PRIVATE Sndfile::libsndfile)

set(wd_arg)
if(WIN32)
    set(wd_arg WORKING_DIRECTORY "${Sndfile_ROOT}/bin")
endif()

add_test(NAME sndfile-found-and-linked
    COMMAND sndfile-version
    ${wd_arg}
)
