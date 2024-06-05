GCCPREFIX := aarch64-linux-gnu-
BUILD_DIR := build
SRC_DIR := src

qemu := /root/code/qemu-9.0.0-rc0/build/qemu-system-aarch64

KERN_IMG := $(BUILD_DIR)/kernel8.img
CC := $(GCCPREFIX)gcc
LD := $(GCCPREFIX)ld
AS := $(GCCPREFIX)as

OBJCOPY := $(GCCPREFIX)objcopy

RM := rm -f

CFLAGS := -Wall -nostdlib -g -Iinclude
ASMFLAGS := -Iinclude

OBJ := $(BUILD_DIR)/main.o  $(BUILD_DIR)/mm.o $(BUILD_DIR)/utils.o $(BUILD_DIR)/entry.o

.PHONY: all

all: clean $(KERN_IMG)

$(KERN_IMG): $(OBJ) Makefile
	$(LD) $(OBJ) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel8.elf $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	$(CC) $(ASMFLAGS) -MMD -c -o $@ $<

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(KERN_IMG)
	$(qemu) -M raspi3b -kernel $< -nographic

qemu-gdb: $(KERN_IMG)
	$(qemu) -M raspi3b -kernel $< -gdb tcp::1234 -nographic -S

gdb:
	gdb-multiarch -n -x .gdbinit
	# aarch64-linux-gdb -x .gdbinit

clean:
	$(RM) $(BUILD_DIR)/kernel8.img $(BUILD_DIR)/kernel8.elf $(OBJ)