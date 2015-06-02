#####################################################################################
# Copyright (c) 2015,  Vipin Bakshi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
######################################################################################


######################################################################################
# GNU ARM Toolchain Initialization.
######################################################################################
GCC_BASE = /home/captainvip/Development/arm-cs-tools/
GCC_BIN  = $(GCC_BASE)bin/
GCC_LIB  = $(GCC_BASE)arm-none-eabi/lib/
GCC_INC  = $(GCC_BASE)arm-none-eabi/include/
AS       = $(GCC_BIN)arm-none-eabi-as
CC       = $(GCC_BIN)arm-none-eabi-gcc
CPP      = $(GCC_BIN)arm-none-eabi-g++
LD       = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY  = $(GCC_BIN)arm-none-eabi-objcopy
SIZE	   = $(GCC_BIN)arm-none-eabi-size


######################################################################################
# MCU Options
######################################################################################
CORTEX_M0_CC_FLAGS      = -mthumb -mcpu=cortex-m0 -march=armv6-m

######################################################################################
# PROJECT Configuration
######################################################################################
PROJECT           = demo
LINKER_SCRIPT     = ./linkergcc/gcc_nrf51_s310_xxac.ld
PROJECT_INC_PATH  = -I. -Is310_nrf51422_2.0.0/s310_nrf51422_2.0.0_API/include/ -Ihal/ -Icmsis/
PROJECT_LIB_PATHS = -L.
PROJECT_OUTPUT = _build/


######################################################################################
# MAKEFILE Pre-Execution
######################################################################################
CFLAGS = -std=gnu99 -c $(CORTEX_MO_CC_FLAGS) $(PROJECT_INC_PATH) -fno-common -fmessage-length=0 -Wall -fno-exceptions -ffunction-sections -fdata-sections -DNRF51
LDFLAGS = $(CORTEX_MO_CC_FLAGS)  -Wl,-Map=$(PROJECT_OUTPUT)$(PROJECT).Map -T $(LINKER_SCRIPT)

VPATH = $(PROJECT_SRC_PATH)
HEX = $(PROJECT_OUTPUT)$(PROJECT).hex
ELF = $(PROJECT_OUTPUT)$(PROJECT).elf
BIN = $(PROJECT_OUTPUT)$(PROJECT).bin

SRCS = $(notdir $(wildcard ./*.c))
OBJS = $(addprefix $(PROJECT_OUTPUT), $(SRCS:.c=.o))
DEPS = $(addprefix $(PROJECT_OUTPUT), $(SRCS:.c=.d))
SRCS_AS += $(notdir $(wildcard ./*.s))
OBJS_AS = $(addprefix $(PROJECT_OUTPUT), $(SRCS_AS:.s=.o))


############################################################################### 
# Makefile execution
###############################################################################
all: makefolder  $(OBJS) $(OBJS_AS) $(HEX)

rebuild: clean cleanup all

cleanup:
		rm -R _build

$(HEX): $(OBJS) $(OBJS_AS)
			$(LD) $(CORTEX_M0_CC_FLAGS)$(LDFLAGS) $(OBJS_AS) $(OBJS) -o $(ELF)
			$(OBJCOPY) -Oihex $(ELF) $(HEX)
			$(OBJCOPY) -Obinary $(ELF) $(BIN)
			$(SIZE) $(ELF)

size: $(ELF)
			$(SIZE) $(ELF)

$(PROJECT_OUTPUT)%.o: %.c
							$(CC) $(CFLAGS) $< -o $@

$(PROJECT_OUTPUT)%.o: %.s
								$(AS) $< -o $@

makefolder:
			mkdir $(PROJECT_OUTPUT)

-include $(DEPS)

.PHONY: all clean rebuild size
