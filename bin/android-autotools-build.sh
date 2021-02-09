[[ -n "${SOURCE_URL}" ]] || {
    >&2 echo "SOURCE_URL not set"
    return 1
}
wget -c -nv "${SOURCE_URL}"

TARBALL="${SOURCE_URL##*/}"
if [[ "${TARBALL}" == *.zip ]]
then
    STEM="${TARBALL%.zip}"
    unzip "${TARBALL}"
elif [[ "${TARBALL}" == *.t* ]]
then
    STEM="${TARBALL%.t*}"
    tar -xf "${TARBALL}"
else
    >&2 echo "Don't know how to handle file ${TARBAL}"
    return 1
fi

INSTALL_DIR="${INSTALL_DIR:-${HOME}/android-deps}"
INSTALL_SUBDIR="${INSTALL_DIR}/${STEM}"
CFLAGS_ORIG="${CFLAGS:-}"
CXXFLAGS_ORIG="${CXXFLAGS:-}"
LDFLAGS_ORIG="${LDFLAGS:-}"

function configure_target_default() {
    export CFLAGS="${CFLAGS_ORIG}"
    export CXXFLAGS="${CXXFLAGS_ORIG}"
    export LDFLAGS="${LDFLAGS_ORIG}"
    source "${THIS_DIR}/android-setup-toolchain.sh"

    local configure_args
    if [[ -n "${CONFIGURE_NO_DEFAULT_ARGS}" ]]
    then
        configure_args=("${CONFIGURE_ARGS[@]}")
    else
        configure_args=(
            --prefix="${INSTALL_SUBDIR}/${ABI}" \
            --host="${TARGET}" \
            --enable-static \
            --enable-shared=no \
            --with-pic 
        )
        [[ -z "${CONFIGURE_ARGS}" ]] || configure_args+=("${CONFIGURE_ARGS[@]}")
    fi

    if [[ $( type -t configure_hook 2> /dev/null ) == "function" ]]
    then
        configure_hook "${configure_args[@]}" "$@"
    else
        ./configure "${configure_args[@]}" "$@"
    fi
}

if [[ $( type -t configure_target 2> /dev/null ) != "function" ]]
then
    function configure_target() {
        configure_target_default "$@"
    }
fi

function build_target_default() {
    configure_target "$@"

    local nproc
    nproc=$( nproc --all 2> /dev/null || sysctl -n hw.ncpu )

    make "-j${nproc}" install
    make distclean
}

if [[ $( type -t build_target 2> /dev/null ) != "function" ]]
then
    function build_target() {
        build_target_default "$@"
    }
fi

TARGETS="${TARGETS:-armv7a-linux-androideabi aarch64-linux-android i686-linux-android x86_64-linux-android}"

rm -rf "${INSTALL_SUBDIR}"
pushd "${STEM}"
echo "*" > .gitignore
for TARGET in ${TARGETS}
do
    build_target "$@"
done
popd
pushd "${INSTALL_DIR}"
rm -rf "${STEM}.tar.bz2"
tar -chaf "${STEM}.tar.bz2" "${STEM}"
popd
