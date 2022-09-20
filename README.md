# 前言

本章节的任务就是: 打印 `hello world` 到屏幕上。

## 运行
```c
make all
make run
```
注：需要安装好 `aarch64-linux-gnu-` 工具链，安装或者编译`qemu`

## Hardware

[RPi Hardware - eLinux.org](https://elinux.org/RPi_Hardware)
[documentation/bcm2837.adoc at develop · raspberrypi/documentation · GitHub](https://github.com/raspberrypi/documentation/blob/develop/documentation/asciidoc/computers/processors/bcm2837.adoc)[BCM2837-ARM-Peripherals.-.Revised.-.V2-1.pdf](file:///C:/Users/later/AppData/Local/Temp/MicrosoftEdgeDownloads/4b2d2e7d-a513-48cb-8208-6b8d47ec5722/BCM2837-ARM-Peripherals.-.Revised.-.V2-1.pdf)
[bcm2836-peripherals.pdf (raspberrypi.com)](https://datasheets.raspberrypi.com/bcm2836/bcm2836-peripherals.pdf)

Raspberry Pi 3  BCM2837 SoC


# Prerequisites

- cross-compiler
- qemu

# start script

```
qemu-system-aarch64 -M raspi3b -kernel kernel8.img -drive file=$(your image file),if=sd,format=raw -serial stdio
```

**-serial null -serial stdio**

Finally the last argument redirects the emulated UART0 to the standard input/output of the terminal running qemu, so that everything
sent to the serial line will be displayed, and every key typed in the terminal will be received by the vm. Only works with the
tutorials 05 and above, as UART1 is *not* redirected by default. For that, you would have to add something like `-chardev socket,host=localhost,port=1111,id=aux -serial chardev:aux` (thanks [@godmar](https://github.com/godmar) for the info),
or simply use two `-serial` arguments (thanks [@cirosantilli](https://github.com/cirosantilli)).

**!!!WARNING!!!** Qemu emulation is rudimentary, only the most common peripherals are emulated! **!!!WARNING!!!**

# ARM
[Stanford CS140e - Operating Systems (sergio.bz)](https://cs140e.sergio.bz/assignments/3-spawn/)
[A Guide to ARM64 / AArch64 Assembly on Linux with Shellcodes and Cryptography | modexp (wordpress.com)](https://modexp.wordpress.com/2018/10/30/arm64-assembly/)
[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a)
[DDI0487_I_a_a-profile_architecture_reference_manual.pdf](file:///C:/Users/later/Documents/DDI0487_I_a_a-profile_architecture_reference_manual.pdf)
https://developer.arm.com/documentation/ddi0500/latest/

# Boot
Qemu just put the kernel8.img on the 0x80000 and jump to the location.

## Memory Map
| ARM physical address                 | description                         |
| ------------------------ | -------------------------- |
| [0x0, 3F000000)          | Free memory                |
| [0x3F000000, 0x40000000) | MMIO                       |
| [0x40000000, 0x40020000) | ARM timer, IRQs, mailboxes |

# linking
CSAPP Chapter 7 Linking

[Linker Scripts](https://sourceware.org/binutils/docs/ld/Scripts.html)。

# BareMetal
We need use the aarch64-linux-gnu-objcopy to get the text section and data section in kernel8.img.

# Exception Level
EL0 for user programs
EL1 for kernel
We will start from EL3 in qemu raspi3b，we need change to EL1.

# asm
 
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

# reference
- [简介 - MIT6.S081 (gitbook.io)](https://mit-public-courses-cn-translatio.gitbook.io/mit6-s081/)
- [6.S081 / Fall 2020 (mit.edu)](https://pdos.csail.mit.edu/6.S081/2020/tools.html)
- [xv6: a simple, Unix-like teaching operating system (mit.edu)](https://pdos.csail.mit.edu/6.S081/2020/xv6/book-riscv-rev1.pdf)
- [Raspberry Pi Bare Bones - OSDev Wiki](https://wiki.osdev.org/Raspberry_Pi_Bare_Bones)
- [bztsrc/raspi3-tutorial: Bare metal Raspberry Pi 3 tutorials (github.com)](https://github.com/bztsrc/raspi3-tutorial)
- [s-matyukevich/raspberry-pi-os: Learning operating system development using Linux kernel and Raspberry Pi (github.com)](https://github.com/s-matyukevich/raspberry-pi-os)
- [FDUCSLG/OS-2021Fall-dev (github.com)](https://github.com/FDUCSLG/OS-2021Fall-dev/)
- [hakula139/xv6-armv8: [WIP] Xv6, a simple Unix-like teaching operating system, re-implemented for ARMv8 (AArch64), written in C (github.com)](https://github.com/hakula139/xv6-armv8)

