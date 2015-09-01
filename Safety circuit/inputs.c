#pragma save
#pragma disable_warning 59 // function must return value
#pragma disable_warning 85 // unreferenced variable

// need 4-byte buffer
u8 maj5(__idata u8 *p, u8 data)
{
#if 1
    p[4] = p[3];
    p[3] = p[2];
    p[2] = p[1];
    p[1] = data;
    
    p[0] |= (p[1] & p[2] & p[3] & p[4]);
    p[0] &= (p[1] | p[2] | p[3] | p[4]);
    
    return p[0];
#else
    __asm
        mov     a,dpl
        mov     r0,a
        add     a,#5
        mov     r1,a
        mov     a,_maj5_PARM_2
        mov     @r1,a
        inc     r1
        xch     a,@r0
        inc     r0
        mov     @r1,a
        inc     r1
        xch     a,@r0
        inc     r0
        mov     @r1,a
        xch     a,@r0
        inc     r0
        xch     a,@r0
        inc     r0
        mov     @r0,a
        mov     r1,dpl
        mov     dpl,#0
        mov     r2,#5
1$:     mov     a,@r1
        inc     r1
        orl     a,@r1
        inc     r1
        anl     a,@r1
        inc     r1
        anl     a,@r1
        orl     dpl,a
        dec     r1
        dec     r1
        djnz    r2,1$
    __endasm;
#endif
}

#pragma restore