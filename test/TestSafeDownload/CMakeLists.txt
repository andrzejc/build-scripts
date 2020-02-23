find_program(SAFE_DOWNLOAD_SCRIPT safe-download${SCRIPT_SUFFIX})
if(NOT SAFE_DOWNLOAD_SCRIPT)
    message(FATAL_ERROR "safe-download script not found")
endif()

add_executable(safe-download IMPORTED)
set_target_properties(safe-download PROPERTIES
    IMPORTED_LOCATION "${SAFE_DOWNLOAD_SCRIPT}"
)

set(TEST_DOWNLOAD_URL https://raw.githubusercontent.com/andrzejc/arrow1/master/makefile)
set(TEST_MD5 a03f66254ac6500ff7980ec25c7addfe)
set(TEST_SHA1 313afd087cd015cb29a1d4e60ec9ec117d3de35d)
set(TEST_SHA256 97c17121503e543f43afb239bf06b10c694971f19955f8dd4bc140555ad3c9a9)

# Use hash string inline as a param
add_test(NAME safe-download-md5-inline
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test "${TEST_MD5}")
add_test(NAME safe-download-sha1-inline
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test "${TEST_SHA1}")
add_test(NAME safe-download-sha256-inline
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test "${TEST_SHA256}")


file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/md5" "${TEST_MD5}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sha1" "${TEST_SHA1}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sha256" "${TEST_SHA256}\n")

# Read hash from explicitly specified file
add_test(NAME safe-download-md5-file
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test md5)
add_test(NAME safe-download-sha1-file
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test sha1)
add_test(NAME safe-download-sha256-file
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" test sha256)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-md5/makefile.md5" "${TEST_MD5}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-sha1/makefile.sha1" "${TEST_SHA1}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-sha256/makefile.sha256" "${TEST_SHA256}\n")

# Read hash from file whose name is inferred from URL with .hash-type extension.
add_test(NAME safe-download-md5-auto
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" data-md5)
add_test(NAME safe-download-sha1-auto
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" data-sha1)
add_test(NAME safe-download-sha256-auto
    COMMAND safe-download "${TEST_DOWNLOAD_URL}" data-sha256)
