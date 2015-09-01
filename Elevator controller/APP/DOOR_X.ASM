; version 4.0

max_reverzov    equ     5
max_zatvarani   equ     5

db_open_a       bit     acc.0
db_open_close_a bit     acc.1
db_close_a      bit     acc.2
db_stop_a       bit     acc.3
db_open_b       bit     acc.4
db_open_close_b bit     acc.5
db_close_b      bit     acc.6
db_stop_b       bit     acc.7

dm_open_a       equ     1
dm_open_close_a equ     2
dm_close_a      equ     4
dm_stop_a       equ     8
dm_open_b       equ     10h
dm_open_close_b equ     20h
dm_close_b      equ     40h
dm_stop_b       equ     80h

dx_close        bit     0
dx_bol_reverz   bit     1

c_reverzov      data    21h
c_zatvarani     data    22h

db_opening      bit     acc.0
db_waiting      bit     acc.1
db_closing      bit     acc.2
db_error        bit     acc.3
db_opened       bit     acc.4
db_waited       bit     acc.5
db_closed       bit     acc.6

dm_opening      equ     1
dm_waiting      equ     2
dm_closing      equ     4
dm_error        equ     8
dm_opened       equ     10h
dm_waited       equ     20h
dm_closed       equ     40h

                xseg
door_command:   ds      1

                cseg
vymaz_tu_volby:
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     vtv_original
                ; this is necessary
                mov     r0,#call_table+na_ktorom_poschodi_dve_volby
                clr     a
                mov     @r0,a

                mov     a,floor_no
                call    vymaz_kabina
                mov     a,floor_no
                call    vymaz_dole
                
                mov     a,floor_no
                inc     a
                call    vymaz_kabina
                mov     a,floor_no
                inc     a
                call    vymaz_dole
vtv_original:
endif
                mov     a,liftpos
                call    vymaz_kabina
ifn maz_obidve_vonkajsie
                mov     a,dr_state
                cjne    a,#dr_dole,vtv_skip1
                mov     a,liftpos
                call    vymaz_dole
                sjmp    vtv_drain
vtv_skip1:      cjne    a,#dr_hore,vtv_skip2
                sjmp    vtv_hore
endif
vtv_skip2:      mov     a,liftpos
                call    vymaz_dole
vtv_hore:       mov     a,liftpos
                call    vymaz_hore
vtv_drain:      mov     r0,#6
vtv_lp1:        push    ar0
                call    do_them
                pop     ar0
                djnz    r0,vtv_lp1
                ret

je_trvala_kontrola_zatvarania:
                jnb     je_nezavisla_jazda,jtkz_0
                call    ake_riadenie
                jnb     acc.0,jtkz_0
                call    ake_dvere
                jb      acc.0,jtkz_1
jtkz_0:         clr     a
                ret
jtkz_1:         mov     a,#0ffh
                ret

dx_door_command_set:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#door_command
                movx    @dptr,a
                ret
if 0
dx_door_command_or:
                mov     r0,a
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#door_command
                movx    a,@dptr
                orl     a,r0
                movx    @dptr,a
                ret
endif
dx_spusti_a_otvor_dvere:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_a
                call    run_it
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_b
                call    run_it
dx_otvor_dvere:
if su_dvere_c
                mov     a,my_liftpos
                cjne    a,#2,dxod_skip1
                call    otvaraj_dvere_c
dxod_skip1:
endif
dx_open_doors:  anl     dra_flags,#not(dm_opened or dm_waited)
                anl     drb_flags,#not(dm_opened or dm_waited)
                mov     a,#dm_open_a or dm_open_b
                jmp     dx_door_command_set

dx_otvor_a_zatvor_dvere:
                anl     dra_flags,#not(dm_opened or dm_waited or dm_closed)
                anl     drb_flags,#not(dm_opened or dm_waited or dm_closed)
                mov     a,#dm_open_close_a or dm_open_close_b
                jmp     dx_door_command_set

dx_spusti_a_zatvor_dvere:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_a
                call    run_it
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#th_door_b
                call    run_it
dx_zatvor_dvere:
if su_dvere_c
                mov     a,my_liftpos
                cjne    a,#2,dxzd_skip1
                call    zatvaraj_dvere_c
dxzd_skip1:
endif
                anl     dra_flags,#not(dm_closed)
                anl     drb_flags,#not(dm_closed)
                mov     a,#dm_close_a or dm_close_b
                jmp     dx_door_command_set

dx_zastav_dvere:
                anl     dra_flags,#not(dm_opened or dm_waited or dm_closed)
                anl     drb_flags,#not(dm_opened or dm_waited or dm_closed)
                mov     a,#dm_stop_a or dm_stop_b
                jmp     dx_door_command_set

zrus_chyby_dveri:
                mov     a,#e_svetelna_zavora
                call    zrus_chybu
                mov     a,#e_vela_reverzov
                call    zrus_chybu
                mov     a,#e_pocet_zatvarani
                call    zrus_chybu
                mov     a,#e_blokovanie_dveri
                jmp     zrus_chybu
