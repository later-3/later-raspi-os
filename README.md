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
