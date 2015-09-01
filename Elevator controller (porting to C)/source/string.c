#include <put_char.h>
#include <serial.h>
#include <lcd.h>
#include <os.h>

void put_char(u8 c)
{
    switch(get_dest())
    {
        case SERIAL:    put_char_serial(c); break;
        case LCD:       lcd_put_char(c);    break;
    }
}

void puts(const __code u8 *s) __naked
{
#if 0
    while(*s) put_char(*s++);
#else
    __asm
2$:             mov     dps,#0
                clr     a
                movc    a,@a+dptr
                jz      1$
                inc     dptr
                push    dpl
                push    dph
                push    dpx
                mov     dpl,a
                acall   _put_char
                pop     dpx
                pop     dph
                pop     dpl
                sjmp    2$
1$:             ret
    __endasm;
#endif
}

u16 strlen_c(__code u8 *str)
{
#if 0
    int i = 0; while(*str) { str++; i++; } return i;
#else
    __asm
                mov     dps,#0
                mov     dpl1,dpl
                mov     dph1,dph
                sjmp    sl_c_entry
sl_c_main_lp:   inc     dptr
sl_c_entry:     clr     a
                movc    a,@a+dptr
                jnz     sl_c_main_lp
                clr     c
                mov     a,dpl
                subb    a,dpl1
                mov     dpl,a
                mov     a,dph
                subb    a,dph1
                mov     dph,a
    __endasm;
#endif
}
