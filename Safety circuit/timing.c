#define FREQUENCY 9216000
#define TMR0_RELOAD (-(FREQUENCY / (12 * 100)))     // -7680
#define SEKUND  *100
#define SEKUNDY *100
#define SEKUNDA *100

u8 tmr0_cnt;

void timer0_init()
{
    tmr0_cnt = 0;
    TMOD &= 0xf0;
    TMOD |= 0x01;       // 16-bit timer
    TR0 = 0;            // stop timer
    TMR0 = TMR0_RELOAD;
    TR0 = 1;            // run timer
    ET0 = 1;            // enable interrupt
}

void timer0_interrupt() __interrupt (1) __naked
{
    __asm
        push    psw
        push    acc
1$:     inc     _tmr0_cnt
        clr     tr0
        mov     a,tl0
        add     a,#TMR0_RELOAD + 7
        mov     tl0,a
        mov     a,th0
        addc    a,#(TMR0_RELOAD + 7) >> 8
        mov     th0,a
        setb    tr0
        jc      1$
        pop     acc
        pop     psw
        reti
    __endasm;
}

#define TIMER(name, bits) u##bits name;
TIMER_TABLE
#undef TIMER

void process_timers()
{
    EA = 0;
    while(tmr0_cnt)
    {
        tmr0_cnt--;
        EA = 1;
        #define TIMER(name, bits) if(name) name--;
        TIMER_TABLE
        #undef TIMER
        EA = 0;
    }
    EA = 1;
}

void reset_watchdog()
{
    EA = 0; 
    WDTRST = 0x1e;
    WDTRST = 0xe1; 
    EA = 1;
}
