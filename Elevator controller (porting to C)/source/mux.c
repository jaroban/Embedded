#include <global.h>

/*

// this was in interrupt

                jnb     im_da_boss,oui_ret
                mov     a,mux_state
                jz      oui_ret
                djnz    mux_timer,oui_ret
                mov     a,mux_state
                dec     a
                rl      a
                mov     dptr,#oui_mux_table
                jmp     @a+dptr

oui_ret:        

oui_mux_table:  sjmp    oui_mux_1
                sjmp    oui_mux_2
                sjmp    oui_mux_3
                sjmp    oui_mux_4
                sjmp    oui_mux_5
                sjmp    oui_mux_6
                sjmp    oui_mux_7
                sjmp    oui_mux_8
                sjmp    oui_mux_9
                sjmp    oui_mux_10
                sjmp    oui_mux_11
                sjmp    oui_mux_12

oui_mux_1:      call    mux_clock_1
                jmp     oui_ret
oui_mux_2:      inc     mux_state
                call    mux_rd_kabina
                setb    mux_new_k
                call    mux_clock_0
                jmp     oui_ret
oui_mux_3:      inc     mux_state
                mov     mux_timer,#1
                call    mux_wr_dole1
                jmp     oui_ret
oui_mux_4:      call    mux_clock_2
                jmp     oui_ret
oui_mux_5:      inc     mux_state
                call    mux_rd_dole1
                setb    mux_new_d1
                call    mux_clock_0
                jmp     oui_ret
oui_mux_6:      mov     mux_state,#1
                mov     mux_timer,#1
                call    mux_wr_kabina
                jmp     oui_ret

oui_mux_7:      call    mux_clock_1
                jmp     oui_ret
oui_mux_8:      inc     mux_state
                call    mux_rd_dole2
                setb    mux_new_d2
                call    mux_clock_0
                jmp     oui_ret
oui_mux_9:      inc     mux_state
                mov     mux_timer,#1
                call    mux_wr_hore
                jmp     oui_ret
oui_mux_10:     call    mux_clock_2
                jmp     oui_ret
oui_mux_11:     inc     mux_state
                call    mux_rd_hore
                setb    mux_new_h
                call    mux_clock_0
                jmp     oui_ret
oui_mux_12:     mov     mux_state,#7
                mov     mux_timer,#1
                call    mux_wr_dole2
                jmp     oui_ret
*/