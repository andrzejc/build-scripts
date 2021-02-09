#!/usr/bin/env bash
## NOTE this script is intended to be sourced, not executed

OS=$( uname -s )
case "${OS}" in
Darwin)
    NDK="${NDK:-${HOME}/Library/Android/sdk/ndk/22.0.7026061}" ;;
Linux)
    NDK="${NDK:-${HOME}/Android/Sdk/ndk/22.0.7026061}" ;;
*)
    >&2 echo "Don't know how to setup NDK on ${OS}"
    return 1
esac

TOOLCHAIN="${NDK}/toolchains/llvm/prebuilt/${OS,,}-x86_64"
API="${API:-21}"

function setup_toolchain() {
    local binutils_target
    local abi
    case "${TARGET}" in
        armv7a-*)
            export CFLAGS="${CFLAGS:-} -fsigned-char -march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb"
            export CXXFLAGS="${CXXFLAGS:-} -fsigned-char -march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb"
            export LDFLAGS="${LDFLAGS:-} -march=armv7-a -Wl,--fix-cortex-a8"
            binutils_target=arm-linux-androideabi
            abi=armeabi-v7a ;;
        aarch64-*)
            abi=arm64-v8a ;;
        i686-*)
            abi=x86 ;;
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
    export CC="ccache ${TOOLCHAIN}/bin/${TARGET}${API}-clang"
    export CXX="ccache ${TOOLCHAIN}/bin/${TARGET}${API}-clang++"
    export LD="${TOOLCHAIN}/bin/${binutils_target}-ld"
    export RANLIB="${TOOLCHAIN}/bin/${binutils_target}-ranlib"
    export STRIP="${TOOLCHAIN}/bin/${binutils_target}-strip"
    echo "Android toolchain configured for ABI: ${abi}"
}

setup_toolchain
