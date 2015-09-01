; version 4.1

set_jazda_skoncila:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#jazda_skoncila
                movx    @dptr,a
                ret
                
get_jazda_skoncila:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#jazda_skoncila
                movx    a,@dptr
                ret
                
th_go_up:       dw      go_up, st_go_up_down
                db      id_go_up, 0, st_go_up_down_size

go_up:          clr     je_predotvaranie
                mov     liftstate,#s_jazda_hore
                mov     a,nextfloor
                clr     c
                subb    a,my_liftpos
                jnc     gu_skip1
                jmp     gu_ret
gu_skip1:       jnz     gu_skip2
                mov     a,liftsub
                clr     c
                subb    a,#1
                jc      gu_skip2
                jmp     gu_ret
gu_skip2:       call    zapni_zatvaranie_dveri2
                setb    liftdir
                call    start_vytahu
                setb    rele_hore
                call    brzdit_par_hore
                jnz     gu_low
                call    brzdit_vys_hore
                jnz     gu_param

gu_high:        clr     a
                call    zmen_rychlost

gu_high_lp:     call    do_them
                call    brzdit_vys_hore
                jz      gu_high_lp

gu_param:       mov     a,nextfloor
                dec     a
                call    rychlost_z_poschodia
                call    zmen_rychlost

gu_param_lp:    call    do_them
                call    brzdit_par_hore
                jz      gu_param_lp

gu_low:         
ifn bez_volby_stop
                mov     a,nextfloor
                call    vymaz_kabina
endif
                mov     a,nextfloor
                call    vymaz_hore
ifn maz_obidve_vonkajsie
                call    nejaka_nad
                jnz     gu_low_skip1
endif
                mov     a,nextfloor
                call    vymaz_dole
gu_low_skip1:   call    ake_riadenie
                cjne    a,#2,gu_low_skip4
                ; simplex bez dveri
                call    vymaz_kabinove
                mov     dr_state,#dr_nic
gu_low_skip4:   call    gong_vysoka
                mov     a,#2
                call    zmen_rychlost

                ; nizka rychlost
gu_low_lp:      call    do_them

                ; predotvaranie
                call    param_predotvaranie
                jz      gu_low_skip2
                jb      je_predotvaranie,gu_low_skip2
                call    je_a_alebo_b
                jz      gu_low_skip2
                call    je_c
                jz      gu_low_skip2
                setb    je_predotvaranie
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_predotvaranie
                call    run_it
                
gu_low_skip2:   call    brzdit_niz_hore
                jz      gu_low_lp
                mov     a,#t_oneskorenie_ab
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_moving
                call    wait_for_timer
                jb      je_predotvaranie,gu_ret
                mov     a,#1
                call    set_jazda_skoncila
                call    nulovanie_rele
                call    gong_zastavenie
gu_ret:         mov     a,#3
                call    set_jazda_skoncila
                call    set_inc_data
                jmp     kill_me

th_go_down:     dw      go_down, st_go_up_down
                db      id_go_down, 0, st_go_up_down_size

go_down:        clr     je_predotvaranie
                mov     liftstate,#s_jazda_dole
                mov     a,my_liftpos
                clr     c
                subb    a,nextfloor
                jnc     gd_skip1
                jmp     gd_ret
gd_skip1:       jnz     gd_skip2
                mov     a,#1
                clr     c
                subb    a,liftsub
                jc      gd_skip2
                jmp     gd_ret
gd_skip2:       call    zapni_zatvaranie_dveri2
                clr     liftdir
                call    start_vytahu
                setb    rele_dole
                call    brzdit_par_dole
                jnz     gd_low
                call    brzdit_vys_dole
                jnz     gd_param

gd_high:        clr     a
                call    zmen_rychlost

gd_high_lp:     call    do_them
                call    brzdit_vys_dole
                jz      gd_high_lp

gd_param:       mov     a,nextfloor
                call    rychlost_z_poschodia
                call    zmen_rychlost

gd_param_lp:    call    do_them
                call    brzdit_par_dole
                jz      gd_param_lp

gd_low:         
ifn bez_volby_stop
                mov     a,nextfloor
                call    vymaz_kabina
endif
                mov     a,nextfloor
                call    vymaz_dole
ifn maz_obidve_vonkajsie
                call    nejaka_pod
                jnz     gd_low_skip1
endif
                mov     a,nextfloor
                call    vymaz_hore
gd_low_skip1:   call    ake_riadenie
                cjne    a,#2,gd_low_skip4
                ; simplex bez dveri
                call    vymaz_kabinove
                mov     dr_state,#dr_nic
gd_low_skip4:   call    gong_vysoka
                mov     a,#2
                call    zmen_rychlost
                
                ; nizka rychlost
gd_low_lp:      call    do_them

                ; predotvaranie
                call    param_predotvaranie
                jz      gd_low_skip2
                jb      je_predotvaranie,gd_low_skip2
                call    je_a_alebo_b
                jz      gd_low_skip2
                call    je_c
                jz      gd_low_skip2
                setb    je_predotvaranie
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_predotvaranie
                call    run_it
                
gd_low_skip2:   call    brzdit_niz_dole
                jz      gd_low_lp
                mov     a,#t_oneskorenie_ab
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_moving
                call    wait_for_timer
                jb      je_predotvaranie,gd_ret
                mov     a,#1
                call    set_jazda_skoncila
                call    nulovanie_rele
                call    gong_zastavenie
gd_ret:         mov     a,#3
                call    set_jazda_skoncila
                call    set_inc_data
                jmp     kill_me
