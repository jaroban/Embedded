#include <global.h>
#include <lcd.h>

       __bit lcd_cursor_on;
static __bit lcd_cursor_on_lo;

       __bit lcd_blinking;
static __bit lcd_blinking_lo;

       __xdata u8 lcd_table[32];
static __xdata u8 lcd_table_lo[32];

       __data u8 lcd_cursor;
static __data u8 lcd_cursor_lo;

       __bit lcd_scrolling;
       
// timer T_LCD

static __code u8 lcd_custom_chars[] =
{
    // 0 square
    0b11111,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b11111,
    0b00000,
    // 1 arrow down
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b10101,
    0b01110,
    0b00100,
    0b00000,
    // 2 arrow up
    0b00100,
    0b01110,
    0b10101,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b00000,
    // 3 arrow up+down
    0b00100,
    0b01110,
    0b10101,
    0b00100,
    0b10101,
    0b01110,
    0b00100,
    0b00000,
    // 4
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    // 5
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    // 6
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    // 7 full square
    0b00000,
    0b11111,
    0b11111,
    0b11111,
    0b11111,
    0b11111,
    0b00000,
    0b00000
};

static void lcd_delay()
{
    __asm
                nop
                nop
                nop
                nop
    __endasm;
}

static void en_on()
{
    lcd_en = 1;
    lcd_delay();
}

static void en_off()
{
    lcd_en = 0;
    lcd_delay();
}

// assuming lcd_en == 0
static void lcd_wait()
{
    u8 c;
    
    lcd_rs = 0;
    lcd_rw = 1;
    
    do
    {
        en_on();
        c = r_keyboard;
        en_off();
    }
    while(c & LCD_READY_MASK);
}

// assuming lcd_en == 0
static void lcd_write(u8 c)
{
    lcd_rw = 0;
    en_on();
    w_lcd = c;
    *((__xdata u8 *)0x100007) = c;
    lcd_delay();
    en_off();
}

static void lcd_command(u8 c)
{
    lcd_rs = 0;
    lcd_write(c);
}

static void lcd_data(u8 c)
{
    lcd_rs = 1;
    lcd_write(c);
}

static void lcd_on_off_lo()
{
    lcd_command(0x08 |                      // on/off
                (1 << 2) |                  // display
                (lcd_cursor_on_lo << 1) |   // cursor
                (lcd_blinking_lo << 0));    // blinking
    lcd_wait();
}

static void lcd_move_lo(u8 a)
{
    a &= 0x1f;
    
    lcd_cursor_lo = a;
    
    if(a & 0x10) a += 0x30;
    
    lcd_command(0x80 | a);  // set ddram address
    lcd_wait();
}

static void lcd_clear_lo()
{
    lcd_command(0x01);  // clear display
    lcd_wait();
    
    lcd_cursor_lo = 0;
    set_memory_x(lcd_table_lo, 32, ' ');
}

static void lcd_put_char_lo(u8 a)
{
    lcd_data(a);
    lcd_wait();

    lcd_cursor_lo++;
    if((lcd_cursor_lo & 0xf) == 0) lcd_move_lo(lcd_cursor_lo);
}

static void lcd_write_custom_chars()
{
    u8 i;
    __code u8 *p;

    lcd_command(0x40 + 0);  // set cgram address
    lcd_wait();

    i = 64;
    p = lcd_custom_chars;
    
    do
    {
        lcd_data(*p++);
        lcd_wait();
    }
    while(--i);
}

static void lcd_init_lo()
{
    movx_slow();
    
    wait_for_timer(T_LCD, 0, 0, 4);
    lcd_command(0x38);
    wait_for_timer(T_LCD, 0, 0, 1);
    lcd_command(0x38);
    wait_for_timer(T_LCD, 0, 0, 1);
    lcd_command(0x38);
    wait_for_timer(T_LCD, 0, 0, 4);
    
    lcd_command(0x20 |      // function set
                (1 << 4) |  // DL = 0/1 = 4/8 bits
                (1 << 3) |  // N  = 0/1 = 1/2 lines
                (0 << 2));  // F  = 0/1 = 5x8/5x10 dots
    lcd_wait();
    lcd_command(0x08);      // everything off
    lcd_wait();
    lcd_command(0x01);      // clear display and home cursor
    lcd_wait();
    lcd_command(0x04 |      // entry mode set
                (1 << 1) |  // 0/1 = decrement/increment
                (0 << 0));  // 0/1 = no shift/shift
    lcd_wait();
    
    lcd_cursor_on_lo = 0;
    lcd_blinking_lo = 0;
    lcd_on_off_lo();
    
    lcd_clear_lo();
}

void lcd_clear()
{
    lcd_cursor = 0;
    set_memory_x(lcd_table, 32, ' ');
}

static void lcd_scroll_line()
{
    copy_xx(lcd_table + 16, lcd_table, 16);
    set_memory_x(lcd_table + 16, 16, ' ');
}

void lcd_put_char(u8 a)
{
    if(a == (u8)'\n')
    {
        if((lcd_cursor >= 16) && lcd_scrolling)
        {
            lcd_scroll_line();
        }
        lcd_cursor = 16;
    }
    else
    {
        lcd_cursor &= 0x1f;
        lcd_table[lcd_cursor] = a;
        lcd_cursor++;
        lcd_cursor &= 0x1f;
        
        if((lcd_cursor == 0) && lcd_scrolling)
        {
            lcd_scroll_line();
        }
    }
}

static u8 lcd_non_space_chars()
{
    __asm
                mov     dps,#0
                mov     dptr,#_lcd_table
                mov     r0,#32
                mov     r1,#0
lcd_nsc_lp:     movx    a,@dptr
                inc     dptr
                xrl     a,#'                    ;'
                jz      lcd_nsc_skip
                inc     r1
lcd_nsc_skip:   djnz    r0,lcd_nsc_lp
                mov     dpl,r1
    __endasm;
}

static u8 lcd_different_chars()
{
    __asm
                mov     dps,#DPS_TOGGLE+0
                mov     dptr,#_lcd_table        ; 0
                mov     dptr,#_lcd_table_lo     ; 1
                mov     r0,#32
                mov     r1,#0
lcd_dc_lp:      movx    a,@dptr                 ; 0
                mov     r2,a
                movx    a,@dptr                 ; 1
                xrl     a,r2
                jz      lcd_dc_skip
                inc     r1
lcd_dc_skip:    inc     dptr                    ; 0
                inc     dptr                    ; 1
                djnz    r0,lcd_dc_lp
                mov     dps,#0
                mov     dpl,r1
    __endasm;
}

static u8 lcd_find_remove_difference()
{
    __asm
                mov     dps,#DPS_TOGGLE+0
                mov     dptr,#_lcd_table_lo     ; 0
                mov     dptr,#_lcd_table        ; 1
                mov     r0,#32
                mov     r1,#0
lcd_ffd_lp:     movx    a,@dptr                 ; 0
                mov     b,a
                movx    a,@dptr                 ; 1
                cjne    a,b,lcd_ffd_done
                inc     r1
                inc     dptr                    ; 0
                inc     dptr                    ; 1
                djnz    r0,lcd_ffd_lp
                mov     dps,#0
                mov     dpl,#-1
                sjmp    lcd_ffd_ret
lcd_ffd_done:   mov     dps,#0
                movx    @dptr,a
                mov     dpl,r1
lcd_ffd_ret:
    __endasm;
}

static void lcd_refresh()
{
    u8 i;
    
    if((u8)(10 + lcd_non_space_chars())     // time to erase + rewrite display
        < lcd_different_chars())            // time to rewrite different chars
    {
        lcd_clear_lo();
    }
    
    // find change
    i = lcd_find_remove_difference();
    
    if(i != 255)
    {
        if(i != lcd_cursor_lo)
        {
            lcd_move_lo(i);
        }
        
        lcd_put_char_lo(lcd_table[i]);
    }

    if((lcd_cursor_on != lcd_cursor_on_lo) ||
       (lcd_blinking != lcd_blinking_lo))
    {
        lcd_cursor_on_lo = lcd_cursor_on;
        lcd_blinking_lo = lcd_blinking;
        
        lcd_on_off_lo();
    }
    
    // lcd cursor
    if((lcd_cursor_on) && (lcd_cursor != lcd_cursor_lo))
    {
        // only if everything else is finished
        if(lcd_different_chars() == 0)
        {
            lcd_move_lo(lcd_cursor);
        }
    }
}

void lcd_thread()
{
    lcd_init_lo();

    lcd_cursor_on = 0;
    lcd_blinking = 0;
    lcd_scrolling = 1;
    
    while(1)
    {
        wait();
        lcd_refresh();
    }
}
