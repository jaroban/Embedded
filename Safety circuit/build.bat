@echo off
sdcc -o "output/" --verbose --nostdinc --code-size 0x5000 --xram-size 0 --iram-size 256 main.c
rem --nostdlib
packihx output/main.ihx > output/main.hex
dis51-0.5\dis51.exe -l 0 3 11 19 27 35 < output/main.hex > output/main.d51
pause