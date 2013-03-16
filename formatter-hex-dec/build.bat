yasm -f win32 -g dwarf2 formatter.asm
gcc formatter.obj -o formatter.exe
formatter.exe "" "123"
