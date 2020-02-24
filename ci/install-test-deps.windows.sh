
# Required for safe-download script
choco install openssl.light
choco install ninja

# Emulate installation of libsndfile via binary installer
# bin/safe-download \
#     https://github.com/bastibe/libsndfile-binaries/archive/1.0.27.tar.gz \
#     install \
#     7886e3d381020f2374e272652c3438c2
# tar -xf install/1.0.27.tar.gz -C install
# mkdir -p "/C/Program Files/Mega-Nerd/libsndfile/lib" \
#     "/C/Program Files/Mega-Nerd/libsndfile/include" \
#     "/C/Program Files/Mega-Nerd/libsndfile/bin"
# cp install/libsndfile-binaries-1.0.27/libsndfile64bit.dll \
#     "/C/Program Files/Mega-Nerd/libsndfile/lib/libsndfile-1.dll"
# bin/dll2lib "/C/Program Files/Mega-Nerd/libsndfile/lib/libsndfile-1.dll" x64
# tar -xf test/deps/libsndfile1-win64-include.tar.bz2 \
#     -C "/C/Program Files/Mega-Nerd/libsndfile/include"
# mv "/C/Program Files/Mega-Nerd/libsndfile/lib/libsndfile-1.dll" \
#     "/C/Program Files/Mega-Nerd/libsndfile/bin"

function install_libsndfile {
    local url="$1"
    local hash="$2"
    local installer_file=
    local temp_dir=
    temp_dir=$( mktemp -d )
    trap "rm -rf '${temp_dir}'" EXIT
    installer_file=$( bin/safe-download "${url}" "${temp_dir}" "${hash}" )
    # HACK: installer shows modal dialog box from subprocess sndfile-about.exe asking to donate
    # (thank you, Erik de Castro Lopo, this is great for CI), but this is Windows
    # native process and we can't get its pid (tasklist shows truncated commands so it doesn't help).
    # Just wait a bit and kill the parent.
    MSYS_NO_PATHCONV=1 "${installer_file}" /VERYSILENT &
    local pid=$!
    sleep 10
    kill "${pid}"
}

case "${TARGET_PLATFORM:-x64}" in
x64)
    install_libsndfile http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe 3783e513d735d1526f19a32a63991026 ;;
Win32)
    install_libsndfile http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w32-setup.exe 443a2a2890969778e8f9fe6a146c0595 ;;
*)
    >&2 echo "Installation of libsndfile for this target is not supported"
    return 1 ;;
esac
