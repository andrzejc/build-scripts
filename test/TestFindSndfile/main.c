#include <sndfile.h>
#include <stdio.h>

int main() {
    printf("libsndfile version: %s\n", sf_version_string());
    return 0;
}
