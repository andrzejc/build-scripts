find_package(SafeDownload REQUIRED)

set(TEST_DOWNLOAD_URL https://raw.githubusercontent.com/andrzejc/build-scripts/develop/test/TestSafeDownload/data)
set(TEST_MD5 dfa1b0b6ef47a15c600b094a93e56002)
set(TEST_SHA1 4e4ced5ee12c698209feaab89fd33e93fb7890dd)
set(TEST_SHA256 f6f24a11d7cbbbc6d9440aca2eba0f6498755ca90adea14c5e233bf4c04bd928)

# Use hash string inline as a param
add_test(NAME safe-download-md5-inline
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test "${TEST_MD5}")
add_test(NAME safe-download-sha1-inline
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test "${TEST_SHA1}")
add_test(NAME safe-download-sha256-inline
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test "${TEST_SHA256}")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/md5" "${TEST_MD5}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sha1" "${TEST_SHA1}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sha256" "${TEST_SHA256}\n")

# Read hash from explicitly specified file
add_test(NAME safe-download-md5-file
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test md5)
add_test(NAME safe-download-sha1-file
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test sha1)
add_test(NAME safe-download-sha256-file
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" test sha256)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-md5/makefile.md5" "${TEST_MD5}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-sha1/makefile.sha1" "${TEST_SHA1}\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/data-sha256/makefile.sha256" "${TEST_SHA256}\n")

# Read hash from file whose name is inferred from URL with .hash-type extension.
add_test(NAME safe-download-md5-auto
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" data-md5)
add_test(NAME safe-download-sha1-auto
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" data-sha1)
add_test(NAME safe-download-sha256-auto
    COMMAND SafeDownload::Script "${TEST_DOWNLOAD_URL}" data-sha256)
