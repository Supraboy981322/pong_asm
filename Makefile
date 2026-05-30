main:
	nasm main.asm -f elf64
	ld main.o -o pong_asm
run: main
	./pong_asm
