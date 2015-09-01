; version 4.0

th_servisna_jazda:
                dw      servisna_jazda, st_servisna_jazda
                db      id_servisna, 0, st_servisna_jazda_size

servisna_jazda: call    do_them
                mov     a,sj_data
                jb      acc.6,sj_end2
                jnb     acc.7,servisna_jazda
                call    je_kvz_dvere_a
                mov     r0,a
                call    je_kvz_dvere_b
                orl     a,r0
                jz      sj_skip1
                call    zapni_zatvaranie_dveri
sj_lp3:         call    init_timer_f
                dw      t_servisna
                db      0,0,75
sj_lp4:         call    do_them
                mov     a,sj_data
                jb      acc.6,sj_end2
                jnb     acc.7,sj_end1
                call    su_obidve_zatvorene
                jz      sj_lp3
                call    timer_running_f
                dw      t_servisna
                jnz     sj_lp4
                sjmp    sj_skip2
sj_skip1:       call    zapni_zatvaranie_dveri
                call    init_timer_f
                dw      t_servisna
                db      0,0,75
sj_lp1:         call    do_them
                mov     a,sj_data
                jb      acc.6,sj_end2
                jnb     acc.7,sj_end1
                call    timer_running_f
                dw      t_servisna
                jnz     sj_lp1
sj_skip2:       call    zapni_zatvaranie_dveri2
                call    start_vytahu
                mov     a,sj_data
                jnb     acc.2,sj_hore
                setb    rele_dole
                sjmp    sj_next
sj_hore:        setb    rele_hore
sj_next:        mov     a,sj_data
                anl     a,#3
                call    zmen_rychlost2
sj_lp2:         call    do_them
                mov     a,sj_data
                jb      acc.6,sj_end2
                jb      acc.7,sj_lp2
sj_end1:        call    nulovanie_rele_a
                jmp     servisna_jazda
sj_end2:        call    nulovanie_rele_a
                jmp     kill_me
