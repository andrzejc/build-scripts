
set -e
set -o pipefail

# Required for safe-download script
choco install openssl.light

bin/winstall-portaudio "${TARGET_PLATFORM}"

case "${TARGET_PLATFORM}" in
*64)
    bin/winstall-libsndfile http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe 3783e513d735d1526f19a32a63991026 ;;

*in32|*86)
    bin/winstall-libsndfile http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w32-setup.exe 443a2a2890969778e8f9fe6a146c0595 ;;
*)
    >&2 echo "Installation of libsndfile for target '${TARGET_PLATFORM}' is not supported"
    return 1 ;;
esac
