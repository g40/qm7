#
# Running on Windows 10x64 22H2
#
CPU=cortex-m7
# i.e. stellaris
MACHINE=lm3s811evb 
#
TARGET=qm7

# QEMU binaries etc
QEMUDIR=r:/apps/qemu/8.0
QEMU=$(QEMUDIR)/qemu-system-arm
QEMUARGS=-m 16M -nographic -machine $(MACHINE) -cpu $(CPU)

# GCC/ARM tooling
ARMDIR=R:/apps/arm/arm-none-eabi/13.2-rel-1/bin
ARMGNU = $(ARMDIR)/arm-none-eabi
GDB=$(ARMDIR)/arm-none-eabi-gdb.exe

# any -D defines
DEFS=
# include paths
INCS=-ICMSIS_6/CMSIS/CORE/INCLUDE 

AOPS = --warn --fatal-warnings -g -mthumb -mcpu=$(CPU)
COPS = -Wall -Wno-unused-variable $(INCS) -O0 -g $(DEFS) -nostdlib -nostartfiles -ffreestanding -mthumb -mcpu=$(CPU)

# linker script
LD_SCRIPT=qm7_gcc.ld

# .c sources
C_SOURCES=$(TARGET).c startup_qm7.c system_qm7.c

# assembler sources
A_SOURCES=
#startup_cm7.s

C_OBJECTS=$(C_SOURCES:.c=.o)
A_OBJECTS=$(A_SOURCES:.s=.o)

# Source headers dependencies to know when it is required to rebuild some 
# objects when headers are modified.
# main.d & co files were created the previous time we run the makefile
include $(wildcard $(addsuffix .d,$(basename $(C_OBJECTS))))

#
all : $(TARGET).elf $(C_OBJECTS) $(A_OBJECTS) $(LD_SCRIPT) util.h
	
#
clean:
	rm -f *.bin *.elf *.list *.map *.o

# generic rules for building
%.o: %.c
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

#
%.o: %.s
	$(ARMGNU)-as $(AOPS) -c $< -o $@

# link
$(TARGET).elf : $(LD_SCRIPT) $(C_OBJECTS) $(A_OBJECTS)
	$(ARMGNU)-ld -T $(LD_SCRIPT) -Map=$(TARGET).map $(C_OBJECTS) $(A_OBJECTS) -o $(TARGET).elf

# $(ARMGNU)-objdump -D $(TARGET).elf > $(TARGET).list
# $(ARMGNU)-objcopy $(TARGET).elf $(TARGET).bin -O binary

# 1: open 1st shell. then 'make run'
run:
	$(QEMU) -gdb tcp::2345,ipv4 -serial mon:stdio $(QEMUARGS) -S -kernel $(TARGET).elf
	# runex $(QEMU) -serial stdio -gdb //./CNCA8 $(QEMUARGS) $(TARGET).elf

# 2: in 2nd shell `make debug` 
debug:
	$(GDB) -ex "target remote localhost:2345" -ex "set output-radix 16" -ex "b main" -ex "c" $(TARGET).elf

# sundry info printing, version etc for sanity checking
help:
	$(ARMGNU)-ld --help

dump:
	$(ARMGNU)-objdump -D $(TARGET).elf

version:
	$(ARMGNU)-gcc -v
	$(ARMGNU)-as --version
	$(ARMGNU)-ld --version


# all in one. spawn qemu in detached window, GDB in another
# requires runex. omit
#xr:
#	runex -r -d -v -- $(QEMU) -gdb tcp::2345,ipv4 -serial mon:stdio $(QEMUARGS) -S -kernel $(TARGET).elf
#	$(GDB) -ex "target remote localhost:2345" -ex "set output-radix 16" -ex "b Reset_Handler" -ex "c" $(TARGET).elf
