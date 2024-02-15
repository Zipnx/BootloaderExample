
NASM := /usr/bin/nasm
SYSTEM := /usr/bin/qemu-system-x86_64

SRCDIR := ./src/

BINDIR := ./
BINNAME := boot.img

bnr:
	$(MAKE) build
	$(SYSTEM) -fda $(BINDIR)$(BINNAME)

build:
	$(NASM) -f bin $(SRCDIR)boot.asm -o $(BINDIR)$(BINNAME)
