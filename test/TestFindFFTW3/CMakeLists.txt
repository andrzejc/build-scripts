project(TestFindFindFFTW3 LANGUAGES C)
find_package(FFTW3 REQUIRED COMPONENTS libfftw3 OPTIONAL_COMPONENTS libfftw3f libfftw3l libfftw3q)

foreach(variant "" f l q)
    if(NOT FFTW3_libfftw3${variant}_FOUND)
        continue()
    endif()
    add_executable(fftw3${variant}-version main.c)
    target_link_libraries(fftw3${variant}-version PRIVATE FFTW3::libfftw3${variant})
    target_compile_definitions(fftw3${variant}-version PRIVATE "FFTW_PREFIX=fftw${variant}_")
    add_test(NAME fftw3${variant}-found-and-linked COMMAND fftw3${variant}-version)
    if(WIN32)
        string(REPLACE ";" "\\;" escaped_path "$ENV{PATH}")
        set_tests_properties(fftw3${variant}-found-and-linked PROPERTIES
            ENVIRONMENT "PATH=${escaped_path}\\;$<SHELL_PATH:$<TARGET_PROPERTY:FFTW3::libfftw3${variant},DLL_DIRECTORY>>"
        )
    endif()
endforeach(variant)
