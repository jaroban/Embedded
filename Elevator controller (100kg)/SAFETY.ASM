; version 1.0

safety_setup:   mov     thread_id,#'s'
                mov     liftpos,#0ffh
                setb    rele_hore
                setb    rele_dole
                setb    rele_jazda
                setb    poradie_faz
                call    wait4it_f
                db      t_start,0,0,16
                call    nulovanie_rele
                call    wait4it_f
                db      t_start,0,1,0
ifdef je_poradie_faz
                jb      poradie_faz,saf_skip1
                setb    error_fazy
saf_lp1:        call    do_them
                jnb     poradie_faz,saf_lp1
                clr     error_fazy
endif
                
saf_skip1:      mov     dptr,#moving_setup
                call    run_it

saf_lp2:        call    do_them
ifdef je_zdochnutie
                jb      zdochnutie,saf_skip2
                call    tmr_int_f
                db      t_zdochnutie,0,0,16
saf_skip2:      mov     a,#t_zdochnutie
                call    tmr_zro
                jc      saf_zdochnut
endif
ifdef je_poradie_faz
                jb      poradie_faz,saf_fazy
endif
                jmp     saf_lp2
saf_fazy:       mov     a,#'m'
                call    kill_him
                setb    error_fazy
                call    nulovanie_rele
                jmp     os_init
                
saf_zdochnut:   mov     a,#'m'
                call    kill_him
                setb    error_fazy
                call    nulovanie_rele
saf_zd_lp:      call    do_them
                jmp     saf_zd_lp
