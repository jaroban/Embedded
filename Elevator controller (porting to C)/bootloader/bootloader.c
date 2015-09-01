#include <ds80c390.h>
#include "bootloader.h"

// serial
#define SRL_RCV_BUF_SIZE 250
#define SRL_XMT_BUF_SIZE 250

__xdata u8 srl_rcv_buf[SRL_RCV_BUF_SIZE];
__data u8 srl_rcv_wr;
__data u8 srl_rcv_rd;

__xdata u8 srl_xmt_buf[SRL_XMT_BUF_SIZE];
__data u8 srl_xmt_wr;
__data u8 srl_xmt_rd;

// stack
__idata u8 stack[50];

// flash / hex
#define LINE_SIZE 50
__data u8 console_line[LINE_SIZE];

__bit flash_identical;
__bit flash_error;
__bit flash_need_erase;
__bit flash_expect_hex;
__bit flash_want_write;

__data u8 hex_line[20];
__data u16 p;

// must be first routine
void bootloader()
{
    IE = 0;
    SP = (u8)(stack - 1);

    serial_init();
    serial_loop();
}

void serial_init()
{
    // set up serial port
    srl_rcv_wr = 0; 
    srl_rcv_rd = 0;
    srl_xmt_wr = 0; 
    srl_xmt_rd = 0;

    SCON0 = (2 << 5) |  // mode = start + 8 + stop, asynch
            (1 << 4) |  // enable reception
            (0 << 3) |  // tb8
            (0 << 2) |  // rb8
            (1 << 1) |  // transmit interrupt flag
            (0 << 0);   // receive interrupt flag

    RCAP2 = T2_RELOAD;  // timer 2 reload
    TMR2 = T2_RELOAD;

    T2CON = (1 << 5) |  // rclk
            (1 << 4) |  // tclk
            (1 << 2);   // run
}

void wait()
{
    if(RI_0)
    {
        RI_0 = 0;

        // new byte has arrived
        srl_rcv_buf[srl_rcv_wr] = SBUF0;

        INC_MOD(srl_rcv_wr, SRL_RCV_BUF_SIZE);

        if(srl_rcv_wr == srl_rcv_rd)
        {
            // buffer is full
            INC_MOD(srl_rcv_rd, SRL_RCV_BUF_SIZE);
        }
    }

    if(srl_xmt_rd != srl_xmt_wr)
    {
        if(TI_0)
        {
            TI_0 = 0;
        
            // send next byte
            SBUF0 = srl_xmt_buf[srl_xmt_rd];

            INC_MOD(srl_xmt_rd, SRL_XMT_BUF_SIZE);
        }
    }
}

u8 get_char_available()
{
    return (srl_rcv_wr < srl_rcv_rd) ?
            srl_rcv_wr - srl_rcv_rd + SRL_RCV_BUF_SIZE :
            srl_rcv_wr - srl_rcv_rd;
}

u8 get_char()
{
    u8 c = 0;
    
    if(srl_rcv_rd != srl_rcv_wr)
    {
        // data available
        c = srl_rcv_buf[srl_rcv_rd];
        
        INC_MOD(srl_rcv_rd, SRL_RCV_BUF_SIZE);
    }
    return c;
}

u8 put_char_available()
{
    return (srl_xmt_wr < srl_xmt_rd) ?
            srl_xmt_rd - srl_xmt_wr - 1 :
            srl_xmt_rd - srl_xmt_wr + SRL_XMT_BUF_SIZE - 1;
}

void put_char(u8 c)
{
    if(c == (u8)'\n') put_char('\r');

    srl_xmt_buf[srl_xmt_wr] = c;
    
    INC_MOD(srl_xmt_wr, SRL_XMT_BUF_SIZE);

    if(srl_xmt_wr == srl_xmt_rd)
    {
        // buffer is full
        INC_MOD(srl_xmt_rd, SRL_XMT_BUF_SIZE);
    }
}

// payload
void reset()
{
    CKCON &= 0x3f;  // shortest watchdog
    TIMED_ACCESS;
    WDCON |= 3;     // enable reset
    while(1) ;      // wait
}

void select_chip(u8 chip)
{
    if(chip == 0)
    {
        // code
        TIMED_ACCESS;
        MCON = 0xe1;
    }
    else
    {
        // 2nd flash
        TIMED_ACCESS;
        MCON = 0xe0;
    }
}

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
            return TRUE;
        }
        if(new & 0x20) exit_next = 1;
    }
}

u8 flash_write(__xdata u8 *p, u8 a)
{
    flash_555 = 0xaa; 
    flash_2aa = 0x55; 
    flash_555 = 0xa0;
    *p = a;
    return flash_wait();
}

u8 flash_erase_chip()
{
    flash_555 = 0xaa; 
    flash_2aa = 0x55; 
    flash_555 = 0x80;
    flash_555 = 0xaa; 
    flash_2aa = 0x55; 
    flash_555 = 0x10;
    return flash_wait();
}

bool is_blank_c()
{
    __xdata u8 *p = 0;

    do { if(*p++ != 0xff) return 0; } while(p != (__xdata u8 *)0x10000);

    return TRUE;
}

// string / text routines
u8 bin_to_hex(u8 a)
{
#if 0
    return "0123456789ABCDEF"[a & 0xf];
#else
    __asm
                mov     a,dpl
                anl     a,#0x0f
                add     a,#2$-1$
                movc    a,@a+pc
1$:             mov     dpl,a
                ret
2$:             .ascii  "0123456789ABCDEF"
    __endasm;
#endif
}

void put_hex(u8 a)
{
#if 0
    put_char(bin_to_hex(a >> 4));
    put_char(bin_to_hex(a));
#else
    __asm
                push    dpl
                mov     a,dpl
                swap    a
                mov     dpl,a
                acall   _bin_to_hex
                acall   _put_char
                pop     dpl
                acall   _bin_to_hex
                acall   _put_char
    __endasm;
#endif
}

void puts_h16(u16 a)
{
#if 0
    put_hex(a >> 8);
    put_hex(a);
#else
    __asm
                push    dpl
                mov     dpl,dph
                acall   _put_hex
                pop     dpl
                acall   _put_hex
    __endasm;
#endif
}

u8 hex_to_bin(u8 c)
{
#if 0
    if((c >= (u8)'0') && (c <= (u8)'9')) return c - '0';
    if((c >= (u8)'A') && (c <= (u8)'F')) return c - 'A' + 10;
    if((c >= (u8)'a') && (c <= (u8)'f')) return c - 'a' + 10;
    return -1;
#else
    __asm
                ; 0-9
                mov     a,dpl
                add     a,#-'0  ;'
                jnc     _ath_no
                add     a,#-10
                jnc     _ath_10

                ; A-F
                mov     a,dpl
                add     a,#-'A  ;'
                jnc     _ath_no
                add     a,#-6
                jnc     _ath_16

                ; a-f
                mov     a,dpl
                add     a,#-'a  ;'
                jnc     _ath_no
                add     a,#-6
                jnc     _ath_16

                ; all others
_ath_no:        mov     dpl,#0xff
                ret
_ath_16:        add     a,#16
                mov     dpl,a
                ret
_ath_10:        add     a,#10
                mov     dpl,a
    __endasm;
#endif
}

void puts_c(__code u8 *p)
{
#if 0
    while(*p) put_char(*p++);
#else
    __asm
_puts_c_lp1:    clr     a
                movc    a,@a+dptr
                jz      _puts_c_ret
                inc     dptr
                push    dpl
                push    dph
                push    dpx
                mov     dpl,a
                acall   _put_char
                pop     dpx
                pop     dph
                pop     dpl
                sjmp    _puts_c_lp1
_puts_c_ret:
    __endasm;
#endif
}

/*
void puts_x(__xdata u8 *p)
{
#if 0
    while(*p) put_char(*p++);
#else
    __asm
_puts_x_lp1:    movx    a,@dptr
                jz      _puts_x_ret
                inc     dptr
                push    dpl
                push    dph
                push    dpx
                mov     dpl,a
                acall   _put_char
                pop     dpx
                pop     dph
                pop     dpl
                sjmp    _puts_x_lp1
_puts_x_ret:
    __endasm;
#endif
}

u16 strlen_c(__code u8 *s)
{
    __code u8 *p = s;
    while(*p) p++;
    return p - s;
}

u16 strlen_x(__xdata u8 *s)
{
    __xdata u8 *p = s;
    while(*p) p++;
    return p - s;
}
*/

u8 strlen_i(__idata u8 *s)
{
    u8 i = 0;
    while(*s) { s++; i++; }
    return i;
}

/*
// is the beginning of s1 == s2 ?
bool strcmp_xc(__xdata u8 *s1, __code u8 *s2)
{
#if 0
    u8 c1, c2;

    while(1)
    {
        c2 = *s2++;
        if(c2 == 0) return TRUE;

        c1 = *s1++;
        if(c1 == 0) return 0;
        if(c1 != c2) return 0;
    }
#else
    __asm
                push    ar0
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     dps,#DPS_TOGGLE+1
_sc_xc_lp1:     clr     a
                movc    a,@a+dptr
                jz      _sc_xc_yes
                mov     r0,a
                movx    a,@dptr
                jz      _sc_xc_no
                inc     dptr
                inc     dptr
                xrl     a,r0
                jz      _sc_xc_lp1
_sc_xc_no:      mov     dpl,#0
                sjmp    _sc_xc_done
_sc_xc_yes:     mov     dpl,#0xff
_sc_xc_done:    mov     dps,#0
                pop     ar0
    __endasm;
#endif
}
*/

// is the beginning of s1 == s2 ?
bool strcmp_ic(__code u8 *s2, __idata u8 *s1)
{
#if 1
    u8 c1, c2;

    while(1)
    {
        c2 = *s2++;
        if(c2 == 0) return TRUE;

        c1 = *s1++;
        if(c1 == 0) return 0;
        if(c1 != c2) return 0;
    }
#else
    __asm
    not equivalent!!111
                push    ar0
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     dps,#DPS_TOGGLE+1
_sc_xc_lp1:     clr     a
                movc    a,@a+dptr
                jz      _sc_xc_yes
                mov     r0,a
                movx    a,@dptr
                jz      _sc_xc_no
                inc     dptr
                inc     dptr
                xrl     a,r0
                jz      _sc_xc_lp1
_sc_xc_no:      mov     dpl,#0
                sjmp    _sc_xc_done
_sc_xc_yes:     mov     dpl,#0xff
_sc_xc_done:    mov     dps,#0
                pop     ar0
    __endasm;
#endif
}



/*
// is the beginning of str1 == str2 ?
u8 strcmp_xf(__xdata u8 *str1)
{
    __asm
                
    
                mov     dps,#0x21
_sc_xc_lp1:     clr     a
                movc    a,@a+dptr
                jz      _sc_xc_yes
                mov     r0,a
                movx    a,@dptr
                jz      _sc_xc_no
                inc     dptr
                inc     dptr
                xrl     a,r0
                jz      _sc_xc_lp1

_sc_xc_no:      mov     dpl,#0
                sjmp    _sc_xc_done
_sc_xc_yes:     mov     dpl,#0xff
_sc_xc_done:    mov     dps,#0
                ret
    __endasm;
}
*/

void dump_code()
{
    __data u8 *q;
    u8 i, s;
    
    p = 0;
    
    hex_line[0] = 16;
    hex_line[3] = 0;

    while(1)
    {
        while(put_char_available() < 45) wait();

        hex_line[1] = p >> 8;
        hex_line[2] = p;

        i = 16;
        q = hex_line + 4;

        do { *q++ = *((__code u8 *)p++); } while(--i);

        // is line all 0xff?
        s = 0xff;
        i = 16;
        q = hex_line + 4;
        
        do { s &= *q++; } while(--i);
        
        if(s != 0xff)
        {
            // printout
            put_char(':');

            s = 0;
            i = 20;
            q = hex_line;
            
            do { s += *q; put_hex(*q++); } while(--i);

            put_hex(-s);
            puts_c("\n");
        }

        if(p == 0) break;
    }
    puts_c(":00000001FF\n");
}

void gets(__idata u8 *buffer, u8 limit, bool echo)
{
    u8 i = 0;
    u8 c;

    while(1)
    {
        while(!get_char_available()) wait();
        c = get_char();
        if(c == LF) continue; // ignore LF
        if(c == CR) break;    // enter
        if(i == (u8)(limit - 1)) continue;
        if(echo) put_char(c);
        if((c == DELETE) && i) { i--; continue; }
        buffer[i++] = c;
    }

    // null terminate string
    buffer[i] = 0;
}

void flash_code()
{
    u8 len, i, s, c1, c2;
    __data u8 *q;
    __data u8 *r;

    flash_identical = 1;
    flash_error = 0;
    flash_need_erase = 0;
    
    while(1)
    {
next_line:
        gets(console_line, LINE_SIZE, 0);
        
        len = strlen_i(console_line);
        
        if(len < 11)
        {
            puts_c("too short\n");
            flash_error = 1;
            continue;
        }
        
        if(console_line[0] != (u8)':')
        {
            puts_c("expecting ':'\n");
            flash_error = 1;
            continue;
        }
        
        i = (u8)(len - 1) >> 1;
        q = console_line + 1;
        r = hex_line;
        
        do
        {
            c1 = hex_to_bin(*q++);
            c2 = hex_to_bin(*q++);

            if((c1 == 0xff) || (c2 == 0xff))
            {
                puts_c("non-hex character\n");
                flash_error = 1;
                goto next_line;
            }
            *r++ = (c1 << 4) | c2;
        }
        while(--i);
        
        if(hex_line[3] == 1) break;
        if(hex_line[3] != 0) continue;

        len = hex_line[0];
        
        // checksum
        i = len + 5;
        r = hex_line;
        s = 0;
        
        do { s += *r++; } while(--i);

        if(s != 0)
        {
            puts_c("bad checksum\n");
            flash_error = 1;
            continue;
        }
        
        i = len;
        r = hex_line + 4;
        p = (hex_line[1] << 8) | hex_line[2];
        
        do
        {
            c1 = *r++;
            c2 = *(__xdata u8 *)p;
            
            if(c1 != c2)
            {
                flash_identical = 0;
                
                if(c1 & ~c2)
                {
                    // flash needs to be erased
                    flash_need_erase = 1;
                }

                if(flash_want_write && !flash_need_erase)
                {
                    if(flash_write((__xdata u8 *)p, c1))
                    {
                        puts_c("writing failed at ");
                        puts_h16(p);
                        puts_c("\n");
                        flash_error = 1;
                    }
                }
                
            }

            p++;
        }
        while(--i);
        
        // write page info (progess info)
        //puts_h16(p);
        put_char('.');
    }
}

void print_help()
{
    puts_c("Available commands:\n"
            "reset dump select erase flash verify\n");
}

void serial_loop()
{
    while(1)
    {
        puts_c("\n# ");

        gets(console_line, LINE_SIZE, 1);

        if(strcmp_ic("reset", console_line)) { reset(); continue; }
        if(strcmp_ic("dump", console_line)) { dump_code(); continue; }
        if(strcmp_ic("select", console_line)) 
        { 
            select_chip(console_line[7] - '0');
            continue; 
        }

        flash_need_erase = 0;
        flash_expect_hex = 0;
        flash_want_write = 0;
        
        if(strcmp_ic("erase", console_line))
        {
            flash_need_erase = 1;
        }
        
        if(strcmp_ic("flash", console_line)) 
        {
            flash_need_erase = 1;
            flash_expect_hex = 1;
            flash_want_write = 1;
        }
        
        if(strcmp_ic("verify", console_line)) 
        {
            flash_expect_hex = 1;
        }
        
        puts_c("\n");
erase:
        if(flash_need_erase)
        {
            if(flash_erase_chip()) 
            { 
                puts_c("erase failed\n"); 
                continue;
            }
            
            // actually check that it's blank
            if(!is_blank_c()) 
            { 
                puts_c("not blank\n"); 
                continue; 
            }
            
            puts_c("all clear\n"); 
        }
        
        if(flash_expect_hex)
        {
resend:
            flash_code();
            
            if(flash_error) 
            {
                puts_c("error, resend\n");
                goto resend;
            }
            
            if(flash_identical)
            {
                puts_c("identical\n"); 
                continue;
            }
            
            if(flash_need_erase)
            {
                puts_c("erasing, resend\n"); 
                goto erase;
            }

            continue;
        }

        print_help();
    }
}
