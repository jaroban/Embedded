#include <global.h>

void _gptrget(u8 *gptr) __naked
{
    __asm
                jnb     b.7,gpg_skip1
                clr     a
                movc    a,@a+dptr
                ret
gpg_skip1:      jb      b.6,gpg_skip2
                movx    a,@dptr
                ret
gpg_skip2:      jb      b.5,gpg_skip3
                mov     dph,r0
                mov     r0,dpl
                mov     a,@r0
                mov     r0,dph
                mov     dph,#0
                ret
gpg_skip3:      mov     dph,r0
                mov     r0,dpl
                movx    a,@r0
                mov     r0,dph
                mov     dph,#0
                ret
     __endasm;
}