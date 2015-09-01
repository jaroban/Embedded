; version 1.0

zapni_rele:     setb    rout
                call    tmr_int_f
                db      t_rele,0,5,0
                setb    check_rele
                ret

output_init:    clr     gled
                clr     yled
                clr     rled
                clr     rout
                setb    short
                call    tmr_int_f
                db      t_blikanie,0,1,0

output_main_lp: call    do_them
                mov     a,#t_blikanie
                call    tmr_zro
                jnc     om_skip1
                jbc     short,om_long
                call    tmr_int_f
                db      t_blikanie,0,0,2
                mov     a,bits1
                anl     a,#0e0h
                cpl     a
                anl     p1,a
                setb    short
                sjmp    om_skip1
om_long:        call    tmr_int_f
                db      t_blikanie,0,0,30
                mov     a,bits1
                anl     a,#0e0h
                orl     p1,a
om_skip1:       jnb     check_rele,om_skip2
                mov     a,#t_rele
                call    tmr_zro
                jnc     om_skip2
                clr     check_rele
                clr     rout
om_skip2:       jmp     output_main_lp
