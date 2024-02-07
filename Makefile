snake: snake.o board.o
	gcc snake.o board.o -o snake -lSDL2 -lSDL2main -lSDL2_ttf

board.o: board.asm
	nasm -g -f elf64 board.asm

snake.o: snake.asm
	nasm -g -f elf64 snake.asm