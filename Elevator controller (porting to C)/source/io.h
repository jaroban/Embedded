#ifndef IO_H
#define IO_H

#include <minimal.h>

// is the key being held down?
#define KEY1_LEFT  (keyboard1 &  1)
#define KEY1_RIGHT (keyboard1 &  2)
#define KEY1_UP    (keyboard1 &  4)
#define KEY1_DOWN  (keyboard1 &  8)
#define KEY1_ENTER (keyboard1 & 16)

// has a key been pressed? (repeated if held down)
#define KEY2_LEFT  (keyboard2 &  1)
#define KEY2_RIGHT (keyboard2 &  2)
#define KEY2_UP    (keyboard2 &  4)
#define KEY2_DOWN  (keyboard2 &  8)
#define KEY2_ENTER (keyboard2 & 16)

void init_inputs();
void read_inputs();
void read_keyboard();

i8 get_input(u8 id);

#endif
