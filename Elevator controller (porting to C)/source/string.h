#ifndef STRINGS_H
#define STRINGS_H

#include <minimal.h>

#define SERIAL 0
#define LCD 1

void write_to(u8 dest);
void put_char(u8 c);
void printf(const __code u8 *f, ...) __reentrant __naked;
void puts(const __code u8 *s);

#endif