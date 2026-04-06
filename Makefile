CC = arm-none-eabi-gcc
GDB = gdb-multiarch
OBJCOPY = arm-none-eabi-objcopy

TARGET_DIR ?=
TARGET_UPPER = $(shell echo $(TARGET_DIR) | tr '[:lower:]' '[:upper:]')
TARGET_LOWER = $(shell echo $(TARGET_DIR) | tr '[:upper:]' '[:lower:]')

INC = L011xx/Inc
SRC = L011xx/Src
DEST = dest
LINKER = $(TARGET_DIR)/STM32$(TARGET_UPPER)_FLASH.ld
STARTUP_SRC = $(TARGET_DIR)/Startup/startup_stm32l011$(shell echo $(TARGET_LOWER) | sed 's/l011//').s
STARTUP_OBJ = $(DEST)/$(notdir $(STARTUP_SRC:.s=.o))

OOCD_SCR = /usr/share/openocd/scripts

INCLUDES = -I$(INC)
COMMON_FLAGS = -mcpu=cortex-m0plus -mthumb -DSTM32L011xx
CFLAGS = $(COMMON_FLAGS) -std=gnu99 -g3 -Os $(INCLUDES) -ffunction-sections -fdata-sections
ASFLAGS = $(COMMON_FLAGS) -x assembler-with-cpp $(INCLUDES)
LDFLAGS = $(COMMON_FLAGS) -T$(LINKER) -Wl,--gc-sections --specs=nosys.specs

SRCS = $(wildcard $(SRC)/*.c)
OBJS = $(patsubst $(SRC)/%.c,$(DEST)/%.o,$(SRCS))

ELF = $(DEST)/main.elf
HEX = $(DEST)/main.hex

.DEFAULT_GOAL := help

help:
	@echo "Explicit target required."
	@echo "Use one of:"
	@echo "  make l011k4tx"
	@echo "  make l011f3ux"
	@echo "  make flash-l011k4tx"
	@echo "  make flash-l011f3ux"
	@echo "  make debug-l011k4tx"
	@echo "  make debug-l011f3ux"
	@false

l011k4tx:
	$(MAKE) TARGET_DIR=L011K4Tx build

l011f3ux:
	$(MAKE) TARGET_DIR=L011F3Ux build

flash-l011k4tx:
	$(MAKE) TARGET_DIR=L011K4Tx flash

flash-l011f3ux:
	$(MAKE) TARGET_DIR=L011F3Ux flash

debug-l011k4tx:
	$(MAKE) TARGET_DIR=L011K4Tx debug

debug-l011f3ux:
	$(MAKE) TARGET_DIR=L011F3Ux debug

build: $(HEX)

$(DEST):
	mkdir -p $(DEST)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(STARTUP_OBJ) $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@

$(STARTUP_OBJ): $(STARTUP_SRC) | $(DEST)
	$(CC) $(ASFLAGS) -c $< -o $@

$(DEST)/%.o: $(SRC)/%.c | $(DEST)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: help l011k4tx l011f3ux flash-l011k4tx flash-l011f3ux debug-l011k4tx debug-l011f3ux build con debug flash clean

con:
	openocd -s $(OOCD_SCR) -f interface/stlink.cfg -f target/stm32l0.cfg

debug: $(ELF)
	@echo "Ensure the board is connected and OpenOCD is running:"
	@echo "  make con"
	$(GDB) $(ELF) -ex "target remote localhost:3333" -ex "monitor reset halt"

flash: $(ELF)
	@echo "Ensure the board is connected and OpenOCD is running:"
	@echo "  make con"
	$(GDB) $(ELF) -ex "target remote localhost:3333" -ex "monitor reset halt" -ex "load" -ex "monitor reset halt" -ex "quit"

clean:
	rm -rf $(DEST)
