This is a os for raspi3b, which test on qemu.
# 前言
这是一个为了学习arm汇编和arm体系结构的项目，切换不同分支开始学习吧！Enjoy!

# asm

- wfe
  
  wait for event
  
  ARM中有一个全局的事件寄存器：event register，系统中的每一个CPU核在这个寄存器上都有对应的位。当CPU执行wfe指令的时候，如果事件寄存器对应当前CPU的位没有被设置为0，则当前CPU进入低功耗模式，会被挂起，不会再执行其他操作。如果事件寄存器对应当前的CPU的位被设置了，也就是1，则会将时间寄存器对应当前的CPU位清空位0，然后立即返回，继续执行下面的指令，不会进入低功耗模式。
  
  [ARM64平台下WFE和SEV相关指令解析_Roland_Sun的博客-CSDN博客_arm sev](https://blog.csdn.net/Roland_Sun/article/details/107456179)
- cbz
  
  compare and branch on zero
- cbnz
  
  compare and branch on non-zero

# reference
- [简介 - MIT6.S081 (gitbook.io)](https://mit-public-courses-cn-translatio.gitbook.io/mit6-s081/)
- [6.S081 / Fall 2020 (mit.edu)](https://pdos.csail.mit.edu/6.S081/2020/tools.html)
- [xv6: a simple, Unix-like teaching operating system (mit.edu)](https://pdos.csail.mit.edu/6.S081/2020/xv6/book-riscv-rev1.pdf)
- [Raspberry Pi Bare Bones - OSDev Wiki](https://wiki.osdev.org/Raspberry_Pi_Bare_Bones)
- [bztsrc/raspi3-tutorial: Bare metal Raspberry Pi 3 tutorials (github.com)](https://github.com/bztsrc/raspi3-tutorial)
- [s-matyukevich/raspberry-pi-os: Learning operating system development using Linux kernel and Raspberry Pi (github.com)](https://github.com/s-matyukevich/raspberry-pi-os)
- [FDUCSLG/OS-2021Fall-dev (github.com)](https://github.com/FDUCSLG/OS-2021Fall-dev/)
- [hakula139/xv6-armv8: [WIP] Xv6, a simple Unix-like teaching operating system, re-implemented for ARMv8 (AArch64), written in C (github.com)](https://github.com/hakula139/xv6-armv8)


