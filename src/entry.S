#include "mm.h"

.section ".text.boot"
.global _start
_start:
    mrs     x1, CurrentEL
    and     x1, x1, #0xc
    cmp     x1, #8
    beq     el2
    cmp     x1, #0xc
    beq     el3

1:
    and     x1, x1, #3
    cbz     x1, master
    cbnz    x1, setup_stack
    cmp     x1, #1
    beq     setup_stack
    cmp     x1, #2
    beq     setup_stack
    cbnz    x1, 2f

el3:
    //mrs     x1, mpidr_el3
    mrs     x1, mpidr_el1
    mov     x2, x1
    and     x2, x2, #3
    b 1b

el2:
    mrs     x1, mpidr_el1
    mov     x2, x1
    and     x2, x2, #3
    b 1b

 2: wfe
     b 2b

master:
    // clear mem
    adr     x0, bss_begin
    adr     x1, bss_end
    sub     x1, x1, x0
    bl      memzero

setup_stack:
	mrs	x0, mpidr_el1		
	and	x0, x0,#0xFF		// Check processor id
	mov 	x1, 0x4000        	// 2Kb for stack
	mul 	x1, x1, x0 		
    mov 	x2, #LOW_MEMORY		// image adresses in 0x0; Start of stack pointer do not override image
	add 	x1, x1, x2		// base + offset
	mov	sp, x1 
    bl c_entry
    b .


multi:
    ldr x30, =stack_top
    mov sp, x30
    mov x0, x2
    bl c_entry
    b .
