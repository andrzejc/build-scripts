project(TestFindSndfile LANGUAGES C)
find_package(Sndfile REQUIRED)
add_executable(sndfile-version main.c)
target_link_libraries(sndfile-version PRIVATE Sndfile::libsndfile)

add_test(NAME sndfile-found-and-linked COMMAND sndfile-version)
if(WIN32)
    set_tests_properties(sndfile-found-and-linked PROPERTIES
        ENVIRONMENT "PATH=$<SHELL_PATH:$<TARGET_PROPERTY:Sndfile::libsndfile,DLL_DIRECTORY>>"
    )
endif()
