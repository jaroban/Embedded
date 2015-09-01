; version 1.0

vypis_ledky:    cpl     a
                mov     c,acc.0
                mov     led1,c
                mov     c,acc.1
                mov     led2,c
                mov     c,acc.2
                mov     led3,c
                mov     c,acc.3
                mov     led4,c
                ret

vypis_poschodie:
                mov     a,liftpos
                cjne    a,#0ffh,vp_ok
                mov     a,#0fh
                jmp     vypis_ledky
vp_ok:          jbc     acc.0,vp_sharp
                rr      a
                mov     c,liftdir
                subb    a,#0
                call    get_nrm_mask
                jmp     vypis_ledky
vp_sharp:       rr      a
                call    get_nrm_mask
                jmp     vypis_ledky

ifdef smerove_sipky
vypis_svetlo:   mov     a,error
                jnz     vs_ok
                jb      moving,vs_moving
vs_ok:          mov     c,svetlo
                mov     rele_4,c
                cpl     c
                mov     rele_5,c
                ret
vs_moving:      mov     c,liftdir
                mov     rele_4,c
                mov     rele_5,c
                ret
else
vypis_svetlo:   mov     a,error
                mov     c,svetlo
                jz      vs_drain                
                setb    c
vs_drain:       mov     rele_4,c
                mov     c,kontrolka
                mov     rele_5,c
                ret
endif

output_setup:   mov     thread_id,#'o'
                mov     error,#0
                setb    short
                setb    svetlo
                clr     kontrolka
                clr     moving

output_main_lp: call    do_them
                call    vypis_svetlo
                mov     a,error
                jz      oml_skip3
                mov     a,#t_blink
                call    tmr_zro
                jnc     oml_skip2
                jbc     short,oml_skip1
                setb    short
                call    tmr_int_f
                db      t_blink,0,0,16
                clr     a
                call    vypis_ledky
                sjmp    oml_skip2
oml_skip1:      call    tmr_int_f
                db      t_blink,0,0,16
                mov     a,error
                call    vypis_ledky
                cpl     kontrolka
oml_skip2:      jmp     output_main_lp
oml_skip3:      call    vypis_poschodie
                jmp     output_main_lp
