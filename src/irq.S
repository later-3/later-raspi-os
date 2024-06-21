.global irq_vector_init
irq_vector_init:
    adr x0, vectors
    msr vbar_el1, x0
    ret

.global enable_irq
enable_irq:
    msr daifclr, #2
    ret

.global disable_irq
disable_irq:
    msr DAIFSet, #2
    ret