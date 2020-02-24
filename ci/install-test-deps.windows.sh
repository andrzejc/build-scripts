# Note: libsndfile installer from http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe is
# unusable for use on CI because it shows "donate or f**k off" dialog box

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
bin/safe-download http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe \
    install \
    f17f4d2e14d332b88b4ab9847d489f44e9e3406b

set -x

# HACK: installer shows modal dialog box from subprocess sndfile-about.exe, but this is Windows
# native process and we can't get its pid (tasklist shows truncated commands so it doesn't help).
# Just wait a bit and kill the parent
install/libsndfile-1.0.28-w64-setup.exe /VERYSILENT &
SF_PID=$!
sleep 10
ps -ef | grep $SF_PID | grep -v grep
kill "${SF_PID}"

set +x
