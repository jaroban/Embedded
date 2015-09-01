// common between source and bootloader

#ifndef COMMON_H
#define COMMON_H

#define TRUE -1

#pragma disable_warning 59      // funtion must return value (inline assembler)
#pragma disable_warning 85      // unreferenced function argument (inline assembler)

#define FREQUENCY 9216000
#define BAUD_RATE 57600
#define T2_RELOAD (65536 - FREQUENCY / (32 * BAUD_RATE))

// movx map
// 4: keyboard
// 5: rele1
// 6: rele2
#define KEYBOARD 4
#define RELAY_1 5
#define RELAY_2 6

#define BUTTON_LEFT_MASK    1
#define BUTTON_RIGHT_MASK   2
#define BUTTON_UP_MASK      4
#define BUTTON_DOWN_MASK    8
#define BUTTON_ENTER_MASK   16

#define CR 13
#define LF 10
#define DELETE 8

#define DPS_TOGGLE 0x20


// types
#define u8 unsigned char
#define i8 char
#define u16 unsigned int
#define i16 int
#define bool unsigned char

// macros
#define INC_MOD(a, b) if(++a == (b)) { a = 0; }

#define ROTL8(a) (((a) << 1) | ((a) >> 7))
//#define ROTR8(a, n) ((((a) >> (n)) | ((a) << (8 - (n)))) & 0xff)

// timed access - interrupts must be disabled
#define TIMED_ACCESS \
TA = 0xaa; \
TA = 0x55

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

// flash
__xdata __at 0x555 volatile u8 flash_555;
__xdata __at 0x2aa volatile u8 flash_2aa;
__xdata __at 0 volatile u8 flash_x;


u8 get_char_available();
u8 get_char();
u8 put_char_available();
void put_char(u8 c);
u8 bin_to_hex(u8 a);
void put_hex(u8 a);
u8 hex_to_bin(u8 c);
void puts_f();
void puts_c(__code u8 *p);
void puts_x(__xdata u8 *p);


#endif
