#
# Common Makefile for the PX4 bootloaders
#

#
# Paths to common dependencies
#
export BL_BASE		?= $(wildcard .)
export LIBOPENCM3	?= $(wildcard libopencm3)

#
# Tools
#
export CC	 	 = arm-none-eabi-gcc
export OBJCOPY		 = arm-none-eabi-objcopy

#
# Common configuration
#
export FLAGS		 = -std=gnu99 \
			   -Os \
			   -g \
			   -Wundef \
			   -Wall \
			   -fno-builtin \
			   -I$(LIBOPENCM3)/include \
			   -ffunction-sections \
			   -nostartfiles \
			   -lnosys \
			   -Wl,-gc-sections \
			   -Wl,-g \
			   -Werror

export COMMON_SRCS	 = bl.c cdcacm.c  usart.c

#
# Bootloaders to build
#
TARGETS	= xlong_bl

all:	$(TARGETS)


clean:
	cd libopencm3 && make --no-print-directory clean && cd ..
	rm -f *.elf *.bin

#
# Specific bootloader targets.
#

xlong_bl: $(MAKEFILE_LIST) $(LIBOPENCM3)
	make -f Makefile.f4 TARGET_HW=XLONG  LINKER_FILE=stm32f4.ld TARGET_FILE_NAME=$@

#
# Binary management
#
.PHONY: deploy
deploy:
	zip Bootloader.zip *.bin

#
# Submodule management
#

$(LIBOPENCM3): checksubmodules
	make -C $(LIBOPENCM3) lib

.PHONY: checksubmodules
checksubmodules: updatesubmodules
	$(Q) ($(BL_BASE)/Tools/check_submodules.sh)

.PHONY: updatesubmodules
updatesubmodules:
	$(Q) (git submodule init)
	$(Q) (git submodule update)
