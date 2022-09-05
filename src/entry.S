
.section ".text.boot"
.global _start
_start:
    // get cpuid, stop slave cores
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbnz    x1, halt

    ldr x30, =stack_top
    mov sp, x30
    bl c_entry
    b .

halt:
    wfe
    b halt