; version 1.0

reset_doba_jazdy:
                call    tmr_int_f
                db      t_doba_jazdy,0,doba_jazdy,0
                ret

check_doba_jazdy:
                mov     a,#t_doba_jazdy
                call    tmr_zro
                jnc     cdj_ret
                setb    error_doba_jazdy
                call    nulovanie_rele
                jmp     kill_me
cdj_ret:        ret

update_liftpos: jnb     dolny,ul_nie_dolny
                mov     liftpos,#1
ul_ret:         ret
ul_nie_dolny:   jnb     horny,ul_nie_horny
                mov     liftpos,#2*floor_no-1
                ret
ul_nie_horny:   mov     a,liftpos
                cpl     a
                jz      ul_ret
                mov     a,liftpos
                mov     c,acc.0
                anl     c,/snimac
                jc      ul_odisiel
                mov     c,snimac
                anl     c,/acc.0
                jnc     ul_ret
                call    reset_doba_jazdy
ul_odisiel:     jb      liftdir,ul_hore
                mov     a,liftpos
                dec     a
                cjne    a,#1,ul_store
                mov     liftpos,#3
                ret
ul_hore:        mov     a,liftpos
                inc     a
                cjne    a,#2*floor_no-1,ul_store
                mov     liftpos,#2*floor_no-3
                ret
ul_store:       mov     liftpos,a
                ret

kam_ist:        mov     a,liftpos
                cjne    a,#0ffh,ki_ok
                jbc     first_time,ki_zrov
                mov     a,inputs
                xch     a,oinputs
                cpl     a
                anl     a,oinputs
ifdef je_zdochnutie
                anl     a,#070h
else
                anl     a,#0f0h
endif
                jz      ki_nothing
ki_zrov:        mov     a,#1
                ret
ki_ok:          mov     a,inputs
                xch     a,oinputs
                cpl     a
                anl     a,oinputs
                mov     b,a
                clr     a
                jb      b.4,ki_drain
                inc     a
                jb      b.5,ki_drain
                inc     a
                jb      b.6,ki_drain
ifndef je_zdochnutie
                inc     a
                jb      b.7,ki_drain
endif
ki_nothing:     mov     a,#0ffh
                ret
ki_drain:       setb    c
                rlc     a
                ret

kam_ist2:       mov     b,inputs
                clr     a
                jb      b.4,ki2_drain
                inc     a
                jb      b.5,ki2_drain
                inc     a
                jb      b.6,ki2_drain
ifndef je_zdochnutie
                inc     a
                jb      b.7,ki2_drain
endif
                mov     a,#0ffh
                ret
ki2_drain:      setb    c
                rlc     a
                ret
                
nulovanie_rele: setb    rele_hore
                setb    rele_dole
                setb    rele_jazda
                setb    svetlo
                clr     moving
                call    tmr_int_f
                db      t_stykace,0,1,0
nr_lp:          call    do_them
                jb      stykace,nr_ret
                mov     a,#t_stykace
                call    tmr_zro
                jnc     nr_lp
                setb    error_stykace
                jmp     kill_me
nr_ret:         call    wait4it_f
                db      t_stykace,0,2,0
                clr     liftdir
                ret

start_vytahu:   jnb     a1,sv_quit
                clr     rele_jazda
                jb      a2,sv_got_a2
                call    tmr_int_f
                db      t_start,0,5,0
sv_lp1:         call    do_them
                jnb     a1,sv_quit
                jb      a2,sv_ok
                mov     a,#t_start
                call    tmr_zro
                jnc     sv_lp1
sv_quit:        setb    rele_jazda
                clr     a
                ret
sv_got_a2:      call    tmr_int_f
                db      t_start,0,1,0
sv_lp2:         call    do_them
                mov     c,a1
                anl     c,a2
                jnc     sv_quit
                mov     a,#t_start
                call    tmr_zro
                jnc     sv_lp2
sv_ok:          mov     a,#0ffh
                ret

a1_safety:      jb      a1,a1s_ret
                setb    svetlo
                setb    kontrolka
a1s_lp:         call    do_them
                jnb     a1,a1s_lp
                clr     kontrolka
                call    tmr_int_f
                db      t_svetlo,0,5,0
a1s_ret:        ret

a1_a2_safety:
ifdef jazda_ked_volba
                call    kam_ist2
                cjne    a,nextfloor,a12s_bad
endif
                mov     c,dolny
                anl     c,horny
                jc      a12s_bad
                mov     c,a1
                anl     c,a2
                jnc     a12s_bad
                clr     a
                ret
a12s_bad:       call    nulovanie_rele
                mov     a,#0ffh
                ret

termistor_safety:
                jnb     termistor,ts_ret
                setb    error_termistor
ts_lp:          call    do_them
                jb      termistor,ts_lp
                clr     error_termistor
                clr     svetlo
ts_ret:         ret

check_termistor:
                jnb     termistor,ct_ret
                jb      liftdir,ct_up
                mov     a,liftpos
                jb      acc.0,ct_store
                dec     a
                sjmp    ct_store
ct_up:          mov     a,liftpos
                setb    acc.0
ct_store:       mov     nextfloor,a
ct_ret:         ret

moving_setup:   mov     thread_id,#'m'
                mov     oinputs,#0ffh
                setb    first_time
                clr     liftdir
                setb    zrovnavacia

mov_main_lp:    call    do_them
                clr     kontrolka
                call    a1_safety
                call    termistor_safety
                clr     moving
                mov     a,#t_svetlo
                call    tmr_zro
                jnc     mm_skip1
                clr     svetlo
mm_skip1:       mov     c,dolny
                anl     c,horny
                jc      mov_main_lp
                call    kam_ist
                mov     r0,a
                cpl     a
                jz      mov_main_lp
                mov     a,r0
                mov     nextfloor,a
                clr     c
                subb    a,liftpos
                jc      mov_go_down
                jz      mov_main_lp
mov_go_up:      call    start_vytahu
                jz      mov_main_lp
                clr     rele_hore
                setb    liftdir
                setb    svetlo
                setb    kontrolka
                setb    moving
                call    reset_doba_jazdy
                jmp     mgu_lp
mov_go_down:    call    start_vytahu
                jz      mov_main_lp
                clr     rele_dole
                clr     liftdir
                setb    svetlo
                setb    kontrolka
                setb    moving
                call    reset_doba_jazdy
                jmp     mgd_lp

mgu_lp:         call    do_them
                call    a1_a2_safety
                jnz     mov_main_lp
                call    check_termistor
                call    check_doba_jazdy
                call    update_liftpos
                mov     a,liftpos
                clr     c
                subb    a,nextfloor
                jc      mgu_lp
                call    nulovanie_rele
                clr     liftdir
                call    tmr_int_f
                db      t_svetlo,0,5,0
                jmp     mov_main_lp

mgd_lp:         call    do_them
                call    a1_a2_safety
                jnz     mov_main_lp
                call    check_termistor
                call    check_doba_jazdy
                call    update_liftpos
                mov     a,nextfloor
                clr     c
                subb    a,liftpos
                jc      mgd_lp
                call    nulovanie_rele
                clr     liftdir
                jbc     zrovnavacia,mgd_skip
                call    tmr_int_f
                db      t_svetlo,0,5,0
mgd_skip:       jmp     mov_main_lp
