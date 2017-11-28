if(USE_PYTHON_LIST_PY_COMPILE)
	if(NOT (IS_ABSOLUTE "${pyc_DIR}"))
		set(pyc_DIR_IN "${pyc_SOURCE_DIR}/${pyc_DIR}")
		set(pyc_DIR_OUT "${pyc_OUTPUT_DIR}/${pyc_DIR}")
	else()
		set(pyc_DIR_IN "${pyc_DIR}")
		set(pyc_DIR_OUT "${pyc_DIR}")
	endif()
	file(GLOB_RECURSE srcs RELATIVE "${pyc_DIR_IN}" "${pyc_DIR_IN}/*.py")
	file(WRITE "${pyc_DIR_OUT}/.py_compile.tmp" "")
	foreach(src ${srcs})
		set(in "${pyc_DIR_IN}/${src}")
		set(out "${src}${pyc_SUFFIX}")
		set(out_abs "${pyc_DIR_OUT}/${out}")
		if("${in}" IS_NEWER_THAN "${out_abs}")
			file(TO_NATIVE_PATH "${in}" in)
			file(TO_NATIVE_PATH "${out}" out)
			string(REPLACE "\"" "\\\"" in "${in}")
			string(REPLACE "\"" "\\\"" out "${out}")
			file(APPEND "${pyc_DIR_OUT}/.py_compile.tmp" "\"${in}\",\"${out}\"\n")
		endif()
	endforeach(src)
	execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_if_different
			"${pyc_DIR_OUT}/.py_compile.tmp" "${pyc_DIR_OUT}/.py_compile")
	return()
endif(USE_PYTHON_LIST_PY_COMPILE)

set(USE_PYTHON_MODULE_PATH "${CMAKE_CURRENT_LIST_FILE}")
set(USE_PYTHON_MODULE_DIR  "${CMAKE_CURRENT_LIST_DIR}")

include(CMakeParseArguments)

macro(_py_compile_one _INPUT _OUTPUT _TARGET _PYFLAGS)
	add_custom_command(
		OUTPUT "${_OUTPUT}"
		COMMAND "${PYTHON_EXECUTABLE}" ${_PYFLAGS}
			"${USE_PYTHON_MODULE_DIR}/use_python_compile.py" "${_INPUT}" "${_OUTPUT}"
		MAIN_DEPENDENCY "${_INPUT}"
		COMMENT "Precompiling Python file '${_TARGET}'"
		VERBATIM)
endmacro(_py_compile_one)

macro(_py_compile_dir _DIR _PYSUFFIX _PYFLAGS)
	add_custom_command(
		OUTPUT "${_DIR}/.py_compile" "${_DIR}/.py_compile.PHONY"
		COMMAND "${CMAKE_COMMAND}"
			"-Dpyc_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
			"-Dpyc_OUTPUT_DIR=${pyc_OUTPUT_DIR}"
			"-Dpyc_DIR=${_DIR}"
			"-Dpyc_SUFFIX=${_PYSUFFIX}"
			-DUSE_PYTHON_LIST_PY_COMPILE=1
			-P "${USE_PYTHON_MODULE_PATH}"
		COMMENT "Generating Python module inventory"
		VERBATIM)
	add_custom_command(
		OUTPUT "${_DIR}/.py_compile.done" "${_DIR}/.py_compile.done.PHONY"
		COMMAND "${PYTHON_EXECUTABLE}" ${_PYFLAGS}
				"${USE_PYTHON_MODULE_DIR}/use_python_compile.py" "${_DIR}"
		DEPENDS "${_DIR}/.py_compile"
		COMMENT "Precompiling Python module"
		VERBATIM)
	set_source_files_properties(
		"${_DIR}/.py_compile.PHONY" "${_DIR}/.py_compile.done.PHONY"
		PROPERTIES SYMBOLIC ON)
endmacro(_py_compile_dir)

set(Python_ADDITIONAL_VERSIONS 3.5 3.4)
find_package(PythonInterp 3.6 REQUIRED)

function(py_compile)
	cmake_parse_arguments(pyc
		"OPTIMIZED"
		"TARGET;OUTPUT_DIR"
		""
		${ARGN})

	if(pyc_OPTIMIZED)
		set(pyflags "-O")
		set(pysuffix "o")
	else()
		set(pysuffix "c")
	endif()

	set(srcs ${pyc_UNPARSED_ARGUMENTS})
	if(NOT srcs)
		# cmake won't understand difference between empty string and empty list
		set(srcs ".")
	endif()

	if(NOT pyc_OUTPUT_DIR)
		set(pyc_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	endif()

	set(exp_srcs)
	set(src_dirs)
	# expand all directory paths to their contained *.py files
	foreach(src ${srcs})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(abs "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
		else()
			set(abs "${src}")
		endif()

		if(IS_DIRECTORY "${abs}")
			list(APPEND src_dirs "${src}")
		else()
			list(APPEND exp_srcs "${src}")
		endif()
	endforeach(src)

	set(srcs ${exp_srcs})

	set(out_dirs)
	set(outs)
	# create compile command for each *.py file into *.pyc
	foreach(src ${srcs})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(target "${src}${pysuffix}")  # output path relative to bin_dir
			set(src "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
			set(out "${pyc_OUTPUT_DIR}/${target}")
		else()
			set(target "${src}${pysuffix}")
			set(out "${target}")
		endif()

		get_filename_component(dir "${out}" DIRECTORY)
		list(APPEND out_dirs "${dir}")
		_py_compile_one("${src}" "${out}" "${target}" "${pyflags}")
		list(APPEND outs "${out}")
	endforeach()

	set(out_dir_stamps)
	foreach(dir ${src_dirs})
		if(NOT (IS_ABSOLUTE "${dir}"))
			set(out "${pyc_OUTPUT_DIR}/${dir}")
		else()
			set(out "${dir}")
		endif()
		list(APPEND out_dirs "${out}")
		_py_compile_dir("${dir}" "${pysuffix}" "${pyflags}")
		list(APPEND out_dir_stamps "${out}/.py_compile.PHONY" "${out}/.py_compile.done.PHONY")
	endforeach(dir)

	# create output directories
	list(REMOVE_DUPLICATES out_dirs)
	foreach(dir ${out_dirs})
		file(MAKE_DIRECTORY "${dir}")
	endforeach(dir)

	if(pyc_TARGET)
		add_custom_target(${pyc_TARGET} ALL
			DEPENDS ${outs} ${out_dir_stamps}
			SOURCES ${srcs})
	endif()
endfunction(py_compile)

function(to_path_list var)
	if("${CMAKE_HOST_SYSTEM}" MATCHES ".*Windows.*")
		set(sep "\\;")
	else()
		set(sep ":")
	endif()
	set(result)
	foreach(path ${ARGN})
		file(TO_NATIVE_PATH "${path}" path)
		if(result)
			set(result "${result}${sep}${path}")
		else()
			set(result "${path}")
		endif()
	endforeach(path)
	set(${var} "${result}" PARENT_SCOPE)
endfunction(to_path_list)

function(py_run)
	cmake_parse_arguments(pyr
		"OPTIMIZED"
		"PREFIX;TARGET"
		"COMPILED;SOURCE;DEPENDS;COMMAND;OUTPUT"
		${ARGN})

	if(pyr_OPTIMIZED)
		set(pyflags "-O")
		set(pysuffix "o")
	else()
		set(pysuffix "c")
	endif()
	if(NOT pyr_PREFIX)
		set(pyr_PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
	endif()
	set(dirs)
	set(deps)
	set(scripts)
	foreach(src ${pyr_COMPILED})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(src "${pyr_PREFIX}/${src}")
		endif()
		if(IS_DIRECTORY "${src}")
			list(APPEND deps "${src}/.py_compile.done" "${src}/.py_compile.done.PHONY")
			list(APPEND dirs "${src}")
		else()
			list(APPEND scripts "${src}${pysuffix}")
			list(APPEND deps "${src}${pysuffix}")
		endif()
	endforeach(src)
	foreach(src ${pyr_SOURCE})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(src "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
		endif()
		if(IS_DIRECTORY "${src}")
			list(APPEND dirs "${src}")
		else()
			list(APPEND scripts "${src}")
			list(APPEND deps "${src}")
		endif()
	endforeach(src)
	list(APPEND pyr_DEPENDS ${deps})
	list(REMOVE_DUPLICATES pyr_DEPENDS)
	file(TO_CMAKE_PATH "$ENV{PYTHONPATH}" pp)
	list(APPEND pp ${PY_RUN_PYTHONPATH})
	list(APPEND pp ${dirs})
	to_path_list(pp ${pp})
	# TODO we should check if only one script is present
	set(cmd ${scripts})
	list(APPEND cmd ${pyr_COMMAND} ${pyr_UNPARSED_ARGUMENTS})
	message(STATUS "cmd: ${cmd}")
	add_custom_command(OUTPUT ${pyr_OUTPUT} TARGET ${pyr_TARGET}
		DEPENDS ${pyr_DEPENDS}
		COMMAND "${CMAKE_COMMAND}" -E env "PYTHONPATH=${pp}"
			"${PYTHON_EXECUTABLE}" ${pyflags} ${cmd})
endfunction(py_run)


function(py_test)
	cmake_parse_arguments(pyt
		"OPTIMIZED"
		"PREFIX;NAME"
		"COMPILED;SOURCE;DEPENDS;COMMAND"
		${ARGN})

	if(pyt_OPTIMIZED)
		set(pyflags "-O")
		set(pysuffix "o")
	else()
		set(pysuffix "c")
	endif()
	if(NOT pyt_PREFIX)
		set(pyt_PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
	endif()
	set(dirs)
	set(deps)
	set(scripts)
	foreach(src ${pyt_COMPILED})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(src "${pyt_PREFIX}/${src}")
		endif()
		if(IS_DIRECTORY "${src}")
			list(APPEND deps "${src}/.py_compile.done" "${src}/.py_compile.done.PHONY")
			list(APPEND dirs "${src}")
		else()
			list(APPEND scripts "${src}${pysuffix}")
			list(APPEND deps "${src}${pysuffix}")
		endif()
	endforeach(src)
	foreach(src ${pyt_SOURCE})
		if(NOT (IS_ABSOLUTE "${src}"))
			set(src "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
		endif()
		if(IS_DIRECTORY "${src}")
			list(APPEND dirs "${src}")
		else()
			list(APPEND scripts "${src}")
			list(APPEND deps "${src}")
		endif()
	endforeach(src)
	list(APPEND pyt_DEPENDS ${deps})
	list(REMOVE_DUPLICATES pyt_DEPENDS)
	file(TO_CMAKE_PATH "$ENV{PYTHONPATH}" pp)
	list(APPEND pp ${PY_TEST_PYTHONPATH})
	list(APPEND pp ${dirs})
	to_path_list(pp ${pp})
	# TODO we should check if only one script is present
	set(cmd ${scripts})
	list(APPEND cmd ${pyt_COMMAND} ${pyt_UNPARSED_ARGUMENTS})
	message(STATUS "cmd: ${cmd}")
	add_test(NAME "${pyt_NAME}"
		COMMAND "${CMAKE_COMMAND}" -E env "PYTHONPATH=${pp}"
			"${PYTHON_EXECUTABLE}" ${pyflags} ${cmd})
endfunction(py_test)
