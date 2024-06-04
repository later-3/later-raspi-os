# 前言

本章节的任务就是: 打印 `hello world` 到屏幕上。主要是参考(或**照抄**)了[复旦大学的OS实验](https://github.com/FDUCSLG/OS-2020Fall-FDU)，以及其他相关的仓库，在之前的Readme中的参考区域已经列出来了。

## 运行
```c
make all
make run
```
注：需要安装好 `aarch64-linux-gnu-` 工具链，安装或者编译`qemu`

目前我是下载的QEMU的9.0版本，这个版本是有树莓派4的仿真的。

# Boot
Qemu just put the kernel8.img on the 0x80000 and jump to the location.
我调整了下之前Readme章节的顺序，之前的顺序逻辑性不强。现在以需要再屏幕上打印`hello world`为目标，逐步展开。
拆解目标：
- 1、如何让QEMU-Raspi3b运行自己写的代码？
- 2、代码该如何编写？

## 1、如何让QEMU-Raspi3b运行自己写的代码？
这是两个大的目标，先看第一个，raspi3b是一个arm单板，需要知道板子上电流程，官方资料：[Boot Loader](https://github.com/raspberrypi/firmware/tree/master/boot)，其实我们根本不用看这个资料，因为我们只是想在QEMU-Raspi3b上跑起来，参考其他的项目的启动脚本的`-kernel kernel8.img`，在仿真代码里面就需要指定cpu上电执行代码的地址，所以先看看仿真代码。

```c
    #define FIRMWARE_ADDR_3 0x80000
    if (machine->firmware) {
        hwaddr firmware_addr = processor_id <= PROCESSOR_ID_BCM2836
                             ? FIRMWARE_ADDR_2 : FIRMWARE_ADDR_3;
        /* load the firmware image (typically kernel.img) */
        r = load_image_targphys(machine->firmware, firmware_addr,
                                ram_size - firmware_addr);
        if (r < 0) {
            error_report("Failed to load firmware from %s", machine->firmware);
            exit(1);
        }

        s->binfo.entry = firmware_addr;
        s->binfo.firmware_loaded = true;
```
加载地址是 `0x80000`，指示了我们写的代码的起始地址。这里还要跟踪下串口信息，仿真了两个串口：
```c
    /* UART0 */
    object_initialize_child(obj, "uart0", &s->uart0, TYPE_PL011);

    /* AUX / UART1 */
    object_initialize_child(obj, "aux", &s->aux, TYPE_BCM2835_AUX);

    /* UART0 */
    qdev_prop_set_chr(DEVICE(&s->uart0), "chardev", serial_hd(0));

    /* AUX / UART1 */
    qdev_prop_set_chr(DEVICE(&s->aux), "chardev", serial_hd(1));
```
第一个串口是`pl011`，第二个是树莓派3b的`aux`（为了方便，树莓派3b以及raspi3b我都用r3b表示了）。
把两个串口控制器的基址查看下，两种方法，一种是直接看代码，一种是直接跑起来（就用QEMU拉起r3b就好了，其他参数不用管）在monitor里面查看`info mtree`, 列出其中一些：
```
address-space: memory
  0000000000000000-ffffffffffffffff (prio 0, i/o): system
    0000000000000000-000000003fffffff (prio 0, ram): ram
    000000003f000000-000000003fffffff (prio 1, i/o): bcm2835-peripherals
      000000003f200000-000000003f200fff (prio 0, i/o): bcm2835_gpio
      000000003f201000-000000003f201fff (prio 0, i/o): pl011
      000000003f215000-000000003f2150ff (prio 0, i/o): bcm2835-aux
      000000003f300000-000000003f3000ff (prio 0, i/o): sdhci
    0000000040000000-00000000400000ff (prio 0, i/o): bcm2836-control
```

## 2、代码该如何编写？
这次的代码相对来说，很简单，仅仅设置了栈，将其余的core停在了wfe，随即就跳转到了c函数，c语言是必要使用栈的。在c语言中，直接向`pl011`的寄存器空间传输字符串。可以看`pl011`的仿真代码，对于寄存器的写动作，偏移为0的情况下，会直接将字符显示到串口的。可以从上面的地址空间看到，`pl011`的寄存器的起始地址是`0x3f201000`,这和代码里面一致。

在仿真代码中，`raspi_machine_class_common_init`函数设置了
```c
mc->default_cpus = mc->min_cpus = mc->max_cpus = cores_count(board_rev);
```
默认的cpu个数为4，在仿真代码中，cpu的启动地址都为0x300,在`hw/arm/boot.c/`的`do_cpu_reset`会设置cpu0的地址`cpu_set_pc(cs, info->loader_start);`为`0x80000`.

在gdb里面，`info threads`可以查看不同的cpu，配合`threads 1.x`切换不同的cpu。因为我们自己处理每个cpu，所以不用默认的`firmware`,不过也看到了QEMU在仿真代码里面，如何做一个简易的`firmware`，`mpidr_el1`这个寄存器里面可以判断当前的cpuID，在arm编程指南里面有说读取`mpidr_el1`可以判断，但`mpidr_el1`是可以被更改的，`mpidr_el3`才是不会变的。最好是读取`mpidr_el3`,当然得有权限读取，如果没有那就读取`mpidr_el1`。但是编译直接报错，`unknown or missing system register name at operand 2 -- mrs x1,mpidr_el3`,而且在arm手册中也没有搜索到`mpidr_el3`，至于arm编程手册为啥会出现`mpidr_el3`，不纠结了，直接读取`mpidr_el1`。

```asm
cbz 等于0跳转
cbnz 不等于0跳转
```

在aarch64中，一条汇编由4个字节组成，以第一条指令为例，`mrs     x1, CurrentEL`，来看看这个条汇编的机器码：
```shell
❯ xxd build/kernel8.img     
00000000: 4142 38d5 2104 7e92 3f20 00f1 6001 0054  AB8.!.~.? ..`..T
```

使用在线的[arm汇编翻译](https://yozan233.github.io/Online-Assembler-Disassembler/)也可以看到一样的。
```asm
Disassembly:

0x10000:      41 42 38 D5            mrs     x1, CurrentEL
```
mrs是将系统寄存器的值读到通用寄存器中，在arm手册里面有`AArch64 System Register Descriptions`可以查看各个系统寄存器的介绍。将十六进制转为二进制与QEMU仿真代码的翻译规则对比：
```
0xd5384241 -> 0b1101 0101 0011 1000 0100 0010 0100 0001
```
r3b使用的是 ARM Cortex-A53 处理器，属于 ARMv8 架构的 64 位处理器。在`target/arm/tcg/a64.decode`，找到MRS的匹配规则：
```
SYS             1101 0101 00 l:1 01 op1:3 crn:4 crm:4 op2:3 rt:5 op0=1
SYS             1101 0101 00 l:1 10 op1:3 crn:4 crm:4 op2:3 rt:5 op0=2
SYS             1101 0101 00 l:1 11 op1:3 crn:4 crm:4 op2:3 rt:5 op0=3
```
最高位的10bits是能够匹配上的，匹配规则可以在arm手册中找到：
![](https://raw.githubusercontent.com/later-3/img_picgo/main/img/20240604083728.png)

`make qemu-gdb`运行QEMU的终端，`make gdb`可以查看其他cpu会执行到wfe，而cpu0会跳转到c函数，往串口输出`hello world`

## Hardware

[RPi Hardware - eLinux.org](https://elinux.org/RPi_Hardware)

[documentation/bcm2837.adoc at develop · raspberrypi/documentation · GitHub](https://github.com/raspberrypi/documentation/blob/develop/documentation/asciidoc/computers/processors/bcm2837.adoc)

[BCM2837-ARM-Peripherals.-.Revised.-.V2-1.pdf]

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

[DDI0487_I_a_a-profile_architecture_reference_manual.pdf]

https://developer.arm.com/documentation/ddi0500/latest/



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
- EL0 for user programs
- EL1 for kernel

We will start from EL3 in qemu raspi3b，we need change to EL1.

# asm
 
This is a os for raspi3b, which test on qemu.
