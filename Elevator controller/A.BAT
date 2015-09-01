@echo off
asm\asemw.exe program.asm
pause
exit
echo Ak bola nejaka chyba, stlac Ctrl+C a Y a Enter, inak stlac Enter
asm\asemw.exe boot.asm boot1.hex /define:part:0
asm\asemw.exe boot.asm boot2.hex /define:part:1
asm\hexbinw.exe boot1.hex /fill:ff /length:200
asm\hexbinw.exe boot2.hex /fill:ff /length:200
asm\hexbinw.exe program.hex /fill:ff
asm\split.exe program.bin 32256
rem prog1.bin prog2.bin
copy /b boot1.bin + prog1.bin part1.bin
copy /b boot2.bin + prog2.bin part2.bin
del boot.lst boot1.bin boot1.hex boot2.bin boot2.hex prog1.bin prog2.bin program.bin
pause