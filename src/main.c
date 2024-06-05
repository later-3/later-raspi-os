volatile unsigned int *const UART0DR = (unsigned int *) 0x3F201000;

void
print_uart0(const char *s) {
    while (*s != '\0') {
        *UART0DR = (unsigned int)(*s);
        s++;
    }
}

extern void delay ( unsigned long);
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

}