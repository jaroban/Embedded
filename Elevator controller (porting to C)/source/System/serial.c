#include <ds80c390.h>
#include <global.h>

// serial
#define SRL_XMT_BUF_SIZE 100

__xdata volatile u8 srl_xmt_buf[SRL_XMT_BUF_SIZE];
__data volatile u8 srl_xmt_wr;
__data volatile u8 srl_xmt_rd;

#define SRL_RCV_BUF_SIZE 100

__xdata volatile u8 srl_rcv_buf[SRL_RCV_BUF_SIZE];
__data volatile u8 srl_rcv_wr;
__data volatile u8 srl_rcv_rd;

void serial_init()
{
    // set up serial port
    srl_xmt_wr = 0; srl_xmt_rd = 0;
    srl_rcv_wr = 0; srl_rcv_rd = 0;

    SCON0 = 0xd0;
    RCAP2H = T2_RELOAD >> 8;
    RCAP2L = T2_RELOAD & 0xff;
    T2CON = 0x30;
    TR2 = 1;
}

void serial_interrupt() __interrupt (4) __naked
{
    __asm
                clr     ea
                push    acc
                push    psw
                push    dpl
                push    dph
                push    dpx
                push    dps
                mov     dps,#0
                
                jnb     ri,srl_rcv_end
                clr     ri
                ; received u8
                mov     a,sbuf
                mov     c,p
                jnb     rb8,srl_rcv_skip1
                cpl     c
srl_rcv_skip1:  jnc     srl_rcv_end
                ; parity ok
                push    acc
                mov     a,_srl_rcv_wr
                inc     a
                cjne    a,#SRL_RCV_BUF_SIZE,srl_rcv_skip2
                clr     a
srl_rcv_skip2:  cjne    a,_srl_rcv_rd,srl_rcv_skip3
                ; buffer full
                pop     acc
                sjmp    srl_rcv_end
srl_rcv_skip3:  ; store it
                xch     a,_srl_rcv_wr
                add     a,#_srl_rcv_buf
                mov     dpl,a
                clr     a
                addc    a,#_srl_rcv_buf >> 8
                mov     dph,a
                mov     dpx,#_srl_rcv_buf >> 16
                pop     acc
                movx    @dptr,a

srl_rcv_end:    jnb     ti,srl_xmt_end
                clr     ti
                mov     a,_srl_xmt_rd
                cjne    a,_srl_xmt_wr,srl_xmt_skip1
                ; buffer empty
                sjmp    srl_xmt_end
srl_xmt_skip1:  inc     a
                cjne    a,#SRL_XMT_BUF_SIZE,srl_xmt_skip2
                clr     a
srl_xmt_skip2:  ; send it
                xch     a,_srl_xmt_rd
                add     a,#_srl_xmt_buf
                mov     dpl,a
                clr     a
                addc    a,#_srl_xmt_buf >> 8
                mov     dph,a
                mov     dpx,#_srl_xmt_buf >> 16
                movx    a,@dptr
                mov     c,p
                cpl     c
                mov     tb8,c
                mov     sbuf,a

srl_xmt_end:    pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     psw
                pop     acc
                setb    ea
                reti
    __endasm;
}

u8 get_char_left()
{
    char n = srl_rcv_wr - srl_rcv_rd;
    if(n < 0) n += SRL_RCV_BUF_SIZE;
    return n;
}

u8 get_char() __critical
{
    u8 c;
    if(srl_rcv_rd == srl_rcv_wr) return 0;  // buffer empty
    c = srl_rcv_buf[srl_rcv_rd];
    if(++srl_rcv_rd == SRL_RCV_BUF_SIZE) srl_rcv_rd = 0;
    return c;
}

u8 put_char_left()
{
    char n = srl_xmt_wr - srl_xmt_rd;
    if(n < 0) n += SRL_XMT_BUF_SIZE;
    return n;
}

void put_char(u8 c) __critical
{
    u8 i = srl_xmt_wr;
    if(++i == SRL_XMT_BUF_SIZE) i = 0;
    if(i == srl_xmt_rd) return; // buffer full
    if(srl_xmt_wr == srl_xmt_rd) TI_0 = 1; // buffer empty
    srl_xmt_buf[srl_xmt_wr] = c;
    srl_xmt_wr = i;
    return;
}
