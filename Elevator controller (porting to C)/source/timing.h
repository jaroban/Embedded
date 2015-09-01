#ifndef TIMING_H
#define TIMING_H

#include <minimal.h>

#define TIMERS_PER_TICK 10
#define TICKS_PER_SECOND 100

extern __data volatile u8 ticks;

void timer0_init();
void timer0_interrupt() __interrupt (1) __naked;

void timer1_init();
void timer1_interrupt() __interrupt (3) __naked;

void init_timers();
void decrement_timers();

void init_timer(u8 id, u8 minutes, u8 seconds, u8 hundredths);
void wait_for_timer(u8 id, u8 minutes, u8 seconds, u8 hundredths);
bool timer_running(u8 id);

#endif