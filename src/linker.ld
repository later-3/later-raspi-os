ENTRY(_start)
SECTIONS
{
    . = 0x80000;
    .text.boot : {
		KEEP(*(.text.boot))
		*(.text)
    }
    .text : { *(.text) }
    .data : { *(.data) }
    . = ALIGN(8);
    PROVIDE(bss_begin = .);
    .bss : { *(.bss*) }
    PROVIDE(bss_end = .);
    . = . + 0x1000; /* 4kB of stack memory */
    stack_top = .;
}
