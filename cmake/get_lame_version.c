#if defined(_WIN32) && !defined(WIN32)
  // LAME header relies on this nonstandard macro to declare symbols as cdecl;
  // without it: unresolved external symbol _get_lame_version referenced in function _main
  #define WIN32
#endif

#include <lame/lame.h>
#include <stdio.h>

int main() {
    printf("%s\n", get_lame_version());
    return 0;
}
