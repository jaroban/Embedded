; version 4.0

entering_stopped:
                mov     a,dr_state
                cjne    a,#dr_niekde,es_skip1
                mov     dr_state,#dr_prednost
                ret
es_skip1:       cjne    a,#dr_j_niekde,es_skip2
                mov     dr_state,#dr_j_prednost
es_skip2:       ret

skonci_prednost_povodneho_smeru:
                mov     a,dr_state
                cjne    a,#dr_prednost_dole,spps_skip1
                call    nejaka_pod
                jnz     spps_d_skip
                jmp     kp_prednost_dole
spps_d_skip:    mov     dr_state,#dr_dole
                ret
spps_skip1:     cjne    a,#dr_prednost_hore,spps_ret
                call    nejaka_nad
                jnz     spps_h_skip
                jmp     kp_prednost_hore
spps_h_skip:    mov     dr_state,#dr_hore
spps_ret:       ret

koniec_prednosti:
                mov     a,dr_state
                call    do_case
                dw      dr_prednost+j_,kp_prednost
                dw      dr_prednost_dole+j_,kp_prednost_dole
                dw      dr_prednost_hore+j_,kp_prednost_hore
                dw      dr_j_prednost+j_,kp_j_prednost
                db      0
                ret

update_stopped: mov     a,dr_state
                call    do_case
                dw      dr_nic+j_,us_nic
                dw      dr_prednost+j_,us_prednost
                dw      dr_niekde+j_,us_niekde
                dw      dr_dole+j_,us_dole
                dw      dr_hore+j_,us_hore
                dw      dr_prednost_dole+j_,us_prednost_dole
                dw      dr_prednost_hore+j_,us_prednost_hore
                dw      dr_parkujeme+j_,us_parkujeme
                dw      dr_r_nic+j_,us_r_nic
                dw      dr_r_dole+j_,us_r_dole
                dw      dr_r_hore+j_,us_r_hore
                dw      dr_r_spat+j_,us_r_spat
                dw      dr_o_nic+j_,us_o_nic
                dw      dr_o_dole+j_,us_o_dole
                dw      dr_o_spat+j_,us_o_spat
                dw      dr_j_prednost+j_,us_j_prednost
                dw      dr_j_niekde+j_,us_j_niekde
                dw      dr_pp_chod+j_,us_pp_chod
                dw      dr_pp_cakaj+j_,us_pp_cakaj
                dw      dr_pp_vykonaj+j_,us_pp_vykonaj
                db      0
                ret

us_nic:         call    je_nejaka_volba
                jz      us_np_ret
                call    ake_riadenie
                jnb     acc.0,us_np_normal
                call    je_tu_volba
                jz      us_np_j_inde
                mov     dr_state,#dr_j_prednost
                ret
us_np_j_inde:   mov     dr_state,#dr_j_niekde
                ret
us_np_normal:   call    je_tu_volba
                jz      us_np_inde
                mov     dr_state,#dr_prednost
                ret
us_np_inde:     mov     dr_state,#dr_niekde
us_np_ret:      ret

us_prednost:    call    je_kabinova_volba
                jz      us_p_ret
                call    kabinova_nad
                jz      us_p_down
                mov     dr_state,#dr_hore
                ret
us_p_down:      call    kabinova_pod
                jz      us_p_ret
                mov     dr_state,#dr_dole
us_p_ret:       ret

kp_prednost:    mov     dr_state,#dr_nic
                ret

us_niekde:      call    je_nejaka_volba
                jz      us_n_bad
                call    je_tu_volba
                jz      us_n_ret
us_n_prednost:  mov     dr_state,#dr_prednost
                ret
us_n_bad:       mov     dr_state,#dr_nic
us_n_ret:       ret

us_dole:        mov     a,liftpos
                jz      us_d_bot
                call    nejaka_pod
                jnz     us_d_ret
                call    aka_nahrada
                jnz     us_n_prednost
                mov     dr_state,#dr_prednost_dole
us_d_ret:       ret
us_d_bot:       call    nejaka_nad
                jz      us_d_nix
                mov     dr_state,#dr_hore
                ret
us_d_nix:       call    aka_nahrada
                jnz     us_n_prednost
                mov     dr_state,#dr_nic
                ret

us_prednost_dole:
                call    nejaka_pod
                jz      us_pd_ret
                mov     dr_state,#dr_dole
us_pd_ret:      ret

kp_prednost_dole:
                jmp     us_d_bot

us_hore:        mov     a,liftpos
                inc     a
                xrl     a,floor_no
                jz      us_h_top
                call    nejaka_nad
                jnz     us_h_ret
                call    aka_nahrada
                jnz     us_n_prednost
                mov     dr_state,#dr_prednost_hore
us_h_ret:       ret
us_h_top:       call    nejaka_pod
                jz      us_h_nix
                mov     dr_state,#dr_dole
                ret
us_h_nix:       call    aka_nahrada
                jnz     us_n_prednost
                mov     dr_state,#dr_nic
                ret

us_prednost_hore:
                call    nejaka_nad
                jz      us_ph_ret
                mov     dr_state,#dr_hore
us_ph_ret:      ret

kp_prednost_hore:
                jmp     us_h_top

us_parkujeme:   call    je_nejaka_volba
                jnz     us_pk_over
                call    parkovacia_stanica
                dec     a
                xrl     a,liftpos
                jz      us_pk_over
                ret
us_pk_over:     mov     dr_state,#dr_nic
                ret

us_r_nic:       call    kabinova_pod
                jz      us_rn_skip
                mov     dr_state,#dr_r_dole
                ret
us_rn_skip:     call    kabinova_nad
                jz      us_rn_ret
                mov     dr_state,#dr_r_hore
us_rn_ret:      ret

us_r_dole:      call    kabinova_pod
                jnz     us_rd_ret
                mov     dr_state,#dr_r_spat
us_rd_ret:      ret

us_r_hore:      call    kabinova_nad
                jnz     us_rh_ret
                mov     dr_state,#dr_r_spat
us_rh_ret:      ret

us_r_spat:      call    hlavna_stanica
                dec     a
                cjne    a,liftpos,us_rs_ret
                mov     dr_state,#dr_r_nic
us_rs_ret:      ret

us_o_nic:       call    nejaka_pod
                jz      us_on_ret
                mov     dr_state,#dr_o_dole
us_on_ret:      ret

us_o_dole:      call    nejaka_pod
                jnz     us_od_ret
                mov     dr_state,#dr_o_spat
us_od_ret:      ret

us_o_spat:      mov     a,floor_no
                dec     a
                cjne    a,liftpos,us_os_ret
                mov     dr_state,#dr_o_nic
us_os_ret:      ret

us_j_prednost:  call    je_tu_volba
                jnz     us_jp_ret
                jnb     uz_mame_volbu,us_jp_ret
                mov     dr_state,#dr_j_niekde
us_jp_ret:      ret

kp_j_prednost:  call    je_nejaka_volba
                jz      kp_jp_nic
                mov     dr_state,#dr_j_niekde
                ret
kp_jp_nic:      mov     dr_state,#dr_nic
                ret

us_j_niekde:    call    je_nejaka_volba
                jnz     us_jn_ret
                mov     dr_state,#dr_j_prednost
us_jn_ret:      ret

us_pp_chod:     call    prednostna_stanica
                dec     a
                cjne    a,liftpos,us_pp_ch_ret
                mov     dr_state,#dr_pp_cakaj
ifn prednostne_zdochnutie
                clr     blokuj_volby
endif
us_pp_ch_ret:   ret

us_pp_cakaj:    call    je_kabinova_volba
                jz      us_pp_ca_ret
                mov     dr_state,#dr_pp_vykonaj
us_pp_ca_ret:   ret

us_pp_vykonaj:  call    prednostna_stanica
                dec     a
                xrl     a,liftpos
                jz      us_pp_vy_ret
                mov     dr_state,#dr_nic
                clr     je_prednostna_jazda
us_pp_vy_ret:   ret

update_down:    call    check_prednostna_jazda
                call    check_poziarna_jazda2
                mov     a,dr_state
                cjne    a,#dr_niekde,ud_park
                call    kolko_je_volieb
                clr     c
                subb    a,#2
                jc      ud_ret
                mov     dr_state,#dr_dole
                ret
ud_park:        cjne    a,#dr_parkujeme,ud_ret
                call    je_nejaka_volba
                jz      ud_ret
                mov     dr_state,#dr_niekde
ud_ret:         ret

update_up:      call    check_prednostna_jazda
                call    check_poziarna_jazda2
                mov     a,dr_state
                cjne    a,#dr_niekde,uu_park
                call    kolko_je_volieb
                clr     c
                subb    a,#2
                jc      uu_ret
                mov     dr_state,#dr_hore
                ret
uu_park:        cjne    a,#dr_parkujeme,uu_ret
                call    je_nejaka_volba
                jz      uu_ret
                mov     dr_state,#dr_niekde
uu_ret:         ret
