# interrupt
处理中断，以及完成一些基础功能。

# 清理BSS
在`linker.ld`里面配置了bss区域:
```ld
    bss_begin = .;
    .bss : { *(.bss*) }
    bss_end = .;
```
在Makefile中的链接语句中加入了`-Map System.map`,生成了`System.map`
```map
.bss            0x0000000000081040       0x18
 *(.bss*)
 .bss           0x0000000000081040        0x4 build/src/main_c.o
                0x0000000000081040                g
 *fill*         0x0000000000081044        0x4 
 .bss           0x0000000000081048       0x10 build/src/printf_c.o
 .bss           0x0000000000081058        0x0 build/src/peripheral/aux_uart_c.o
 .bss           0x0000000000081058        0x0 build/src/entry_s.o
 .bss           0x0000000000081058        0x0 build/src/mm_s.o
 .bss           0x0000000000081058        0x0 build/src/utils_s.o
                0x0000000000081058                bss_end = .
```

在main.c中声明了`int g`，然后故意在memzero中将bss全部清理为了1，在将g全局变量打印到串口验证：
```c
Hello world g 1
```

然后再写一个memset_r3p函数，将bss清0:
```c
    PROVIDE(bss_begin = .);
    .bss : { *(.bss*) }
    PROVIDE(bss_end = .);

    extern char bss_begin[], bss_end[];
    memset_rsp(bss_begin, 0, bss_end - bss_begin);

void memset_rsp(void *start, unsigned char val, int len)
{
    unsigned char *t = (unsigned char *)start;
    for (int i = 0; i < len; i++ ) {
        *t = val;
        t++;
    }
}
```

在打印之前将bss设置为0，
```c
Hello world g 0
```

# reference
https://krinkinmu.github.io/2021/01/10/aarch64-interrupt-handling.html
