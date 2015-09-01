; version 4.0

jazda_disable:  db      id_go_up
                db      id_go_down
                db      id_predotvaranie
                db      id_door_a
                db      id_door_b
                db      0

th_normalna:    dw      normalna_jazda, st_normalna
                db      id_normalna, 0, st_normalna_size

th_z_reviznej:  dw      normalna_z_reviznej, st_normalna
                db      id_normalna, 0, st_normalna_size

normalna_z_reviznej:
                clr     a
                call    set_jazda_skoncila
                mov     c,liftdir
                mov     oliftdir,c
                clr     liftdir
                call    ms_a2_entry
                ; should never return
                jmp     starting_point

nj_exit:        mov     r0,#7
nje_lp:         push    ar0
                call    do_them
                pop     ar0
                djnz    r0,nje_lp
                mov     dptr,#th_door_act
                call    run_it
                jmp     kill_me

normalna_jazda: clr     a
                call    set_jazda_skoncila
                mov     a,liftpos
                jnz     nj_skip1
                call    je_dolny
                jnz     nj_skip2
nj_do_zrov:     jmp     starting_point
nj_skip1:       inc     a
                cjne    a,floor_no,nj_skip2
                call    je_horny
                jz      nj_do_zrov
nj_skip2:       mov     a,ac_rd
                anl     a,#0eh
                cjne    a,#0eh,nj_exit
                mov     a,nextfloor
                clr     c
                subb    a,liftpos
                jc      nj_dole
                jz      nj_exit
nj_hore:        call    hsds_up
                mov     smer,#hore
                mov     dptr,#th_go_up
                call    run_it
                call    init_pohnutie
                sjmp    nj_hore_lp
nj_dole:        call    hsds_dn
                mov     smer,#dole
                mov     dptr,#th_go_down
                call    run_it
                call    init_pohnutie
                sjmp    nj_dole_lp
nj_hore_lp:     call    do_them
                call    hsds_up
                call    check_pohnutie
                call    check_doba_jazdy
                call    update_liftpos
                call    movement_safety
                call    update_up
                mov     a,liftpos
                xrl     a,nextfloor
                jz      nj_hore_skip
                call    next_stop_up
nj_hore_skip:   call    do_blikanie
                call    get_jazda_skoncila
                jnb     acc.1,nj_hore_lp
                mov     cnt_pohnutie,#2
                sjmp    nj_drain1
nj_dole_lp:     call    do_them
                call    hsds_dn
                call    check_pohnutie
                call    check_doba_jazdy
                call    update_liftpos
                call    movement_safety
                call    update_down
                mov     a,liftpos
                xrl     a,nextfloor
                jz      nj_dole_skip
                call    next_stop_down
nj_dole_skip:   call    do_blikanie
                call    get_jazda_skoncila
                jnb     acc.1,nj_dole_lp
                mov     cnt_pohnutie,#2
nj_drain1:      
if bez_volby_stop
                mov     a,nextfloor
                call    vymaz_kabina
endif
                call    end_blikanie
                jnb     bola_strata_a4,nj_drain2
                clr     bola_strata_a4
                mov     a,#e_strata_a4
                call    zrus_chybu
nj_drain2:      call    entering_stopped
if pocet_otoceni
                mov     c,liftdir
                jnb     oliftdir,nj_drain_2_5
                cpl     c
nj_drain_2_5:   jnc     nj_drain3
endif
                call    inc_pocet_jazd
                call    uloz_pocet_jazd
                call    compare_pocet_jazd
                jz      nj_drain3
                call    zdochni_pocet_jazd
nj_drain3:      mov     c,liftdir
                mov     oliftdir,c
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_act
                call    run_it
                jmp     kill_me

stop_de_lift:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#jazda_disable
                call    kill_em
                call    nulovanie_rele
                call    end_blikanie

                mov     a,liftpos
                cjne    a,nextfloor,sdl_skip
                mov     a,liftsub
                cjne    a,#1,sdl_skip
                mov     a,liftpos
                call    vymaz_kabina
                mov     a,liftpos
                call    vymaz_dole
                mov     a,liftpos
                call    vymaz_hore
                pop     b
                pop     b
                pop     b
                pop     b
                pop     b
                pop     b
                mov     a,#e_strata_a4
                call    zrus_chybu
                jmp     nj_drain1
sdl_skip:       mov     c,liftdir
                mov     oliftdir,c
                clr     liftdir
                ret

bspm_skip1_:    jmp     bspm_skip1

movement_safety:
                ; kontrola menica
                call    je_kontrola_menica
                jz      ms_km_skip1
                call    timer_running_f
                dw      t_menic
                jnz     ms_km_skip1
                call    kontrola_menica
                jnz     ms_km_skip1
                ; zastavime
                call    stop_de_lift
                mov     a,#e_kontrola_menica
                call    zapis_chybu
                jmp     ms_a2_entry2

ms_km_skip1:    call    je_porucha_menica
                jz      bspm_skip1_
                call    porucha_menica
                jz      bspm_skip1_
                ; zastavime
                call    stop_de_lift
                mov     a,#e_porucha_menica
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both
                setb    blokuj_volby
                call    uloz_volby_nic
                call    vymaz_volby

                ; otvorime dvere ak je v stanici
                call    je_a_aj_b
                jz      bspm_skip0
                call    zapni_otvaranie_dveri
                call    wait_for_timer_f
                dw      t_menic
                db      0,10,0
                call    vypni_otvaranie_dveri
bspm_skip0:

                ; opakuje sa to?
                call    timer_running_reload_f
                dw      t_od_resetu
                db      5,0,0
                jnz     bspm_bad

                ; reset menica
                mov     a,#1
                call    reset_menica
                call    wait_for_timer_f
                dw      t_menic
                db      0,3,0
                clr     a
                call    reset_menica
                call    wait_for_timer_f
                dw      t_menic
                db      0,30,0
                
                ; cakame ci sa opravi
bspm_main_lp:   call    do_them
                call    porucha_menica
                jnz     bspm_main_lp
                ; opravil sa
                mov     smer,#none
                mov     a,#e_porucha_menica
                call    zrus_chybu
                clr     blokuj_volby
                ; dufame ze neprebehne celu bezpecnost bez toho aby niekde zastal
                jb      a2,bspm_try3_1
                jmp     ms_a2_entry2
bspm_try3_1:
if polska_lista
                jb      a5,bspm_try3_2
                jmp     ms_a5_entry
endif
bspm_try3_2:    jb      a3,bspm_try4
                jmp     ms_a3_entry
bspm_try4:      jb      a4,bspm_try5
                jmp     ms_a4_stop
bspm_try5:      jmp     ms_a4_entry
                ; zdochneme
bspm_bad:       call    do_them
                jmp     bspm_bad
bspm_skip1:

if bez_volby_stop
                jnb     uz_mame_volbu,ms_volba_skip1
                mov     r4,nextfloor
                call    je_kabina
                jnz     ms_volba_skip1
                call    stop_de_lift
                call    uloz_volby_nic
                setb    zakaz_vonkajsie
                call    vymaz_volby
                mov     smer,#both
ms_volba_lp1:   call    do_them
                call    update_liftpos
                jnb     a3,ms_volba_escape
                jnb     a4,ms_volba_escape
                call    je_kabinova_volba
                jz      ms_volba_lp1
ms_volba_escape:
                mov     smer,#none
                clr     zakaz_vonkajsie
                sjmp    ms_a3_lp
ms_volba_skip1:
endif

if polska_lista
                jb      a2,ms_try_a5
else
                jb      a2,ms_try_a3
endif
                call    stop_de_lift
ms_a2_entry:    setb    blokuj_volby
                call    uloz_volby_nic
                call    vymaz_volby
                mov     a,#e_strata_a2
                call    pridaj_chybu
                call    zapis_chybu
ms_a2_entry2:   mov     smer,#both
ms_a2_lp:       call    do_them
                call    update_liftpos
                jnb     a2,ms_a2_lp
                mov     smer,#none
                mov     a,#e_strata_a2
                call    zrus_chybu
                clr     blokuj_volby
if polska_lista
                sjmp    ms_a5_entry
else
                sjmp    ms_a3_entry
endif

if polska_lista
ms_try_a5:      jb      a5,ms_try_a3
                call    stop_de_lift
ms_a5_entry:    setb    zakaz_vonkajsie
                call    uloz_volby_nic
                call    vymaz_volby
                mov     a,#e_strata_a5
                call    zapis_chybu
                mov     smer,#both
ms_a5_entry2:   mov     a,#e_strata_a5
                call    pridaj_chybu
                setb    blokuj_volby
ms_a5_lp1:      call    do_them
                call    update_liftpos
                jnb     a5,ms_a5_lp1
                clr     blokuj_volby
                mov     a,#e_strata_a5
                call    zrus_chybu
ms_a5_lp2:      call    do_them
                call    update_liftpos
                jnb     a5,ms_a5_entry2
                call    je_kabinova_volba
                jz      ms_a5_lp2
                mov     smer,#none
                clr     zakaz_vonkajsie
                sjmp    ms_a3_entry
endif

ms_try_a3:      mov     c,a3
                orl     c,je_predotvaranie
                jnc     ms_a3_skip0
                jmp     ms_try_a4
ms_a3_skip0:    call    stop_de_lift
                call    a3_maze_volby
                jz      ms_a3_skip1
                call    uloz_volby_nic
                sjmp    ms_a3_skip2
ms_a3_skip1:    call    uloz_volby
ms_a3_skip2:    mov     a,#e_strata_a3
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both
                call    zapni_svetlo
ms_a3_entry:    call    vymaz_volby

                ; A3 je vypnute
ms_a3_lp:       call    do_them
                call    update_liftpos
                jb      a2,ms_a3_skip3
                clr     zakaz_vonkajsie
                jmp     ms_a2_entry
ms_a3_skip3:
if polska_lista
                jb      a5,ms_a3_skip4
                jmp     ms_a5_entry
ms_a3_skip4:
endif
                call    ake_dvere
                clr     acc.0
                jnz     ms_a3_skip10
                call    je_nejaka_volba
                jnz     ms_a3_skip11
                sjmp    ms_a3_lp
ms_a3_skip10:   jnb     a3,ms_a3_lp

                ; A3 sa zaplo / mame volbu
ms_a3_skip11:   mov     a,#e_strata_a3
                call    zrus_chybu
                call    a3_maze_volby
                jz      ms_a3_skip6
                jb      ovazenie_10,ms_a3_skip6
                call    vypni_svetlo
                mov     smer,#none
ms_a3_skip6:
                ; A3 je zapnute
ms_a3_lp2:      call    do_them
                call    update_liftpos
                jb      a2,ms_a3_skip7
                jmp     ms_a2_entry
ms_a3_skip7:
if polska_lista
                jb      a5,ms_a3_skip8
                jmp     ms_a5_entry
ms_a3_skip8:
endif
                call    ake_dvere
                clr     acc.0
                jz      ms_a3_skip12
                jnb     a3,ms_a3_skip2
ms_a3_skip12:   call    a3_maze_volby
                jz      ms_a3_skip5
                jnb     ovazenie_10,ms_a3_skip5
                call    je_kabinova_volba
                jz      ms_a3_skip9
                jmp     ms_a4_entry2
ms_a3_skip5:    call    je_nejaka_volba
                jz      ms_a3_skip9
                jmp     ms_a4_entry
ms_a3_skip9:    ; kvoli napr jazda do najnizsej
                call    next_stop2
                cjne    a,#na_jazda,ms_a3_lp2
                jmp     ms_a4_entry3

ms_try_a4:      call    get_jazda_skoncila
                mov     c,acc.0
                ;jb      bola_strata_a4,ms_a4_spec
                orl     c,a4
                orl     c,je_predotvaranie
                jc      ms_ret
                ;setb    bola_strata_a4
                mov     a,#e_strata_a4
                call    pridaj_chybu
;                call    aky_pohon
;                jz      ms_a4_stop
;                call    init_timer_f
;                dw      t_obnovenie_a4
;                db      0,3,0
;                ret
;ms_a4_spec:     jnb     a4,ms_a4_time
;                clr     bola_strata_a4
;                mov     a,#e_strata_a4
;                jmp     zrus_chybu
;ms_a4_time:     call    timer_running_f
;                dw      t_obnovenie_a4
;                jz      ms_a4_stop
;                ret
ms_a4_stop:     call    stop_de_lift
                call    uloz_volby
                call    vymaz_volby
                mov     smer,#none
ms_a4_lp:       call    do_them
                call    update_liftpos
                jb      a2,ms_a4_skip1
                jmp     ms_a2_entry
ms_ret:         ret
ms_a4_skip1:
if polska_lista
                jb      a5,ms_a4_skip1_1
                jmp     ms_a5_entry
ms_a4_skip1_1:
endif
                mov     c,a3
                orl     c,je_predotvaranie
                jc      ms_a4_skip2
                jmp     ms_a3_entry
ms_a4_skip2:    ; kvoli napr jazda do najnizsej
                call    next_stop2
                cjne    a,#na_jazda,ms_a4_skip2_1
                sjmp    ms_a4_entry3
ms_a4_skip2_1:  call    je_nejaka_volba
                jz      ms_a4_lp
ms_a4_entry:    call    obnov_volby
                jb      oliftdir,ms_a4_skip3
                call    next_down
                cjne    a,#0ffh,ms_a4_skip5
                sjmp    ms_a4_skip4
ms_a4_skip3:    call    next_up
                cjne    a,#0ffh,ms_a4_skip5
ms_a4_skip4:    call    next_one
                sjmp    ms_a4_skip5
ms_a4_entry2:   call    kde_je_kabinova_volba
ms_a4_skip5:    mov     nextfloor,a
                sjmp    ms_a4_skip6
ms_a4_entry3:   call    obnov_volby
ms_a4_skip6:    clr     bola_strata_a4
                mov     a,#e_strata_a4
                call    zrus_chybu
                call    zj_close_doors
                pop     b
                pop     b
                pop     b
                mov     a,nextfloor
                mov     b,#13
                mul     ab
                add     a,#1
                mov     r0,a
                clr     a
                addc    a,b
                mov     r1,a
                mov     a,my_liftpos
                mov     b,#13
                mul     ab
                add     a,liftsub
                mov     r2,a
                clr     a
                addc    a,b
                mov     r3,a
                mov     a,r2
                clr     c
                subb    a,r0
                mov     a,r3
                subb    a,r1
                jnc     rfs_go_dn
                jb      oliftdir,rfs_up_ok
                setb    liftdir
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      rfs_up_typ_0
                cjne    a,#2,rfs_up_typ_1
                mov     a,liftsub
                clr     c
                subb    a,#5
                jc      rfs_up_ok
                subb    a,#6
                jnc     rfs_up_ok
                inc     liftpos
                sjmp    rfs_up_ok
rfs_up_typ_1:   mov     a,liftsub
                clr     c
                subb    a,#5
                jc      rfs_up_ok
                subb    a,#6
                jnc     rfs_up_ok
                sjmp    rfs_up_change
rfs_up_typ_0:   mov     a,liftsub
                cjne    a,#3,rfs_up_ok
rfs_up_change:  dec     liftpos
rfs_up_ok:      jmp     nj_hore

rfs_go_dn:      jnb     oliftdir,rfs_dn_ok
                clr     liftdir
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      rfs_dn_typ_0
                cjne    a,#2,rfs_dn_typ_1
                mov     a,liftsub
                clr     c
                subb    a,#5
                jc      rfs_dn_ok
                subb    a,#6
                jnc     rfs_dn_ok
                dec     liftpos
                sjmp    rfs_dn_ok
rfs_dn_typ_1:   mov     a,liftsub
                clr     c
                subb    a,#5
                jc      rfs_dn_ok
                subb    a,#6
                jnc     rfs_dn_ok
                sjmp    rfs_dn_change
rfs_dn_typ_0:   mov     a,liftsub
                cjne    a,#3,rfs_dn_ok
rfs_dn_change:  inc     liftpos
rfs_dn_ok:      jmp     nj_dole
