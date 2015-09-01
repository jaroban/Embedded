; version 4.1

th_safety:      dw      basic_safety, st_safety
                db      id_safety, os_bits0, st_safety_size

was_a4_a5       bit     0
oa1             bit     1
uz_je_chyba_kb  bit     2

revizna_disable:
                db      id_nudzova
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      id_dorovnavanie
                db      id_predotvaranie
                db      id_door_a
                db      id_door_b
                db      0

nudzova_disable:
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      id_dorovnavanie
                db      id_predotvaranie
                db      id_door_a
                db      id_door_b
                db      0

a1_disable:     db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      id_dorovnavanie
                db      id_predotvaranie
                db      id_door_a
                db      id_door_b
                db      0

fazy_disable:   db      id_revizna
                db      id_nudzova
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      id_dorovnavanie
                db      id_predotvaranie
                db      id_door_a
                db      id_door_b
                db      0

is_a4_a5:       call    kontrola_modulu_c
                mov     c,a4
                jnz     iaa_skip1
                cpl     c
iaa_skip1:      jc      iaa_skip2
                jbc     was_a4_a5,iaa_reset
                mov     dps,#0
                mov     dptr,#t_a4_a5_delay
                jmp     timer_running
iaa_reset:      call    init_timer_f
                dw      t_a4_a5_delay
                db      0,2,0    
                sjmp    iaa_yes
iaa_skip2:      setb    was_a4_a5
iaa_yes:        mov     a,#0ffh
                ret

bs_ozivenie:    call    je_ozivenie2
                jz      bso_ret
                jb      uz_je_zakapanie,bso_uz_je
                ; mozeme zakapat takto
                jb      zakapanie,bso_po_resete
if dva_kontakty_sachtove_dvere
                call    ozivenie2
else
                jnb     a3,bso_its_off
                jb      a4,bso_its_off
                call    ozivenie2
endif
                jz      bso_its_on
                ; it's ok
bso_its_off:    call    init_timer_f
                dw      t_delay_a5
                db      0,0,50
                ret
bso_its_on:     ; not in bottom station
ifn dva_kontakty_sachtove_dvere
                call    je_dolny
                jnz     bso_ret
endif
                ; check time
                call    timer_running_f
                dw      t_delay_a5
                jnz     bso_ret
                ; time up
                setb    uz_je_zakapanie
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#nudzova_disable
                call    kill_em
                call    nulovanie_rele_t
                setb    blokuj_volby
                call    vymaz_volby
                ; store bit
                setb    zakapanie
                call    output_zakapanie
                jmp     zapis_zakapanie
bso_po_resete:  setb    uz_je_zakapanie
                jmp     output_zakapanie
bso_ret:        ret
bso_uz_je:      call    je_ozivenie
                jz      bso_ret
                jnb     a2,bso_ret
                jb      uz_je_revizna,bso_ret
                call    ozivenie
                jz      bso_ret
                ; vstup je aktivovany
                clr     zakapanie
                clr     uz_je_zakapanie
                call    output_zakapanie
                call    zapis_zakapanie
                call    wait_for_timer_f
                dw      t_nd
                db      0,0,50
                jmp     starting_point
                
reset_npk_timer:
                call    init_timer_f
                dw      t_kontrola_npk
                db      0,1,0
                ret
if hydraulika_a3
reset_hydraulika_timer:
                call    init_timer_f
                dw      t_kontrola_brzdy
                db      0,2,0
bcn_ret2:       ret
else
reset_kontrola_brzdy_timer:
                call    init_timer_f
                dw      t_kontrola_brzdy
                db      0,3,0
                ret

rele_jazda_kontrola_brzdy:
                ; must preserve acc
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#kb_expected
                movx    @dptr,a
bcn_ret2:       ret
endif

bs_check_kb:    jb      uz_je_chyba_kb,bcn_ret2
                jb      uz_je_nudzova,bcn_ret2
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#kb_die_soon
                movx    a,@dptr
                jnz     bs_kb_try_dying
                ; modul npk
                call    je_modul_npk
                jz      bs_npk_ok
                call    modul_npk
                jnz     bs_npk_reset_timer
                call    timer_running_f
                dw      t_kontrola_npk
                jnz     bs_npk_ok
                ; chyba npk
                mov     a,#e_modul_npk
                sjmp    bs_kb_kaputt
bs_npk_reset_timer:
                call    reset_npk_timer
bs_npk_ok:      
if hydraulika_a3
                call    je_hydraulika_rdy
                jz      bcn_ret
                call    je_hydraulika_run
                jz      bcn_ret

                call    hydraulika_rdy
                jz      bs_hyd_exp1
bs_hyd_exp0:    call    hydraulika_run
                jz      bs_hyd_ok
                sjmp    bs_hyd_bad
bs_hyd_exp1:    call    hydraulika_run
                jnz     bs_hyd_ok
bs_hyd_bad:     call    timer_running_f
                dw      t_kontrola_brzdy
                jnz     bcn_ret
                ; kaputt
                call    hydraulika_run
                jz      bs_hyd_zdochnutie
                mov     a,#e_porucha_rdy
                sjmp    bs_kb_kaputt
bs_hyd_zdochnutie:
                mov     a,#e_porucha_run
                call    pridaj_chybu
                call    zapis_chybu
                sjmp    bs_kb_zdochnutie
bs_hyd_ok:      call    reset_hydraulika_timer
                sjmp    bcn_ret
else
                call    je_kontrola_brzdy1
                mov     b,a
                call    je_kontrola_brzdy2
                orl     a,b
                jz      bcn_ret

                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#kb_expected
                movx    a,@dptr
                jz      bs_kb_all_zeroes
bs_kb_all_ones:
                call    je_kontrola_brzdy1
                jz      bcn_kb_1_try2
                call    kontrola_brzdy1
                jz      bs_kb_bad1

bcn_kb_1_try2:  call    je_kontrola_brzdy2
                jz      bc_kb_good
                call    kontrola_brzdy2
                jz      bs_kb_bad2
                sjmp    bc_kb_good
                
bs_kb_all_zeroes:
                call    je_kontrola_brzdy1
                jz      bcn_kb_0_try2
                call    kontrola_brzdy1
                jnz     bs_kb_bad1

bcn_kb_0_try2:  call    je_kontrola_brzdy2
                jz      bc_kb_good
                call    kontrola_brzdy2
                jnz     bs_kb_bad2
;               sjmp    bc_kb_good
               
bc_kb_good:     jmp     reset_kontrola_brzdy_timer

bs_kb_bad1:     call    timer_running_f
                dw      t_kontrola_brzdy
                jnz     bcn_ret
                mov     a,#e_kontrola_brzdy1
                sjmp    bs_kb_kaputt
                
bs_kb_bad2:     call    timer_running_f
                dw      t_kontrola_brzdy
                jnz     bcn_ret
                mov     a,#e_kontrola_brzdy2
;               sjmp    bs_kb_kaputt
endif
bs_kb_kaputt:   call    pridaj_chybu
                call    zapis_chybu

                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#kb_die_soon
                mov     a,#0ffh
                movx    @dptr,a
bs_kb_try_dying:
                ; kedy mozeme zdochnut kontrolu brzdy
                mov     a,liftsub
                clr     c
                subb    a,#3
                jnc     bcn_ret
                jb      rele_hore,bcn_ret
                jb      rele_dole,bcn_ret
bs_kb_zdochnutie:
                mov     dptr,#revizna_disable
                call    kill_em
                call    nulovanie_rele_t
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                setb    uz_je_chyba_kb
                jmp     bs_otvorit_a_zdochnut
bcn_ret:        ret
                
bs_revizna:     mov     c,revizna_jazda
                anl     c,/uz_je_revizna
                jnc     bsr_try
                setb    uz_je_revizna
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#revizna_disable
                call    kill_em
                call    nulovanie_rele_t
                setb    blokuj_volby
                call    vymaz_volby
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_revizna
                jmp     run_it
bsr_try:        mov     c,uz_je_revizna
                anl     c,/revizna_jazda
                jnc     bsr_ret
                clr     uz_je_revizna
bsr_ret:        ret

bs_nudzova:     call    aka_nahrada
                jnz     bsn_ret
                mov     c,nudzova_jazda
                call    inverzia_nud
                jz      bsn_skip
                cpl     c
bsn_skip:       anl     c,/uz_je_nudzova
                anl     c,/uz_je_revizna
                jnc     bsn_ret
                setb    uz_je_nudzova
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#nudzova_disable
                call    kill_em
                call    nulovanie_rele_t
                setb    blokuj_volby
                call    vymaz_volby
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_nudzova
                jmp     run_it
bsn_ret:        ret

bs_a1:          jb      a1,bsa_1
                jbc     oa1,bsa_start
                call    timer_running_f
                dw      t_delay_a1
                jnz     bsa_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#a1_disable
                call    kill_em
                call    nulovanie_rele
                mov     a,#e_strata_a1
                call    pridaj_chybu
                call    zapis_chybu
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                call    wait_for_timer_f
                dw      t_nd
                db      0,1,0
                call    param_fazy
                jz      bsa_zdoch1
                jb      poradie_faz,bsa_zdoch1

                call    dx_spusti_a_otvor_dvere
bs_zdoch2_lp:   call    do_them
                call    bs_revizna
                call    bs_check_kb
                call    bs_nudzova
                jnb     poradie_faz,bs_zdoch2_lp
                jmp     starting_point

bsa_zdoch1:     jmp     bs_otvorit_a_zdochnut
bsa_start:      call    init_timer_f
                dw      t_delay_a1
                db      0,1,0
                ret
bsa_1:          setb    oa1
bsa_ret:        ret

bsf_ret:        ret
bs_fazy:        call    param_fazy
                jz      bsf_ret
                jb      poradie_faz,bsf_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#fazy_disable
                call    kill_em
                call    nulovanie_rele
                mov     a,#e_poradie_faz
                call    pridaj_chybu
                call    zapis_chybu
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                mov     c,uz_je_revizna
                orl     c,uz_je_nudzova
                jc      bsf_skip1
                call    je_nudzovy_dojazd
                jz      bsf_skip1
                call    aky_pohon
                jnz     bsf_skip0
                jmp     bsf_nd_hydraulicky

bsf_skip0:      call    dojazd_do
                jnz     bsf_skip2
                call    je_a_aj_b
                jz      bsf_skip2
bsf_skip1:      jmp     bsf_nd_done

bsf_skip2:      mov     a,#e_nudzovy_dojazd
                call    pridaj_chybu
                setb    nezapinaj_fazy
                clr     a
                call    nudzovy_dojazd
                call    wait_for_timer_f
                dw      t_nd
                db      0,cas_na_rele_baterka,0
                mov     a,#1
                call    rele_baterka
                call    wait_for_timer_f
                dw      t_nd
                db      0,20,0     ; IKEA, was: 1s
if nudzovy_dojazd_rele_10
                call    param_dorovnavanie
                jnz     bsf_skip3
                call    param_predotvaranie
                jnz     bsf_skip3
                setb    rele_10
                call    wait_for_timer_f
                dw      t_nd
                db      0,2,0
endif
bsf_skip3:      call    zapni_zatvaranie_dveri2
                call    dojazd_do
                jz      bsf_skip4
                dec     a
                mov     nextfloor,a
                xrl     a,my_liftpos
                jnz     bsf_diff
                mov     a,liftsub
                xrl     a,#1
                jnz     bsf_diff
                jmp     bsf_nd_ok
bsf_skip4:      jmp     bsf_nd_do_najblizsej

bsf_diff:       mov     a,nextfloor
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
                jnc     bsf_go_dn
                jb      liftdir,bsf_up_ok
                setb    liftdir
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      bsf_up_typ_0
                cjne    a,#2,bsf_up_typ_1
                mov     a,liftsub
                clr     c
                subb    a,#5
                jc      bsf_up_ok
                subb    a,#6
                jnc     bsf_up_ok
                inc     liftpos
                sjmp    bsf_up_ok
bsf_up_typ_1:   mov     a,liftsub
                clr     c
                subb    a,#5
                jc      bsf_up_ok
                subb    a,#6
                jnc     bsf_up_ok
                sjmp    bsf_up_change
bsf_up_typ_0:   mov     a,liftsub
                cjne    a,#3,bsf_up_ok
bsf_up_change:  dec     liftpos
bsf_up_ok:      jmp     bsf_drain

bsf_go_dn:      jnb     liftdir,bsf_dn_ok
                clr     liftdir
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      bsf_dn_typ_0
                cjne    a,#2,bsf_dn_typ_1
                mov     a,liftsub
                clr     c
                subb    a,#5
                jc      bsf_dn_ok
                subb    a,#6
                jnc     bsf_dn_ok
                dec     liftpos
                sjmp    bsf_dn_ok
bsf_dn_typ_1:   mov     a,liftsub
                clr     c
                subb    a,#5
                jc      bsf_dn_ok
                subb    a,#6
                jnc     bsf_dn_ok
                sjmp    bsf_dn_change
bsf_dn_typ_0:   mov     a,liftsub
                cjne    a,#3,bsf_dn_ok
bsf_dn_change:  inc     liftpos
bsf_dn_ok:      jmp     bsf_drain

bsf_drain:      call    start_vytahu
                jb      liftdir,bsf_hore
                setb    rele_dole
                clr     rele_hore
                mov     smer,#dole_blink
                sjmp    bsf_drain2

bsf_hore:       clr     rele_dole
                setb    rele_hore
                mov     smer,#hore_blink

bsf_drain2:     mov     a,#1
                call    nizka_rychlost
                call    init_timer_f
                dw      t_doba_nudz
                db      5,0,0
bsf_nd_lp:      call    do_them
                call    bs_a1
                call    bs_a4_a5
                call    timer_running_f
                dw      t_doba_nudz
                jz      bsf_nd_ok
                call    je_nudzova
                jnz     bsf_nd_ok
                mov     a,ac_rd
                anl     a,#0fh
                xrl     a,#0fh
                jnz     bsf_nd_error
                call    update_liftpos
                mov     a,my_liftpos
                cjne    a,nextfloor,bsf_nd_lp
                mov     a,liftsub
                cjne    a,#1,bsf_nd_lp
                jmp     bsf_nd_ok

bsf_nd_do_najblizsej:
                call    start_vytahu
if dojazd_do_najblizsej
                setb    rele_hore
                mov     smer,#hore_blink
else
                setb    rele_dole
                mov     smer,#dole_blink
endif
                mov     a,#1
                call    nizka_rychlost
                call    init_timer_f
                dw      t_doba_nudz
                db      5,0,0
bsf_nd_lp2:     call    do_them
                call    bs_a1
                call    bs_a4_a5
                call    je_a_aj_b
                jnz     bsf_nd_ok
                call    timer_running_f
                dw      t_doba_nudz
                jz      bsf_nd_ok
                call    je_nudzova
                jnz     bsf_nd_ok
                mov     a,ac_rd
                anl     a,#0fh
                xrl     a,#0fh
                jz      bsf_nd_lp2
bsf_nd_error:   call    nulovanie_rele
                mov     smer,#none
bsf_nd_e_lp:    call    do_them
                mov     a,ac_rd
                anl     a,#0fh
                xrl     a,#0fh
                jnz     bsf_nd_e_lp
                jmp     bsf_skip0   ; try again

bsf_nd_ok:      call    nulovanie_rele
                mov     smer,#none
bsf_nd_done:    call    zapni_otvaranie_dveri
                call    wait_for_timer_f
                dw      t_nd
                db      0,10,0
                call    vypni_otvaranie_dveri
                clr     uz_je_nudzova
bsf_lp1:        call    do_them
                call    bs_a1
                call    bs_a4_a5
                call    bs_nudzova
                jnb     poradie_faz,bsf_lp1
                jmp     starting_point

bsf_nd_hydraulicky:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_zrovnavacia
                call    run_it
bsf_lp2:        call    do_them
                call    bs_a1
                call    bs_a4_a5
                jnb     poradie_faz,bsf_lp2
                jmp     starting_point

bs_a4_a5:       call    je_kontrola_modulu_c
                jz      bsaa_ret
                call    is_a4_a5
                jnz     bsaa_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#a1_disable
                call    kill_em
                call    nulovanie_rele
                mov     a,#e_porucha_modulu_c
                call    pridaj_chybu
                call    zapis_chybu
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                
                ; open doors
                call    zapni_otvaranie_dveri2
                call    wait_for_timer_f
                dw      t_nd
                db      0,10,0
                call    vypni_otvaranie_dveri
                
                call    wait_for_timer_f
                dw      t_nd
                db      0,1,0
                
                ; check a4 a5
                call    is_a4_a5
                jnz     bsaa_skip1
                jmp     bs_zdochnut_lp
bsaa_skip1:
                ; close doors
                call    dx_spusti_a_zatvor_dvere
bsaa_lp1:       call    do_them
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_closed,bsaa_lp1

                ; check a4 a5
                call    is_a4_a5
                jnz     bsaa_skip2
                call    dx_open_doors
                jmp     bs_zdochnut_lp
bsaa_skip2:
                ; reset
                jmp     starting_point
bsaa_ret:       ret

basic_safety:   setb    oa1
                clr     nezapinaj_fazy
                setb    was_a4_a5
                clr     uz_je_chyba_kb
                clr     uz_je_revizna
                clr     uz_je_nudzova
                clr     uz_je_zakapanie
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#kb_die_soon
                movx    @dptr,a
                call    reset_npk_timer
if hydraulika_a3
                call    reset_hydraulika_timer
else
                call    reset_kontrola_brzdy_timer
                clr     a
                call    rele_jazda_kontrola_brzdy
endif
                call    init_timer_f
                dw      t_delay_a5
                db      0,1,0
                call    param_fazy
                jz      bs_skip_ok
                jb      poradie_faz,bs_skip_ok
                call    aky_pohon
                jz      bs_wait_lp2
                call    su_rele_fazy_baterka
                jz      bs_wait_lp2
bs_wait_lp1:    call    do_them
                jb      poradie_faz,bs_skip_ok
                call    bs_nudzova
                jnb     uz_je_nudzova,bs_wait_lp1
bs_main_lp1:    call    do_them
                call    bs_a4_a5
                jmp     bs_main_lp1

bs_wait_lp2:    call    do_them
                jnb     poradie_faz,bs_wait_lp2
bs_skip_ok:     call    bs_nudzova
                call    bs_revizna
                call    bs_check_kb
                call    bs_ozivenie
                call    bs_fazy
                call    bs_a1
                call    bs_a4_a5
                mov     c,uz_je_revizna
                orl     c,uz_je_nudzova
                orl     c,uz_je_zakapanie
                jc      bs_main_lp2
                call    wait_for_timer_f
                dw      t_nd
                db      0,3,0
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_zrovnavacia
                call    run_it
bs_main_lp2:    call    do_them
                call    bs_revizna
                call    bs_check_kb
                call    bs_nudzova
                call    bs_ozivenie
                call    bs_fazy
                call    bs_a1
                call    bs_a4_a5
                jmp     bs_main_lp2

bs_otvorit_a_zdochnut:
                call    dx_spusti_a_otvor_dvere
bs_zdochnut_lp: call    do_them
                call    bs_revizna
                call    bs_check_kb
                call    bs_nudzova
                call    bs_ozivenie
                jmp     bs_zdochnut_lp
