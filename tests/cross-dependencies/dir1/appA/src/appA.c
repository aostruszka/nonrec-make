#include "libA.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    (void) argc; (void) argv; // shut compiler up

    printf("%d\n", funcA(42));
    return 0;
}
