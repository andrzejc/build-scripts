cmake_minimum_required(VERSION 3.1)
project(BuildScriptsTests
    VERSION 0.1
    # DESCRIPTION "Test driver project for https://github.com/andrzejc/build-scripts"
    # HOMEPAGE_URL https://github.com/andrzejc/build-scripts
    LANGUAGES NONE
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}")

enable_testing()
add_subdirectory(test)
