#include <global.h>

u8 random()
{
    __asm
                mov     a,tl0
                rl      a
                addc    a,th0
                rl      a
                addc    a,tl1
                rl      a
                addc    a,th1
                rl      a
                addc    a,tl2
                rl      a
                addc    a,th2
                mov     dpl,a
    __endasm;
}

// system
void reset()
{
    //reset_source = RESET_BY_SOFTWARE;
    EA = 0;
    CKCON &= 0x3f;  // shortest watchdog
    TIMED_ACCESS;
    WDCON |= 3;     // enable watchdog reset
    while(1) ;      // wait
}

void reset_watchdog()
{
    thread_watchdog = 0;
    EA = 0;
    TIMED_ACCESS;
    WDCON |= 1;
    EA = 1;
}

void halt()
{
    EA = 0;
    TIMED_ACCESS;
    WDCON &= ~2;    // disable watchdog reset
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
#if 0
    u8 d;
    CKCON |= 7;
    d = *((__xdata u8 *)(0x100000 | a));
    CKCON &= 0xf8;
    return d;
#else
    __asm
                orl     _CKCON,#7       ; stretch movx cycle
                clr     a
                mov     dps,a
                mov     dpx,#0x10
                mov     dph,a
                movx    a,@dptr
                mov     dpl,a
                anl     _CKCON,#0xf8    ; shorten movx cycle
    __endasm;
#endif
}

void movx_write(u8 a, u8 d)
{
#if 0
    CKCON |= 7;
    *((__xdata u8 *)(0x100000 | a)) = d;
    CKCON &= 0xf8;
#else
    __asm
                orl     _CKCON,#7       ; stretch movx cycle
                clr     a
                mov     dps,a
                mov     dpx,#0x10
                mov     dph,a
                mov     a,b1_0
                movx    @dptr,a
                anl     _CKCON,#0xf8    ; shorten movx cycle
    __endasm;
#endif
}

void set_mcu_speed(u8 multiplier)
{
    PMR = 0x80;
    
    if(multiplier == 2)
    {
        PMR = 0x90;
        while((EXIF & 8) == 0);
        PMR = 0x10;
    }
    else if(multiplier == 4)
    {
        PMR = 0x88;
        PMR = 0x98;
        while((EXIF & 8) == 0);
        PMR = 0x18;
    }
}

u8 get_mcu_speed()
{
    if((PMR >> 6) == 2)
    {
        return 1;
    }
    else if(PMR & 8)
    {
        return 4;
    }
    else
    {
        return 2;
    }
}

void memset_i(__idata u8 *p, u8 value, u8 len)
{
    __asm
                mov     a,b1_1
                jz      msi_ret
                mov     r0,dpl
                mov     r1,a
                mov     a,b1_0

msi_lp:         mov     @r0,a
                inc     r0
                djnz    r1,msi_lp
msi_ret:
    __endasm;
}

void memset_x(__xdata u8 *p, u8 value, u16 len)
{
    __asm
                mov     dps,#0
                mov     a,b1_0
                mov     r0,b1_1
                mov     r1,b1_2
                inc     r0
                inc     r1
                sjmp    msx_entry
                
msx_lp:         movx    @dptr,a
                inc     dptr
msx_entry:      djnz    r0,msx_lp
                djnz    r1,msx_lp
    __endasm;
}

void copy_ii(__idata u8 *src, __idata u8 *dest, u8 len)
{
    __asm
                mov     a,b1_1
                jz      cp_ii_ret
                mov     r0,dpl
                mov     r1,b1_0
                mov     r2,a
cp_ii_lp:       mov     a,@r0
                mov     @r1,a
                inc     r0
                inc     r1
                djnz    r2,cp_ii_lp
cp_ii_ret:
    __endasm;
}

void copy_cx(const __code u8 *src, __xdata u8 *dest, u16 len)
{
    __asm
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     r2,b1_3
                mov     r3,b1_4
                mov     dps,#DPS_TOGGLE
                
                inc     r2
                inc     r3
                sjmp    _cp_cx_entry

_cp_cx_lp1:     clr     a
                movc    a,@a+dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
_cp_cx_entry:   djnz    r2,_cp_cx_lp1
                djnz    r3,_cp_cx_lp1
                mov     dps,#0
    __endasm;
}

void copy_ix(__idata u8 *src, __xdata u8 *dest, u8 len)
{
    __asm
                mov     a,b1_3
                jz      cp_ix_ret
                mov     r0,dpl
                mov     r1,a
                mov     dpl,b1_0
                mov     dph,b1_1
                mov     dpx,b1_2
                mov     dps,#0
cp_ix_lp:       mov     a,@r0
                movx    @dptr,a
                inc     r0
                inc     dptr
                djnz    r1,cp_ix_lp
cp_ix_ret:
    __endasm;
}

void copy_xi(__xdata u8 *src, __idata u8 *dest, u8 len)
{
    __asm
                mov     a,b1_1
                jz      cp_xi_ret
                mov     r0,b1_0
                mov     r1,a
                mov     dps,#0
cp_xi_lp:       movx    a,@dptr
                mov     @r0,a
                inc     dptr
                inc     r0
                djnz    r1,cp_xi_lp
cp_xi_ret:
    __endasm;
}

void copy_xx(__xdata u8 *src, __xdata u8 *dest, u8 len)
{
    __asm
                mov     a,b1_3
                jz      cp_xx_ret
                mov     r0,a
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     dps,#DPS_TOGGLE+0
cp_xx_lp:       movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,cp_xx_lp
                mov     dps,#0
cp_xx_ret:
    __endasm;
}

void copy_xx_5(__xdata u8 *src, __xdata u8 *dest, u8 len)
{
    __asm
                mov     a,b1_3
                jz      cp_xx_5_ret
                mov     r0,a
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
cp_xx_5_lp:     
                mov     dps,#0
                movx    a,@dptr
                inc     dptr
                mov     dps,#1
                movx    @dptr,a
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,cp_xx_5_lp
                mov     dps,#0
cp_xx_5_ret:
    __endasm;
}

bool diff_xx(__xdata u8 *a, __xdata u8 *b, u8 len)
{
    __asm
                mov     a,b1_3
                jz      chg_xx_no
                mov     r0,a
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     dps,#DPS_TOGGLE+0
chg_xx_lp:      movx    a,@dptr
                mov     b,a
                movx    a,@dptr
                cjne    a,b,chg_xx_yes
                inc     dptr
                inc     dptr
                djnz    r0,chg_xx_lp
chg_xx_no:      mov     dpl,#0
                sjmp    chg_xx_ret
chg_xx_yes:     mov     dpl,#TRUE
chg_xx_ret:     mov     dps,#0
    __endasm;
}

u8 get_mask_1(u8 lsb) __naked
{
    __asm
                mov     a,dpl
                anl     a,#7
                add     a,#gm1_table - gm1_movc
                movc    a,@a+pc
gm1_movc:       mov     dpl,a
                ret
gm1_table:      .db     1,2,4,8,16,32,64,128
    __endasm;
}

u8 get_mask(u8 lsb, u8 width) __naked
{
    __asm
                mov     a,dpl
                mov     r0,#0xff
                jb      acc.7,gm_drain1
                anl     a,#~7
                mov     r0,#0
                jnz     gm_drain3
                mov     a,dpl
                add     a,#gm_table1 - gm_movc1
                movc    a,@a+pc
gm_movc1:       mov     r0,a
gm_drain1:
                mov     a,dpl
                add     a,b1_0
                dec     a
                mov     r2,a
                mov     r1,#0
                jb      acc.7,gm_drain3
                anl     a,#~7
                mov     r1,#0xff
                jnz     gm_drain2
                mov     a,r2
                add     a,#gm_table2 - gm_movc2
                movc    a,@a+pc
gm_movc2:       mov     r1,a
gm_drain2:
gm_drain3:      mov     a,r0
                anl     a,r1
                mov     dpl,a
                ret
gm_table1:      .db     -1,-2,-4,-8,-16,-32,-64,-128
gm_table2:      .db     1,3,7,15,31,63,127,255
    __endasm;
}

u8 shift_and_filter5(__xdata u8 *src, u8 a)
{
    __asm
                mov     r4,b1_0
                mov     dps,#0
                
                movx    a,@dptr
                xch     a,r4
                movx    @dptr,a
                inc     dptr
                mov     r0,a
                
                movx    a,@dptr
                xch     a,r4
                movx    @dptr,a
                inc     dptr
                mov     r1,a
                
                movx    a,@dptr
                xch     a,r4
                movx    @dptr,a
                inc     dptr
                mov     r2,a
                
                movx    a,@dptr
                xch     a,r4
                movx    @dptr,a
                mov     r3,a

                ;  0 & 1  & (2  |  3 | 4)
                mov     a,r4
                orl     a,r3
                mov     r6,a    ; r6 = r3 | r4
                orl     a,r2
                anl     a,r1
                anl     a,r0
                mov     r7,a
                
                ; (0 | 1) &  2  & (3 | 4)
                mov     a,r0
                orl     a,r1
                anl     a,r2
                anl     a,r6
                orl     ar7,a
                
                ; (0 | 1  |  2) &  3 & 4
                mov     a,r0
                orl     a,r1
                orl     a,r2
                anl     a,r3
                anl     a,r4
                orl     a,r7

                mov     dpl,a
    __endasm;
}

void shift_up_x(__xdata u8 *p, u8 a, u8 len)
{
    __asm
                mov     a,b1_1
                jz      sux_ret
                mov     r0,a
                mov     r1,b1_0
                mov     dps,#0
sux_lp:         movx    a,@dptr
                xch     a,r1
                movx    @dptr,a
                inc     dptr
                djnz    r0,sux_lp
sux_ret:
    __endasm;
}

void shift_down_x(__xdata u8 *p, u8 a, u8 len)
{
    __asm
                mov     a,b1_1
                jz      sdx_ret
                mov     r0,a
                dec     a
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                clr     a
                addc    a,dpx
                mov     dpx,a
                mov     r1,b1_0
                mov     dps,#DPS_DEC0+0
sdx_lp:         movx    a,@dptr
                xch     a,r1
                movx    @dptr,a
                inc     dptr
                djnz    r0,sdx_lp
                mov     dps,#0
sdx_ret:
    __endasm;
}

/*
void filter5(__xdata u8 *src, __xdata u8 *dest, u8 len)
{
    __asm
                
                mov     a,b1_3
                jz      f5_ret
                mov     r5,a
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
f5_lp:
                mov     dps,#0
                movx    a,@dptr
                mov     r0,a
                inc     dptr
                movx    a,@dptr
                mov     r1,a
                inc     dptr
                movx    a,@dptr
                mov     r2,a
                inc     dptr
                movx    a,@dptr
                mov     r3,a
                inc     dptr
                movx    a,@dptr
                mov     r4,a
                inc     dptr
                
                ;  0 & 1  & (2  |  3 | 4)
                mov     a,r4
                orl     a,r3
                mov     r6,a    ; r6 = r3 | r4
                orl     a,r2
                anl     a,r1
                anl     a,r0
                mov     r7,a
                
                ; (0 | 1) &  2  & (3 | 4)
                mov     a,r0
                orl     a,r1
                anl     a,r2
                anl     a,r6
                orl     ar7,a
                
                ; (0 | 1  |  2) &  3 & 4
                mov     a,r0
                orl     a,r1
                orl     a,r2
                anl     a,r3
                anl     a,r4
                orl     a,r7
                
                mov     dps,#1
                movx    @dptr,a
                inc     dptr
                djnz    r5,f5_lp
                mov     dps,#0
f5_ret:
    __endasm;
}
*/
