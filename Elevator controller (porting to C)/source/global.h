#ifndef GLOBAL_H
#define GLOBAL_H

#include <minimal.h>
#include <ds80c390.h>
#include <routines.h>
#include <string.h>
#include <timing.h>
#include <os.h>
#include <generated.h>

// my additions - since ds80c390.h is GPL'd
__sfr16 __at (0x9b81) SP16;

// timed access - interrupts must be disabled
#define TIMED_ACCESS \
do { \
TA = 0xaa; \
TA = 0x55; \
} while(0)

// dps
#define DPS_TOGGLE 0x20
#define DPS_DEC0 0x40
#define DPS_DEC1 0x80

#define TRUE -1

// timing
#define FREQUENCY 9216000
#define CLOCK_MULTIPLIER 2      // 1, 2, 4
#define THREAD_WATCHDOG_BEFORE_RESET 250  // 0: off

// flash
__xdata __at 0x555 volatile u8 flash_555;
__xdata __at 0x2aa volatile u8 flash_2aa;
__xdata __at 0 volatile u8 flash_x;

// ce0 -> code flash
// pce0 -> data flash
// pce1 -> peripheral bus

// movx map
// 4: keyboard
// 5: rele1
// 6: rele2
// 7: lcd

__xdata __at 0x100000 volatile u8 rw_reg[4];
//__xdata __at 0x100001 volatile u8 rw_reg1;
//__xdata __at 0x100002 volatile u8 rw_reg2;
//__xdata __at 0x100003 volatile u8 rw_reg3;

__xdata __at 0x100004 volatile u8 r_keyboard;
__xdata __at 0x100005 volatile u8 r_ac_inputs;
__xdata __at 0x100006 volatile u8 r_24v_reg[2];
//__xdata __at 0x100007 volatile u8 r_24v_reg1;

__xdata __at 0x100004 volatile u8 w_reg;
__xdata __at 0x100005 volatile u8 w_relay[2];
//__xdata __at 0x100006 volatile u8 w_relay1;
__xdata __at 0x100007 volatile u8 w_lcd;

// movx_read(KEYBOARD) masks
#define BUTTON_LEFT_MASK    1
#define BUTTON_RIGHT_MASK   2
#define BUTTON_UP_MASK      4
#define BUTTON_DOWN_MASK    8
#define BUTTON_ENTER_MASK   16
#define LCD_READY_MASK      0x80








// move to serial
#define BAUD_RATE 57600
#define T2_RELOAD (65536 - FREQUENCY / (32 * BAUD_RATE))







// bits


// reset sources


#define RST_POWER_ON 0
#define RST_WATCHDOG 1
#define RST_OSC_FAIL 2
#define RST_OTHER 3
//#define RESET_BY_SOFTWARE 4
// huh? fix!




//#define T_RELOAD_US(us) (65536 - (us) * FREQUENCY / (12 * 1000000))

//@ f=9.216 mhz -> /12 -> 768000 tix/sec
//tmr0_period     equ     768*20  ; 768=1ms 2304=3ms




// macros
#define INC_MOD(a, b) \
    a++;\
    if(a == (b)) { a = 0; }

#define DEC_MOD(a, b) \
    if(a == 0) { a = (b) - 1; } else { a--; }

#define ROTL8(a) (((a) << 1) | ((a) >> 7))
//#define ROTR8(a, n) ((((a) >> (n)) | ((a) << (8 - (n)))) & 0xff)









/*
u8 get_char_available();
u8 get_char();

u8 bin_to_hex(u8 a);
void put_hex(u8 a);
u8 hex_to_bin(u8 c);
void puts_f();
void puts_c(__code u8 *p);
void puts_x(__xdata u8 *p);
*/







/*



void wait();

//void xram_copy(__xdata char *src, __xdata char *dest, unsigned int len);

// serial

u8 get_char_left();
u8 get_char() __critical;
u8 put_char_left();
void put_char(u8 c) __critical;
void puts_c(__code u8 *p);
void puts_x(__xdata u8 *p);
//void gets();
void put_hex(u8 a);
u8 hex_to_asc(u8 a);
u8 asc_to_hex(u8 a);

// string
//u8 strlen_x(__xdata char *str);
u8 strcmp_xc(__xdata u8 *str1, __code u8 *str2);

// bootloader
void flash_code();
void dump_code();

// flash
u8 flash_erase_chip();
u8 flash_write(__xdata u8 *p, u8 a);
u8 is_blank_c();
*/
// frame pointer
//__data u8 bpx[2];

// data
//extern __bit bootloader_mode;



/*
// inline string with newline              
#define PUTS_FN(s) \
puts_f(); \
__asm \
.ascii s \
.db 10,0 \
__endasm

// inline string
#define PUTS_F(s) \
puts_f(); \
__asm \
.asciz s \
__endasm
*/
#endif
