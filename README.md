# multicore
raspberry pi 3b has four core processor ID, and after the device is powered on, each core begins to execute the same code. However, we don't want to work with four cores; we want to only with the first one and put all of the other cores in an endless loop.

增加了一个清理bss区域的动作，也就是全局变量区域清0。在前一个章节，我们使用了cpu0，这个章节把其余三个cpu也使用起来。

include/hw/arm/bcm2836.h
#define BCM283X_NCPUS 4

hw/arm/raspi.c
mc->min_cpus = 1;
mc->default_cpus = 2;
mc->max_cpus = 4;

```shell
❯ make run
/root/code/qemu-9.0.0-rc0/build/qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -nographic
Hello world 0
Hello world 1
Hello world 2
Hello world 3
```