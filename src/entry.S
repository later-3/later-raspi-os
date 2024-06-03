
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
    cbnz    x1, 2f
    ldr x30, =stack_top
    mov sp, x30
    bl c_entry
    b .

el3:
    //mrs     x1, mpidr_el3
    mrs     x1, mpidr_el1
    b 1b

el2:
    mrs     x1, mpidr_el1
    b 1b

2: wfe
    b 2b

