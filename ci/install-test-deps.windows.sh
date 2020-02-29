
set -e
set -o pipefail

# Required for safe-download script
choco install openssl.light

bin/winstall-portaudio "${TARGET_PLATFORM}"

case "${TARGET_PLATFORM}" in
*64)
    bin/winstall-exe https://sourceforge.net/projects/boost/files/boost-binaries/1.72.0/boost_1_72_0-msvc-14.1-32.exe 121e069354cc792a3b1bb42fe7285e5380beea45 /VERYSILENT
    bin/winstall-libsndfile "${TARGET_PLATFORM}" http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe 3783e513d735d1526f19a32a63991026
    bin/winstall-fftw3 "${TARGET_PLATFORM}" ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip 409f4a5272506eb7422d265a68a02deeefcb5c17
    ;;
*in32|*86)
    bin/winstall-exe https://sourceforge.net/projects/boost/files/boost-binaries/1.72.0/boost_1_72_0-msvc-14.1-64.exe f49cd0c11976a9bb4e5edd3e8111e61fd0b859ac /VERYSILENT
    bin/winstall-libsndfile "${TARGET_PLATFORM}" http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w32-setup.exe 443a2a2890969778e8f9fe6a146c0595
    bin/winstall-fftw3 "${TARGET_PLATFORM}" ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll32.zip b19d875b07a0e4ac8251b0aa072321582374e000
    ;;
*)
    >&2 echo "Installation of libsndfile for target '${TARGET_PLATFORM}' is not supported"
    return 1 ;;
esac
