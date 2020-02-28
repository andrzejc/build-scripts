#include <fftw3.h>
#include <stdio.h>

#define CAT(a, ...) PRIMITIVE_CAT(a, __VA_ARGS__)
#define PRIMITIVE_CAT(a, ...) a ## __VA_ARGS__

int main() {
    printf("libfftw3 version: %s\n", CAT(FFTW_PREFIX, version));
    // This will make sure the _threads libraries are linked in
    if (CAT(FFTW_PREFIX, init_threads)()) {
        CAT(FFTW_PREFIX, cleanup_threads)();
    }
    return 0;
}
