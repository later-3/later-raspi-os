#include "utils.h"
#include "printf.h"
#include "peripheral/timer.h"

const unsigned int interval = 200000;
unsigned int curVal = 0;
unsigned int curVal_3 = 0;

void timer_init ( void )
{
	curVal = read_reg(TIMER_CLO);
	curVal += interval;
	write_reg(TIMER_C1, curVal);
}

void timer_init_3 ( void )
{
	curVal_3 = read_reg(TIMER_CLO);
	curVal_3 += interval;
	write_reg(TIMER_C3, curVal_3);
}



void handle_timer_irq( void ) 
{
	curVal += interval;
	write_reg(TIMER_C1, curVal);
	write_reg(TIMER_CS, TIMER_CS_M1);
	printf("Timer 1 interrupt received\n\r");
}



void handle_timer_irq_3( void ) 
{
	curVal_3 += interval;
	write_reg(TIMER_C3, curVal_3);
	write_reg(TIMER_CS, TIMER_CS_M3);
	printf("Timer 3 interrupt received\n\r");
}


