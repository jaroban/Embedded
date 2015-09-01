; version 4.0

next_stop2:     mov     a,dr_state
                call    do_case
                dw      dr_parkujeme+j_,ns_parkujeme
                dw      dr_do_poziarnej+j_,ns_do_poziarnej2
                dw      dr_do_najnizsej+j_,ns_do_najnizsej2
                dw      dr_r_spat+j_,ns_do_hlavnej
                dw      dr_o_spat+j_,ns_o_spat
                dw      dr_pp_chod+j_,ns_pp_chod2
                db      0
                mov     a,#na_nic
                ret

next_stop:      mov     a,dr_state
                call    do_case
                dw      dr_nic+j_,ns_nic
                dw      dr_prednost+j_,ns_prednost
                dw      dr_niekde+j_,ns_niekde
                dw      dr_dole+j_,ns_dole
                dw      dr_hore+j_,ns_hore
                dw      dr_prednost_dole+j_,ns_prednost
                dw      dr_prednost_hore+j_,ns_prednost
                dw      dr_parkujeme+j_,ns_parkujeme
                dw      dr_do_poziarnej+j_,ns_do_poziarnej
                dw      dr_do_najnizsej+j_,ns_do_najnizsej
                dw      dr_r_nic+j_,ns_nic
                dw      dr_r_dole+j_,ns_dole
                dw      dr_r_hore+j_,ns_hore
                dw      dr_r_spat+j_,ns_do_hlavnej
                dw      dr_o_nic+j_,ns_nic
                dw      dr_o_dole+j_,ns_dole
                dw      dr_o_spat+j_,ns_o_spat
                dw      dr_j_prednost+j_,ns_prednost
                dw      dr_j_niekde+j_,ns_j_niekde
                dw      dr_pp_chod+j_,ns_pp_chod
                dw      dr_pp_cakaj+j_,ns_nic
                dw      dr_pp_vykonaj+j_,ns_niekde
                db      0
                mov     a,#na_nic
                ret

ns_nic:         mov     a,#na_nic
                mov     nextfloor,liftpos
                ret

ns_prednost:    mov     a,#na_prednost
                mov     nextfloor,liftpos
                ret

ns_ok:          mov     nextfloor,a
                mov     a,#na_jazda
                ret

ns_niekde:      call    next_up
                cjne    a,#0ffh,ns_ok
                call    next_down
                cjne    a,#0ffh,ns_ok
                mov     a,#na_nic
                ret

ns_dole:        call    next_down
                cjne    a,#0ffh,ns_ok
                mov     a,#na_nic
                ret

ns_hore:        call    next_up
                cjne    a,#0ffh,ns_ok
                mov     a,#na_nic
                ret

ns_parkujeme:   call    parkovacia_stanica
                dec     a
                jmp     ns_ok

ns_do_poziarnej2: 
                call    poziarna_stanica
                jz      ns_nic
                dec     a
                jmp     ns_ok
                
ns_do_poziarnej:
                call    poziarna_stanica
                dec     a
                cjne    a,liftpos,ns_ok
                mov     a,#na_nic
                ret
                
ns_do_hlavnej:  call    hlavna_stanica
                jz      ns_nic
                dec     a
                jmp     ns_ok
                
ns_do_najnizsej2:
                clr     a
                jmp     ns_ok
                
ns_do_najnizsej:
                clr     a
                cjne    a,liftpos,ns_ok
                mov     a,#na_nic
                ret

ns_o_spat:      mov     a,floor_no
                dec     a
                jmp     ns_ok

ns_j_niekde:    jnb     uz_mame_volbu,ns_niekde
                call    kde_je_kabinova_volba
                jmp     ns_ok

ns_pp_chod2:    call    prednostna_stanica
                jz      ns_nic
                dec     a
                jmp     ns_ok
                
ns_pp_chod:     call    prednostna_stanica
                dec     a
                cjne    a,liftpos,ns_ok
                mov     a,#na_nic
                ret

next_stop_down: call    je_termistor
                jnz     nsd_stop
                mov     a,dr_state
                call    do_case
                dw      dr_niekde+j_,nsd_dole
                dw      dr_dole+j_,nsd_dole
                dw      dr_do_poziarnej+j_,nsd_do_poziarnej
                dw      dr_do_najnizsej+j_,nsd_do_najnizsej
                dw      dr_r_dole+j_,nsd_dole
                dw      dr_o_dole+j_,nsd_dole
                dw      dr_pp_chod+j_,nsd_do_prednostnej
                dw      dr_pp_vykonaj+j_,nsd_dole
                db      0
                ret

nsd_dole:       call    next_down
                cjne    a,#0ffh,nsd_ok
nsd_stop:       mov     a,liftpos
                cjne    a,nextfloor,nsd_bad
                ret
nsd_bad:        jz      nsd_ok
                dec     a
nsd_ok:         mov     nextfloor,a
                ret

nsd_do_poziarnej: 
                call    poziarna_stanica
                dec     a
                mov     r0,a
                clr     c
                subb    a,liftpos
                jnc     nsd_stop
                mov     nextfloor,r0
                ret

nsd_do_najnizsej:
                mov     nextfloor,#0
                ret

nsd_do_prednostnej:
                call    prednostna_stanica
                dec     a
                mov     r0,a
                clr     c
                subb    a,liftpos
                jnc     nsd_stop
                mov     nextfloor,r0
                ret

next_stop_up:   call    je_termistor
                jnz     nsu_stop
                mov     a,dr_state
                call    do_case
                dw      dr_niekde+j_,nsu_hore
                dw      dr_hore+j_,nsu_hore
                dw      dr_do_poziarnej+j_,nsu_do_poziarnej
                dw      dr_do_najnizsej+j_,nsu_stop
                dw      dr_r_hore+j_,nsu_hore
                dw      dr_pp_chod+j_,nsu_do_prednostnej
                dw      dr_pp_vykonaj+j_,nsu_hore
                db      0
                ret

nsu_hore:       call    next_up
                cjne    a,#0ffh,nsu_ok
nsu_stop:       mov     a,liftpos
                cjne    a,nextfloor,nsu_bad
                ret
nsu_bad:        inc     a
                cjne    a,floor_no,nsu_ok
                dec     a
nsu_ok:         mov     nextfloor,a
                ret

nsu_do_poziarnej: 
                call    poziarna_stanica
                dec     a
                mov     r0,a
                setb    c
                subb    a,liftpos
                jc      nsu_stop
                mov     nextfloor,r0
                ret

nsu_do_prednostnej:
                call    prednostna_stanica
                dec     a
                mov     r0,a
                setb    c
                subb    a,liftpos
                jc      nsu_stop
                mov     nextfloor,r0
                ret

urci_smer:      mov     a,dr_state
                cjne    a,#dr_do_poziarnej,sm_skip1
                sjmp    sm_ok
sm_skip1:       xrl     a,#dr_do_najnizsej
                jz      sm_ok
                call    ake_riadenie
                jnb     acc.0,sm_ok
                call    ake_dvere
                cjne    a,#4,sm_ok
                jb      a3,sm_nic

sm_obidve:      mov     smer,#both
                ret

sm_nic:         mov     smer,#none
                ret

sm_ok:          mov     a,dr_state
                call    do_case
                dw      dr_nic+j_,sm_nic
                dw      dr_prednost+j_,sm_obidve
                dw      dr_niekde+j_,sm_niekde
                dw      dr_dole+j_,sm_dole
                dw      dr_hore+j_,sm_hore
                dw      dr_prednost_dole+j_,sm_obidve
                dw      dr_prednost_hore+j_,sm_obidve
                dw      dr_parkujeme+j_,sm_niekde
                dw      dr_do_poziarnej+j_,sm_blikaj
                dw      dr_do_najnizsej+j_,sm_blikaj
                dw      dr_r_nic+j_,sm_nic
                dw      dr_r_dole+j_,sm_dole
                dw      dr_r_hore+j_,sm_hore
                dw      dr_r_spat+j_,sm_niekde
                dw      dr_o_nic+j_,sm_nic
                dw      dr_o_dole+j_,sm_dole
                dw      dr_o_spat+j_,sm_niekde
                dw      dr_j_prednost+j_,sm_obidve
                dw      dr_j_niekde+j_,sm_niekde
                dw      dr_pp_chod+j_,sm_niekde
                dw      dr_pp_cakaj+j_,sm_obidve
                dw      dr_pp_vykonaj+j_,sm_niekde
                db      0
                ret

sm_niekde:      mov     a,nextfloor
                clr     c
                subb    a,liftpos
                jz      sm_nic
                jnc     sm_hore

sm_dole:        mov     smer,#dole
                ret

sm_hore:        mov     smer,#hore
                ret

sm_blikaj:      mov     smer,#both_blink
                ret

je_nejaka_prednost:
                call    je_kabinova_volba
                jnz     jnp_2
                mov     a,dr_state
                cjne    a,#dr_j_prednost,jnp_1
                mov     a,#0ffh
                ret
jnp_1:          cjne    a,#dr_prednost,jnp_2
                mov     a,#0ffh
                ret
jnp_2:          clr     a
                ret

je_este_prednost:
                mov     a,dr_state
                cjne    a,#dr_prednost,jep_skip1
                mov     a,#0ffh
                ret
jep_skip1:      cjne    a,#dr_prednost_dole,jep_skip2
                mov     a,#0ffh
                ret
jep_skip2:      cjne    a,#dr_prednost_hore,jep_skip3
                mov     a,#0ffh
                ret
jep_skip3:      cjne    a,#dr_j_prednost,jep_skip4
                mov     a,#0ffh
                ret
jep_skip4:      clr     a
                ret
