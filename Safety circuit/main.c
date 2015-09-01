// BANEL NPK

#define u8 unsigned char
#define u16 unsigned short

#include "at89c55wd.h"

// we have no xram, override these routines
void _mcs51_genXINIT() { }
void _mcs51_genXRAMCLEAR() { }

// clears ram, no need to override this
//void _mcs51_genRAMCLEAR() { } 

#define EEPROM_NO_ERROR     0x55

#define COME_ALIVE  P3_0
#define k2_out      P3_1
#define k1_out      P3_2
#define k3_out      P3_3
#define k4_out      P3_4
#define SDA         P3_5
#define SCL         P3_6
#define WP          P3_7

#define error1  P0_0
#define error2  P0_1
#define error3  P0_2
#define error4  P0_3

#define TIMER_TABLE \
    TIMER(t_npk, 16) \
    TIMER(t_ac, 8) \
    TIMER(t_inputs, 8) \
    TIMER(t_blink, 8) \
    TIMER(t_kr, 8) \
    TIMER(t_delay_k2, 16) \
    TIMER(t_dorovnavanie, 16)
    
    //TIMER(t_sleep, 16)
    
#include "timing.c"
#include "inputs.c"
#include "i2c.c"

u8      error;
u8      inputs, ac_in, ac_new;
__bit   k1, k2, k3, k4, k5, blink;
__bit   dor, kr, kc, npk, jazda, ab, c, reset, bo;

#include "fsm.c"

__idata u8 maj_buffer[5];

void main()
{
    P0 = 0xff;
    P1 = 0xff;
    P2 = 0xff;
    COME_ALIVE = 1;     // input
    WP = 1;             // write protect on

    // turn off all relays
    k1_out = 0;
    k2_out = 0;
    k3_out = 0;
    k4_out = 0;

    // turn on all leds
    error1 = 0;
    error2 = 0;
    error3 = 0;
    error4 = 0;

    i2c_reset();
    
    if(eeprom_read(0) != EEPROM_NO_ERROR)
    {
        // we need to be stuck -> npk has gone active
        // only way to get out is if user grounds a pin
        while(COME_ALIVE) reset_watchdog();
        // user has grounded the pin, try to write correct value
        eeprom_write(0, EEPROM_NO_ERROR);
    }
    
    timer0_init();
    fsm_init();
    
    EA = 1;
    
    while(1)
    {
        reset_watchdog();
        
        process_timers();
        
        // ac
        ac_new |= ~P1;
        
        if(t_ac == 0) 
        { 
            t_ac = 60;
            ac_in = ac_new;
            ac_new = 0;
            
            jazda = ac_in & (1 << 7);
            bo    = ac_in & (1 << 6);
        }
        
        // inputs
        if(t_inputs == 0)
        {
            t_inputs = 3;
            inputs = maj5(maj_buffer, P1);
                        
            //jazda = inputs & (1 << 7);
            //bo    = inputs & (1 << 6);
            dor   = inputs & (1 << 5);
            npk   = inputs & (1 << 4);
            c     = !(inputs & (1 << 3));
            ab    = !(inputs & (1 << 2));
            kc    = inputs & (1 << 1);
            kr    = inputs & (1 << 0);
        }

        // blink relay 5 every 1 second
        if(t_blink == 0) { t_blink = 1.00 SEKUNDA; blink = !blink; }
        
        reset_watchdog();
        
        fsm();
        
        k1_out = k1;
        k2_out = k2;
        k3_out = k3;
        k4_out = k4;
        
        // debugging
        //error = stav;
        
        error1 = !(error & 1) || ((error & 16) && blink);
        error2 = !(error & 2) || ((error & 16) && blink);
        error3 = !(error & 4) || ((error & 16) && blink);
        error4 = !(error & 8) || ((error & 16) && blink);
    }
}
