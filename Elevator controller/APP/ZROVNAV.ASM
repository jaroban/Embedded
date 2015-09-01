; version 4.1

th_zrovnavacia: dw      zrovnavacia_jazda, st_normalna
                db      id_zrovnavacia, 0, st_normalna_size

bolo_a_aj_b     bit     f0

                dseg
floor_cntr:     ds      1

                cseg
if zrovnavacia_hore
zrov_smer               equ     hore
zrov_smer_opacny        equ     dole
zrov_rele               equ     rele_hore
zrov_rele_opacne        equ     rele_dole
zrov_snimac             equ     je_len_horny
zrov_snimac_opacny      equ     je_len_dolny
zrov_posch_pri_snimaci  equ     posch_nad_hs
else
zrov_smer               equ     dole
zrov_smer_opacny        equ     hore
zrov_rele               equ     rele_dole
zrov_rele_opacne        equ     rele_hore
zrov_snimac             equ     je_len_dolny
zrov_snimac_opacny      equ     je_len_horny
zrov_posch_pri_snimaci  equ     posch_pod_ds
endif

zj_termistor_safety:
                call    je_termistor
                jz      zjts_ret
                call    dx_zastav_dvere
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_termistor
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
zjts_lp1:       call    do_them
                call    je_termistor
                jnz     zjts_lp1
                mov     smer,#zrov_smer
                mov     a,#e_termistor
                call    zrus_chybu
                clr     blokuj_volby
                mov     a,#0ffh
                ret
zjts_ret:       clr     a
                ret

zj_pretazenie_safety:
                jnb     ovazenie_110,zjps_ret
                call    dx_zastav_dvere
                mov     liftstate,#s_pretazenie
                call    pretazenie_on
if zapisuj_pretazenie
                mov     a,#e_pretazenie
                call    zapis_chybu
endif
zjps_lp1:       call    do_them
                jb      ovazenie_110,zjps_lp1
                call    pretazenie_off
                mov     liftstate,#s_dvere
                mov     a,#0ffh
                ret
zjps_ret:       clr     a
                ret

zj_a2_safety:   jb      a2,zj_a2s_ret
                call    dx_zastav_dvere
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                mov     a,#e_strata_a2
                call    pridaj_chybu
                call    zapis_chybu
zj_a2s_lp:      call    do_them
                jnb     a2,zj_a2s_lp
                mov     a,#e_strata_a2
                call    zrus_chybu
                mov     smer,#none
                clr     blokuj_volby
                mov     a,#0ffh
                ret
zj_a2s_ret:     clr     a
                ret

zj_a3_safety:   call    ake_dvere2
                clr     acc.0
                jz      zj_a3s_ret
                jb      a3,zj_a3s_ret
                call    dx_zastav_dvere
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both
zj_a3s_lp:      call    do_them
                jnb     a2,zj_a3s_ret
                jnb     a3,zj_a3s_lp
                mov     smer,#zrov_smer
                clr     blokuj_volby
                mov     a,#0ffh
                ret
zj_a3s_ret:     clr     a
                ret

zjcd_ret:       ret
zj_close_doors: jb      a4,zjcd_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_a
                call    run_it
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_b
                call    run_it
                mov     liftstate,#s_dvere
zjcd_lp1:       call    dx_zatvor_dvere
zjcd_lp2:       call    do_them
                call    zj_termistor_safety
                jnz     zjcd_lp1
                call    zj_pretazenie_safety
                jnz     zjcd_lp1
                call    zj_a2_safety
                jnz     zjcd_lp1
                call    zj_a3_safety
                jnz     zjcd_lp1
                mov     a,dra_flags
                orl     a,drb_flags
                jb      db_error,zjcd_clean_up
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_closed,zjcd_lp2
                call    init_timer_f
                dw      t_z_delay_a4
                db      0,0,75
zjcd_lp3:       call    do_them
                jnb     a4,zjcd_lp1
                call    timer_running_f
                dw      t_z_delay_a4
                jnz     zjcd_lp3
                mov     a,#id_door_a
                call    kill_it
                mov     a,#id_door_b
                jmp     kill_it
zjcd_clean_up:  mov     a,#not(dm_error)
                anl     dra_flags,a
                anl     drb_flags,a
                call    vymaz_volby
                mov     smer,#both_blink
                clr     a
                mov     c,a3
                rlc     a
                mov     c,a2
                rlc     a
                mov     r7,a
zjcd_lp4:       push    ar7
                call    do_them
                pop     ar7
                clr     a
                mov     c,a3
                rlc     a
                mov     c,a2
                rlc     a
                xch     a,r7
                cpl     a
                anl     a,r7
                jb      acc.0,zjcd_ok
                mov     r6,a
                call    ake_dvere2
                clr     acc.0
                jz      zjcd_auto
                mov     a,r6
                jb      acc.1,zjcd_ok
zjcd_auto:      call    je_nejaka_volba
                jz      zjcd_lp4
zjcd_ok:        call    zrus_chyby_dveri
                mov     smer,#zrov_smer
                jmp     zjcd_lp1

zj_check_doba_jazdy:
                call    timer_running_f
                dw      t_cas_jazdy
                jnz     zjcdj_ok
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_doba_jazdy
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
                jmp     kill_me
zjcdj_ok:       ret

zj_reset_doba_jazdy:
                call    je_a_alebo_b
                jz      zjrdj_skip
                jb      bolo_a_aj_b,zjrdj_ret
                setb    bolo_a_aj_b
                jmp     reset_doba_jazdy
zjrdj_skip:     clr     bolo_a_aj_b
zjrdj_ret:      ret

hsds_zrov:      call    je_h_aj_d
                jz      hsdsz_ret
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_hs_ds
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
                jmp     kill_me
hsdsz_ret:      ret

zrovnavacia_safety:
                ; kontrola menica
                call    je_kontrola_menica
                jz      zs_km_skip1
                call    timer_running_f
                dw      t_menic
                jnz     zs_km_skip1
                call    kontrola_menica
                jnz     zs_km_skip1
                jmp     zs_menic_entry

zs_km_skip1:    call    je_porucha_menica
                jz      zsm_skip1
                call    porucha_menica
                jz      zsm_skip1
                ; zastavime
                call    nulovanie_rele
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_porucha_menica
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both

                ; opakuje sa to?
                call    timer_running_reload_f
                dw      t_od_resetu
                db      5,0,0
                jnz     zsm_bad
                
                ; reset menica
                mov     a,#1
                call    reset_menica
                call    wait_for_timer_f
                dw      t_z_menic
                db      0,3,0
                clr     a
                call    reset_menica
                call    wait_for_timer_f
                dw      t_z_menic
                db      0,30,0

                ; cakame ci sa opravi
zsm_main_lp:    call    do_them
                call    porucha_menica
                jnz     zsm_main_lp
                ; opravil sa
                mov     smer,#none
                mov     a,#e_porucha_menica
                call    zrus_chybu
                clr     blokuj_volby
                ; dufame ze neprebehne celu bezpecnost bez toho aby niekde zastal
                jb      a2,zsm_try3_1
                jmp     zs_a2_entry
zsm_try3_1:
if polska_lista
                jb      a5,zsm_try3_2
                jmp     zs_a5_entry
endif
zsm_try3_2:     jb      a3,zsm_try4
                jmp     zs_a3_entry
zsm_try4:       jb      a4,zsm_try5
                jmp     zs_try_a4
zsm_try5:       jmp     zs_c_dvere
                ; zdochneme
zsm_bad:        call    do_them
                jmp     zsm_bad
zsm_skip1:

zs_try_a2:
if polska_lista
                jb      a2,zs_try_a5
else
                jb      a2,zs_try_a3
endif
zs_menic_entry: call    nulovanie_rele
                mov     a,#e_strata_a2
                call    pridaj_chybu
                call    zapis_chybu
zs_a2_entry:    setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both
zs_a2_lp:       call    do_them
                jnb     a2,zs_a2_lp
                clr     blokuj_volby
                mov     a,#e_strata_a2
                call    zrus_chybu
                call    ake_dvere2
                clr     acc.0
                jz      zs_c_dvere
if polska_lista
                sjmp    zs_a5_entry
else
                sjmp    zs_a3_entry
endif

if polska_lista
zs_try_a5:      jb      a5,zs_try_a3
                call    nulovanie_rele
zs_a5_entry:    setb    zakaz_vonkajsie
                call    vymaz_volby
                mov     a,#e_strata_a5
                call    zapis_chybu
                mov     smer,#both
zs_a5_entry2:   mov     a,#e_strata_a5
                call    pridaj_chybu
                setb    blokuj_volby
zs_a5_lp1:      call    do_them
                jnb     a5,zs_a5_lp1
                clr     blokuj_volby
                mov     a,#e_strata_a5
                call    zrus_chybu
zs_a5_lp2:      call    do_them
                jnb     a5,zs_a5_entry2
                call    je_kabinova_volba
                jz      zs_a5_lp2
                mov     smer,#none
                clr     zakaz_vonkajsie
                sjmp    zs_a3_entry
endif

zs_try_a3:      jb      a3,zs_try_a4
                call    nulovanie_rele
                mov     a,#e_strata_a3
                call    pridaj_chybu
                call    zapis_chybu
zs_a3_entry:    call    ake_dvere2
                clr     acc.0
                jz      zs_c_dvere
                setb    blokuj_volby
                call    vymaz_volby
zs_a3_lp:       call    do_them
                jnb     a2,zs_a2_entry
if polska_lista
                jb      a5,zs_a3_skip4
                jmp     zs_a5_entry
zs_a3_skip4:
endif
                jnb     a3,zs_a3_lp
                clr     blokuj_volby
zs_c_dvere:     mov     a,#e_strata_a3
                call    zrus_chybu
                pop     b
                pop     b
                pop     b
                mov     a,liftpos
                inc     a
                jz      zs_c_no
                jmp     zjnh_entry
zs_c_no:        jmp     zj_entry

zs_try_a4:      jb      bola_strata_a4,zs_a4_spec
                jb      a4,zs_ret
                setb    bola_strata_a4
                mov     a,#e_strata_a4
                call    pridaj_chybu
                call    aky_pohon
                jz      zs_a4_stop
                call    init_timer_f
                dw      t_obnovenie_a4
                db      0,3,0
                ret
zs_a4_spec:     jnb     a4,zs_a4_time
                clr     bola_strata_a4
                mov     a,#e_strata_a4
                jmp     zrus_chybu
zs_a4_time:     call    timer_running_f
                dw      t_obnovenie_a4
                jz      zs_a4_stop
                ret
zs_a4_stop:     call    nulovanie_rele
                call    vymaz_volby
                mov     a,#e_strata_a4
                call    zrus_chybu
                clr     bola_strata_a4
                jmp     zs_c_dvere
zs_ret:         ret

zrovnavacia_jazda:
                clr     je_ranny_program
                clr     je_obed_program
                clr     je_nezavisla_jazda
                clr     je_prednostna_jazda
                mov     je_poziarna_jazda,#0
if v_poziarnej_bx_do_nuly
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    clear_bx
endif
                clr     je_posledna_jazda
                clr     dorovnava_sa
                clr     je_predotvaranie

                call    pocet_preruseni_sza
                mov     c_preruseni_sza,a

                mov     liftstate,#s_zrov_jazda
                clr     bola_strata_a4
                mov     liftpos,#0ffh
                call    vypis_poschodie
                mov     my_liftpos,#0ffh
                mov     liftsub,#0ffh
if zrovnavacia_hore
                mov     a,floor_no
                dec     a
                mov     nextfloor,a
else
                mov     nextfloor,#0
endif           
                mov     smer,#zrov_smer
                
                mov     cnt_pohnutie,#2
                call    zapni_svetlo
                call    pretazenie_off
                call    check_stykace
zj_entry:       
                ; rucne dvere, vazenie 10 -> kabinova volba
                call    ake_dvere2
                cjne    a,#4,zj_start0
zj_start_lp:    call    do_them
                jnb     ovazenie_10,zj_start0
                call    je_kabinova_volba
                jz      zj_start_lp
zj_start0:
                
                call    zj_close_doors
                mov     liftstate,#s_zrov_jazda
                call    hsds_zrov
                mov     smer,#zrov_smer
                call    reset_doba_jazdy
                clr     bolo_a_aj_b

                call    aka_nahrada
                jz      zj_start
                call    zrov_snimac
                jz      zjn_start
                jmp     zj_finish
zjn_start:      call    zapni_zatvaranie_dveri2
                call    start_vytahu
                setb    zrov_rele
zjn_lp1:        call    do_them
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    zj_reset_doba_jazdy
                call    zrov_snimac
                jz      zjn_lp1
                jmp     zj_finish

zj_go_up:       call    zapni_zatvaranie_dveri2
                mov     smer,#zrov_smer_opacny
                call    start_vytahu
                setb    zrov_rele_opacne
                clr     a
                call    zmen_rychlost2
zjgu_lp1:       call    do_them
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    zj_reset_doba_jazdy
                call    zrov_snimac
                jnz     zjgu_lp1
                call    nulovanie_rele
                call    wait_for_timer_f
                dw      t_zrovnavacia
                db      0,1,0
                call    zrovnavacia_safety
                call    hsds_zrov
                call    reset_doba_jazdy
                clr     bolo_a_aj_b
                call    zapni_zatvaranie_dveri2
                mov     smer,#zrov_smer
                call    start_vytahu
                setb    zrov_rele
                mov     a,#1
                call    nizka_rychlost
                jmp     zj_lp2_init

zj_start:       call    zrov_snimac
                jz      zj_skip3
                call    zrov_posch_pri_snimaci
                dec     a
                jnz     zj_go_up
                call    je_a_aj_b
                jz      zj_skip0
                jmp     zj_finish
zj_skip0:       call    zapni_zatvaranie_dveri2
                call    start_vytahu
                call    je_len_a
                jz      zj_skip1
                setb    zrov_rele
                sjmp    zj_skip2
zj_skip1:       call    je_len_b
                jz      zj_skip4
                setb    zrov_rele_opacne
                mov     smer,#zrov_smer_opacny
zj_skip2:       mov     a,#1
                call    nizka_rychlost
                sjmp    zj_lp2_init

zj_skip3:       call    zapni_zatvaranie_dveri2
                call    start_vytahu
                setb    zrov_rele
                clr     a
                call    zmen_rychlost2

zj_lp1:         call    do_them
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    zj_reset_doba_jazdy
                call    zrov_snimac
                jz      zj_lp1
                mov     a,#2
                call    zmen_rychlost2
                sjmp    zj_lp2_init

zj_skip4:       call    zapni_zatvaranie_dveri2
                call    start_vytahu
                setb    zrov_rele
                mov     a,#2
                call    zmen_rychlost2

zj_lp2_init:    call    zrov_posch_pri_snimaci
                mov     floor_cntr,a
zj_lp2:         call    do_them
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    je_a_aj_b
                jz      zj_lp2
                djnz    floor_cntr,zj_lp2_ab
                sjmp    zj_finish
zj_lp2_ab:      call    do_them
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    je_a_aj_b
                jnz     zj_lp2_ab
                jmp     zj_lp2

zj_finish:      mov     a,#e_strata_a4
                call    zrus_chybu
                mov     a,#t_oneskorenie_ab
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_zrovnavacia
                call    wait_for_timer
                call    nulovanie_rele
if zrovnavacia_hore
                mov     a,floor_no
                dec     a
                mov     liftpos,a
                mov     my_liftpos,a
else
                mov     liftpos,#0
                mov     my_liftpos,#0
endif
                clr     liftdir
                clr     oliftdir
                call    vypis_poschodie
                mov     liftsub,#1
                mov     smer,#none
                call    wait_for_timer_f
                dw      t_zrovnavacia
                db      0,1,0
                call    reset_inc_counter
                jb      je_nahravacia,zj_nahravacia
                mov     dptr,#th_dra_zrov
                call    run_it
                jmp     kill_me

zj_nahravacia:  call    inc_init
                call    wait_for_timer_f
                dw      t_zrovnavacia
                db      0,1,0
zjnh_entry:     call    zj_close_doors
                call    hsds_zrov
                mov     smer,#zrov_smer_opacny
                call    reset_doba_jazdy
                clr     bolo_a_aj_b
if zrovnavacia_hore
                clr     liftdir
else
                setb    liftdir
endif

                call    zapni_zatvaranie_dveri2
                call    start_vytahu
                setb    zrov_rele_opacne
                clr     a
                call    zmen_rychlost2

zjnh_lp1:       call    do_them
                call    zjnh_vypis
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    zj_reset_doba_jazdy
                call    update_liftpos
                call    zrov_snimac
                jz      zjnh_skip2
                call    je_a_aj_b
                jz      zjnh_skip1
                mov     nextfloor,#0
                sjmp    zjnh_skip2
zjnh_skip1:     mov     nextfloor,inc_cnt_lo
zjnh_skip2:     mov     a,liftsub
                cjne    a,#1,zjnh_skip3
                clr     ea
                mov     r3,inc_cnt_lo
                mov     r4,inc_cnt_hi
                setb    ea
                mov     a,my_liftpos
                call    put_inc_data
zjnh_skip3:     call    zrov_snimac_opacny
                jz      zjnh_lp1
                clr     a
                call    vysoka_rychlost

zjnh_lp2:       call    do_them
                call    zjnh_vypis
                call    zrovnavacia_safety
                call    hsds_zrov
                call    zj_check_doba_jazdy
                call    update_liftpos
                mov     a,liftsub
                cjne    a,#1,zjnh_lp2
                clr     ea
                mov     r3,inc_cnt_lo
                mov     r4,inc_cnt_hi
                setb    ea
                mov     a,my_liftpos
                call    put_inc_data

                mov     a,#t_oneskorenie_ab
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_zrovnavacia
                call    wait_for_timer
                call    nulovanie_rele
                mov     smer,#none
                call    zjnh_vypis
                call    wait_for_timer_f
                dw      t_zrovnavacia
                db      0,1,0
                mov     a,nextfloor
                mov     dptr,#num_table+9
                movx    @dptr,a
                inc     dptr
                movx    @dptr,a
                clr     je_nahravacia
                jmp     kill_me

zjnh_vypis:     mov     lcd_ind,#0
                mov     a,my_liftpos
                call    lcd_dec2
                mov     lcd_ind,#3
                mov     a,liftsub
                call    lcd_dec2
                mov     lcd_ind,#12
                mov     a,inc_cnt_hi
                call    lcd_hex
                mov     a,inc_cnt_lo
                call    lcd_hex
                mov     lcd_ind,#16
                mov     a,nextfloor
                call    lcd_dec2
                mov     lcd_ind,#28
                mov     a,my_liftpos
                call    get_inc_data
                mov     a,r4
                call    lcd_hex
                mov     a,r3
                jmp     lcd_hex
