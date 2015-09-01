; version 1.0

th_outputs:     mov     thread_id,#'o'

out_main_lp:    call    do_them
                mov     a,#t_blink
                call    tmr_zro
                jnc     oml_skip10
                call    tmr_int_f
                db      t_blink,0,1,0
                cpl     blink

                ;setb    lift
oml_next_lp1:   call    get_state

                cjne    a,#st_dead,oml_try1
                mov     c,blink
                sjmp    oml_drain1

oml_try1:       push    acc
                call    read_button
                jnc     oml_button1
                call    reset_error_timer
                setb    c
                call    set_relay2
                sjmp    oml_button2
oml_button1:    call    is_error_timer_zero
                jnc     oml_button2
                clr     c
                call    set_relay2
oml_button2:    pop     acc

                cjne    a,#st_disabled,oml_try2
                clr     c
                sjmp    oml_drain1

oml_try2:       cjne    a,#st_ok,oml_try3
                clr     c
                sjmp    oml_drain1

oml_try3:       setb    c

oml_drain1:     call    set_relay1
                ;jbc     lift,oml_next_lp1
oml_skip10:     jmp     out_main_lp
