#include <mpg123.h>
#include <stdio.h>

int main() {
    if (MPG123_OK == mpg123_init()) {
        printf("libmpg123 init ok\n");
        mpg123_exit();
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}
