sdcc -c ^
    -mds390 --model-flat24 --protect-sp-update --stack-10bit --use-accelerator ^
    --nostdinc --nostdlib --nooverlay --opt-code-size ^
    main.c
    
    
sdcc -c ^
    -mds390 --model-flat24 --protect-sp-update --stack-10bit --use-accelerator ^
    --nostdinc --nostdlib --nooverlay --opt-code-size ^
    os.c
    
sdcc ^
    --data-loc 0x30 ^
    --idata-loc 0x80 ^
    --xram-size 0x401200 ^
    --code-loc 0 ^
    --code-size 0x10000 ^
    main.rel os.rel
    
rem packihx test.ihx > test.hex
rem     --xstack ^          --model-large ^     
del main.link
ren main.lnk main.link
pause