main:
	nasm main.asm -f elf64
	ld main.o
run: main
	./a.out
