#include <global.h>
#include <io.h>
#include <serial.h>

// timer T_INPUTS

void big_loop()
{
    timer0_init();
    init_timers();
    init_inputs();

    while(1)
    {
        wait();
        
        // inputs
        decrement_timers();
        
        read_inputs();
        
        

        // outputs
        
        
        
        // serial in
        serial_decode();

    }
}