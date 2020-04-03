
set -e
set -o pipefail

# Required for safe-download script
choco install openssl.light

bin/winstall-portaudio "${TARGET_PLATFORM}"

case "${TARGET_PLATFORM}" in
*64)
    bin/winstall-libsndfile "${TARGET_PLATFORM}" http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe 3783e513d735d1526f19a32a63991026
    bin/winstall-fftw3 "${TARGET_PLATFORM}" ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip 409f4a5272506eb7422d265a68a02deeefcb5c17
    bin/winstall-mpg123 "${TARGET_PLATFORM}" http://mpg123.de/download/win64/1.25.13/mpg123-1.25.13-x86-64.zip 809e847de9169e63b65d1593d163977c2fca5a65
    bin/winstall-lame "${TARGET_PLATFORM}" https://github.com/andrzejc/libmp3lame-windows-release/releases/download/3.100/lame-3.100-win-amd64.zip b1286ef97251d1f64e1f47a87cf462eb84447561
    ;;
*in32|*86)
    bin/winstall-libsndfile "${TARGET_PLATFORM}" http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w32-setup.exe 443a2a2890969778e8f9fe6a146c0595
    bin/winstall-fftw3 "${TARGET_PLATFORM}" ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll32.zip b19d875b07a0e4ac8251b0aa072321582374e000
    bin/winstall-mpg123 "${TARGET_PLATFORM}" http://mpg123.de/download/win32/1.25.13/mpg123-1.25.13-x86.zip 4af3c0e278dab84e9d2c503c30a0517aa5d40205
    bin/winstall-lame "${TARGET_PLATFORM}" https://github.com/andrzejc/libmp3lame-windows-release/releases/download/3.100/lame-3.100-win-x86.zip 609bcfd655c24b7a2dfbb73c6e564bd23fb6d09c
    ;;
*)
    >&2 echo "Installation of libsndfile for target '${TARGET_PLATFORM}' is not supported"
    return 1 ;;
esac
