#include <cstdio>
#include <iostream>
#include <string.h>

using namespace std;

int bit(char c, int i)
{
    int res = c & (1 << i);
    return res == 0 ? 0 : 1;
}

void print_char_bin(char c)
{
    for (int i = 0; i < 8; ++i) {
        printf("%d", bit(c, 8 - i - 1));
        if (i == 3) printf(" ");
    }
}

void double2str(double *in, char *out_buf)
{
    sprintf(out_buf, "%f", *in);
    char* s = (char*)malloc(8);
    memcpy(s, in, 8);

    for (int i = 0; i < 8; ++i)
    {
        print_char_bin(s[8 - i - 1]);
        printf(" ");
    }

    free(s);
}

int main(int argc, char ** argv)
{
    (void)argc;(void)argv;

    char buf[100];
    double d = -0.0;
    double* pd = &d;

    double2str(pd, buf);
    return 0;
}
