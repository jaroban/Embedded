#ifndef SERIAL_H
#define SERIAL_H

/*
#define CR 13
#define LF 10
#define DELETE 8
*/

void serial_interrupt() __interrupt (4) __naked;

u8 get_char_available();
u8 get_char();
void put_char_serial(u8 c);
void serial_thread();
void serial_decode();

#endif