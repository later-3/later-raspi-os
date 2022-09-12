GCCPREFIX := aarch64-linux-gnu-
BUILD_DIR := ./build
qemu := /home/later/code/qemu/build/qemu-system-aarch64
KERN_IMG := $(BUILD_DIR)/kernel8.img
CC := $(GCCPREFIX)gcc
LD := $(GCCPREFIX)ld
AS := $(GCCPREFIX)as

OBJCOPY := $(GCCPREFIX)objcopy

RM := rm -fr

CFLAGS := -Wall -nostdlib -g

OBJ := src/main.o src/entry.o

.PHONY: all

all: clean $(KERN_IMG)

$(KERN_IMG): $(OBJ) Makefile
	mkdir build
	$(LD) $(OBJ) -T src/linker.ld -o $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel8.elf $@

$(BUILD_DIR)/%.o: %.S
	$(AS) -o $@ $<

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(KERN_IMG)
	$(qemu) -M raspi3b -kernel $< -nographic

qemu-gdb: $(KERN_IMG)
	$(qemu) -M raspi3b -kernel $< -gdb tcp::1234 -nographic -S

gdb:
	# gdb-multiarch -n -x .gdbinit
	aarch64-linux-gdb -x .gdbinit

clean:
	# $(RM) $(BUILD_DIR)/kernel8.img $(BUILD_DIR)/kernel8.elf $(OBJ)
	$(RM) $(BUILD_DIR)