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

char choose = '1';
void rp3_core0_init(void)
{
    printf("rp3_core0_init\n");
    irq_vector_init();

    // while (1) {
    //     uart_putchar(uart_getchar());
    // }

	while(1){	
		printf("If you want stop timer，just enter any key\n\r");
		printf("Please choose a timer number 1 or 3\n\r");
		choose = uart_getchar();
		printf("Your choice:%c\n\r", choose);
		switch (choose) {
			case '1':
				timer_init();
				break;
			case '3':
				timer_init_3();
				break;
			default:
				printf("Undefine choose: %d\r\n", choose);
		}

		enable_interrupt_controller();
		enable_irq();
		uart_putchar(uart_getchar());
		disable_irq();
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