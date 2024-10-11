AS = nasm
ASFLAGS = -f bin

VM = qemu-system-x86_64
VMFLAGS = -cdrom

all: build disk

build:
	$(AS) $(ASFLAGS) -o tuxpen-boot.sys boot/tuxpen-boot.asm

disk: tuxpen-boot.sys
	mkdir -p iso/boot
	cp tuxpen-boot.sys iso/boot/tuxpen-boot.sys
	genisoimage -R -J -c boot/bootcat -b boot/tuxpen-boot.sys -no-emul-boot -boot-load-size 4 -o Tuxpen.iso ./iso

run: Tuxpen.iso
	$(VM) $(VMFLAGS) Tuxpen.iso

clean:
	rm -rf iso
	rm -f *.sys *.iso
