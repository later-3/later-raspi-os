#include "peripheral/aux_uart.h"
#include "peripheral/gpio.h"

void
uart_putchar(char c)
{
    while (!(read_reg(AUX_MU_LSR_REG) & 0x20))
        ;
    write_reg(AUX_MU_IO_REG, c & 0xFF);
}

char
uart_getchar()
{
    while (!(read_reg(AUX_MU_LSR_REG) & 0x01))
        ;
    return read_reg(AUX_MU_IO_REG) & 0xFF;
}

// This function is required by printf function
void putc ( void* p, char c)
{
	uart_putchar(c);
}

void aux_uart_init(void)
{
	unsigned int selector;

	selector = read_reg(GPFSEL1);
	selector &= ~(7<<12);                   // clean gpio14
	selector |= 4<<12;                      // set alt0 for gpio14
	selector &= ~(7<<15);                   // clean gpio15
	selector |= 4<<15;                      // set alt0 for gpio15
	write_reg(GPFSEL1, selector);

	write_reg(GPPUD,0);
	delay(150);
	write_reg(GPPUDCLK0,(1<<14)|(1<<15));
	delay(150);
	write_reg(GPPUDCLK0,0);

    /* Enable mini uart (this also enables access to it registers) */
    write_reg(AUX_ENABLES, 1);
    /* Disable auto flow control and disable receiver and transmitter (for now) */
    write_reg(AUX_MU_CNTL_REG, 0);
    /* Disable receive and transmit interrupts */
    write_reg(AUX_MU_IER_REG, 0);
    /* Enable 8 bit mode */
    write_reg(AUX_MU_LCR_REG, 3);
    /* Set RTS line to be always high */
    write_reg(AUX_MU_MCR_REG, 0);
    /* Set baud rate to 115200 */
    write_reg(AUX_MU_BAUD_REG, 270);
    /* Finally, enable transmitter and receiver */
    write_reg(AUX_MU_CNTL_REG, 3);
}