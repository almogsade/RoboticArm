# MCU settings
MCU = atmega328p
F_CPU = 1000000UL
PROGRAMMER = usbasp

# Tools
CC = avr-gcc
OBJCOPY = avr-objcopy
AVRDUDE = avrdude

# Directories
SRC_DIR = src
BUILD_DIR = build
INCLUDE_DIR = include

# Files
TARGET = main
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC))

# Flags
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -I$(INCLUDE_DIR) -Os
LDFLAGS = -mmcu=$(MCU)

# Default target
all: $(BUILD_DIR)/$(TARGET).hex

# Compile
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Link
$(BUILD_DIR)/$(TARGET).elf: $(OBJ)
	$(CC) $(LDFLAGS) $^ -o $@

# Generate HEX
$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

# Upload
flash: $(BUILD_DIR)/$(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:w:$<

size:
	avr-size $(BUILD_DIR)/$(TARGET).elf

fuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) \
	-U lfuse:w:0x62:m \
	-U hfuse:w:0xD9:m \
	-U efuse:w:0xFF:m

# Clean build artifacts
clean:
	rmdir /s /q build

# Create build dir if missing
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)