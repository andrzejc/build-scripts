#include <portaudio.h>
#include <stdio.h>

int main() {
    printf("libportaudio version: %s\n", Pa_GetVersionText());
    return 0;
}
