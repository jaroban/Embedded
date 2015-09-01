#ifndef ROUTINES_H
#define ROUTINES_H

#include <minimal.h>

// system functions
void reset();
void halt();
void delay(u16 ms);
void movx_slow();
void movx_fast();
u8 movx_read(u8 addr);
void movx_write(u8 a, u8 d);
u8 get_mcu_speed();
void set_mcu_speed(u8 multiplier);
void start_bootloader();
void reset_watchdog();

void memset_i(__idata u8 *p, u8 value, u8 len);
void memset_x(__xdata u8 *p, u8 value, u16 len);


void copy_ii(__idata u8 *src, __idata u8 *dest, u8 len);
void copy_cx(const __code u8 *src, __xdata u8 *dest, u16 len);
void copy_ix(__idata u8 *src, __xdata u8 *dest, u8 len);
void copy_xi(__xdata u8 *src, __idata u8 *dest, u8 len);
void copy_xx(__xdata u8 *src, __xdata u8 *dest, u8 len);
void copy_xx_5(__xdata u8 *src, __xdata u8 *dest, u8 len);
bool diff_xx(__xdata u8 *a, __xdata u8 *b, u8 len);

u8 get_mask(u8 lsb, u8 width);
u8 get_mask_1(u8 lsb);

void shift_up_x(__xdata u8 *p, u8 a, u8 len);
void shift_down_x(__xdata u8 *p, u8 a, u8 len);
//void filter5(__xdata u8 *src, __xdata u8 *dest, u8 len);
//u8 filter5(__xdata u8 *src);
u8 shift_and_filter5(__xdata u8 *src, u8 a);

#endif