# multicore
raspberry pi 3b has four core processor ID, and after the device is powered on, each core begins to execute the same code. However, we don't want to work with four cores; we want to only with the first one and put all of the other cores in an endless loop.

增加了一个清理bss区域的动作，也就是全局变量区域清0。