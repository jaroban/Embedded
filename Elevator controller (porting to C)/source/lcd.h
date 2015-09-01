#ifndef LCD_H
#define LCD_H

__sbit __at 0x92 lcd_rs;        // p1.2
__sbit __at 0x93 lcd_rw;        // p1.3
__sbit __at 0x97 lcd_en;        // p1.7
__sbit __at 0x95 lcd_backlight; // p1.5

// lcd
extern __bit lcd_cursor_on;
extern __bit lcd_blinking;
extern __xdata u8 lcd_table[32];
extern __data u8 lcd_cursor;
extern __bit lcd_scrolling;

void lcd_clear();
void lcd_put_char(u8 a);
void lcd_thread();

#endif