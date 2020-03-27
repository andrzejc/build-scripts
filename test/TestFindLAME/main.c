#include <lame/lame.h>
#include <stdio.h>

int main() {
    printf("libmp3lame version: %s\n", get_lame_version());
    return 0;
}
