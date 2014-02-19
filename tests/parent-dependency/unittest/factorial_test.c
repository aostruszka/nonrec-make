#include "factorial_lib.h"
#include <stdio.h>

int main()
{
    int n = 10;
    int expected_result = 3628800;

    int result = factorial(n);
    printf("Result: %d!\n", result);

    if (result == expected_result)
    {
        printf("PASS!\n");
        return 0;
    }
    else
    {
        printf("FAIL!\n");
        return 1;
    }
    
    return 0;
}
