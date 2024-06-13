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
COPS = -nostartfiles -ffreestanding -mgeneral-regs-only
ASMFLAGS := -Iinclude

C_FILES = $(wildcard src/*.c)
P_FILES = $(wildcard src/peripheral/*.c)
ASM_FILES = $(wildcard src/*.S)
OBJ_FILES = $(C_FILES:%.c=build/%_c.o)
OBJ_FILES += $(P_FILES:%.c=build/%_c.o)
OBJ_FILES += $(ASM_FILES:%.S=build/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

.PHONY: all

all: clean $(KERN_IMG) 

print_variable:
	mkdir -p build
	mkdir -p build/src
	mkdir -p build/src/peripheral
	@echo $(QEMU-START-ARGS)
	@echo $(ASM_FILES)
	@echo $(C_FILES)
	@echo $(OBJ_FILES)

$(BUILD_DIR)/src/%_s.o: $(SRC_DIR)/%.S
	$(CC) $(ASMFLAGS) -MMD -c -o $@ $<

$(BUILD_DIR)/src/%_c.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(COPS) -MMD -c -o $@ $<

$(BUILD_DIR)/src/peripheral/%_c.o: $(SRC_DIR)/peripheral/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(KERN_IMG): print_variable $(OBJ_FILES) Makefile
	$(LD) $(OBJ_FILES) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel8.elf $@

QEMU-START-ARGS = -M raspi3b -nographic -monitor none -serial null \
					-chardev stdio,id=uart1 -serial chardev:uart1

run: $(KERN_IMG)
	$(qemu) $(QEMU-START-ARGS) -kernel $< 

qemu-gdb: $(KERN_IMG)
	$(qemu) $(QEMU-START-ARGS) -kernel $< -gdb tcp::1234 -S

gdb:
	gdb-multiarch -n -x .gdbinit
	# aarch64-linux-gdb -x .gdbinit

clean:
	$(RM) -rf $(BUILD_DIR)