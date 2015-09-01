; version 3.0

th_predotvaranie:
                dw      predotvaranie, st_predotvaranie
                db      id_predotvaranie, 0, st_predotvaranie_size

predotvaranie_disable:
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      0

predotvaranie:  setb    rele_10
                call    init_timer_f
                dw      t_predotvaranie
                db      0,0,80
pr_lp0:         call    do_them
                call    get_jazda_skoncila
                jb      acc.1,pr_lp1
                jnb     kontrola_mpd,pr_skip1
                call    timer_running_f
                dw      t_predotvaranie
                jnz     pr_lp0
                call    nulovanie_rele_p
                sjmp    pr_mpd

pr_skip1:       call    vypni_zatvaranie_dveri
                call    zapni_otvaranie_dveri2
pr_lp1:         call    do_them
                call    get_jazda_skoncila
                jb      acc.1,pr_skip2
                jb      a4,pr_lp1
                call    nulovanie_rele_p
                sjmp    pr_mpd

pr_skip2:       call    nulovanie_rele_p        ; turns off rele_10 as well
                call    gong_zastavenie
                call    init_timer_f
                dw      t_predotvaranie
                db      0,0,80
pr_lp2:         call    do_them
                jb      kontrola_mpd,pr_mpd_ok
                call    timer_running_f
                dw      t_predotvaranie
                jnz     pr_lp2
pr_mpd:         mov     a,#e_porucha_mpd
                call    pridaj_chybu
                call    zapis_chybu
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#predotvaranie_disable
                call    kill_em
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                clr     rele_svetlo
                call    dx_spusti_a_otvor_dvere
pr_mpd_ok:      jmp     kill_me
