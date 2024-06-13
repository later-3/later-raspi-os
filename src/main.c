#include "utils.h"
#include "printf.h"
#include "peripheral/aux_uart.h"

volatile unsigned int *const UART0DR = (unsigned int *) 0x3F201000;

void print_uart0(const char *s) {
    while (*s != '\0') {
        *UART0DR = (unsigned int)(*s);
        s++;
    }
}

void  rp3_init(void)
{
    extern char bss_begin[], bss_end[];

    memset_rsp(bss_begin, 0, bss_end - bss_begin);

    aux_uart_init();
    init_printf(0, putc);
    printf("rp3_init\n");
}

void rp3_core0_init(void)
{
    printf("rp3_core0_init\n");
    while (1) {
        uart_putchar(uart_getchar());
    }
}

int g;
void c_entry(int cpuID) {
    char id;
    // delay(10);
    if (cpuID == 0) {
        rp3_init();
    }

    if (cpuID != 0) {
        delay(100000000 * cpuID);
    }
    id = cpuID + '0';
    printf("Hello world g %d\n", g);
    // printf(&id);
    // printf("\r\n");

    if (cpuID == 0) {
        rp3_core0_init();
    } else {
        sleep();
    }
}