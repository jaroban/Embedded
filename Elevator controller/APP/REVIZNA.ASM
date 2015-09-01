; version 4.1

th_revizna:     dw      init_revizna, st_revizna
                db      id_revizna, 0, st_revizna_size

su_obidve_zatvorene:
                call    je_kvz_dvere_a
                mov     r0,a
                call    je_kvz_dvere_b
                orl     a,r0
                jz      soz_a4
                mov     a,r0
                jz      soz_try_b
                call    kvz_dvere_a
                jz      soz_no
soz_try_b:      call    je_kvz_dvere_b
                jz      soz_yes
                call    kvz_dvere_b
                jz      soz_no
soz_yes:        mov     a,#0ffh
                ret
soz_no:         clr     a
                ret
soz_a4:         mov     c,a4
                clr     a
                rlc     a
                ret

rj_termistor_safety:
                call    je_termistor
                jz      rjts_ret
                mov     a,#e_termistor
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
rjts_lp1:       call    do_them
                call    je_termistor
                jnz     rjts_lp1
                mov     a,#e_termistor
                call    zrus_chybu
                mov     a,#0ffh
                ret
rjts_ret:       clr     a
                ret
                
safety_revizna: mov     a,ac_rd
                anl     a,#0eh
                xrl     a,#0eh
                jz      sr_ret
                call    nulovanie_rele_r
                mov     smer,#none
sr_lp1:         call    do_them      
                jnb     a2,sr_lp1
                mov     c,hore24
                orl     c,dole24
                jc      sr_lp1
                pop     b
                pop     b
                pop     b
                jmp     rev_main_lp
sr_ret:         ret

skus_vysoku:    call    revizna_vysoka
                jz      sv_0
                mov     a,#80h
sv_0:           mov     c,acc.7
                xrl     a,rev_old
                jnb     acc.7,sv_ret
                mov     acc.7,c
                mov     rev_old,a
urc_rychlost_reviznej:
                call    revizna_vysoka
                jnz     urr_skip1
                call    rychlost_reviznej_jazdy1
                jmp     zmen_rychlost2
urr_skip1:      call    rychlost_reviznej_jazdy2
                jmp     zmen_rychlost2
sv_ret:         ret

init_revizna:   mov     error_no,#0
                mov     smer,#none
                call    zapni_svetlo
                ; skontroluj ci neodislo 24v
                call    je_kontrola_24v
                jz      rev_start_up
                call    wait_for_timer_f
                dw      t_revizna
                db      0,0,50
                call    kontrola_24v
                jnz     rev_start_up
                ; odislo 24v
                mov     a,#e_strata_24v
                call    pridaj_chybu
rev_24v_lp:     call    do_them
                call    kontrola_24v
                jz      rev_24v_lp
                jmp     starting_point

rev_start_up:   mov     a,#e_revizna_jazda
                call    zapis_chybu
                call    zapni_poruchu
                
rev_main_lp:    mov     smer,#alt_blink
                call    do_them
                call    rj_termistor_safety
                jnz     rev_main_lp
                clr     liftdir
                call    update_liftpos
                mov     r0,#lcom_output+1
                mov     @r0,#62
                jb      revizna_jazda,rev_skip1
ifn revizna_resetuje
;;; zmena: ide do statia...
                call    vypni_poruchu
                mov     a,liftpos
                inc     a
                jz      rev_reset
                clr     uz_je_revizna
                clr     blokuj_volby
                mov     dps,#0
                mov     dpx,#0
                mov     a,liftsub
                clr     c
                subb    a,#3
                jc      rv_rst2stop
                mov     dptr,#th_z_reviznej
                call    run_it
                jmp     kill_me
rv_rst2stop:    mov     dptr,#th_door_act
                call    run_it
                jmp     kill_me
;;; koniec reviznej jazdy - ide do resetu
endif
rev_reset:      jmp     starting_point
rev_skip1:      jnb     a2,rev_main_lp
                call    ake_dvere2
                clr     acc.0
                jz      rev_no_a3
                jnb     a3,rev_main_lp
rev_no_a3:      mov     c,hore24
                orl     c,dole24
                jnc     rev_main_lp
                call    wait_for_timer_f
                dw      t_revizna
                db      0,0,50
                mov     c,hore24
                anl     c,dole24
                jc      rev_obidve
                jnb     hore24,rev_try_dole
                call    je_horny
                jnz     rev_main_lp
                jmp     rev_hore
rev_try_dole:   jnb     dole24,rev_main_lp
                call    je_dolny
                jnz     rev_main_lp
                jmp     rev_dole

rev_obidve:     call    zapni_otvaranie_dveri
                mov     a,#t_otvarania_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_revizna
                call    init_timer
rev_otv_lp:     call    do_them
                jnb     a2,rev_otv_stop
                call    timer_running_f
                dw      t_revizna
                jnz     rev_otv_lp
rev_otv_stop:   call    vypni_otvaranie_dveri
                jmp     rev_main_lp

revh_stop:      call    vypni_zatvaranie_dveri
                jmp     rev_main_lp
rev_hore:       call    zapni_zatvaranie_dveri
revh_lp0:       call    init_timer_f
                dw      t_revizna
                db      0,0,75
revh_lp1:       call    do_them
                jnb     hore24,revh_stop
                jnb     a2,revh_stop
                call    su_obidve_zatvorene
                jz      revh_lp0
                call    timer_running_f
                dw      t_revizna
                jnz     revh_lp1
                call    je_horny
                jnz     revh_end
                mov     a,ac_rd
                anl     a,#0eh
                cjne    a,#0eh,revh_end
                call    zapni_zatvaranie_dveri2
                mov     smer,#hore
                call    start_vytahu
                call    urc_rychlost_reviznej
                ; kvoli frekvencnemu menicu yaskawa
                call    wait_for_timer_f
                dw      t_revizna
                db      0,0,40
                setb    rele_hore
                setb    liftdir
revh_lp2:       call    do_them
                call    update_liftpos
                call    safety_revizna
                call    skus_vysoku
                jb      dole24,revh_end
                jnb     hore24,revh_end
                call    je_horny
                jz      revh_lp2
                call    bezpecny_priestor
                jz      revh_end
                clr     a
                call    vysoka_rychlost
                clr     a
                call    stredna_rychlost
revh_lp3:       call    do_them
                call    update_liftpos
                call    safety_revizna
                call    je_a_aj_b
                jnz     revh_end
                jb      hore24,revh_lp3
revh_end:       call    nulovanie_rele_r
                mov     smer,#none
                jmp     rev_main_lp

revd_stop:      call    vypni_zatvaranie_dveri
                jmp     rev_main_lp
rev_dole:       call    zapni_zatvaranie_dveri
revd_lp0:       call    init_timer_f
                dw      t_revizna
                db      0,0,75
revd_lp1:       call    do_them
                jnb     dole24,revd_stop
                jnb     a2,revd_stop
                call    su_obidve_zatvorene
                jz      revd_lp0
                call    timer_running_f
                dw      t_revizna
                jnz     revd_lp1
                call    je_dolny
                jnz     revd_end
                mov     a,ac_rd
                anl     a,#0eh
                cjne    a,#0eh,revd_end
                call    zapni_zatvaranie_dveri2
                mov     smer,#dole
                call    start_vytahu
                call    urc_rychlost_reviznej
                ; kvoli frekvencnemu menicu yaskawa
                call    wait_for_timer_f
                dw      t_revizna
                db      0,0,40
                setb    rele_dole
                clr     liftdir
revd_lp2:       call    do_them
                call    update_liftpos
                call    safety_revizna
                call    skus_vysoku
                jb      hore24,revd_end
                jnb     dole24,revd_end
                call    je_dolny
                jz      revd_lp2
                call    bezpecny_priestor
                jz      revd_end
                clr     a
                call    vysoka_rychlost
                clr     a
                call    stredna_rychlost
revd_lp3:       call    do_them
                call    update_liftpos
                call    safety_revizna
                call    je_a_aj_b
                jnz     revd_end
                jb      dole24,revd_lp3
revd_end:       call    nulovanie_rele_r
                mov     smer,#none
                jmp     rev_main_lp
