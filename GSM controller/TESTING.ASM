; version 2.0

; reading from gsm module
main_init1:     call    switch_gsm
                call    tmr_int_f
                db      0,0,1,0
main_lp1:       call    do_them
                call    read_serial
                jnc     ml1_skip1
                ;call    tmr_int_f
                ;db      0,0,1,0
ml1_skip1:      clr     a
                call    tmr_zro
                jnc     main_lp1
; writing to pc
                call    switch_out
main_lp2:       call    do_them
                call    get_chr
                jnc     main_init3
                call    put_chr
                jmp     main_lp2

; reading from pc
main_init3:     call    switch_out
main_lp3:       call    do_them
                call    read_serial
                mov     r0,#srl_fifo
                call    fifo_show_last
                jnc     main_lp3
                cjne    a,#cr,main_lp3
; writing to gsm
                call    switch_gsm
main_lp4:       call    do_them
                call    get_chr
                jnc     main_init1
                call    put_chr
                jmp     main_lp4
