; version 4.1

th_door_a:      dw      door_a, st_door_a
                db      id_door_a, os_bits1 or os_bits0, st_door_a_size

                bseg
top_reverz_a:   dbit    1

                dseg
dra_flags:      ds      1
dvere_a:        ds      1
error_a:        ds      1

                cseg
do_door_events_a:
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#door_command
                movx    a,@dptr
                
                jnb     db_open_a,dde_try_open_close_a
                clr     db_open_a
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_zatvaranie_dveri_a
if 0 ; na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dax_m_o_orig
                mov     a,mozu_dvere_ab
                jb      acc.0,dax_m_o_orig
                mov     dra_flags,#dm_opened or dm_waited
                jmp     dan_lp3
dax_m_o_orig:
endif
                clr     dx_close
                jmp     da_otvaranie
                
dde_try_open_close_a:
                jnb     db_open_close_a,dde_try_close_a
                clr     db_open_close_a
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_zatvaranie_dveri_a
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dax_m_oc_orig
                mov     a,mozu_dvere_ab
                jb      acc.0,dax_m_oc_orig
                mov     dra_flags,#dm_opened or dm_waited or dm_closed
                jmp     dan_lp3
dax_m_oc_orig:
endif
                setb    dx_close
                jmp     da_otvaranie
                
dde_try_close_a:
                jnb     db_close_a,dde_try_stop_a
                clr     db_close_a
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_otvaranie_dveri_a
if 0 ; na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dax_m_c_orig
                mov     a,mozu_dvere_ab
                jb      acc.0,dax_m_c_orig
                mov     dra_flags,#dm_closed
                jmp     dan_lp3
dax_m_c_orig:
endif
                setb    dx_close
                jmp     da_zatvaranie
                
dde_try_stop_a:
                jnb     db_stop_a,dde_ret_a
                clr     db_stop_a
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_otvaranie_dveri_a
                clr     rele_zatvaranie_dveri_a
                jmp     da_entry
                
dde_ret_a:      ret

do_door_events_nothing_a:
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#door_command
                movx    a,@dptr
                jbc     db_open_a,dden_open_a
                jbc     db_open_close_a,dden_open_close_a
                jbc     db_close_a,dden_close_a
                jbc     db_stop_a,dden_stop_a
                ret
dden_open_a:    movx    @dptr,a
                mov     dra_flags,#dm_opened or dm_waited
                ret
dden_open_close_a:
                movx    @dptr,a
                mov     dra_flags,#dm_opened or dm_waited or dm_closed
                ret
dden_close_a:   movx    @dptr,a
                mov     dra_flags,#dm_closed
                ret
dden_stop_a:    movx    @dptr,a
                ret

dan_lp1:        call    do_them
                call    do_door_events_nothing_a
                jmp     dan_lp1

dan_lp2:        call    do_them
                call    do_door_events_nothing_a
                call    je_kvz_dvere_a
                jnz     dan_lp2
                mov     c,rele_zatvaranie_dveri_b
                mov     rele_zatvaranie_dveri_a,c
                jmp     dan_lp2

door_a:         mov     dra_flags,#0
da_entry:       anl     dra_flags,#not(dm_opening+dm_waiting+dm_closing)
                mov     error_a,#0
                mov     dvere_a,#d_nie_su
                clr     dx_bol_reverz
                mov     c_reverzov,#max_reverzov
                mov     c_zatvarani,#max_zatvarani
                jnb     su_vobec_dvere_a,dan_lp1
                mov     a,my_liftpos
                call    su_dvere_a
                jz      dan_lp2

dan_lp3:        call    do_them
                call    do_door_events_a
                jmp     dan_lp3

dao_opened_:    jmp     dao_opened
da_otvaranie:   mov     a,liftsub
                clr     c
                subb    a,#3
                jnc     dao_opened_
                jb      zakaz_pohon,dao_opened_
                mov     dvere_a,#d_otvaraju_sa

                setb    rele_otvaranie_dveri_a
                mov     a,#t_otvarania_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_a_timeout
                call    init_timer
                call    init_timer_f
                dw      t_door_a_delay
                db      0,0,75
                orl     dra_flags,#dm_opening

dao_lp1:        call    do_them
                call    do_door_events_a
                call    je_trvala_kontrola_zatvarania
                jz      dao_normal
                call    tlacitko_otvarania_dveri
                jnz     dao_skip0
dao_normal:     ;call    tlacitko_zatvarania_dveri
                ;jnz     dao_opened
dao_skip0:      call    timer_running_f
                dw      t_door_a_timeout
                jnz     dao_try_kvo
                mov     error_a,#e_prek_doba_otv
                sjmp    dao_opened
dao_try_kvo:    call    timer_running_f
                dw      t_door_a_delay
                jnz     dao_lp1
                call    kvo_dvere
                jz      dao_lp1

dao_opened:     clr     rele_otvaranie_dveri_a
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
                clr     top_reverz_a
                mov     dvere_a,#d_cakaju
                mov     dra_flags,#dm_opened
                mov     a,#t_otvorenych_dveri
                jnb     dx_bol_reverz,dao_skip1
                mov     a,#t_cod_po_reverze
dao_skip1:      call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_a_timeout
                call    init_timer
                orl     dra_flags,#dm_waiting

daw_lp1:        call    do_them
                call    do_door_events_a
                ;jb      top_reverz_a,daw_open
                call    tlacitko_zatvarania_dveri
                jnz     daw_waited
                call    je_trvala_kontrola_zatvarania
                jz      daw_normal
                call    tlacitko_otvarania_dveri
                jz      daw_lp1
daw_open:       jmp     da_otvaranie
daw_normal:     jb      dorovnava_sa,daw_lp1
                call    timer_running_f
                dw      t_door_a_timeout
                jnz     daw_lp1
daw_waited:     mov     dra_flags,#dm_opened+dm_waited
if maz_volby_neskor
                call    vymaz_tu_volby
                clr     top_reverz_a
endif
                jb      dx_close,da_zatvaranie
                jmp     da_entry

da_zatvaranie:  anl     dra_flags,#not(dm_closing)

dac_pred_again: jnb     ovazenie_10,dac_sza
                call    je_nejaka_prednost
                jz      dac_sza
dac_pred_lp:    call    do_them
                call    do_door_events_a
                call    je_nejaka_prednost
                jz      dac_sza
                jb      ovazenie_10,dac_pred_lp

                mov     a,#t_otvorenych_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_a_timeout
                call    wait_for_timer
                jmp     dac_pred_again

dac_sza:        call    sza_r
                jz      dac_no_sza
                mov     dvere_a,#d_svetelna_zavora
if vyhodnocovat_chybu_sza
                call    init_timer_f
                dw      t_door_a_timeout
                db      1,0,0
endif
dac_sza_lp:     call    do_them
                call    do_door_events_a
                call    sza_r
                jz      dac_no_sza
if vyhodnocovat_chybu_sza
                call    timer_running_f
                dw      t_door_a_timeout
                jnz     dac_sza_lp
                call    ake_dvere
                clr     acc.0
                mov     r0,#e_svetelna_zavora
                jz      dac_sza_auto
                mov     r0,#e_blokovanie_dveri
dac_sza_auto:   mov     a,r0
                call    pridaj_chybu
                call    zapis_chybu
                orl     dra_flags,#dm_error
                jmp     da_entry
else
                jmp     dac_sza_lp
endif

dac_no_sza:     orl     dra_flags,#dm_closing
                anl     dra_flags,#not(dm_waiting)
                mov     dvere_a,#d_zatvaraju_sa
                setb    rele_zatvaranie_dveri_a
                mov     a,#t_zatvarania_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_a_timeout
                call    init_timer
                call    init_timer_f
                dw      t_door_a_delay
                db      0,0,75

dac_lp1:        call    do_them
                call    do_door_events_a
                jb      top_reverz_a,dac_reverse
                call    je_trvala_kontrola_zatvarania
                jz      dac_try_sza
                call    tlacitko_zatvarania_dveri
                jz      dac_stop
dac_try_sza:    call    sza
                jz      dac_try_tod
ifn a3_reverzuje
                call    ake_dvere
                clr     acc.0
                jnz     dac_stop
endif
                sjmp    dac_reverse
dac_try_tod:    call    tlacitko_otvarania_dveri
                jnz     dac_reverse
                call    timer_running_f
                dw      t_door_a_timeout
                jnz     dac_try_kvz
                clr     rele_zatvaranie_dveri_a
                mov     error_a,#e_prek_doba_zat
                djnz    c_zatvarani,dac_open
                mov     a,#e_pocet_zatvarani
                call    pridaj_chybu
                call    zapis_chybu
                sjmp    dac_error
dac_try_kvz:    call    timer_running_f
                dw      t_door_a_delay
                jnz     dac_try_a4
                call    je_kvz_dvere_a
                jz      dac_try_a4
                call    kvz_dvere_a
                jnz     dac_closed1
                jmp     dac_lp1
dac_try_a4:     mov     c,a4
                anl     c,/dorovnava_sa
                jc      dac_closed2
                jmp     dac_lp1
dac_reverse:    clr     rele_zatvaranie_dveri_a
                setb    dx_bol_reverz
                djnz    c_reverzov,dac_open
                mov     a,je_poziarna_jazda
                xrl     a,#2
                jz      dac_open
                mov     a,#e_vela_reverzov
                call    pridaj_chybu
                call    zapis_chybu
dac_error:      orl     dra_flags,#dm_error
                jmp     da_entry
dac_stop:       clr     rele_zatvaranie_dveri_a
                jmp     dao_opened
dac_open:       anl     dra_flags,#not(dm_closing)
if cas_medzi_zatvaranim_a_otvaranim
                call    wait_for_timer_f
                dw      t_door_a_timeout
                db      0,0,cas_medzi_zatvaranim_a_otvaranim
endif
                jmp     da_otvaranie

dac_closed1:    clr     rele_zatvaranie_dveri_a
                ; check whether other door is closed
                jnb     su_vobec_dvere_b,dac_skip0
                mov     a,drb_flags
                jnb     db_closed,dac_closed2
dac_skip0:      call    init_timer_f
                dw      t_door_a_timeout
                db      0,3,0
dac_lp2:        call    do_them
                mov     c,a4
                anl     c,/dorovnava_sa
                jc      dac_closed2
                call    timer_running_f
                dw      t_door_a_timeout
                jnz     dac_lp2
                anl     dra_flags,#not(dm_closing)
                mov     a,#e_sachtove_dvere
                call    pridaj_chybu
                call    zapis_chybu
                call    wait_for_timer_f
                dw      t_door_a_timeout
                db      0,5,0
                mov     a,#e_sachtove_dvere
                call    zrus_chybu
                djnz    c_zatvarani,dac_reopen
                mov     a,#e_pocet_zatvarani
                call    pridaj_chybu
                call    zapis_chybu
                jmp     dac_error
dac_reopen:     jmp     da_otvaranie
dac_closed2:    
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dac_original
                anl     mozu_dvere_ab,#not 1
dac_original:
endif
                orl     dra_flags,#dm_closed
                call    wait_for_timer_f
                dw      t_door_a_timeout
                db      0,1,0
                anl     dra_flags,#not(dm_closing)
                clr     rele_zatvaranie_dveri_a
                jmp     da_entry
