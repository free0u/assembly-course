all: test-dct dct
	g++ ./build/test-dct.o ./build/dct.o -o ./build/test.exe -msse4.2

test-dct: test-dct.cpp
	g++ -c test-dct.cpp -o ./build/test-dct.o -msse4.2

dct: dct.asm
	yasm -f win32 -g dwarf2 dct.asm -o ./build/dct.o
