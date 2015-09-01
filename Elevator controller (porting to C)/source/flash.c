#include <ds80c390.h>
#include <global.h>

// flash
__xdata __at 0x555 volatile u8 flash_555;
__xdata __at 0x2aa volatile u8 flash_2aa;
__xdata __at 0 volatile u8 flash_x;

u8 flash_wait()
{
    u8 old, new, exit_next = 0;

    while(1)
    {
        wait();
        old = flash_x;
        new = flash_x;
        if(((new ^ old) & 0x40) == 0) return 0;
        if(exit_next)
        {
            flash_x = 0xf0;
            return -1;
        }
        if(new & 0x20) exit_next = 1;
    }
}

u8 flash_write(__xdata u8 *p, u8 a)
{
    flash_555 = 0xaa; flash_2aa = 0x55; flash_555 = 0xa0;
    *p = a;
    return flash_wait();
}

u8 flash_erase_chip()
{
    flash_555 = 0xaa; flash_2aa = 0x55; flash_555 = 0x80;
    flash_555 = 0xaa; flash_2aa = 0x55; flash_555 = 0x10;
    return flash_wait();
}

bool is_blank_c()
{
#if 0
    unsigned int p = 0;

    while(1)
    {
        if(*((__code u8 *)p) != 0xff) return 0;
        p++;
        if(p == 0) return -1;
    }
#else
    __asm
                mov     dps,#0
                mov     dptr,#0
ibc_main_lp:    clr     a
                movc    a,@a+dptr
                inc     a
                jnz     ibc_ret_false
                inc     dptr
                mov     a,dpl
                orl     a,dph
                jnz     ibc_main_lp
                mov     dpl,#0xff
                ret
ibc_ret_false:  mov     dpl,#0
    __endasm;
#endif
}

