#include "mm.h"

.section ".text.boot"
.global _start
_start:
    // get cpuid, stop slave cores
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbnz    x1, halt
    cbz     x1, master

master:
    // clear mem
    adr     x0, bss_begin
    adr     x1, bss_end
    sub     x1, x1, x0
    bl      memzero

    ldr x30, =stack_top
    mov sp, x30
    bl c_entry
    b .

halt:
    wfe
    b halt