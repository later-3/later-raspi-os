# multicore
raspberry pi 3b has four core processor ID, and after the device is powered on, each core begins to execute the same code. However, we don't want to work with four cores; we want to only with the first one and put all of the other cores in an endless loop.

增加了一个清理bss区域的动作，也就是全局变量区域清0。在前一个章节，我们使用了cpu0，这个章节把其余三个cpu也使用起来。各个cpu共用内存，需要设置每个cpu的栈在不同的内存地址空间中。这次的目标是让每个cpu都在串口上输出hello world，并且跟上自己的cpuID，就像下面这样：
```shell
❯ make run
/root/code/qemu-9.0.0-rc0/build/qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -nographic
Hello world 0
Hello world 1
Hello world 2
Hello world 3
```

因为仿真中默认是4个cpu，这对调试来说不太方便，gdb中可能反复在切不同的cpu，可以修改以下相关字段：
```c
include/hw/arm/bcm2836.h
#define BCM283X_NCPUS 4 

hw/arm/raspi.c
mc->min_cpus = 1;
mc->default_cpus = 2;
mc->max_cpus = 4;
```
可以修改为2，好处是，调试时方便观察。

将Makefile中编译.S的语句换成了gcc，因为as似乎不处理宏或者头文件。在这个章节，不仅仅是从汇编跳转到了c语言，更是在c语言中调用了汇编，其实在gdb中也能看到，汇编中的标号（或者说锚点）都是和函数名一样的符号，可以直接打断点。

## 步骤一：从汇编跳转到c函数，并传递参数
这里主要涉及到，c语言的abi，函数有参数，如何向函数传递参数，以及如果从函数返回，该如何返回。在arm编程手册中，有一个章节是`The ABI for ARM 64-bit Architecture`, 现在重点解析下这个。