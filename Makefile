all:
	@echo	""
	@echo	"*************************"
	@echo	"**** M A K E F I L E ****"
	@echo	"*************************"
	@echo	""

	nasm -f bin -o bootsector.bin bootsector.asm
	nasm main.asm -l main.lst -o main.elf -f elf64
	nasm init16.asm -l init16.lst  -o init16.elf -f elf64
	nasm sys_tables.asm -l sys_tables.lst -o sys_tables.elf -f elf64
	ld -melf_x86_64 --oformat binary  init16.elf  main.elf  sys_tables.elf   -o kernel.bin  -T script.lds -Map kernel.map
	mkdir ./disco
	sudo mkdosfs -C floppy.dsk -F 12 1440
	sudo mount -o loop -t msdos floppy.dsk ./disco
	sudo cp kernel.bin ./disco
	sudo umount ./disco
	dd if=floppy.dsk bs=512 skip=1 of=floppy1.dsk
	cat bootsector.bin floppy1.dsk > floppy.img
	echo Borrando auxiliares...
	rmdir ./disco
	rm -f *.dsk
	
	

bochs:
	@echo	""
	@echo	"**************************"
	@echo	"**** EXCECUTING BOCHS ****"
	@echo	"**************************"
	@echo	""
	bochs -q

clean:	
	@echo	""
	@echo	"*************************"
	@echo	"**** CLEANING FILES  ****"
	@echo	"*************************"
	@echo	""
	rm -f *.elf
	rm -f bootsector.bin
	rm -f floppy.img
	rm -f kernel.bin
	rm -f *.lst
	@echo	""
	@echo	"*************************"
	@echo	"****  CLEANING DONE  ****"
	@echo	"*************************"
	@echo	""
