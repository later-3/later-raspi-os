#include "utils.h"

void memset_rsp(void *start, unsigned char val, int len)
{
    unsigned char *t = (unsigned char *)start;
    for (int i = 0; i < len; i++ ) {
        *t = val;
        t++;
    }
}