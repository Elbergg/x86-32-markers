CC=g++
ASMBIN=nasm

all : asm cc link
asm :
	$(ASMBIN) -o markers.o -f elf -g -l markers.lst markers.asm
cc :
	$(CC) -m32 -c -g -O0 main.cpp &> errors.txt
link :
	$(CC) -m32 -g -o test main.o markers.o
clean :
	rm *.o
	rm test
	rm errors.txt
	rm markers.lst
