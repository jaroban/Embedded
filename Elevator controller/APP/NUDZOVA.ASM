; version 4.1

th_nudzova:     dw      init_nudzova, st_nudzova
                db      id_nudzova, 0, st_nudzova_size

safety_nudzova: jb      a4,sn_ret
                call    nulovanie_rele_n
                mov     smer,#none
sn_lp1:         call    do_them
                jnb     a4,sn_lp1
                mov     c,hore24
                orl     c,dole24
                jc      sn_lp1
                pop     b
                pop     b
                pop     b
                jmp     nud_main_lp
sn_ret:         ret

init_nudzova:   mov     error_no,#0
                mov     smer,#none
                call    zapni_svetlo
                call    param_fazy
                jz      nud_main_lp
                jb      poradie_faz,nud_main_lp
                call    aky_pohon
                jz      nud_main_lp
                call    su_rele_fazy_baterka
                jz      nud_main_lp
                setb    nezapinaj_fazy
                clr     a
                call    nudzovy_dojazd
                call    wait_for_timer_f
                dw      t_nudzova
                db      0,2,0
                call    param_dorovnavanie
                jnz     nud_skip_ff
                call    param_predotvaranie
                jnz     nud_skip_ff
                setb    rele_10
nud_skip_ff:    mov     a,#1
                call    rele_baterka
                call    wait_for_timer_f
                dw      t_nudzova
                db      0,20,0         ; IKEA

nud_main_lp:    call    do_them
                mov     r0,#lcom_output+1
                mov     @r0,#62
                call    je_nudzova
                jnz     nud_skip1
                jmp     starting_point
nud_skip1:      jnb     a2,nud_main_lp
                call    ake_dvere2
                clr     acc.0
                jz      nud_no_a3
                jnb     a3,nud_main_lp
nud_no_a3:      mov     c,hore24
                orl     c,dole24
                jnc     nud_main_lp
                jb      hore24,nud_hore
                jnb     dole24,nud_main_lp
                jmp     nud_dole

nudh_stop:      call    vypni_zatvaranie_dveri
                jmp     nud_main_lp
nud_hore:       call    su_obidve_zatvorene
                jnz     nudh_skip
                call    zapni_zatvaranie_dveri
nudh_lp0:       call    init_timer_f
                dw      t_nudzova
                db      0,0,75
nudh_lp1:       call    do_them
                jnb     hore24,nudh_stop
                jnb     a2,nudh_stop
                call    su_obidve_zatvorene
                jz      nudh_lp0
                call    timer_running_f
                dw      t_nudzova
                jnz     nudh_lp1
nudh_skip:      jnb     a4,nudh_end
                call    zapni_zatvaranie_dveri2
                mov     smer,#hore
                call    start_vytahu
                setb    rele_hore
                mov     a,#1
                call    nizka_rychlost
nudh_lp2:       call    do_them
                call    safety_nudzova
                jb      dole24,nudh_end
                jb      hore24,nudh_lp2
nudh_end:       call    nulovanie_rele_n
                mov     smer,#none
                jmp     nud_main_lp

nudd_stop:      call    vypni_zatvaranie_dveri
                jmp     nud_main_lp
nud_dole:       call    su_obidve_zatvorene
                jnz     nudd_skip
                call    zapni_zatvaranie_dveri
nudd_lp0:       call    init_timer_f
                dw      t_nudzova
                db      0,0,75
nudd_lp1:       call    do_them
                jnb     dole24,nudd_stop
                jnb     a2,nudd_stop
                call    su_obidve_zatvorene
                jz      nudd_lp0
                call    timer_running_f
                dw      t_nudzova
                jnz     nudd_lp1
nudd_skip:      jnb     a4,nudd_end
                call    zapni_zatvaranie_dveri2
                mov     smer,#dole
                call    start_vytahu
                setb    rele_dole
                mov     a,#1
                call    nizka_rychlost
nudd_lp2:       call    do_them
                call    safety_nudzova
                jb      hore24,nudd_end
                jb      dole24,nudd_lp2
nudd_end:       call    nulovanie_rele_n
                mov     smer,#none
                jmp     nud_main_lp
