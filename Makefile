main:
	fasm main.asm
	gcc -no-pie main.o -o pong_asm -lraylib -lm -lc -nostdlib
run: main
	./pong_asm
