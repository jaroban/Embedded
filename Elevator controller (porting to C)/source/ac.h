#ifndef AC_H
#define AC_H

#include <minimal.h>

#define READ_AC_THIS_MANY_TIMES 120

#define PHASE_MASK 0b01110000
#define MIN_ZEROES 5            // out of 20
#define MIN_ONES 2              // out of 20
#define PHASE_FILTER 5

#define A1 (ac_values & 1)
#define A2 (ac_values & 2)
#define A3 (ac_values & 4)
#define A4 (ac_values & 8)
#define A5 (ac_values & 128)

extern __sbit ac_phases;
extern __data u8 ac_values;

#endif