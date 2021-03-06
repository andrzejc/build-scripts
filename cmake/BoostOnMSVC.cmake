# Setup BOOST_LIBRARYDIR variable for binary Boost distribution, based on
# existing BOOST_ROOT variable (or env var). BOOST_LIBRARYDIR is set only if
# directory matching the platform and compiler version is found. Supports only
# MSVC. Must be inluded before find_package(Boost) to have effect.
if (CMAKE_GENERATOR MATCHES "Visual Studio .*")
    if (CMAKE_CL_64)
        set(_BOOST_LIB_PREFIX lib64)
    else ()
        set(_BOOST_LIB_PREFIX lib32)
    endif()

    if (MSVC60)
        set(_VCVER_SUFFIX "6.0")
    elseif (MSVC70)
        set(_VCVER_SUFFIX "7.0")
    elseif (MSVC71)
        set(_VCVER_SUFFIX "7.1")
    elseif (MSVC80)
        set(_VCVER_SUFFIX "8.0")
    elseif (MSVC90)
        set(_VCVER_SUFFIX "9.0")
    elseif (MSVC10)
        set(_VCVER_SUFFIX "10.0")
    elseif (MSVC11)
        set(_VCVER_SUFFIX "11.0")
    elseif (MSVC12)
        set(_VCVER_SUFFIX "12.0")
    elseif (MSVC14)
        set(_VCVER_SUFFIX "14.0")
    endif()

    set(_BOOST_MSVC_LIBDIR "${_BOOST_LIB_PREFIX}-msvc-${_VCVER_SUFFIX}")
    if (EXISTS "${BOOST_ROOT}/${_BOOST_MSVC_LIBDIR}")
        set(BOOST_LIBRARYDIR "${BOOST_ROOT}/${_BOOST_MSVC_LIBDIR}")
    elseif (EXISTS "$ENV{BOOST_ROOT}/${_BOOST_MSVC_LIBDIR}")
        set(BOOST_LIBRARYDIR "$ENV{BOOST_ROOT}/${_BOOST_MSVC_LIBDIR}")
    endif()
endif()
