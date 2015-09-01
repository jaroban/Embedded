#include <global.h>
#include <parameters.h>

// timer T_KEYBOARD

__sbit key_state;
__data u8 key_previous;
__data u8 keyboard1;
__data u8 keyboard2;

__data u8 inputs1[6];               // raw inputs
__xdata u8 input_filter[6 * 4];     // history 4 long
__data u8 inputs2[6];               // 5-majority filtered

__xdata u8 keyboard_filter[4];

volatile __data u8 blink_reg[4];

void init_inputs()
{
    key_state = 0;
}

void read_keyboard()
{
    if(key_state == 0)
    {
        if(keyboard1)
        {
            // a key is pressed
            key_previous = keyboard1;
            keyboard2 |= key_previous;
            init_timer(T_KEYBOARD, 0, 1, 0);
            key_state = 1;
        }
    }
    else
    {
        if(keyboard1 != key_previous)
        {
            key_state = 0;
        }
        else if(!timer_running(T_KEYBOARD))
        {
            keyboard2 |= key_previous;
            init_timer(T_KEYBOARD, 0, 0, 10);
        }
    }
}

void read_inputs()
{
    if(!timer_running(T_INPUTS))
    {
        // once every 0.03s
        init_timer(T_INPUTS, 0, 0, 3);

        movx_slow();
        
        inputs1[0] = ~rw_reg[0] ^ blink_reg[0];
        inputs1[1] = ~rw_reg[1] ^ blink_reg[1];
        inputs1[2] = ~rw_reg[2];
        inputs1[3] = ~rw_reg[3];
        inputs1[4] = ~r_24v_reg[0];
        inputs1[5] = ~r_24v_reg[1];

        inputs2[0] = shift_and_filter5(input_filter     , inputs1[0]);
        inputs2[1] = shift_and_filter5(input_filter +  4, inputs1[1]);
        inputs2[2] = shift_and_filter5(input_filter +  8, inputs1[2]);
        inputs2[3] = shift_and_filter5(input_filter + 12, inputs1[3]);
        inputs2[4] = shift_and_filter5(input_filter + 16, inputs1[4]);
        inputs2[5] = shift_and_filter5(input_filter + 20, inputs1[5]);
        
        keyboard1 = shift_and_filter5(keyboard_filter, ~r_keyboard & 0x1f);
        
        read_keyboard();
    }
}









#define P_ID_RIADENIE 0
#define P_RIADENIE p_options[P_ID_RIADENIE]



#define P_ID_SZA 0
#define ASS_SZA p_inputs[P_ID_RIADENIE]
#define V_SZA (get_input(P_ID_RIADENIE))

bool get_input(u8 id)
{
    u8 a = p_inputs[id];

    // if input not assigned, return garbage
    if(a == 0) return 123;

    a--;

    if(a & 1)
    {
        // inverted
        a >>= 1;
        return (inputs2[a >> 3] & get_mask_1(a)) ? TRUE : 0;
    }
    else
    {
        // normal
        a >>= 1;
        return (inputs2[a >> 3] & get_mask_1(a)) ? 0 : TRUE;
    }
}
