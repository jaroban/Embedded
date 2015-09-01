#include <global.h>

__xdata u8 timer_table[4 * NO_OF_TIMERS];
__data u8 timer_no;
__data volatile u8 ticks;

void init_timers()
{
    ticks = 0;
    timer_no = 0;
}

void decrement_timers2()
{
    __asm
                mov     a,_timer_no
                jz      dt2_ret
                mov     r0,a
                mov     b,#4
                mul     ab
                add     a,#(_timer_table + 3)
                mov     dpl,a
                mov     dpl1,a
                mov     a,b
                addc    a,#(_timer_table + 3) >> 8
                mov     dph,a
                mov     dph1,a
                clr     a
                addc    a,#(_timer_table + 3) >> 16
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#DPS_DEC0+0
dt2_lp1:        
                movx    a,@dptr
                djnz    acc,dt2_dec4
                mov     a,#TICKS_PER_SECOND
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                djnz    acc,dt2_dec3
                mov     a,#60
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                djnz    acc,dt2_dec2
                
                dec     _timer_no
                mov     dps,#0
                inc     dptr
                inc     dptr
                mov     dps,#DPS_TOGGLE+DPS_DEC1+DPS_DEC0+1
                mov     r1,#4
dt2_lp2:        movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r1,dt2_lp2
                mov     dps,#DPS_DEC0+0
                djnz    r0,dt2_lp1
                sjmp    dt2_ret
                
dt2_dec2:       movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,dt2_lp1
                sjmp    dt2_ret
                
dt2_dec3:       movx    @dptr,a
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,dt2_lp1
                sjmp    dt2_ret
                
dt2_dec4:       movx    @dptr,a
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,dt2_lp1
dt2_ret:        mov     dps,#0
    __endasm;
}

void decrement_timers()
{
    while(ticks > TIMERS_PER_TICK) 
    {
        __critical { ticks -= TIMERS_PER_TICK; }
        decrement_timers2();
    }
}

void init_timer(u8 id, u8 minutes, u8 seconds, u8 hundredths)
{
    __asm
                mov     r2,b1_0
                mov     r3,b1_1
                mov     r4,b1_2
                
                inc     r2
                inc     r3
                inc     r4
                
                djnz    r4,it_adjusted
                mov     r4,#TICKS_PER_SECOND
                djnz    r3,it_adjusted
                mov     r3,#60
                djnz    r2,it_adjusted
                
                mov     r2,#1
                mov     r3,#1
                mov     r4,#1
it_adjusted:
                mov     r1,dpl
                mov     dps,#0
                mov     dptr,#_timer_table
                mov     a,_timer_no
                jz      it_store1
                mov     r0,a
it_lp:
                movx    a,@dptr
                inc     dptr
                xrl     a,r1
                jz      it_store2
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,it_lp

it_store1:      inc     _timer_no
                mov     a,r1
                movx    @dptr,a
                inc     dptr
it_store2:      mov     a,r2
                movx    @dptr,a
                inc     dptr
                mov     a,r3
                movx    @dptr,a
                inc     dptr
                mov     a,r4
                movx    @dptr,a
it_ret:
    __endasm;
}

bool timer_running(u8 id)
{
    __asm
                mov     a,_timer_no
                jz      tz_no
                mov     r0,a
                mov     r1,dpl
                mov     dps,#0
                mov     dptr,#_timer_table
tz_lp:
                movx    a,@dptr
                xrl     a,r1
                jz      tz_yes
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,tz_lp
tz_no:          mov     dpl,#0
                ret
tz_yes:         mov     dpl,#TRUE
    __endasm;
}

void wait_for_timer(u8 id, u8 minutes, u8 seconds, u8 hundredths)
{
    init_timer(id, minutes, seconds, hundredths);
    while(timer_running(id)) wait();
}
