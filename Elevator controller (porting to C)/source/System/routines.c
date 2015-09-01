#include <ds80c390.h>
#include <global.h>

// system
void reset()
{
    IE = 0;
    CKCON &= 0x3f;  // shortest watchdog
    TIMED_ACCESS;
    WDCON |= 3;     // enable reset
    while(1) ;      // wait
}

void movx_slow()
{
    CKCON |= 7;
}

void movx_fast()
{
    CKCON &= 0xf8;
}

u8 movx_read(u8 a)
{
#if 1
    u8 d;
    CKCON |= 7;
    d = *((__xdata u8 *)(0x100000 | a));
    CKCON &= 0xf8;
    return d;
#else
    __asm
        orl     _ckcon,#7       ; stretch movx cycle
        clr     a
        mov     dps,a
        mov     dpx,#0x10
        mov     dph,a
        movx    a,@dptr
        mov     dpl,a
        anl     _ckcon,#0xf8    ; shorten movx cycle
    __endasm;
#endif
}

void movx_write(u8 a, u8 d)
{
#if 1
    CKCON |= 7;
    *((__xdata u8 *)(0x100000 | a)) = d;
    CKCON &= 0xf8;
#else
    __asm
        orl     _ckcon,#7       ; stretch movx cycle
        clr     a
        mov     dps,a
        mov     dpx,#0x10
        mov     dph,a
        mov     a,b1_0
        movx    @dptr,a
        anl     _ckcon,#0xf8    ; shorten movx cycle
    __endasm;
#endif
}
