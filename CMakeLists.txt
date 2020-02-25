message(STATUS "PATH: $ENV{PATH}")
cmake_minimum_required(VERSION 3.1)
project(BuildScriptsTests LANGUAGES NONE)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}")

enable_testing()
add_subdirectory(test)
