#ifndef OS_H
#define OS_H

#include <minimal.h>

extern volatile __data u8 thread_watchdog;

void os_init();
void set_id(u8 id);
u8 get_id();
void write_to(u8 dest);
u8 get_dest();
void wait();
u8 fork();
void kill_me();
void kill(u8 id);

#endif