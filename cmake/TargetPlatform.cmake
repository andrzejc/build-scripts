include(CheckCXXSourceCompiles)

check_cxx_source_compiles("
#if defined(__i386) || defined(_M_IX86) || defined(__x86_64__) || defined(_M_X64) || defined(_M_AMD64)
int main() {return 0;}
#else
#error Not X86 platform
#endif
" TARGET_PLATFORM_X86)

check_cxx_source_compiles("
#if defined(__x86_64__) || defined(_M_X64) || defined(_M_AMD64)
int main() {return 0;}
#else
#error Not X64 platform
#endif
" TARGET_PLATFORM_X64)

check_cxx_source_compiles("
#if defined(__arm__) || defined(_M_ARM)
int main() {return 0;}
#else
#error Not ARM platform
#endif
" TARGET_PLATFORM_ARM)

check_cxx_source_compiles("
#if defined(__thumb__) || defined(_M_ARMT)
int main() {return 0;}
#else
#error Not Thumb platform
#endif
" TARGET_PLATFORM_THUMB)

check_cxx_source_compiles("
#if defined(__aarch64__)
int main() {return 0;}
#else
#error Not ARM platform
#endif
" TARGET_PLATFORM_ARM64)

check_cxx_source_compiles("
#if defined(__ia64) || defined(__itanium__) || defined(_M_IA64)
int main() {return 0;}
#else
#error Not IA64 platform
#endif
" TARGET_PLATFORM_IA64)

check_cxx_source_compiles("
#if defined(__powerpc__) || defined(__ppc__) || defined(__PPC__)
int main() {return 0;}
#else
#error Not PPC platform
#endif
" TARGET_PLATFORM_PPC)

check_cxx_source_compiles("
#if (defined(__powerpc__) || defined(__ppc__) || defined(__PPC__)) && (defined(__powerpc64__) || defined(__ppc64__) || defined(__PPC64__) || defined(__64BIT__) || defined(_LP64) || defined(__LP64__))
int main() {return 0;}
#else
#error Not PPC64 platform
#endif
" TARGET_PLATFORM_PPC64)

check_cxx_source_compiles("
#if defined(__sparc)
int main() {return 0;}
#else
#error Not Sparc platform
#endif
" TARGET_PLATFORM_SPARC)

if (TARGET_PLATFORM_X86)
	if (MSVC)
		# using Visual Studio C++ or Intel
		if (NOT TARGET_PLATFORM_X64)
			set(CXX_COMPILER_SSE_FLAG "/arch:SSE")
			set(CXX_COMPILER_SSE2_FLAG "/arch:SSE2")
			set(CXX_COMPILER_SSE3_FLAG ${CXX_COMPILER_SSE2_FLAG})
			set(CXX_COMPILER_SSE41_FLAG ${CXX_COMPILER_SSE2_FLAG})
		else ()
			set(CXX_COMPILER_AVX_FLAG "/arch:AVX")
			set(CXX_COMPILER_AVX2_FLAG "/arch:AVX2")
		endif ()
	else()
		set(CXX_COMPILER_SSE_FLAG "-msse")
		set(CXX_COMPILER_SSE2_FLAG "-msse2")
		set(CXX_COMPILER_SSE3_FLAG "-msse3")
		set(CXX_COMPILER_SSE41_FLAG "-msse4.1")
		set(CXX_COMPILER_AVX_FLAG "-mavx")
		set(CXX_COMPILER_AVX2_FLAG "-mavx2")
	endif()
endif()
