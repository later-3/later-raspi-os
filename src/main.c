#include "utils.h"
#include "peripheral/aux_uart.h"

volatile unsigned int *const UART0DR = (unsigned int *) 0x3F201000;

void print_uart0(const char *s) {
    while (*s != '\0') {
        *UART0DR = (unsigned int)(*s);
        s++;
    }
}

void rp3_core0_init(void)
{
    aux_uart_init();
    while (1) {
        uart_putchar(uart_getchar());
    }
}

void c_entry(int cpuID) {
    char id;
    // delay(10);
    if (cpuID != 0) {
        delay(100000000 * cpuID);
    }
    id = cpuID + '0';
    print_uart0("Hello world ");
    print_uart0(&id);
    print_uart0("\r\n");

    if (cpuID == 0) {
        rp3_core0_init();
    } else {
        sleep();
    }
}