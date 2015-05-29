######################################################################################
# GNU GCC ARM Embeded Toolchain base directories and binaries 
######################################################################################
GCC_BASE = /Users/vbb/arm-cs-tools/
GCC_BIN  = $(GCC_BASE)bin/
GCC_LIB  = $(GCC_BASE)arm-none-eabi/lib/
GCC_INC  = $(GCC_BASE)arm-none-eabi/include/
AS       = $(GCC_BIN)arm-none-eabi-as
CC       = $(GCC_BIN)arm-none-eabi-gcc
CPP      = $(GCC_BIN)arm-none-eabi-g++
LD       = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY  = $(GCC_BIN)arm-none-eabi-objcopy
SIZE	 = $(GCC_BIN)arm-none-eabi-size

######################################################################################
# Custom options for cortex-m and cortex-r processors 
######################################################################################
CORTEX_M0_CC_FLAGS      = -mthumb -mcpu=cortex-m0
CORTEX_M0_LIB_PATH      = $(GCC_LIB)armv6-m

######################################################################################
# Main makefile project configuration
#    PROJECT      = <name of the target to be built>
#    MCU_CC_FLAGS = <one of the CC_FLAGS above>
#    MCU_LIB_PATH = <one of the LIB_PATH above>
#    OPTIMIZE_FOR = < SIZE or nothing >
#    DEBUG_LEVEL  = < -g compiler option or nothing >
#    OPTIM_LEVEL  = < -O compiler option or nothing >
######################################################################################
PROJECT           = demo
MCU_CC_FLAGS      = $(CORTEX_M0_CC_FLAGS)
MCU_LIB_PATH      = $(CORTEX_M0_LIB_PATH)
OPTIMIZE_FOR      = 
DEBUG_LEVEL       = 
OPTIM_LEVEL       = 
LINKER_SCRIPT     = ./gcc_nrf51_s310.ld
PROJECT_OBJECTS   = startup_nrf51.o main.o
PROJECT_INC_PATHS = -I.
PROJECT_LIB_PATHS = -L.
PROJECT_LIBRARIES =
PROJECT_SYMBOLS   = -DTOOLCHAIN_GCC_ARM -DNO_RELOC='0'  


######################################################################################
# Main makefile system configuration
######################################################################################
SYS_OBJECTS = 
SYS_INC_PATHS = -I. -I$(GCC_INC) 
SYS_LIB_PATHS = -L$(MCU_LIB_PATH)
ifeq (OPTIMIZE_FOR, SIZE)
SYS_LIBRARIES = -lm -lc_s -lg_s
SYS_LD_FLAGS  = --specs=nano.specs -u _printf_float -u _scanf_float
else 
SYS_LIBRARIES = -lm -lc -lg
SYS_LD_FLAGS  = 
endif


############################################################################### 
# Command line building
###############################################################################
ifdef DEBUG_LEVEL
CC_DEBUG_FLAGS = -g$(DEBUG_LEVEL)
CC_SYMBOLS = -DDEBUG $(PROJECT_SYMBOLS)
else
CC_DEBUG_FLAGS =
CC_SYMBOLS = -DNODEBUG $(PROJECT_SYMBOLS)
endif 

ifdef OPTIM_LEVEL
CC_OPTIM_FLAGS = -O$(OPTIM_LEVEL)
else 
CC_OPTIM_FLAGS = 
endif

INCLUDE_PATHS = $(PROJECT_INC_LIB) $(SYS_INC_PATHS)
LIBRARY_PATHS = $(PROJECT_LIB_LIB) $(SYS_LIB_PATHS)
CC_FLAGS = $(MCU_CC_FLAGS) -c $(CC_OPTIM_FLAGS) $(CC_DEBUG_FLAGS) -fno-common -fmessage-length=0 -Wall -fno-exceptions -ffunction-sections -fdata-sections 
LD_FLAGS = $(MCU_CC_FLAGS) -Wl,--gc-sections $(SYS_LD_FLAGS) -Wl,-Map=$(PROJECT).map 
LD_SYS_LIBS = $(SYS_LIBRARIES)

BULD_TARGET = $(PROJECT)


############################################################################### 
# Makefile execution
###############################################################################
all: $(BULD_TARGET).hex

clean:
	rm -f $(BULD_TARGET).bin $(BULD_TARGET).elf $(PROJECT_OBJECTS)

.s.o:
	$(AS) $(MCU_CC_FLAGS) $(INCLUDE_PATH) -o $@ $<

.c.o:
	$(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99   $(INCLUDE_PATHS) -o $@ $<

.cpp.o:
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 $(INCLUDE_PATHS) -o $@ $<


$(BULD_TARGET).elf: $(PROJECT_OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(PROJECT_LIBRARIES) $(SYS_LIBRARIES) $(PROJECT_LIBRARIES) $(SYS_LIBRARIES)

$(BULD_TARGET).hex: $(BULD_TARGET).elf
	$(OBJCOPY) -O ihex $< $@

size: $(SIZE) $(PROJECT).elf 


