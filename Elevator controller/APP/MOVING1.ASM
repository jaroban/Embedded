; version 4.1

zapni_otvaranie_dveri:
                jnb     su_vobec_dvere_a,zod_skip1
                setb    rele_otvaranie_dveri_a
zod_skip1:      jnb     su_vobec_dvere_b,zod_skip2
                setb    rele_otvaranie_dveri_b
zod_skip2:      ret

zapni_otvaranie_dveri2:
                jnb     su_vobec_dvere_a,zod2_skip1
                mov     a,my_liftpos
                call    su_dvere_a
                jz      zod2_skip1
                setb    rele_otvaranie_dveri_a
zod2_skip1:     jnb     su_vobec_dvere_b,zod2_skip2
                mov     a,my_liftpos
                call    su_dvere_b
                jz      zod2_skip2
                setb    rele_otvaranie_dveri_b
zod2_skip2:     ret

vypni_otvaranie_dveri:
                jnb     su_vobec_dvere_a,vod_skip1
                clr     rele_otvaranie_dveri_a
vod_skip1:      jnb     su_vobec_dvere_b,vod_skip2
                clr     rele_otvaranie_dveri_b
vod_skip2:      ret

zapni_zatvaranie_dveri:
                jnb     su_vobec_dvere_a,zzd_skip1
                setb    rele_zatvaranie_dveri_a
zzd_skip1:      jnb     su_vobec_dvere_b,zzd_skip2
                setb    rele_zatvaranie_dveri_b
zzd_skip2:      ret

zapni_zatvaranie_dveri2:
                call    zapni_zatvaranie_dveri
                call    wait_for_timer_f
                dw      t_zatvaranie_dveri
                db      0,0,20
                ret

vypni_zatvaranie_dveri:
                jnb     su_vobec_dvere_a,vzd_skip1
                clr     rele_zatvaranie_dveri_a
vzd_skip1:      jnb     su_vobec_dvere_b,vzd_skip2
                clr     rele_zatvaranie_dveri_b
vzd_skip2:      ret

vysoka_rychlost:
                jz      vr_vypni
                setb    rele_vysoka_rychlost
                ret
vr_vypni:       clr     rele_vysoka_rychlost
                ret

vypni_rychlosti:
                clr     a
                call    vysoka_rychlost
                clr     a
                call    stredna_rychlost
                clr     a
                jmp     nizka_rychlost

zmen_rychlost:  mov     b,a
                call    aka_nahrada
                jz      zr_ok
                mov     a,#1
                jmp     nizka_rychlost
zr_ok:          mov     a,b
zmen_rychlost2: jnz     zr_try_1
                ; vysoka
                mov     a,#1
                call    vysoka_rychlost
                call    typ_menica
                jz      zr_0_old
                clr     a
                call    stredna_rychlost
                clr     a
                jmp     nizka_rychlost
zr_0_old:       mov     a,#1
                call    stredna_rychlost
                jmp     zapni_nizka
zr_try_1:       cjne    a,#1,zr_try_2
                ; stredna
                clr     a
                call    vysoka_rychlost
                mov     a,#1
                call    stredna_rychlost
                call    typ_menica
                jz      zr_1_old
                clr     a
                jmp     nizka_rychlost
zr_1_old:       jmp     zapni_nizka
zr_try_2:       cjne    a,#2,zr_try_3
                ; nizka
                clr     a
                call    vysoka_rychlost
                clr     a
                call    stredna_rychlost
                mov     a,#1
                jmp     nizka_rychlost
zr_try_3:       cjne    a,#3,zr_ret
                ; revizna
                call    typ_menica
                jz      zr_3_old
                jmp     vypni_rychlosti
zr_3_old:       mov     a,#1
                call    vysoka_rychlost
                clr     a
                call    stredna_rychlost
                jmp     zapni_nizka
zr_ret:         ret

reset_doba_jazdy:
                mov     a,#t_doba_jazdy
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_cas_jazdy
                jmp     init_timer

start_vytahu:   call    zapni_svetlo
start_vytahu_bez_svetla:
                call    je_rele_jazda
                jz      sv_skip1
                call    wait_for_timer_f
                dw      t_start_vytahu
                db      0,0,20
                mov     a,#1
                call    jazda
                call    aky_pohon
                jz      sj_skip3
                ; trakcny
                call    zapni_hv_tr
sv_lp1:         call    do_them
                mov     a,check_hv_tr
                jnz     sv_lp1
                call    wait_for_timer_f
                dw      t_start_vytahu
                db      0,0,20
                sjmp    sj_ret
sj_skip3:       ; hydraulicky
                call    wait_for_timer_f
                dw      t_start_vytahu
                db      0,0,20
sv_skip1:       call    zapni_hv_tr
sj_ret:         call    init_timer_f
                dw      t_menic
                db      0,5,0
                ret
                ;jmp     start_ac_ignore

wait_for_nulovanie:
                call    do_them
                call    update_liftpos
                call    timer_running_f
                dw      t_nulovanie
                jnz     wait_for_nulovanie
                ret

nulovanie_rele: call    init_timer_f
                dw      t_menic
                db      0,20,0
                call    prestan_hv_tr
                call    prestan_nizka
                call    je_rele_nizka
                jnz     nr_skip1
                clr     rele_hore
                clr     rele_dole
nr_skip1:       clr     rele_svetlo
                clr     rele_10
                call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nr_skip2
                mov     a,#t_vypni_jazda
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_nulovanie
                call    init_timer
                call    wait_for_nulovanie
                clr     a
                call    hviezda_trojuholnik
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,normalna_hviezda_jazda
                call    wait_for_nulovanie
nr_skip2:       mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
                jmp     check_stykace

nulovanie_rele_s:
                call    prestan_hv_tr
                call    prestan_nizka
                call    je_rele_nizka
                jnz     nrs_skip1
                clr     rele_hore
                clr     rele_dole
nrs_skip1:      call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nrs_skip2
                mov     a,#t_vypni_jazda
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_nulovanie
                call    init_timer
                call    wait_for_nulovanie
nrs_skip2:      anl     wr_rele_reg1,#11110000b
if kruzkovy_motor
                anl     wr_rele_reg2,#11001010b
else
                anl     wr_rele_reg2,#11111010b
endif
                clr     a
                call    jazda
                call    wait_for_timer_f
                dw      t_moving
                db      0,0,50
                clr     rele_10
                jmp     check_stykace

nulovanie_rele_t:
                call    prestan_hv_tr
                call    prestan_nizka
                anl     wr_rele_reg1,#11001000b
                anl     wr_rele_reg2,#11110101b
                clr     a
                call    stredna_rychlost
                clr     a
                call    nizka_rychlost
                call    je_rele_jazda_alebo_hv_tr
                jz      nrt_skip
                mov     a,#t_vypni_jazda
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_nulovanie
                call    init_timer
                call    wait_for_nulovanie
                mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
nrt_skip:       jmp     check_stykace

nulovanie_rele_p:
                call    prestan_hv_tr
                call    prestan_nizka
                call    je_rele_nizka
                jnz     nrp_skip1
                clr     rele_hore
                clr     rele_dole
nrp_skip1:      clr     rele_svetlo
                call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nrp_skip2
                mov     a,#t_vypni_jazda
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_nulovanie
                call    init_timer
                call    wait_for_nulovanie
nrp_skip2:      mov     a,#11010000b
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
                jmp     check_stykace

; servisna
nulovanie_rele_a:
                call    prestan_hv_tr
                call    prestan_nizka
                clr     rele_hore
                clr     rele_dole
                clr     rele_svetlo
                clr     rele_10
                call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nra_skip1
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,servisna_smerove_hviedza
                call    wait_for_nulovanie
                clr     a
                call    hviezda_trojuholnik
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,servisna_hviedza_jazda
                call    wait_for_nulovanie
nra_skip1:      mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
                jb      nezapinaj_fazy,nra_ret
                jmp     check_stykace
nra_ret:        ret

; revizna
nulovanie_rele_r:
                call    prestan_hv_tr
                call    prestan_nizka
                clr     rele_hore
                clr     rele_dole
                clr     rele_svetlo
                clr     rele_10
                call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nrr_skip1
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,revizna_smerove_hviedza
                call    wait_for_nulovanie
                clr     a
                call    hviezda_trojuholnik
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,revizna_hviedza_jazda
                call    wait_for_nulovanie
nrr_skip1:      mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
                jb      nezapinaj_fazy,nrr_ret
                jmp     check_stykace
nrr_ret:        ret

; nudzova
nulovanie_rele_n:
                call    prestan_hv_tr
                call    prestan_nizka
                clr     rele_hore
                clr     rele_dole
                clr     rele_svetlo
                clr     rele_10
                call    vypni_rychlosti
                call    je_rele_jazda_alebo_hv_tr
                jz      nrn_skip0
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,nudzova_smerove_hviedza
                call    wait_for_nulovanie
                clr     a
                call    hviezda_trojuholnik
                call    init_timer_f
                dw      t_nulovanie
                db      0,0,nudzova_hviedza_jazda
                call    wait_for_nulovanie
nrn_skip0:      mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                clr     a
                call    jazda
                jnb     nezapinaj_fazy,nrn_skip2
                call    param_dorovnavanie
                jnz     nrn_skip1
                call    param_predotvaranie
                jnz     nrn_skip1
                setb    rele_10
nrn_skip1:      mov     a,#1
                jmp     rele_baterka
nrn_skip2:      jmp     check_stykace

stykace_disable1:
                db      id_stopped
                db      id_door_a
                db      id_door_b
                db      id_predotvaranie
                db      0

stykace_disable2:
                db      id_nudzova
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_dorovnavanie
                db      0

check_stykace:  call    init_timer_f
                dw      t_stykace
                db      0,3,0
cs_lp:          call    do_them
                call    je_bezpecnost_menica
                jz      cs_skip1
                call    bezpecnost_menica
                jz      cs_skip2
cs_skip1:       jb      kontrola_stykacov,cs_ret
cs_skip2:       call    timer_running_f
                dw      t_stykace
                jnz     cs_lp
                ; bezpecnost menica
                call    je_bezpecnost_menica
                jz      cs_skip3
                call    bezpecnost_menica
                jnz     cs_skip3
                mov     a,#e_bezpecnost_menica
                call    pridaj_chybu
                call    zapis_chybu
                sjmp    cs_skip4
cs_skip3:       ; porucha stykacov
                jb      kontrola_stykacov,cs_skip4
                mov     a,#e_porucha_stykacov
                call    pridaj_chybu
                call    zapis_chybu
                ; zdochnutie
cs_skip4:       setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#stykace_disable1
                call    kill_em
                call    dx_spusti_a_otvor_dvere
                mov     dptr,#stykace_disable2
                jmp     kill_em
cs_ret:         mov     r0,#bola_zapnuta_jazda
                clr     a
                mov     @r0,a
                ret
