sdcc ^
    -mds390 ^
    --model-flat24 ^
    --stack-10bit ^
    --protect-sp-update ^
    --no-xinit-opt ^
    --main-return ^
    --use-accelerator ^
    --nostdinc ^
    --nostdlib ^
    -I ./source ^
    --peep-file optimizer.txt ^
    --data-loc 0x30 ^
    --idata-loc 0x80 ^
    --xram-loc 0x400000 ^
    --code-loc 0 ^
    -Wl-r ^
    ./source/main.c
    
   
rem packihx test.ihx > test.hex
rem     --xstack ^          --model-large ^     
rem del main.link
copy main.lnk main.link
pause