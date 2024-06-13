.global memzero
memzero:
    mov     x2, #1
    str     x2, [x0], #8
    subs    x1, x1, #8
    b.gt    memzero
    ret    
    