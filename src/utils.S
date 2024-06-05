.global delay
delay:
    mov x2, x0
repeat:
    subs x2, x2, #1
    bne repeat
    ret
