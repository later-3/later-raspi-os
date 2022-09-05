This is a os for raspi3b, which test on qemu.

# asm

- wfe
  
  wait for event
  
  ARM中有一个全局的事件寄存器：event register，系统中的每一个CPU核在这个寄存器上都有对应的位。当CPU执行wfe指令的时候，如果事件寄存器对应当前CPU的位没有被设置为0，则当前CPU进入低功耗模式，会被挂起，不会再执行其他操作。如果事件寄存器对应当前的CPU的位被设置了，也就是1，则会将时间寄存器对应当前的CPU位清空位0，然后立即返回，继续执行下面的指令，不会进入低功耗模式。
  
  [ARM64平台下WFE和SEV相关指令解析_Roland_Sun的博客-CSDN博客_arm sev](https://blog.csdn.net/Roland_Sun/article/details/107456179)
- cbz
  
  compare and branch on zero
- cbnz
  
  compare and branch on non-zero