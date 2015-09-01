#include <global.h>
#include <lcd.h>
#include <messages.h>

// timer T_UI

__xdata u8 * __data text;

void ui_thread()
{
    write_to(LCD);
    
    lcd_clear();
    lcd_cursor = 0;
    
    puts(" BANEL " BUILD_DATE "\n   SDCC " SDCC_VERSION);
    
    wait_for_timer(T_UI, 0, 5, 0);
    
    
    
    send_message8(0, 1, 2, 3, 4, 5, 6, 7, 8);

}
