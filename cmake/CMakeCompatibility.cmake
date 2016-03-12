if (POLICY CMP0042)
	cmake_policy(SET CMP0042 NEW)
endif()
if (POLICY CMP0054)
	cmake_policy(SET CMP0054 OLD)
endif()

if (NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin CACHE
		PATH "Directory where .exe and .dll files are dumped.")
endif()

