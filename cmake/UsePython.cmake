
include(CMakeParseArguments)

macro(_py_compile_one _INPUT _OUTPUT _TARGET _PYFLAGS)
    add_custom_command(
        OUTPUT ${_OUTPUT}
        COMMAND ${PYTHON_EXECUTABLE} ${_PYFLAGS}
        -c "import py_compile; py_compile.compile(\"${_INPUT}\",\
 \"${_OUTPUT}\")"
        MAIN_DEPENDENCY ${_INPUT}
        COMMENT "Precompiling Python file ${_TARGET}"
        VERBATIM)
endmacro(_py_compile_one)

function(py_compile)

    cmake_parse_arguments(_py_compile
      "OPTIMIZED"
      "TARGET;OUTPUT_DIR"
      ""
      ${ARGN}
    )

    if(_py_compile_OPTIMIZED)
        set(_PYFLAGS "-O")
        set(_PYSUFFIX "o")
    else()
        set(_PYSUFFIX "c")
    endif()

    set(_srcs "${_py_compile_UNPARSED_ARGUMENTS}")

    if(NOT DEFINED _py_compile_OUTPUT_DIR)
        set(_py_compile_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    set(_exp)
    # expand all directory paths to their contained *.py files
    foreach(_src ${_srcs})
        if(NOT IS_ABSOLUTE ${_src})
            set(_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
        else()
            set(_abs ${_src})
        endif()

        if(IS_DIRECTORY ${_abs})
            file(GLOB_RECURSE _pysrcs RELATIVE ${_abs} "${_abs}/*.py")
            foreach(_pysrc ${_pysrcs})
                list(APPEND _exp "${_src}/${_pysrc}")
            endforeach()
        else()
            list(APPEND _exp ${_src})
        endif()
    endforeach()

    set(_srcs ${_exp})

    set(_dirs)
    set(_outs)
    # create compile command for each *.py file into *.pyc
    foreach(_src ${_srcs})
        if(NOT IS_ABSOLUTE ${_src})
            set(_target "${_src}${_PYSUFFIX}")
            set(_src "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
            set(_out "${_py_compile_OUTPUT_DIR}/${_target}")
        else()
            set(_target "${_src}${_PYSUFFIX}")
            set(_out "${_target}")
        endif()

        get_filename_component(_dir "${_out}" DIRECTORY)
        list(APPEND _dirs ${_dir})
        _py_compile_one("${_src}" "${_out}" "${_target}" "${_PYFLAGS}")
        list(APPEND _outs ${_out})
    endforeach()

    # create output directories
    list(REMOVE_DUPLICATES _dirs)
    foreach(_dir ${_dirs})
        file(MAKE_DIRECTORY ${_dir})
    endforeach()

    if(DEFINED _py_compile_TARGET)
        add_custom_target(${_py_compile_TARGET} ALL
            DEPENDS ${_outs}
            SOURCES ${_srcs})
    endif()
endfunction()