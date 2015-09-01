; version 4.1

th_dra_zrov:    dw      door_act_zrov, st_door_act
                db      id_stopped, 0, st_door_act_size

th_door_act:    dw      door_act, st_door_act
                db      id_stopped, 0, st_door_act_size

if gong_kym_a3
cgs_door_closed:
                call    ake_dvere
                clr     acc.0
                jnz     cgs_da_a3
                ; automaticke dvere
                mov     c,a4
                rlc     a
                ret
cgs_da_a3:      ; rucne dvere
                clr     a
                mov     c,a3
                rlc     a
                ret

check_gong_stopped:  
                mov     a,gong_stopped_state
                jnz     cgs_try_1
                ; 0 = no gonging
                call    cgs_door_closed
                jz      cgs_entry_2
                ret
cgs_try_1:      cjne    a,#1,cgs_try_2
                ; 1 = gong until opened
                call    cgs_door_closed
                jnz     cgs_gong
cgs_entry_2:    call    init_timer_f
                dw      t_gonganie
                db      10,0,0
                mov     gong_stopped_state,#2
                ret
cgs_try_2:      cjne    a,#2,cgs_to_zero
                ; 2 = opened, waiting
                call    cgs_door_closed
                jnz     cgs_to_zero
                call    timer_running_f
                dw      t_gonganie
                jnz     cgs_ret
cgs_gong:       jmp     zapni_gong
cgs_to_zero:    mov     gong_stopped_state,#0
cgs_ret:        ret
endif

dra_init:       mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_dorovnavanie
                call    run_it
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_a
                call    run_it
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_b
                jmp     run_it

door_act_zrov:
if gong_kym_a3
                mov     gong_stopped_state,#0
endif
if spec_ver
                mov     krap,#0
endif
if na_jednom_poschodi_dve_volby
                mov     mozu_dvere_ab,#0
endif
                mov     dr_state,#dr_nic
                call    dra_init
                call    param_fazy
                jz      daz_skip1
                jb      poradie_faz,daz_skip1
                call    je_nudzovy_dojazd
                jz      daz_skip1
                mov     liftstate,#s_dvere
                clr     mozes_dorovnavat
                setb    blokuj_volby
                call    vymaz_volby
                call    dx_otvor_dvere
                call    zapni_svetlo
                call    gong_otvorenie
dra_fazy_lp:    call    do_them
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_waited,dra_fazy_lp
                mov     a,#id_dorovnavanie
                call    kill_it
                mov     a,#id_door_a
                call    kill_it
                mov     a,#id_door_b
                call    kill_it
                jmp     kill_me

daz_skip1:      call    treba_otvorit_dvere
                jnz     daz_skip2
                jmp     dra_nic
daz_skip2:      jmp     dra_otv

door_act:       clr     pjf2_opened
if cas_medzi_zatvaranim_a_otvaranim
                call    wait_for_timer_f
                dw      t_prednost
                db      0,0,cas_medzi_zatvaranim_a_otvaranim
endif
if spec_ver
                mov     a,krap
                mov     my_liftpos,a
                mov     liftpos,a
endif
                call    dra_init
if gong_kym_a3
                mov     gong_stopped_state,#1
endif
dra_gen_otv:    call    neotvaraj_dvere
                jnz     da_p_skip2
                call    netreba_otvorit_dvere
                jnz     da_p_skip1
                call    treba_otvorit_dvere
                jnz     dgo_skip
                jmp     dra_otv_zat
dgo_skip:       jmp     dra_otv
da_p_skip2:     
if maz_volby_neskor
                call    vymaz_tu_volby
endif
if gong_kym_a3
                mov     gong_stopped_state,#0
endif
                jmp     dra_n_entry
da_p_skip1:     
if maz_volby_neskor
                call    vymaz_tu_volby
endif
if gong_kym_a3
                mov     gong_stopped_state,#0
endif

dra_nic:        mov     liftstate,#s_dvere
                setb    mozes_dorovnavat
                call    reset_svetlo
                call    reset_parkovanie

dra_n_lp1:      call    do_them
                call    termistor_safety
                jnz     dra_nic
                call    pretazenie_safety1
                jnz     dra_nic
                call    a2_safety
                jnz     dra_nic

if gong_kym_a3
                call    check_gong_stopped
endif
                call    sza
                call    szb
                call    check_poziarna_jazda
                call    check_prednostna_jazda
                call    check_nezavisla_jazda
                call    check_obed_program
                call    check_ranny_program

                call    ake_dvere
                clr     acc.0
                jz      dra_n_skip1
                jnb     a3,dra_n_daj

dra_n_skip1:    jb      ovazenie_10,dra_n_daj
                call    statie_s_otvorenymi_dverami
                cjne    a,#2,dra_n_skip2
                call    sza_normal
                jnz     dra_n_daj
                call    szb_normal
                jz      dra_n_skip2
dra_n_daj:      call    daj_prednost
dra_n_skip2:

                call    update_stopped
                call    urci_smer

                call    skus_zapnut_svetlo
                call    skus_vypnut_svetlo
                call    skus_ist_parkovat

                mov     a,dr_state
                cjne    a,#dr_pp_cakaj,dra_n_skip137
                jmp     dra_n_skip3
dra_n_skip137:  
                mov     a,je_poziarna_jazda
                xrl     a,#2
                jz      dra_n_pjf2_skip0
                mov     a,je_poziarna_jazda
                xrl     a,#3
                jz      dra_n_lp1

                call    tlacitko_otvarania_dveri
                jnz     dra_n_skip3
                call    je_tu_volba2
                jz      dra_n_entry
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
                jmp     dra_n_skip3

dra_n_entry:    call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
                jmp     dra_n_lp1
dra_n_skip3:    jmp     dra_gen_otv

; poziarna jazda
dra_n_pjf2_skip0:
                call    tlacitko_otvarania_dveri
                jz      dra_n_pjf2_skip1
                jmp     dra_otv
dra_n_pjf2_skip1:
                ;call    tlacitko_zatvarania_dveri
                ;jz      dra_n_pjf2_skip2
                call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
;dra_n_pjf2_skip2:
                jmp     dra_n_lp1

dra_otv:        mov     liftstate,#s_dvere
                setb    mozes_dorovnavat
                call    dx_otvor_dvere
                call    zapni_svetlo
                call    gong_otvorenie
dra_o_lp1:      call    do_them
                call    termistor_safety
                jnz     dra_otv
                call    pretazenie_safety2
                jnz     dra_otv
                call    a2_safety
                jnz     dra_otv
                
if gong_kym_a3
                call    check_gong_stopped
endif
                call    sza
                call    szb
                call    check_poziarna_jazda
                call    check_prednostna_jazda
                call    check_nezavisla_jazda
                call    check_obed_program
                call    check_ranny_program

                call    update_stopped
                call    urci_smer

                mov     a,je_poziarna_jazda
                xrl     a,#2
                jz      dra_o_pjf2_skip0
                mov     a,je_poziarna_jazda
                xrl     a,#3
                jz      dra_o_pjf2_skip1

                jnb     ovazenie_10,dra_o_skip1
                call    daj_prednost

dra_o_skip1:    mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_waited,dra_o_lp1
                call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
                jmp     dra_nic

; poziarna jazda
dra_o_pjf2_skip0:
                jb      pjf2_opened,dra_o_pjf2_skip1
                call    tlacitko_otvarania_dveri
                jnz     dra_o_pjf2_skip1
                jmp     dra_zat
dra_o_pjf2_skip1:
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_opened,dra_o_lp1
                setb    pjf2_opened
                jmp     dra_nic

dra_otv_zat:    mov     liftstate,#s_dvere
                setb    mozes_dorovnavat
                call    dx_otvor_a_zatvor_dvere
                call    zapni_svetlo
                call    gong_otvorenie
dra_oc_lp1:     call    do_them
                call    termistor_safety
                jnz     dra_otv_zat
                call    pretazenie_safety2
                jnz     dra_otv_zat
                call    a2_safety
                jnz     dra_otv_zat
                
if gong_kym_a3
                call    check_gong_stopped
endif
                call    sza
                call    szb
                call    check_poziarna_jazda
                call    check_prednostna_jazda
                call    check_nezavisla_jazda
                call    check_obed_program
                call    check_ranny_program

                call    update_stopped
                call    urci_smer

                call    je_tu_volba2
                jz      dra_oc_skip1
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
                setb    top_reverz_a
                setb    top_reverz_b

                mov     a,je_poziarna_jazda
                jz      dra_oc_pjf2_skip0
                jmp     dra_nic
dra_oc_pjf2_skip0:

dra_oc_skip1:   jnb     ovazenie_10,dra_oc_skip2
                call    daj_prednost

dra_oc_skip2:   mov     a,dra_flags
                orl     a,drb_flags
                jnb     db_error,dra_oc_skip3
                jmp     dra_clean_up
dra_oc_skip3:   mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_closed,dra_oc_lp1
                call    skonci_prednost_povodneho_smeru
                call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
                jmp     dra_nic

dra_zat:        mov     liftstate,#s_dvere
                clr     mozes_dorovnavat
                call    dx_zatvor_dvere
                call    zapni_svetlo
dra_c_lp1:      call    do_them
                call    termistor_safety
                jnz     dra_zat
                call    pretazenie_safety2
                jnz     dra_zat
                call    a2_safety
                jnz     dra_zat
                
if gong_kym_a3
                call    check_gong_stopped
endif
                call    sza
                call    szb
                call    check_poziarna_jazda
                call    check_prednostna_jazda
                call    check_nezavisla_jazda
                call    check_obed_program
                call    check_ranny_program

                call    update_stopped
                call    urci_smer

                call    je_tu_volba2
                jz      dra_c_skip0
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
                setb    top_reverz_a
                setb    top_reverz_b

dra_c_skip0:    jnb     ovazenie_10,dra_c_skip1
                call    daj_prednost

dra_c_skip1:    mov     a,dra_flags
                orl     a,drb_flags
                jb      db_error,dra_clean_up
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_closed,dra_c_lp1
                call    skonci_prednost_povodneho_smeru
                call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
                jmp     dra_nic

dra_clean_up:   mov     liftstate,#s_dvere
                setb    mozes_dorovnavat
                mov     a,#not(dm_error)
                anl     dra_flags,a
                anl     drb_flags,a
                call    dx_otvor_dvere
ifn vonkajsia_volba_opravi_dvere
                setb    zakaz_vonkajsie
endif
                call    vymaz_volby
                mov     smer,#both_blink
                clr     a
                mov     c,a3
                rlc     a
                mov     c,a2
                rlc     a
                mov     r7,a
dra_cu_lp:      push    ar7
                call    do_them
if gong_kym_a3
                call    check_gong_stopped
endif
                pop     ar7
                clr     a
                mov     c,a3
                rlc     a
                mov     c,a2
                rlc     a
                xch     a,r7
                cpl     a
                anl     a,r7
                jb      acc.0,dra_cu_ok
                mov     r6,a
                call    ake_dvere
                clr     acc.0
                jz      dra_cu_auto
                mov     a,r6
                jb      acc.1,dra_cu_ok
dra_cu_auto:
if vonkajsia_volba_opravi_dvere
                call    je_nejaka_volba
else
                call    je_kabinova_volba
endif
                jz      dra_cu_lp
dra_cu_ok:      clr     zakaz_vonkajsie
                call    zrus_chyby_dveri
                mov     smer,#none
                jmp     dra_nic

dra_prednost:   mov     liftstate,#s_prednost
                setb    mozes_dorovnavat
                call    reset_prednost
                call    zapni_svetlo
                call    init_timer_f
                dw      t_a3_error
                db      0,30,0
                call    ake_dvere
                clr     acc.0
                jnz     dra_p_lp1
                jb      ovazenie_10,dra_p_lp1
                call    first_or_last
                jz      dra_p_lp1
                jmp     dra_p_done

dra_p_lp1:      call    do_them
                call    a2_safety
                call    do_blikanie

if gong_kym_a3
                call    check_gong_stopped
endif
                call    sza
                call    szb
                call    check_poziarna_jazda
                call    check_prednostna_jazda
                call    check_nezavisla_jazda
                call    check_obed_program
                call    check_ranny_program

                call    update_stopped
                call    urci_smer

                mov     a,je_poziarna_jazda
                jz      dra_p_pjf2_skip0
                jmp     dra_p_done
dra_p_pjf2_skip0:

                call    ake_dvere
                clr     acc.0
                jz      dra_p_auto
                jb      a3,dra_p_a3_rst
                call    pretazenie_safety3
                call    reset_prednost
                call    timer_running_f
                dw      t_a3_error
                jnz     dra_p_auto
                mov     a,#e_blokovanie_dveri
                call    pridaj_chybu
                jmp     dra_clean_up
dra_p_a3_rst:   call    init_timer_f
                dw      t_a3_error
                db      0,30,0

dra_p_auto:     call    tlacitko_otvarania_dveri
                jnz     dra_p_skip1
                call    je_tu_volba2
                jz      dra_p_vaz10
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
dra_p_skip1:    jmp     dra_gen_otv

dra_p_vaz10:    jnb     ovazenie_10,dra_p_time
                call    je_kabinova_volba
                jnz     dra_p_time
                call    reset_prednost

dra_p_time:     call    je_este_prednost
                jz      dra_p_done
                call    timer_running_f
                dw      t_prednost
                jz      dra_p_done
                jmp     dra_p_lp1

dra_p_done:     call    koniec_prednosti
                call    end_blikanie
                call    next_stop
                call    do_case
                dw      na_prednost+j_,dra_prednost
                dw      na_jazda+j_,dra_jazda
                db      0
                jmp     dra_nic

dra_jazda:
if su_dvere_c
                ; wait for door to close
                mov     a,my_liftpos
                cjne    a,#2,dra_j_ok1
                jb      a3,dra_j_ok0
                jmp     dra_prednost
dra_j_ok0:      call    dx_zatvor_dvere
                call    init_timer_f
                dw      t_delay_a4
                db      0,15,0
dra_j_lp0:      call    do_them
                jb      a4,dra_j_ok1
                jnb     a3,dra_j_reverz
                call    timer_running_f
                dw      t_delay_a4
                jnz     dra_j_lp0
                call    vymaz_volby
                jmp     dra_otv
dra_j_reverz:   call    dx_otvor_dvere
                jmp     dra_prednost
dra_j_ok1:
endif
                clr     mozes_dorovnavat
                jnb     a4,dra_j_close
                call    zapni_zatvaranie_dveri
                call    init_timer_f
                dw      t_delay_a4
                db      0,0,20
dra_j_lp1:      call    do_them
                jb      a4,dra_j_skip1
dra_j_close:    jmp     dra_zat
dra_j_skip1:    call    timer_running_f
                dw      t_delay_a4
                jnz     dra_j_lp1
if ziadne_kabinove_bez_10
                call    je_vazenie_10
                jz      dra_j_skip2
                jb      ovazenie_10,dra_j_skip2
                call    je_kabinova_volba
                jz      dra_j_skip2
                call    vymaz_kabinove
                call    do_them
                call    do_them
                call    do_them
                call    update_stopped
                call    urci_smer
                call    next_stop
                xrl     a,#na_jazda
                jz      dra_j_skip2
                call    vypni_zatvaranie_dveri
                jmp     dra_prednost
endif
dra_j_skip2:    call    pocet_preruseni_sza
                mov     r0,a
                jz      dra_j_lp2
                mov     a,c_preruseni_sza
                jnz     dra_j_ok
                mov     c_preruseni_sza,r0
                call    vymaz_kabinove
                call    vypni_zatvaranie_dveri
                call    do_them
                call    do_them
                call    do_them
                jmp     dra_nic
dra_j_ok:       dec     c_preruseni_sza

dra_j_lp2:      call    do_them
                jb      dorovnava_sa,dra_j_lp2

                mov     a,#id_dorovnavanie
                call    kill_it
                mov     a,#id_door_a
                call    kill_it
                mov     a,#id_door_b
                call    kill_it

if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dra_j_original1
                mov     mozu_dvere_ab,#0
dra_j_original1:
endif
if spec_ver
                mov     a,liftpos
                xrl     a,nextfloor
                jb      acc.1,spec_cont
                mov     krap,nextfloor
                mov     a,krap
                call    vymaz_kabina
                mov     a,krap
                call    vymaz_dole
                mov     a,krap
                call    vymaz_hore
                call    entering_stopped
                clr     je_predotvaranie
                jmp     door_act
spec_cont:      mov     a,liftpos
                cjne    a,#2,spec_hore
                mov     krap,nextfloor
                mov     my_liftpos,#1
                mov     liftpos,#1
                mov     nextfloor,#0
                sjmp    spec_end
spec_hore:      mov     my_liftpos,#1
                mov     liftpos,#1
                mov     nextfloor,#2
                mov     krap,#2
spec_end:
endif
                mov     dptr,#th_normalna
                call    run_it
                jmp     kill_me
