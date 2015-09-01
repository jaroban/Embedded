#ifndef BOOTLOADER_H
#define BOOTLOADER_H

#define TRUE -1

#pragma disable_warning 59      // funtion must return value (inline assembler)
#pragma disable_warning 85      // unreferenced function argument (inline assembler)

#define FREQUENCY 9216000
#define BAUD_RATE 57600
#define T2_RELOAD (65536 - FREQUENCY / (32 * BAUD_RATE))

#define CR 13
#define LF 10
#define DELETE 8

#define DPS_TOGGLE 0x20
#define DPS_DEC0 0x40
#define DPS_DEC1 0x80

// types
#define u8 unsigned char
#define i8 char
#define u16 unsigned int
#define i16 int
#define u32 unsigned long int
#define i32 long int
#define bool unsigned char

// macros
#define INC_MOD(a, b) \
    a++;\
    if(a == (b)) { a = 0; }

// timed access - interrupts must be disabled
#define TIMED_ACCESS \
TA = 0xaa; \
TA = 0x55

// flash
__xdata __at 0x555 volatile u8 flash_555;
__xdata __at 0x2aa volatile u8 flash_2aa;
__xdata __at 0 volatile u8 flash_x;

// forward calls
void serial_init();
u8 get_char_available();
u8 get_char();
void serial_loop();
void reset();
void wait();

#endif
