# Note: libsndfile installer from http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28-w64-setup.exe is
# unusable for use on CI because it shows "donate or f**k off" dialog box

# Emulate installation of libsndfile via binary installer
bin/safe-download \
    https://github.com/bastibe/libsndfile-binaries/archive/1.0.27.tar.gz \
    install \
    7886e3d381020f2374e272652c3438c2
tar -xf install/1.0.27.tar.gz -C install
mkdir -p "/C/Program Files/Mega-Nerd/libsndfile/lib" \
    "/C/Program Files/Mega-Nerd/libsndfile/include"
cp install/libsndfile-binaries-1.0.27/libsndfile64bit.dll \
    "/C/Program Files/Mega-Nerd/libsndfile/lib/libsndfile-1.dll"
bin/dll2lib "/C/Program Files/Mega-Nerd/libsndfile/lib/libsndfile-1.dll" x64
tar -xf test/deps/libsndfile1-win64-include.tar.bz2 \
    -C "/C/Program Files/Mega-Nerd/slibsndfile/include"
