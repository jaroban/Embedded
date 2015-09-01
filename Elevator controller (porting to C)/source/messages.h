#ifndef MESSAGES_H
#define MESSAGES_H

#include <minimal.h>

void init_messages();

void send_message0(u8 id);
void send_message1(u8 id, u8 a);
void send_message2(u8 id, u8 a, u8 b);
void send_message3(u8 id, u8 a, u8 b, u8 c);
void send_message4(u8 id, u8 a, u8 b, u8 c, u8 d);
void send_message5(u8 id, u8 a, u8 b, u8 c, u8 d, u8 e);
void send_message6(u8 id, u8 a, u8 b, u8 c, u8 d, u8 e, u8 f);
void send_message7(u8 id, u8 a, u8 b, u8 c, u8 d, u8 e, u8 f, u8 g);
void send_message8(u8 id, u8 a, u8 b, u8 c, u8 d, u8 e, u8 f, u8 g, u8 h);

__xdata u8 *get_message(u8 id);

#endif