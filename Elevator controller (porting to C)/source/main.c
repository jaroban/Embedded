#include <global.h>
#include <serial.h>
#include <i2c.h>
#include <lcd.h>
#include <ac.h>
#include <ui.h>
#include <big_loop.h>
#include <serial.h>

__data u8 reset_source;

u8 _sdcc_external_startup()
{
    return TRUE;
}

void main(void)
{
    TIMED_ACCESS;
    ACON = (1 << 2) |   // 10 bit stack
           (2 << 0);    // 24-bit mode

    // ce0 = program/data chip enable
    TIMED_ACCESS;
    MCON = (2 << 6) |   // data memory at 0x400000 - 0x400fff
           (1 << 5) |   // can0 memory at 0x401000 - 0x4010ff
                        // can1 memory at 0x401100 - 0x4011ff
           (0 << 0);    // no program/data chip enables

    SP16 = -1;
    DPS = 0;
    PSW = 0;
    IP = 0;

    // get reset source
    if(POR)                     reset_source = RST_POWER_ON;
    else if(WDRF)               reset_source = RST_WATCHDOG;
    else if(PCON & (1 << 5))    reset_source = RST_OSC_FAIL;
    else                        reset_source = RST_OTHER;

    PCON = (1 << 4);    // enable oscillator fail reset

    TIMED_ACCESS;
    P5CNT = (0 << 5) |  // serial 1 @ 0: p1.2 / p1.3, 1: p5.2 / p5.3
            (1 << 4) |  // can1 enable
            (1 << 3) |  // can0 enable
            (7 << 0);   // p5.4 - p5.7 are peripheral chip enables

    TIMED_ACCESS;
    P4CNT = (0 << 6) |  // single bus can
            (7 << 3) |  // p4.4 - p4.7 are address lines a16 - a19
            (7 << 0);   // p4.0 - p4.3 are chip enables

    CKCON = (3 << 6) |  // 0,1,2,3: watchdog = 2^(17,20,23,26) + 512 clocks
            (0 << 5) |  // 0,1: timer 2 = crystal / (12,4-2-1), no effect on baud rate
            (1 << 4) |  // 0,1: timer 1 = crystal / (12,4-2-1)
            (1 << 3) |  // 0,1: timer 0 = crystal / (12,4-2-1)
            (0 << 0);   // 0-7: movx timing stretch

    TIMED_ACCESS;
    WDCON = (0 << 7) |  // double serial port 1 rate
            (0 << 6) |  // power on reset flag
            (0 << 5) |  // enable power fail interrupt
            (0 << 4) |  // power fail interrupt flag
            (0 << 3) |  // watchdog interrupt flag
            (0 << 2) |  // watchdog timer reset flag
            (1 << 1) |  // enable watchdog reset
            (1 << 0);   // reset watchdog timer

    set_mcu_speed(CLOCK_MULTIPLIER);

    movx_slow();
    if(~r_keyboard & BUTTON_ENTER_MASK) start_bootloader();

    EA = 1;     // enable interrupts

    os_init();
    set_id('m');
    
    if(fork()) { set_id('s'); serial_thread(); kill_me(); }
    if(fork()) { set_id('i'); i2c_thread(); kill_me(); }
    if(fork()) { set_id('l'); lcd_thread(); kill_me(); }
    if(fork()) { set_id('b'); big_loop(); kill_me(); }
    if(fork()) { set_id('u'); ui_thread(); kill_me(); }

    kill_me();
}
