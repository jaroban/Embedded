#include <ds80c390.h>
#include <global.h>

#define SRL_RCV_BUF_SIZE 200
#define SRL_XMT_BUF_SIZE 200

__xdata volatile u8 srl_rcv_buf[SRL_RCV_BUF_SIZE];
__data volatile u8 srl_rcv_wr;
__data volatile u8 srl_rcv_rd;

__xdata volatile u8 srl_xmt_buf[SRL_XMT_BUF_SIZE];
__data volatile u8 srl_xmt_wr;
__data volatile u8 srl_xmt_rd;

__bit volatile srl_xmt_ready;

#define SRL_IN_HISTORY 10
#define SRL_IN_TEXTS 9

__xdata u8 srl_in_history[SRL_IN_HISTORY];
__xdata u8 srl_in_index[SRL_IN_TEXTS];

void serial_init()
{
    srl_rcv_wr = 0;
    srl_rcv_rd = 0;
    srl_xmt_wr = 0;
    srl_xmt_rd = 0;
    srl_xmt_ready = 1;

    memset_x(srl_in_index, 0, SRL_IN_TEXTS);

    SCON0 = (2 << 5) |  // mode = start + 8 + stop, asynch
            (1 << 4) |  // enable reception
            (0 << 3) |  // tb8
            (0 << 2) |  // rb8
            (0 << 1) |  // transmit interrupt flag
            (0 << 0);   // receive interrupt flag

    RCAP2 = T2_RELOAD;  // timer 2 reload
    TMR2 = T2_RELOAD;

    T2CON = (1 << 5) |  // rclk
            (1 << 4) |  // tclk
            (1 << 2);   // run

    ES0 = 1;    // enable interrupt
}

void serial_interrupt() __interrupt (4) __naked
{
    __asm
                push    psw
                push    acc
                push    dpl
                push    dph
                push    dpx
                push    dps
                mov     dps,#0

                jnb     ri,srl_rcv_end
                clr     ri

                mov     a,_srl_rcv_wr
                add     a,#_srl_rcv_buf
                mov     dpl,a
                clr     a
                addc    a,#_srl_rcv_buf >> 8
                mov     dph,a
                mov     dpx,#_srl_rcv_buf >> 16

                mov     a,sbuf
                movx    @dptr,a

                mov     a,_srl_rcv_wr
                inc     a
                cjne    a,#SRL_RCV_BUF_SIZE,srl_rcv_skip1
                clr     a
srl_rcv_skip1:  cjne    a,_srl_rcv_rd,srl_rcv_store
                sjmp    srl_rcv_end         ; buffer overrun - last char overwritten
srl_rcv_store:  mov     _srl_rcv_wr,a

srl_rcv_end:    jnb     ti,srl_xmt_end
                clr     ti

                mov     a,_srl_xmt_rd
                cjne    a,_srl_xmt_wr,srl_xmt_skip1
                setb    _srl_xmt_ready      ; no more chars in buffer to write
                sjmp    srl_xmt_end

srl_xmt_skip1:  add     a,#_srl_xmt_buf
                mov     dpl,a
                clr     a
                addc    a,#_srl_xmt_buf >> 8
                mov     dph,a
                mov     dpx,#_srl_xmt_buf >> 16

                movx    a,@dptr
                mov     sbuf,a

                mov     a,_srl_xmt_rd
                inc     a
                cjne    a,#SRL_XMT_BUF_SIZE,srl_xmt_skip2
                clr     a
srl_xmt_skip2:  mov     _srl_xmt_rd,a

srl_xmt_end:    pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     acc
                pop     psw
                reti
    __endasm;
}

u8 get_char_available() __critical
{
    return (srl_rcv_wr < srl_rcv_rd) ?
            srl_rcv_wr - srl_rcv_rd + SRL_RCV_BUF_SIZE :
            srl_rcv_wr - srl_rcv_rd;
}

u8 get_char() __critical
{
    u8 c = 0;

    if(srl_rcv_rd != srl_rcv_wr)
    {
        // data available
        c = srl_rcv_buf[srl_rcv_rd];

        srl_rcv_rd++;
        if(srl_rcv_rd == SRL_RCV_BUF_SIZE) srl_rcv_rd = 0;
    }
    return c;
}

u8 put_char_available() __critical
{
    return (srl_xmt_wr < srl_xmt_rd) ?
            srl_xmt_rd - srl_xmt_wr - 1 :
            srl_xmt_rd - srl_xmt_wr + SRL_XMT_BUF_SIZE - 1;
}

void put_char_direct(u8 c)
{
    ES0 = 0;    // disable interrupt
    TI_0 = 0;
    SBUF0 = c;
    while(!TI_0) reset_watchdog();
    TI_0 = 0;
    ES0 = 1;    // enable interrupt
}

void put_char_buffered(u8 c) __critical
{
    u8 i;

    //if(c == (u8)'\n') put_char('\r');

    if(srl_xmt_ready)
    {
        // empty buffer
        srl_xmt_ready = 0;

        SBUF0 = c;
    }
    else
    {
        i = srl_xmt_wr;

        srl_xmt_buf[i] = c;

        INC_MOD(i, SRL_XMT_BUF_SIZE);

        if(i != srl_xmt_rd)
        {
            srl_xmt_wr = i;
        }
        // else: buffer overrun, last char overwritten
    }
}

__code u8 srl_in_format[] =
    "reset\0"
    "msg0####\0"
    "msg1######\0"
    "msg2########\0"
    "debug on\0"
    "debug off\0"
    "cmp########\0"
    "del####\0"
    "zak####\0"
    "loc####\0"
    "boss\0"
    "download\0"
    "parameters\0"
    "ok?\0"
    "sig##\0"
    "stat\0"
    "next\0"
    "again\0";

void (* __code srl_in_callback[])() = {
    reset
};
/*
    srl_get_msg0
    srl_get_msg1
    srl_get_msg2
    srl_dbg_on
    srl_dbg_off
    srl_get_cmp
    srl_get_del
    srl_get_zak
    srl_get_loc
    srl_get_boss
    do_download
    do_parameters
    srl_gsm_ok
    srl_gsm_sig
    srl_gsm_stat
    srl_gsm_next
    srl_gsm_again
*/


// returns index of detected string or -1 if none
u8 detect_string(__code u8 *format, __xdata u8 *indices, u8 a)
{
    __asm
                mov     dpl1,b1_0
                mov     dph1,b1_1
                mov     dpx1,b1_2
                mov     dps,#DPS_TOGGLE+1
                mov     r1,#0

srl_in_lp1:     movx    a,@dptr                 ; 1
srl_in_first:   mov     r2,a
                movc    a,@a+dptr               ; 0
                acall   srl_in_check
                jnz     srl_in_ok

                ; reset index
                mov     a,r2
                jz      srl_in_next
                clr     a
                movx    @dptr,a                 ; 1
                sjmp    srl_in_first

                ; increment index
srl_in_ok:      mov     a,r2
                inc     a
                movx    @dptr,a                 ; 1
                movc    a,@a+dptr               ; 0

                ; end of string?
                jz      srl_in_ret

                ; go to next string (find 0)
srl_in_next:    mov     dps,#0
srl_in_lp2:     inc     dptr
                clr     a
                movc    a,@a+dptr
                jnz     srl_in_lp2

                mov     dps,#DPS_TOGGLE+0
                inc     r1

                ; move to first character of next string
                inc     dptr                    ; 0

                ; move to next index
                inc     dptr                    ; 1

                ; is the character zero?
                clr     a
                movc    a,@a+dptr               ; 0
                jnz     srl_in_lp1

                mov     r1,#0xff
srl_in_ret:     mov     dps,#0
                mov     dpl,r1
                ret

srl_in_check:   cjne    a,#'#',srl_in_exact
                mov     a,b1_3
                clr     c
                subb    a,#'0'
                jc      srl_in_diff
                subb    a,#'9'-'0'+1
                jc      srl_in_match
                subb    a,#'A'-'9'-1
                jc      srl_in_diff
                subb    a,#'F'-'A'+1
                jc      srl_in_match
                subb    a,#'a'-'F'-1
                jc      srl_in_diff
                subb    a,#'f'-'a'+1
                jc      srl_in_match
srl_in_diff:    clr     a
                ret
srl_in_exact:   cjne    a,b1_3,srl_in_diff
srl_in_match:   mov     a,#0xff
    __endasm;
}
/*

                ; call callback function
                mov     dps,#0

                ; reset all indices
                acall   _srl_in_init


                ; push return address
                mov     a,#low(srl_in_callback)
                push    acc
                mov     a,#high(srl_in_callback)
                push    acc
                clr     a
                push    acc
                mov     a,r1
                add     a,r1
                add     a,r1
                mov     dptr,#srl_in_callback
                jmp     @a+dptr

                ; return to where????

*/




void serial_in_detect()
{
    u8 a;

    while(get_char_available())
    {
        a = get_char();

        // save for hex numbers
        shift_up_x(srl_in_history, a, SRL_IN_HISTORY);

        // string detector
        a = serial_in_detect2(srl_in_format, srl_in_index, a);

        if(a != 0xff)
        {
            // clear indices
            memset_x(srl_in_index, 0, SRL_IN_TEXTS);
            
            // call callback
            srl_in_callback[a]();
        }
    }
}
