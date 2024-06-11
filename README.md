# uart1
本次任务是使能uart1，操作uart1。在前述章节都偷懒使用的是`pl011`,我们根本没有为串口写任何驱动，直接走后门，往串口地址输出，就显示文字了，为了能够熟悉rp3的硬件，熟悉如何操作这些硬件，我们需要将输出任务交给rp3的串口模块：mini-uart

# 硬件信息
https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
这里能看到uart相关的寄存器信息，但是偏移和仿真的板子有点差异：
```
memory-region: bcm2835-peripherals
  000000003f000000-000000003fffffff (prio 1, i/o): bcm2835-peripherals
    000000003f003000-000000003f00301f (prio 0, i/o): bcm2835-sys-timer
    000000003f004000-000000003f004fff (prio -1000, i/o): bcm2835-txp
    000000003f006000-000000003f006fff (prio 0, i/o): mphi
    000000003f007000-000000003f007fff (prio 0, i/o): bcm2835-dma
    000000003f00b200-000000003f00b3ff (prio 0, i/o): bcm2835-ic
    000000003f00b400-000000003f00b43f (prio -1000, i/o): bcm2835-sp804
    000000003f00b800-000000003f00bbff (prio 0, i/o): bcm2835-mbox
    000000003f100000-000000003f1001ff (prio 0, i/o): bcm2835-powermgt
    000000003f101000-000000003f102fff (prio 0, i/o): bcm2835-cprman
    000000003f104000-000000003f10400f (prio 0, i/o): bcm2835-rng
    000000003f200000-000000003f200fff (prio 0, i/o): bcm2835_gpio
    000000003f201000-000000003f201fff (prio 0, i/o): pl011
    000000003f202000-000000003f202fff (prio 0, i/o): bcm2835-sdhost
    000000003f203000-000000003f2030ff (prio -1000, i/o): bcm2835-i2s
    000000003f204000-000000003f204017 (prio 0, i/o): bcm2835-spi
    000000003f205000-000000003f205023 (prio 0, i/o): bcm2835-i2c
    000000003f20f000-000000003f20f07f (prio -1000, i/o): bcm2835-otp
    000000003f212000-000000003f212007 (prio 0, i/o): bcm2835-thermal
    000000003f214000-000000003f2140ff (prio -1000, i/o): bcm2835-spis
    000000003f215000-000000003f2150ff (prio 0, i/o): bcm2835-aux
    000000003f300000-000000003f3000ff (prio 0, i/o): sdhci
    000000003f600000-000000003f6000ff (prio -1000, i/o): bcm2835-smi
    000000003f804000-000000003f804023 (prio 0, i/o): bcm2835-i2c
    000000003f805000-000000003f805023 (prio 0, i/o): bcm2835-i2c
    000000003f900000-000000003f907fff (prio -1000, i/o): bcm2835-dbus
    000000003f910000-000000003f917fff (prio -1000, i/o): bcm2835-ave0
    000000003f980000-000000003f990fff (prio 0, i/o): dwc2
      000000003f980000-000000003f980fff (prio 0, i/o): dwc2-io
      000000003f981000-000000003f990fff (prio 0, i/o): dwc2-fifo
    000000003fc00000-000000003fc00fff (prio -1000, i/o): bcm2835-v3d
    000000003fe00000-000000003fe000ff (prio -1000, i/o): bcm2835-sdramc
    000000003fe05000-000000003fe050ff (prio 0, i/o): bcm2835-dma-chan15
```
pdf里面的偏移是0x7E215000，仿真板子是0x3f215000,里面的寄存器是一样的：
![](https://raw.githubusercontent.com/later-3/img_picgo/main/img/20240607185722.png)

仿真里面对uart寄存器的定义：
```c
hw/char/bcm2835_aux.c
#define AUX_IRQ         0x0
#define AUX_ENABLES     0x4
#define AUX_MU_IO_REG   0x40
#define AUX_MU_IER_REG  0x44
#define AUX_MU_IIR_REG  0x48
#define AUX_MU_LCR_REG  0x4c
#define AUX_MU_MCR_REG  0x50
#define AUX_MU_LSR_REG  0x54
#define AUX_MU_MSR_REG  0x58
#define AUX_MU_SCRATCH  0x5c
#define AUX_MU_CNTL_REG 0x60
#define AUX_MU_STAT_REG 0x64
#define AUX_MU_BAUD_REG 0x68

```

