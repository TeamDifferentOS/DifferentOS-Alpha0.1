all: diffos.iso

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

diffos.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > diffos.img
	# Pad to 1.44MB floppy size
	dd if=/dev/zero of=diffos.img bs=512 count=2880 conv=notrunc 2>/dev/null || true
	dd if=boot.bin of=diffos.img conv=notrunc 2>/dev/null
	dd if=kernel.bin of=diffos.img bs=512 seek=1 conv=notrunc 2>/dev/null

diffos.iso: diffos.img
	mkdir -p iso
	cp diffos.img iso/
	genisoimage -o diffos.iso -b diffos.img -no-emul-boot iso/ 2>/dev/null || \
	mkisofs -o diffos.iso -b diffos.img -no-emul-boot iso/ 2>/dev/null || \
	xorriso -as mkisofs -o diffos.iso -b diffos.img -no-emul-boot iso/

clean:
	rm -f *.bin *.img *.iso
	rm -rf iso

.PHONY: all clean
