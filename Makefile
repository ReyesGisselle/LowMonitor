NASM ?= nasm
LD ?= ld
ASMFLAGS = -f elf64 -g -F dwarf

.PHONY: all clean run test
all: lowmonitor

lowmonitor: LowMonitor.o
	$(LD) -o $@ $<

LowMonitor.o: LowMonitor.asm
	$(NASM) $(ASMFLAGS) -o $@ $<

run: lowmonitor
	./lowmonitor

test: lowmonitor
	printf '7\n0\n' | ./lowmonitor

clean:
	rm -f LowMonitor.o lowmonitor
