; version 4.1

th_door_b:      dw      door_b, st_door_b
                db      id_door_b, os_bits1 or os_bits0, st_door_b_size

                bseg
top_reverz_b:   dbit    1

                dseg
drb_flags:      ds      1
dvere_b:        ds      1
error_b:        ds      1

                cseg
do_door_events_b:
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#door_command
                movx    a,@dptr
                
                jnb     db_open_b,dde_try_open_close_b
                clr     db_open_b
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_zatvaranie_dveri_b
if 0 ; na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dbx_m_o_orig
                mov     a,mozu_dvere_ab
                jb      acc.1,dbx_m_o_orig
                mov     drb_flags,#dm_opened or dm_waited
                jmp     dbn_lp3
dbx_m_o_orig:   
endif
                clr     dx_close
                jmp     db_otvaranie

dde_try_open_close_b:
                jnb     db_open_close_b,dde_try_close_b
                clr     db_open_close_b
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_zatvaranie_dveri_b
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dbx_m_oc_orig
                mov     a,mozu_dvere_ab
                jb      acc.1,dbx_m_oc_orig
                mov     drb_flags,#dm_opened or dm_waited or dm_closed
                jmp     dbn_lp3
dbx_m_oc_orig:
endif
                setb    dx_close
                jmp     db_otvaranie

dde_try_close_b:
                jnb     db_close_b,dde_try_stop_b
                clr     db_close_b
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_otvaranie_dveri_b
if 0 ; na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dbx_m_c_orig
                mov     a,mozu_dvere_ab
                jb      acc.1,dbx_m_c_orig
                mov     drb_flags,#dm_closed
                jmp     dbn_lp3
dbx_m_c_orig:
endif
                setb    dx_close
                jmp     db_zatvaranie

dde_try_stop_b:
                jnb     db_stop_b,dde_ret_b
                clr     db_stop_b
                movx    @dptr,a
                pop     b
                pop     b
                pop     b
                clr     rele_otvaranie_dveri_b
                clr     rele_zatvaranie_dveri_b
                jmp     db_entry

dde_ret_b:      ret

do_door_events_nothing_b:
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#door_command
                movx    a,@dptr
                jbc     db_open_b,dden_open_b
                jbc     db_open_close_b,dden_open_close_b
                jbc     db_close_b,dden_close_b
                jbc     db_stop_b,dden_stop_b
                ret
dden_open_b:    movx    @dptr,a
                mov     drb_flags,#dm_opened or dm_waited
                ret
dden_open_close_b:
                movx    @dptr,a
                mov     drb_flags,#dm_opened or dm_waited or dm_closed
                ret
dden_close_b:   movx    @dptr,a
                mov     drb_flags,#dm_closed
                ret
dden_stop_b:    movx    @dptr,a
                ret

dbn_lp1:        call    do_them
                call    do_door_events_nothing_b
                jmp     dbn_lp1

dbn_lp2:        call    do_them
                call    do_door_events_nothing_b
                call    je_kvz_dvere_b
                jnz     dbn_lp2
                mov     c,rele_zatvaranie_dveri_a
                mov     rele_zatvaranie_dveri_b,c
                jmp     dbn_lp2

door_b:         mov     drb_flags,#0
db_entry:       anl     drb_flags,#not(dm_opening+dm_waiting+dm_closing)
                mov     error_b,#0
                mov     dvere_b,#d_nie_su
                clr     dx_bol_reverz
                mov     c_reverzov,#max_reverzov
                mov     c_zatvarani,#max_zatvarani
                jnb     su_vobec_dvere_b,dbn_lp1
                mov     a,my_liftpos
                call    su_dvere_b
                jz      dbn_lp2

dbn_lp3:        call    do_them
                call    do_door_events_b
                jmp     dbn_lp3

dbo_opened_:    jmp     dbo_opened
db_otvaranie:   mov     a,liftsub
                clr     c
                subb    a,#3
                jnc     dbo_opened_
                jb      zakaz_pohon,dbo_opened_
                mov     dvere_b,#d_otvaraju_sa

                setb    rele_otvaranie_dveri_b
                mov     a,#t_otvarania_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_b_timeout
                call    init_timer
                call    init_timer_f
                dw      t_door_b_delay
                db      0,0,75
                orl     drb_flags,#dm_opening

dbo_lp1:        call    do_them
                call    do_door_events_b
                call    je_trvala_kontrola_zatvarania
                jz      dbo_normal
                call    tlacitko_otvarania_dveri
                jnz     dbo_skip0
dbo_normal:     ;call    tlacitko_zatvarania_dveri
                ;jnz     dbo_opened
dbo_skip0:      call    timer_running_f
                dw      t_door_b_timeout
                jnz     dbo_try_kvo
                mov     error_b,#e_prek_doba_otv
                sjmp    dbo_opened
dbo_try_kvo:    call    timer_running_f
                dw      t_door_b_delay
                jnz     dbo_lp1
                call    kvo_dvere
                jz      dbo_lp1

dbo_opened:     clr     rele_otvaranie_dveri_b
ifn maz_volby_neskor
                call    vymaz_tu_volby
endif
                clr     top_reverz_b
                mov     dvere_b,#d_cakaju
                mov     drb_flags,#dm_opened
                mov     a,#t_otvorenych_dveri
                jnb     dx_bol_reverz,dbo_skip1
                mov     a,#t_cod_po_reverze
dbo_skip1:      call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_b_timeout
                call    init_timer
                orl     drb_flags,#dm_waiting

dbw_lp1:        call    do_them
                call    do_door_events_b
                ;jb      top_reverz_b,dbw_open
                call    tlacitko_zatvarania_dveri
                jnz     dbw_waited
                call    je_trvala_kontrola_zatvarania
                jz      dbw_normal
                call    tlacitko_otvarania_dveri
                jz      dbw_lp1
dbw_open:       jmp     db_otvaranie
dbw_normal:     jb      dorovnava_sa,dbw_lp1
                call    timer_running_f
                dw      t_door_b_timeout
                jnz     dbw_lp1
dbw_waited:     mov     drb_flags,#dm_opened+dm_waited
if maz_volby_neskor
                call    vymaz_tu_volby
                clr     top_reverz_b
endif
                jb      dx_close,db_zatvaranie
                jmp     db_entry

db_zatvaranie:  anl     drb_flags,#not(dm_closing)

dbc_pred_again: jnb     ovazenie_10,dbc_sza
                call    je_nejaka_prednost
                jz      dbc_sza
dbc_pred_lp:    call    do_them
                call    do_door_events_b
                call    je_nejaka_prednost
                jz      dbc_sza
                jb      ovazenie_10,dbc_pred_lp

                mov     a,#t_otvorenych_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_b_timeout
                call    wait_for_timer
                jmp     dbc_pred_again

dbc_sza:        call    szb_r
                jz      dbc_no_sza
                mov     dvere_b,#d_svetelna_zavora
if vyhodnocovat_chybu_sza
                call    init_timer_f
                dw      t_door_b_timeout
                db      1,0,0
endif
dbc_sza_lp:     call    do_them
                call    do_door_events_b
                call    szb_r
                jz      dbc_no_sza
if vyhodnocovat_chybu_sza
                call    timer_running_f
                dw      t_door_b_timeout
                jnz     dbc_sza_lp
                call    ake_dvere
                clr     acc.0
                mov     r0,#e_svetelna_zavora
                jz      dbc_sza_auto
                mov     r0,#e_blokovanie_dveri
dbc_sza_auto:   mov     a,r0
                call    pridaj_chybu
                call    zapis_chybu
                orl     drb_flags,#dm_error
                jmp     db_entry
else
                jmp     dbc_sza_lp
endif

dbc_no_sza:     orl     drb_flags,#dm_closing
                anl     drb_flags,#not(dm_waiting)
                mov     dvere_b,#d_zatvaraju_sa
                setb    rele_zatvaranie_dveri_b
                mov     a,#t_zatvarania_dveri
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_door_b_timeout
                call    init_timer
                call    init_timer_f
                dw      t_door_b_delay
                db      0,0,75

dbc_lp1:        call    do_them
                call    do_door_events_b
                jb      top_reverz_b,dbc_reverse
                call    je_trvala_kontrola_zatvarania
                jz      dbc_try_sza
                call    tlacitko_zatvarania_dveri
                jz      dbc_stop
dbc_try_sza:    call    szb
                jz      dbc_try_tod
ifn a3_reverzuje
                call    ake_dvere
                clr     acc.0
                jnz     dbc_stop
endif
                sjmp    dbc_reverse
dbc_try_tod:    call    tlacitko_otvarania_dveri
                jnz     dbc_reverse
                call    timer_running_f
                dw      t_door_b_timeout
                jnz     dbc_try_kvz
                clr     rele_zatvaranie_dveri_b
                mov     error_b,#e_prek_doba_zat
                djnz    c_zatvarani,dbc_open
                mov     a,#e_pocet_zatvarani
                call    pridaj_chybu
                call    zapis_chybu
                sjmp    dbc_error
dbc_try_kvz:    call    timer_running_f
                dw      t_door_b_delay
                jnz     dbc_try_a4
                call    je_kvz_dvere_b
                jz      dbc_try_a4
                call    kvz_dvere_b
                jnz     dbc_closed1
                jmp     dbc_lp1
dbc_try_a4:     mov     c,a4
                anl     c,/dorovnava_sa
                jc      dbc_closed2
                jmp     dbc_lp1
dbc_reverse:    clr     rele_zatvaranie_dveri_b
                setb    dx_bol_reverz
                djnz    c_reverzov,dbc_open
                mov     a,je_poziarna_jazda
                xrl     a,#2
                jz      dbc_open
                mov     a,#e_vela_reverzov
                call    pridaj_chybu
                call    zapis_chybu
dbc_error:      orl     drb_flags,#dm_error
                jmp     db_entry
dbc_stop:       clr     rele_zatvaranie_dveri_b
                jmp     dbo_opened
dbc_open:       anl     drb_flags,#not(dm_closing)
if cas_medzi_zatvaranim_a_otvaranim
                call    wait_for_timer_f
                dw      t_door_b_timeout
                db      0,0,cas_medzi_zatvaranim_a_otvaranim
endif
                jmp     db_otvaranie

dbc_closed1:    clr     rele_zatvaranie_dveri_b
                ; check whether other door is closed
                jnb     su_vobec_dvere_a,dbc_skip0
                mov     a,dra_flags
                jnb     db_closed,dbc_closed2
dbc_skip0:      call    init_timer_f
                dw      t_door_b_timeout
                db      0,3,0
dbc_lp2:        call    do_them
                mov     c,a4
                anl     c,/dorovnava_sa
                jc      dbc_closed2
                call    timer_running_f
                dw      t_door_b_timeout
                jnz     dbc_lp2
                anl     drb_flags,#not(dm_closing)
                mov     a,#e_sachtove_dvere
                call    pridaj_chybu
                call    zapis_chybu
                call    wait_for_timer_f
                dw      t_door_b_timeout
                db      0,5,0
                mov     a,#e_sachtove_dvere
                call    zrus_chybu
                djnz    c_zatvarani,dbc_reopen
                mov     a,#e_pocet_zatvarani
                call    pridaj_chybu
                call    zapis_chybu
                jmp     dbc_error
dbc_reopen:     jmp     db_otvaranie
dbc_closed2:    
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     dbc_original
                anl     mozu_dvere_ab,#not 2
dbc_original:
endif
                orl     drb_flags,#dm_closed
                call    wait_for_timer_f
                dw      t_door_b_timeout
                db      0,1,0
                anl     drb_flags,#not(dm_closing)
                clr     rele_zatvaranie_dveri_b
                jmp     db_entry
