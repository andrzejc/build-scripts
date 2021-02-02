project(TestFindSndfile LANGUAGES C)
find_package(Sndfile REQUIRED)
add_executable(sndfile-version main.c)
target_link_libraries(sndfile-version PRIVATE Sndfile::libsndfile)

add_test(NAME sndfile-found-and-linked COMMAND sndfile-version)
if(WIN32)
    string(REPLACE ";" "\\;" escaped_path "$ENV{PATH}")
    set_tests_properties(sndfile-found-and-linked PROPERTIES
        ENVIRONMENT "PATH=${escaped_path}\\;$<SHELL_PATH:$<TARGET_PROPERTY:Sndfile::libsndfile,DLL_DIRECTORIES>>"
    )
endif()
