; version 4.1

first_or_last:  mov     a,liftpos
                jz      fol_yes
                inc     a
                xrl     a,floor_no
                jz      fol_yes
                clr     a
                ret
fol_yes:        mov     a,#0ffh
                ret

termistor_safety:
                call    je_termistor
                jz      ts_ret
                call    dx_otvor_dvere
                setb    blokuj_volby
                call    vymaz_volby
                mov     a,#e_termistor
                call    pridaj_chybu
                call    zapis_chybu
                mov     smer,#both_blink
                clr     mozes_dorovnavat
ts_lp:          call    do_them
                call    je_termistor
                jnz     ts_lp
                setb    mozes_dorovnavat
                mov     a,#e_termistor
                call    zrus_chybu
                clr     blokuj_volby
                mov     a,#0ffh
                ret
ts_ret:         clr     a
                ret

pretazenie_safety1:
                call    statie_s_otvorenymi_dverami
                jz      ps_ret
                call    ake_dvere
                clr     acc.0
                jz      ps_auto
                jb      a3,ps_ret
                sjmp    pretazenie_safety3
ps_auto:        jb      a4,ps_ret
                sjmp    pretazenie_safety3
pretazenie_safety2:
                mov     a,dra_flags
                anl     a,drb_flags
                jb      db_closed,ps_ret        ; both closed
                mov     a,dra_flags
                orl     a,drb_flags
                jb      db_waiting,pretazenie_safety3   ; at least one is waiting
                ; neither is waiting
                jb      db_closing,ps_ret   ; at least one is closing
pretazenie_safety3:
                jnb     ovazenie_110,ps_ret
                call    dx_otvor_dvere
                call    gong_otvorenie
                mov     liftstate,#s_pretazenie
                call    pretazenie_on
if zapisuj_pretazenie
                mov     a,#e_pretazenie
                call    zapis_chybu
endif
ps_lp:          call    do_them
                jb      ovazenie_110,ps_lp
                call    pretazenie_off
                mov     liftstate,#s_dvere
                mov     a,#0ffh
                ret
ps_ret:         clr     a
                ret

a2_safety:      jb      a2,a2s_no
                call    dx_zastav_dvere
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                call    zapni_svetlo
                mov     a,#e_strata_a2
                call    pridaj_chybu
                call    zapis_chybu
a2s_lp:         call    do_them
                jnb     a2,a2s_lp
                mov     a,#e_strata_a2
                call    zrus_chybu
                mov     smer,#none
                clr     blokuj_volby
                mov     a,#0ffh
                ret
a2s_no:         clr     a
                ret

zdochni_snimac_c:
ifn snimac_c_nevyhodnoti
                call    is_posledna_top
                jz      zsc_ret
if snimac_c_reset_po_10_min
                call    init_timer_f
                dw      t_reset_me
                db      10,0,0
                
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#reset_me
                mov     a,#1
                movx    @dptr,a
endif
                mov     a,#e_snimac_c
                call    pridaj_chybu
                call    zapis_chybu
                jb      je_posledna_jazda,zsc_ret
                setb    je_posledna_jazda
                mov     dr_state,#dr_do_najnizsej
                jmp     vymaz_volby
endif
zsc_ret:        ret

zdochni_pocet_jazd:
                call    is_posledna_top
                jz      zpj_ret
                mov     a,#e_pocet_jazd
                call    pridaj_chybu
                call    zapis_chybu
                jb      je_posledna_jazda,zpj_ret
                setb    je_posledna_jazda
                mov     dr_state,#dr_do_najnizsej
                jmp     vymaz_volby
zpj_ret:        ret

check_poziarna_jazda:
                call    is_poziarna_top
                jz      cpj_disappear
                mov     a,je_poziarna_jazda
                jnz     cpj_skip123
                call    poziarna_jazda
                jz      cpj_ret

                ; 0/3 -> 1
cpj_to_1:       mov     je_poziarna_jazda,#1
                mov     dr_state,#dr_do_poziarnej
                call    store_poziarna_dest
                call    vymaz_volby
                call    poziarna_stanica
                dec     a
                cjne    a,liftpos,cpj_ret
                call    zapni_svetlo
                pop     b
                pop     b
                pop     b
                jmp     dra_otv
cpj_skip123:    mov     a,je_poziarna_jazda
                cjne    a,#1,cpj_skip2
                call    poziarna_stanica
                dec     a
                cjne    a,liftpos,cpj_ret
if v_poziarnej_bx_do_nuly
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_opened,cpj_poz_skip1
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    set_bx
cpj_poz_skip1:
endif
                call    poziarna_jazda
                jz      cpj_skip0
                call    nezavisla_jazda
                jz      cpj_ret

                ; 1/3 -> 2
cpj_to_2:       mov     je_poziarna_jazda,#2
                mov     dr_state,#dr_nic
                setb    pjf2_opened
                pop     b
                pop     b
                pop     b
                jmp     dra_otv

                ; 1 -> 0
cpj_skip0:      mov     je_poziarna_jazda,#0
if v_poziarnej_bx_do_nuly
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    clear_bx
endif
                mov     dr_state,#dr_nic
                call    mozem_zatvorit_dvere
                jz      cpj_ret
                pop     b
                pop     b
                pop     b
                jmp     dra_zat
cpj_disappear:  mov     je_poziarna_jazda,#0
if v_poziarnej_bx_do_nuly
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    clear_bx
endif
cpj_ret:        ret
cpj_skip2:      cjne    a,#2,cpj_skip3
if v_poziarnej_bx_do_nuly
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_opened,cpj_poz_skip2
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    set_bx
cpj_poz_skip2:
endif
                call    nezavisla_jazda
                jnz     cpj_ret
                
                ; 2 -> 3
                mov     je_poziarna_jazda,#3
                mov     dr_state,#dr_nic
                call    vymaz_volby
                call    zapni_svetlo
                pop     b
                pop     b
                pop     b
                jmp     dra_otv
                
cpj_skip3:      call    poziarna_jazda
                jnz     cpj_skip3_1
                jmp     cpj_to_1
cpj_skip3_1:    call    nezavisla_jazda
                jnz     cpj_to_2
                ret

check_poziarna_jazda2:
                call    is_poziarna_top
                jz      cpj2_disappear
                mov     a,je_poziarna_jazda
                jnz     cpj2_skip1
                call    poziarna_jazda
                jz      cpj2_ret
                mov     je_poziarna_jazda,#1
                call    store_poziarna_dest
                mov     dr_state,#dr_do_poziarnej
                jmp     vymaz_volby
cpj2_skip1:     call    poziarna_jazda
                jnz     cpj2_ret
                mov     dr_state,#dr_nic
cpj2_disappear: mov     je_poziarna_jazda,#0
if v_poziarnej_bx_do_nuly
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    clear_bx
endif
cpj2_ret:       ret

check_prednostna_jazda:
                call    is_prednostna_top
                jz      cppj_disappear
                jb      je_prednostna_jazda,cppj_skip1
if prednostne_zdochnutie
                call    je_nejaka_volba
                jnz     cppj_ret
endif
                call    prednostne_privolanie
                jz      cppj_ret
                call    store_prednostna_dest
                setb    je_prednostna_jazda
                setb    blokuj_volby
                call    vymaz_volby
                mov     dr_state,#dr_pp_chod
                ret
cppj_skip1:     call    prednostne_privolanie
                jnz     cppj_ret
                clr     je_prednostna_jazda
                clr     blokuj_volby
                call    vymaz_volby
                mov     dr_state,#dr_nic
                ret
cppj_disappear: clr     je_prednostna_jazda
cppj_ret:       ret

check_nezavisla_jazda:
                call    is_nezavisla_top
                jz      cnj_disappear
                jb      je_nezavisla_jazda,cnj_skip1
                call    nezavisla_jazda
                jnz     cnj_turn_on
                mov     a,tlac_otv_state
                jnb     acc.1,cnj_ret
cnj_turn_on:    setb    je_nezavisla_jazda
                call    vymaz_volby
                mov     dr_state,#dr_nic
                mov     smer,#both
                call    zapni_svetlo
                pop     b
                pop     b
                pop     b
                jmp     dra_otv
cnj_skip1:      call    nezavisla_jazda
                jnz     cnj_ret
                mov     a,tlac_otv_state
                jb      acc.1,cnj_ret
                clr     je_nezavisla_jazda
                call    vymaz_volby
                mov     dr_state,#dr_nic
                call    mozem_zatvorit_dvere
                jz      cnj_ret
                pop     b
                pop     b
                pop     b
                jmp     dra_zat
cnj_disappear:  clr     je_nezavisla_jazda
cnj_ret:        ret

check_obed_program:
                call    is_obed_top
                jz      cop_disappear
                jb      je_obed_program,cop_skip1
                call    obednajsi_program
                jz      cop_ret
                setb    je_obed_program
                call    vymaz_volby
                mov     a,floor_no
                dec     a
                cjne    a,liftpos,cop_skip2
                mov     dr_state,#dr_o_nic
                pop     b
                pop     b
                pop     b
                jmp     dra_otv
cop_skip2:      mov     dr_state,#dr_o_spat
                ret
cop_skip1:      call    obednajsi_program
                jnz     cop_ret
                clr     je_obed_program
                mov     dr_state,#dr_nic
                call    mozem_zatvorit_dvere
                jz      cop_ret
                pop     b
                pop     b
                pop     b
                jmp     dra_zat
cop_disappear:  clr     je_obed_program
cop_ret:        ret

check_ranny_program:
                call    is_ranny_top
                jz      crp_disappear
                jb      je_ranny_program,crp_skip1
                call    ranny_program
                jz      crp_ret
                setb    je_ranny_program
                call    vymaz_volby
                call    hlavna_stanica
                dec     a
                cjne    a,liftpos,crp_skip2
                mov     dr_state,#dr_r_nic
                pop     b
                pop     b
                pop     b
                jmp     dra_otv
crp_skip2:      mov     dr_state,#dr_r_spat
                ret
crp_skip1:      call    ranny_program
                jnz     crp_ret
                clr     je_ranny_program
                mov     dr_state,#dr_nic
                call    mozem_zatvorit_dvere
                jz      crp_ret
                pop     b
                pop     b
                pop     b
                jmp     dra_zat
crp_disappear:  clr     je_ranny_program
crp_ret:        ret

daj_prednost:   call    ake_riadenie
                xrl     a,#2
                jz      dp_skip
                mov     a,dr_state
                cjne    a,#dr_nic,dp_ret
dp_skip:        mov     dr_state,#dr_prednost
dp_ret:         ret

skus_zapnut_svetlo:
                jb      ovazenie_10,szs_ok
                call    statie_s_otvorenymi_dverami
                xrl     a,#2
                jz      szs_stat
                jnb     a3,szs_ok
if a4_ovlada_svetlo
                jb      a4,szs_ret
                call    ake_dvere
                clr     acc.0
                jz      szs_ok
endif
szs_ret:        ret
szs_ok:         call    reset_svetlo
                jmp     zapni_svetlo
szs_stat:       call    sza_normal
                jnz     szs_ok
                call    szb_normal
                jnz     szs_ok
                ret

skus_vypnut_svetlo:
                mov     a,je_poziarna_jazda
                jnz     svs_ret
                jb      je_ranny_program,svs_ret
                jb      je_obed_program,svs_ret
                jb      je_nezavisla_jazda,svs_ret
                jb      je_posledna_jazda,svs_ret
                jnb     chceme_vypnut_svetlo,svs_ret
                call    timer_running_f
                dw      t_svetlo
                jnz     svs_ret
                clr     chceme_vypnut_svetlo
                jmp     vypni_svetlo
svs_ret:        ret

skus_ist_parkovat:
                call    parkovacia_stanica
                jz      sip_ret
                dec     a
                xrl     a,liftpos
                jz      sip_ret
                mov     a,dr_state
                cjne    a,#dr_nic,sip_ret
                mov     a,je_poziarna_jazda
                jnz     sip_ret
                jb      je_ranny_program,sip_ret
                jb      je_obed_program,sip_ret
                jb      je_nezavisla_jazda,sip_ret
                jb      je_posledna_jazda,sip_ret
                jnb     chceme_ist_parkovat,sip_ret
                call    timer_running_f
                dw      t_parkovanie
                jnz     sip_ret
                clr     chceme_ist_parkovat
                mov     dr_state,#dr_parkujeme
sip_ret:        ret
