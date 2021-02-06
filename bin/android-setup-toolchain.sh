#!/usr/bin/env bash
## NOTE this script is intended to be sourced, not executed

NDK="${NDK:-${HOME}/Android/Sdk/ndk/22.0.7026061}"
#TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
API="${API:-21}"
TARGETS=(armv7a-linux-androideabi aarch64-linux-android i686-linux-android x86_64-linux-android)
TARGET="${TARGET:-${TARGETS[1]}}"

function setup_toolchain() {
    local binutils_target
    local abi
    case "${TARGET}" in
        armv7a-*)
            abi=armeabi-v7a
            binutils_target=arm-linux-androideabi
            export CFLAGS="${CFLAGS} -fsigned-char"
            export CXXFLAGS="${CXXFLAGS} -fsigned-char"
            ;;
        aarch64-*)
            abi=arm64-v8a ;;
        i686-*)
            abi=x86
            ;;
        x86_64-*)
            abi=x86_64 ;;
        *)
            >&2 echo "Don't know ABI for TARGET ${TARGET}"
            return 1
    esac
    binutils_target="${binutils_target:-${TARGET}}"
    export ABI="${abi}"
    export AR="${TOOLCHAIN}/bin/${binutils_target}-ar"
    export AS="${TOOLCHAIN}/bin/${binutils_target}-as"
    export CC="${TOOLCHAIN}/bin/${TARGET}${API}-clang"
    export CXX="${TOOLCHAIN}/bin/${TARGET}${API}-clang++"
    export LD="${TOOLCHAIN}/bin/${binutils_target}-ld"
    export RANLIB="${TOOLCHAIN}/bin/${binutils_target}-ranlib"
    export STRIP="${TOOLCHAIN}/bin/${binutils_target}-strip"
    echo "Android toolchain configured for ABI: ${abi}"
}

setup_toolchain
