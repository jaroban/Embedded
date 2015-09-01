#include <global.h>

#define T1_RELOAD (65536 - (FREQUENCY * CLOCK_MULTIPLIER) / \
                           (4 * 1010))

__data u16 lcom_shift;
__sbit outputs_changed1;

void timer1_init()
{
    // add stuff here?
    
    TMOD |= 0x10;
    TR1 = 0;
    TMR1 = T1_RELOAD;
    TR1 = 1;
    ET1 = 1;
}

void clear_lcom_data() { }
void set_lcom_data() { }
void write_board_outputs() { }

void timer1_interrupt() __interrupt (3) __naked
{
    __asm
                push    psw
                push    acc
                push    dpl
                push    dph
                push    dpx
                push    dps
                push    ar0
                push    ar1
                push    _CKCON
                
                mov     dps,#0

                ; reset timer
t1i_again:      clr     tr1
                mov     a,tl1                       ; 1
                add     a,#T1_RELOAD + 7            ; 1
                mov     tl1,a                       ; 1
                mov     a,th1                       ; 1
                addc    a,#(T1_RELOAD + 7) >> 8     ; 1
                mov     th1,a                       ; 1
                setb    tr1                         ; 1
                jc      t1i_again
                
                ; 1010 baud serial port
                mov     a,_lcom_shift
                orl     a,_lcom_shift+1
                jz      t1i_lcom_done
                mov     a,_lcom_shift+1
                clr     c
                rrc     a
                mov     _lcom_shift+1,a
                mov     a,_lcom_shift
                rrc     a
                mov     _lcom_shift,a
                jc      t1i_lcom_1
                acall   _clear_lcom_data
                sjmp    t1i_lcom_out
t1i_lcom_1:     acall   _set_lcom_data
t1i_lcom_out:   jnb     _outputs_changed1,t1i_lcom_done
                clr     _outputs_changed1
                acall   _write_board_outputs
t1i_lcom_done:

/*
                ; mux
                jnb     im_da_boss,t1_ret
                mov     a,mux_state
                jz      t1_ret
                djnz    mux_timer,t1_ret
                mov     a,mux_state
                dec     a
                rl      a
                mov     dptr,#t1_mux_table
                jmp     @a+dptr
t1_ret:         
                jnb     brd_change2,t1_ret2
                clr     brd_change2
                call    write_trans_reg
t1_ret2:        
*/
                pop     _CKCON
                pop     ar1
                pop     ar0
                pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     acc
                pop     psw
t1i_reti:       reti
    __endasm;
}
