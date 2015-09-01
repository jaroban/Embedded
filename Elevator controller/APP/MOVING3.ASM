; version 4.1

init_pohnutie:  call    reset_doba_jazdy
                call    init_timer_f
                dw      t_pohnutia
                db      0,10,0
                setb    checkuj_pohnutie
                call    init_timer_f
                dw      t_menic
                db      0,5,0
                ret

cp_no_more:     clr     checkuj_pohnutie
cp_ret:         ret
check_pohnutie: jnb     checkuj_pohnutie,cp_ret
                mov     a,liftsub
                cjne    a,#1,cp_no_more
                call    timer_running_f
                dw      t_pohnutia
                jnz     cp_ret
                call    je_cas_pohnutia
                jz      cp_no
                djnz    cnt_pohnutie,cp_no
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#jazda_disable
                call    kill_em
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_chyba_start
                call    pridaj_chybu
                call    zapis_chybu
                mov     a,ac_rd
                anl     a,#0fh
                cjne    a,#0fh,cp_skip1
                call    zapni_poruchu
cp_skip1:       mov     smer,#both_blink
                call    dx_spusti_a_otvor_dvere
                jmp     kill_me
cp_no:          mov     dptr,#jazda_disable
                call    kill_em
                call    nulovanie_rele
                call    vymaz_volby
                call    wait_for_timer_f
                dw      t_moving
                db      0,10,0
                pop     b
                pop     b
                pop     b
                jmp     nj_drain1

check_doba_jazdy:
                call    timer_running_f
                dw      t_cas_jazdy
                jnz     cdj_ok
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#jazda_disable
                call    kill_em
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_doba_jazdy
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
                jmp     kill_me
cdj_ok:         ret

hsds_disable:   db      id_go_up
                db      id_go_down
                db      0

hsds_up:        call    je_horny
                jz      hdu_ret
                call    je_dolny
                jnz     hsds_obidva
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                inc     a
                inc     a
                clr     c
                subb    a,floor_no
                jnc     hdu_ret2
endif
                call    aka_nahrada
                jz      hdu_normal
                mov     a,floor_no
                dec     a
                clr     c
                subb    a,liftpos
                clr     acc.0           ; 0 or 1
                jnz     hdu_vysoka
hdu_ret2:       ret
hdu_normal:     jb      rele_vysoka_rychlost,hdu_vysoka
                call    je_nad_hornym
                jnz     hdu_ret
hdu_vysoka:     mov     dptr,#jazda_disable
                call    kill_em
                clr     a
                call    stredna_rychlost
                clr     a
                call    vysoka_rychlost
                mov     a,#e_hs
                call    pridaj_chybu
                call    zapis_chybu
                call    aka_nahrada
                jnz     hdu_end
hdu_lp:         call    do_them
                jnb     a4,hdu_end
                call    je_a_aj_b
                jz      hdu_lp
hdu_end:        call    nulovanie_rele
                call    wait_for_timer_f
                dw      t_moving
                db      0,1,0
                jmp     starting_point
hdu_ret:        ret

hsds_obidva:    mov     dptr,#hsds_disable
                call    kill_em
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_hs_ds
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
                jmp     kill_me

hsds_dn:        call    je_dolny
                jz      hdd_ret
                call    je_horny
                jnz     hsds_obidva
if bratislava_dolny
                mov     a,liftpos
                xrl     a,#1
                jz      hdd_ret2
endif
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                jz      hdd_ret2
endif
                call    aka_nahrada
                jz      hdd_normal
                mov     a,liftpos
                clr     acc.0           ; 0 or 1
                jnz     hdd_vysoka
hdd_ret2:       ret
hdd_normal:     jb      rele_vysoka_rychlost,hdd_vysoka
                call    je_pod_dolnym
                jnz     hdd_ret
hdd_vysoka:     mov     dptr,#jazda_disable
                call    kill_em
                clr     a
                call    stredna_rychlost
                clr     a
                call    vysoka_rychlost
                mov     a,#e_ds
                call    pridaj_chybu
                call    zapis_chybu
                call    aka_nahrada
                jnz     hdd_end
hdd_lp:         call    do_them
                jnb     a4,hdd_end
                call    je_a_aj_b
                jz      hdd_lp
hdd_end:        call    nulovanie_rele
                call    wait_for_timer_f
                dw      t_moving
                db      0,1,0
                jmp     starting_point
hdd_ret:        ret

uloz_volby_nic: mov     dptr,#call_save
                mov     r0,call_no
                clr     a
uvn_lp:         movx    @dptr,a
                inc     dptr
                djnz    r0,uvn_lp
                ret

uloz_volby:     mov     r0,#call_table
                mov     dptr,#call_save
                mov     r1,call_no
uv_lp:          mov     a,@r0
                movx    @dptr,a
                inc     r0
                inc     dptr
                djnz    r1,uv_lp
                ret

obnov_volby:
if obnovuje_volby
                mov     dptr,#call_save
                mov     r0,#call_table
                mov     r1,call_no
ov_lp:          movx    a,@dptr
                orl     a,@r0
                mov     @r0,a
                inc     dptr
                inc     r0
                djnz    r1,ov_lp
endif
                ret
