.global delay
delay:
    mov x2, x0
repeat:
    subs x2, x2, #1
    bne repeat
    ret

.global get_cpuid
get_cpuid:
    mrs     x1, mpidr_el1
    mov     x2, x1
    and     x2, x2, #3
    ret