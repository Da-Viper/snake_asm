snake: snake.o
	gcc snake.o -o snake -lSDL2 -lSDL2main

snake.o: snake.asm
	nasm -g -f elf64 snake.asm