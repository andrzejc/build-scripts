#include <fdk-aac/aacenc_lib.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    LIB_INFO li[FDK_MODULE_LAST] = {};

    if (AACENC_OK == aacEncGetLibInfo(li)) {
        for (int i = 0; i < FDK_MODULE_LAST; ++i) {
            if (FDK_AACENC == li[i].module_id) {
                printf("libfdk-aac version: %s\n", li[0].versionStr);
                return EXIT_SUCCESS;
            }
        }
    }
    return EXIT_FAILURE;
}
