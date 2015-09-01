; version 4.0

th_dorovnavanie:
                dw      dorovnavanie, st_dorovnavanie
                db      id_dorovnavanie, 0, st_dorovnavanie_size

dorovnavanie_disable:
                db      id_servisna
                db      id_zrovnavacia
                db      id_normalna
                db      id_go_up
                db      id_go_down
                db      id_stopped
                db      id_door_a
                db      id_door_b
                db      0

dorovnavanie:   clr     dorovnava_sa
                call    param_dorovnavanie
                jnz     drv_lp1
                jmp     kill_me
drv_lp1:        call    do_them
                jnb     mozes_dorovnavat,drv_lp1
                jnb     a2,drv_lp1
                call    je_c
                jz      drv_lp1
                call    je_a_aj_b
                jnz     drv_lp1
                mov     a,dra_flags
                orl     a,drb_flags
                jb      db_closing,drv_lp1
                setb    dorovnava_sa
                setb    rele_10
                call    wait_for_timer_f
                dw      t_dorovnavanie
                db      0,0,50      ; cas po zap. K10
                call    init_timer_f
                dw      t_dorovnavanie
                db      0,3,0
drv_lp1_5:      call    do_them
                jb      a4,drv_decide
                call    timer_running_f
                dw      t_dorovnavanie
                jz      drv_error2_
                mov     a,snimace
                anl     a,#c_mask+ba_mask
                cjne    a,#c_mask+ba_mask,drv_lp1_5
                clr     rele_10
                sjmp    drv_done
drv_error2_:    jmp     drv_error2
drv_decide:     call    start_vytahu_bez_svetla
                mov     a,snimace
                anl     a,#c_mask+ba_mask
                xrl     a,#c_mask+b_
                jz      drv_hore
                mov     a,snimace
                anl     a,#c_mask+ba_mask
                cjne    a,#c_mask+_a,drv_end
                setb    rele_dole
                clr     liftdir
                sjmp    drv_skip1
drv_hore:       setb    rele_hore
                setb    liftdir
drv_skip1:      call    init_timer_f
                dw      t_dorovnavanie
                db      0,12,0
                mov     a,#1
                call    nizka_rychlost
drv_lp2:        call    do_them
                jnb     a2,drv_stop
                jnb     a4,drv_error2
                call    timer_running_f
                dw      t_dorovnavanie
                jz      drv_error1
                call    je_c
                jz      drv_stop
                call    je_a_alebo_b
                jz      drv_stop
                call    je_a_aj_b
                jz      drv_lp2
drv_end:        clr     liftdir
                mov     a,#t_oneskorenie_ab
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_dorovnavanie
                call    wait_for_timer
                call    nulovanie_rele_s
                call    wait_for_timer_f
                dw      t_dorovnavanie
                db      0,0,80        ; cas po vyp. K10
drv_done:       jnb     kontrola_mpd,drv_error2
                clr     dorovnava_sa
                jmp     drv_lp1
drv_stop:       call    nulovanie_rele_s
                clr     dorovnava_sa
                jmp     drv_lp1
                
drv_error1:     mov     a,#e_doba_dorovnavania
                call    pridaj_chybu
                call    zapis_chybu
                sjmp    drv_error3
drv_error2:     mov     a,#e_porucha_mpd
                call    pridaj_chybu
                call    zapis_chybu
drv_error3:     mov     dptr,#dorovnavanie_disable
                call    kill_em
                call    nulovanie_rele_s
                setb    blokuj_volby
                call    vymaz_volby
                mov     smer,#both_blink
                call    zapni_svetlo
                clr     dorovnava_sa
                call    dx_spusti_a_otvor_dvere
                jmp     kill_me
