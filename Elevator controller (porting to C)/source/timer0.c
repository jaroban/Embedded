#include <global.h>
#include <incremental.h>
#include <ac.h>

#define T0_RELOAD (65536 - (FREQUENCY * CLOCK_MULTIPLIER) / \
                           (4 * TIMERS_PER_TICK * TICKS_PER_SECOND))

static __sbit __at 0x90 inc_toggle;     // p1.0
static __sbit __at 0x91 inc_dir;        // p1.1

static __sbit inc_toggle_old;

static __data u8 ac_index1;
static __data u8 ac_index2;
static __data u8 ac_index3;

static __idata u8 ac_table[20];
static __data u8 ac_counter;
static __data u8 ac_phase_filter;

__sbit ac_phases;
__data u8 ac_values;

void timer0_init()
{
    ac_index1 = 1;
    ac_index2 = 1 + 7;
    ac_index3 = 1 + 7 + 7;
    ac_counter = 1;
    ac_phase_filter = 0;
    
    TMOD |= 0x01;
    TR0 = 0;
    TMR0 = T0_RELOAD;
    TR0 = 1;
    ET0 = 1;
}

// every 1 ms
void timer0_interrupt() __interrupt (1) __naked
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

                ; hw watchdog
                mov     _TA,#0xaa
                mov     _TA,#0x55
                orl     _WDCON,#1

t0i_again:      ; ticks
                inc     _ticks

                ; sw watchdog
                inc     _thread_watchdog
                mov     a,_thread_watchdog
                add     a,#-THREAD_WATCHDOG_BEFORE_RESET
                jnc     t0i_sw_done
                ajmp    _reset
t0i_sw_done:
                ; a/c indices
                djnz    _ac_index1,t0i_ac_skip1
                mov     _ac_index1,#20
t0i_ac_skip1:   djnz    _ac_index2,t0i_ac_skip2
                mov     _ac_index2,#20
t0i_ac_skip2:   djnz    _ac_index3,t0i_ac_skip3
                mov     _ac_index3,#20
t0i_ac_skip3:   
                ; reset timer
                clr     tr0
                mov     a,tl0                       ; 1
                add     a,#T0_RELOAD + 7            ; 1
                mov     tl0,a                       ; 1
                mov     a,th0                       ; 1
                addc    a,#(T0_RELOAD + 7) >> 8     ; 1
                mov     th0,a                       ; 1
                setb    tr0                         ; 1
                jc      t0i_again

                ; incremental counter
                jnb     _inc_running,t0i_inc_done
                clr     a
                mov     c,_inc_toggle
                rlc     a
                mov     c,_inc_toggle_old
                rlc     a
                jnb     p,t0i_inc_done
                cpl     _inc_toggle_old
                jb      _inc_dir,t0i_inc_up
                mov     dps,#DPS_DEC0+0
t0i_inc_up:     mov     dpl,_inc_counter
                mov     dph,_inc_counter+1
                inc     dptr
                mov     _inc_counter,dpl
                mov     _inc_counter+1,dph
                mov     dps,#0
t0i_inc_done:   

                ; a/c inputs
                orl     _CKCON,#7
                mov     dptr,#0x100005      ; a/c inputs
                movx    a,@dptr
                mov     r1,a

                mov     a,_ac_index1
                add     a,#_ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#0b11001111
                orl     a,@r0
                mov     @r0,a
                
                mov     a,_ac_index2
                add     a,#_ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#0b10101111
                orl     a,@r0
                mov     @r0,a
                
                mov     a,_ac_index3
                add     a,#_ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#0b10011111
                orl     a,@r0
                mov     @r0,a

                djnz    _ac_counter,t0i_ac_done
                mov     _ac_counter,#READ_AC_THIS_MANY_TIMES

                ; allow other interrupts
                acall   t0i_reti

                ; a/c evaluation
                push    ar2
                push    ar3
                clr     a
                mov     r0,#_ac_table
                mov     r1,a
                mov     r2,a
                mov     r3,#20
                mov     _ac_values,a
t0i_ac_lp1:     
                mov     a,@r0
                orl     _ac_values,a
                anl     a,#PHASE_MASK
                jnz     t0i_ac_nz
                inc     r1
t0i_ac_nz:      xrl     a,#PHASE_MASK
                jnz     t0i_ac_nff
                inc     r2
t0i_ac_nff:     clr     a
                mov     @r0,a
                inc     r0
                djnz    r3,t0i_ac_lp1
                
                mov     a,r1
                add     a,#-MIN_ZEROES
                jnc     t0i_ac_bad
                mov     a,r2
                add     a,#-MIN_ONES
                jnc     t0i_ac_bad

                mov     a,_ac_phase_filter
                add     a,#-(2 * PHASE_FILTER + 1)
                jc      t0i_ac_eval
                inc     _ac_phase_filter
                sjmp    t0i_ac_eval
t0i_ac_bad: 
                mov     a,_ac_phase_filter
                jz      t0i_ac_eval
                dec     _ac_phase_filter
t0i_ac_eval:    
                mov     a,_ac_phase_filter
                add     a,#-PHASE_FILTER
                mov     _ac_phases,c
                pop     ar3
                pop     ar2
t0i_ac_done:

                pop     _CKCON
                pop     ar1
                pop     ar0
                pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     acc
                pop     psw
t0i_reti:       reti
    __endasm;
}
