#include "mm.h"
#include "sysregs.h"

.section ".text.boot"
.global _start
_start:
    mrs     x1, CurrentEL
    and     x1, x1, #0xc
    cmp     x1, #8
    beq     el2
    cmp     x1, #0xc
    beq     el3

el1:
    and     x1, x1, #3
    cbz     x1, master
    cbnz    x1, setup_stack
    cmp     x1, #1
    beq     setup_stack
    cmp     x1, #2
    beq     setup_stack
    cbnz    x1, 2f

el3:
    ldr     x2, =SCREL3_VALUE
    msr     scr_el3, x2
    ldr     x2, =SPSREL3_VALUE
    msr     spsr_el3, x2
    adr     x2, el1
    msr     elr_el3, x2

    bl      get_cpuid

    eret

    //mrs     x1, mpidr_el3
   
    //b 1b

el2:
    /* Enable CNTP for EL1. */
    mrs     x0, cnthctl_el2
    orr     x0, x0, #3
    msr     cnthctl_el2, x0
    msr     cntvoff_el2, xzr

    /* Enable AArch64 in EL1. */
    mov     x0, #(1 << 31)      /* AArch64 */
    orr     x0, x0, #(1 << 1)   /* SWIO hardwired on Pi3 */
    msr     hcr_el2, x0
    mrs     x0, hcr_el2

    /* Setup SCTLR access. */
    mov     x2, #0x0800
    movk    x2, #0x30d0, lsl #16
    msr     sctlr_el1, x2

    ldr     x2, =SCTLR_VALUE_MMU_DISABLED
    msr     sctlr_el1, x2

    /* Change execution level to EL1. */
    ldr     x2, =SPSREL2_VALUE
    msr     spsr_el2, x2
    
    adr     x2, el1
    msr     elr_el2, x2

    bl      get_cpuid

    eret

    //b 1b

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
