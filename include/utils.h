#ifndef	_UTILS_H
#define	_UTILS_H

extern void delay ( unsigned long);
extern void get_cpuid ( unsigned long);

extern unsigned int read_reg ( unsigned int);
extern void write_reg ( unsigned int, unsigned int);

extern void sleep ( void);
void memset_rsp(void *start, unsigned char val, int len);

#endif