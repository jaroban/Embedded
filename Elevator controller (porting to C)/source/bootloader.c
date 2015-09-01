#include <global.h>

__code u8 bootloader[] = {
#include "../bootloader/bootloader_include.c"
};

void start_bootloader()
{
    // when run from realtime:
    IE = 0;

    // turn off watchdog
    TIMED_ACCESS;
    WDCON &= ~2;
    
    // turn off relays

    TIMED_ACCESS;
    ACON = (0 << 2) |   // 8 bit stack
           (2 << 0);    // 24-bit mode

    TIMED_ACCESS;
    MCON = (3 << 6) |   // program/code memory at 0x400000 - 0x400fff
           (1 << 5) |   // can0 memory at 0x401000 - 0x4010ff
                        // can1 memory at 0x401100 - 0x4011ff
           (1 << 0);    // program/data chip enable 0

    SP = 0x7f;

    // copy first 4kB of code to on-chip ram...
    copy_cx(bootloader, (__xdata u8 *)0x400000, sizeof(bootloader));

    // ...and jump there
    __asm
                ljmp    0x400000
    __endasm;
}