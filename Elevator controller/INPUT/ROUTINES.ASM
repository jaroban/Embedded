; version 4.1

update_floorno: mov     floor_no,a
if na_jednom_poschodi_dve_volby
                add     a,#2
endif
                mov     call_no,a
                ret

ake_riadenie:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_riadenie
                movx    a,@dptr
                ret

aka_nahrada:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_nahrada
                movx    a,@dptr
                ret

a3_maze_volby:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_a3_maze_volby
                movx    a,@dptr
                ret

aka_skupina:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_typ
                movx    a,@dptr
                ret

je_normal:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_typ
                movx    a,@dptr
                xrl     a,#1
                jz      jnr_yes
                clr     a
                ret
je_blok:        mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_typ
                movx    a,@dptr
                xrl     a,#2
                jz      jnr_yes
                clr     a
                ret
je_double:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_typ
                movx    a,@dptr
                xrl     a,#3
                jz      jnr_yes
                clr     a
                ret
je_zdochnutie:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_typ
                movx    a,@dptr
                xrl     a,#4
                jz      jnr_yes
                clr     a
                ret
jnr_yes:        cpl     a
                ret

ake_spojenie:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_spojenie
                movx    a,@dptr
                ret

je_skupina_po_cane:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_skupina_spojenie
                movx    a,@dptr
                xrl     a,#2
                jz      jspc_yes
                clr     a
                ret
jspc_yes:       cpl     a
                ret

ake_dvere:
if su_dvere_c
                mov     a,my_liftpos
                cjne    a,#2,ake_dvere_1
                mov     a,#4
                ret
ake_dvere_1:
endif
                mov     a,my_liftpos
                call    su_dvere_a
                mov     dps,#0
                mov     dpx,#0
                jnz     ad_skip_a
                mov     dptr,#enum_table+p_dvere_b
                movx    a,@dptr
                ret
ad_skip_a:      mov     dptr,#enum_table+p_dvere_a
                movx    a,@dptr
                ret

ake_dvere2:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_dvere_b
                movx    a,@dptr
                clr     acc.0
                mov     r0,a
                mov     dptr,#enum_table+p_dvere_a
                movx    a,@dptr
                clr     acc.0
                mov     r1,a
                clr     c
                subb    a,r0
                jc      ad2_skip1
                mov     a,r1
                ret
ad2_skip1:      mov     a,r0
                ret

aky_pohon:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_pohon
                movx    a,@dptr
                ret

rychlost_reviznej_jazdy1:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_revizna_rychlost1
                movx    a,@dptr
                ret

rychlost_reviznej_jazdy2:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_revizna_rychlost2
                movx    a,@dptr
                ret

param_fazy:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_poradie_faz
                movx    a,@dptr
                ret

bezpecny_priestor:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_bezpecny_priestor
                movx    a,@dptr
                ret

je_cas_pohnutia:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_cas_pohnutia
                movx    a,@dptr
                ret

je_inkrement:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_inkrementalny
                movx    a,@dptr
                ret

param_termistor:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_termistor
                movx    a,@dptr
                ret

je_termistor:   call    param_termistor
                jnz     jt_ok
                ret
jt_ok:          mov     a,term_state
                jnz     jt_try_1
                jb      termistor_n,jt_0
                inc     term_state
                call    init_timer_f
                dw      t_termistor
                db      0,2,0
                sjmp    jt_0
jt_try_1:       cjne    a,#1,jt_try_2
                jb      termistor_n,jt_rst
                call    timer_running_f
                dw      t_termistor
                jnz     jt_0
                inc     term_state
                sjmp    jt_1
jt_try_2:       cjne    a,#2,jt_try_3
                jnb     termistor_n,jt_1
                inc     term_state
                call    init_timer_f
                dw      t_termistor
                db      0,30,0
                sjmp    jt_1
jt_try_3:       cjne    a,#3,jt_rst
                call    timer_running_f
                dw      t_termistor
                jnz     jt_1
jt_rst:         mov     term_state,#0
jt_0:           clr     a
                ret
jt_1:           mov     a,#0ffh
                ret

param_dorovnavanie:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_dorovnavanie
                movx    a,@dptr
                ret

param_predotvaranie:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_predotvaranie
                movx    a,@dptr
                ret

param_snimac_c: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_dorovnavanie
                movx    a,@dptr
                mov     b,a
                mov     dptr,#enum_table+p_predotvaranie
                movx    a,@dptr
                orl     a,b
                ret

c_vedla_a_b:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_c_vedla_a_b
                movx    a,@dptr
                ret

statie_s_otvorenymi_dverami:
if su_dvere_c
                mov     a,my_liftpos
                cjne    a,#2,ssod_skip1
                mov     a,#1
                ret
ssod_skip1:
endif
                mov     a,my_liftpos
                call    su_dvere_a
                mov     dps,#0
                mov     dpx,#0
                jnz     ssod_a
                mov     dptr,#enum_table+p_statie_s_o_d_b
                movx    a,@dptr
                ret
ssod_a:         mov     dptr,#enum_table+p_statie_s_o_d_a
                movx    a,@dptr
                ret

je_kontrola_modulu_c:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_modul_c
                movx    a,@dptr
                ret

kontrola_modulu_c:
                mov     a,#p_modul_c
                jmp     get_a14_a21

param_kabina:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_volby_kabina
                movx    a,@dptr
                ret

je_kabina_po_cane:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_volby_kabina
                movx    a,@dptr
                xrl     a,#3
                jz      jkpc_yes
                clr     a
                ret
jkpc_yes:       cpl     a
                ret

param_dole:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_volby_dole
                movx    a,@dptr
                ret

param_hore:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_volby_hore
                movx    a,@dptr
                ret

inverzia_a_b:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_inverzia_a_b
                movx    a,@dptr
                ret

inverzia_h_d:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_inverzia_h_d
                movx    a,@dptr
                ret

inverzia_nud:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_inverzia_nudzova
                movx    a,@dptr
                ret

je_nudzova:     mov     c,nudzova_jazda
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_inverzia_nudzova
                movx    a,@dptr
                jz      jenud_ret
                cpl     c
jenud_ret:      mov     acc.0,c
                ret

su_smerove_sipky:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_smerove_sipky
                movx    a,@dptr
                ret

kedy_je_gong:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_gong_kedy
                movx    a,@dptr
                ret

je_blikanie:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_blikanie
                movx    a,@dptr
                ret

je_rele_jazda:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_rele_jazda
                movx    a,@dptr
                ret

je_rele_hv_tr:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_rele_hv_tr
                movx    a,@dptr
                ret

je_rele_jazda_alebo_hv_tr:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_rele_jazda
                movx    a,@dptr
                mov     r0,a
                mov     dptr,#enum_table+p_rele_hv_tr
                movx    a,@dptr
                orl     a,r0
                ret
                
je_rele_nizka:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_rele_nizka
                movx    a,@dptr
                ret

je_nudzovy_dojazd:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_je_nudzovy_dojazd
                movx    a,@dptr
                ret

su_rele_fazy_baterka:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_nudzovy_dojazd
                movx    a,@dptr
                jz      srfb_ret
                mov     dptr,#enum_table+p_rele_baterka
                movx    a,@dptr
srfb_ret:       ret

aky_jazyk:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_jazyk
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#no_of_languages
                dec     r1
                jmp     adj_r0_r1

aky_seriovy_kod:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_seriovy_typ
                movx    a,@dptr
                ret

aky_seriovy_kod_rdk:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_seriovy_typ_rdk
                movx    a,@dptr
                ret
                
je_multiplex:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_multiplex
                movx    a,@dptr
                ret

aky_typ_bcd:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_typ_bcd
                movx    a,@dptr
                ret

je_grayov_kod:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_grayov_kod
                movx    a,@dptr
                ret

zdielane_vonkajsie:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_zdielane_vonkajsie
                movx    a,@dptr
                ret

je_ohrievanie:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_ohrievanie
                movx    a,@dptr
                ret

aky_vypis:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_vypis
                movx    a,@dptr
                ret

get_a14_a21:    mov     dps,#0
                mov     dpx,#0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      gaa_ret
                dec     a
                clr     c
                
                mov     r0,a
                subb    a,#16
                jc      gaa_a14_21
                
                mov     r0,a
                subb    a,#64
                jc      gaa_a101_216
gaa_entry:
                mov     r0,a
                subb    a,#18
                jc      gaa_can1_9
                
                mov     r0,a
                subb    a,#4
                jc      gaa_t0_3
                
                mov     r0,a
                subb    a,#2
                jc      gaa_a5
                
                clr     a
                ret

gaa_a14_21:     mov     a,r0
                clr     c
                rrc     a
                jc      gaa_skip1
                call    get_nrm_mask
                anl     a,rd_24v_reg2
                ret
gaa_skip1:      call    get_nrm_cpl_mask
                orl     a,rd_24v_reg2
                cpl     a
                ret
                
gaa_a101_216:   mov     a,r0
                swap    a
                anl     a,#3
                add     a,#rd_brd_reg1
                mov     r1,a
                mov     a,r0
                rrc     a
                anl     a,#7
                jc      gaa_skip2
                call    get_nrm_mask
                anl     a,@r1
                ret
gaa_skip2:      call    get_nrm_cpl_mask
                orl     a,@r1
                cpl     a
                ret
                
gaa_can1_9:     mov     a,r0
                clr     c
                rrc     a
                jc      gaa_skip4
                jb      acc.3,gaa_skip3
                call    get_rvs_mask
                anl     a,rd_can_reg5
                ret
gaa_skip3:      mov     a,rd_can_reg6
                anl     a,#4
                ret
gaa_skip4:      jb      acc.3,gaa_skip5
                call    get_rvs_cpl_mask
                orl     a,rd_can_reg5
                cpl     a
                ret
gaa_skip5:      mov     a,rd_can_reg6
                orl     a,#not(4)
                cpl     a
gaai_ret:       ret

gaa_t0_3:       mov     a,r0
                add     a,#low(hodiny_values)
                mov     dpl,a
                clr     a
                addc    a,#high(hodiny_values)
                mov     dph,a
                movx    a,@dptr
                jnz     gaa_zero
                cpl     a
                ret
gaa_zero:       clr     a
gaa_ret:        ret

gaa_a5:         mov     a,r0
                jb      acc.0,gaa_skip6
                clr     a
                mov     c,a5
                rlc     a
                ret
gaa_skip6:      clr     a
                mov     c,a5
                cpl     c
                rlc     a
                ret

get_a14_a21i:   mov     dps,#0
                mov     dpx,#0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      gaai_ret
                dec     a
                clr     c
                
                mov     r0,a
                subb    a,#16
                jc      gaa_a14_21i
                
                mov     r0,a
                subb    a,#64
                jc      gaa_a101_216i
                
                jmp     gaa_entry
                
gaa_a14_21i:    mov     a,r0
                clr     c
                rrc     a
                jc      gaai_skip1
                call    get_nrm_mask
                mov     r0,a
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#7
                movx    a,@dptr
                cpl     a
                mov     dpx,#0
                mov     ckcon,#ck_po
                anl     a,r0
                ret
gaai_skip1:     call    get_nrm_mask
                mov     r0,a
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#7
                movx    a,@dptr
                mov     dpx,#0
                mov     ckcon,#ck_po
                anl     a,r0
                ret
                
gaa_a101_216i:  mov     a,r0
                rrc     a
                anl     a,#7
                jc      gaai_skip2
                call    get_nrm_mask
                mov     r1,a
                mov     a,r0
                swap    a
                anl     a,#3
                mov     dpl,a
                mov     dph,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                movx    a,@dptr
                cpl     a
                mov     dpx,#0
                mov     ckcon,#ck_po
                anl     a,r1
                ret
gaai_skip2:     call    get_nrm_mask
                mov     r1,a
                mov     a,r0
                swap    a
                anl     a,#3
                mov     dpl,a
                mov     dph,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                movx    a,@dptr
                mov     dpx,#0
                mov     ckcon,#ck_po
                anl     a,r1
                ret

kvo_dvere:      mov     a,#p_koniec_o_d
                jmp     get_a14_a21

je_kvz_dvere_a: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_koniec_z_d_a
                movx    a,@dptr
                ret

kvz_dvere_a:    mov     a,#p_koniec_z_d_a
                jmp     get_a14_a21

je_kvz_dvere_b: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_koniec_z_d_b
                movx    a,@dptr
                ret

kvz_dvere_b:    mov     a,#p_koniec_z_d_b
                jmp     get_a14_a21

je_kontrola_24v:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_kontrola_24v
                movx    a,@dptr
                ret

kontrola_24v:   mov     a,#p_kontrola_24v
                jmp     get_a14_a21

je_kopia_vstup: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_copy_in
                movx    a,@dptr
                ret

kopia_vstup:    mov     a,#p_copy_in
                jmp     get_a14_a21

szx_reset_preruseni:
                call    pocet_preruseni_sza
                mov     c_preruseni_sza,a
                mov     a,#0ffh
                ret

szb:            call    szb_normal
                sjmp    szb_entry
sza:            call    sza_normal
szb_entry:      mov     r0,a
                mov     r1,#0
                mov     r2,#0ffh
                mov     a,je_poziarna_jazda
                cjne    a,#2,sza_skip0
                mov     r2,#0
sza_skip0:      call    ake_dvere
                clr     acc.0
                jz      sza_skip1
                jb      a3,sza_skip1
                mov     r1,#0ffh
sza_skip1:      mov     a,r0
                orl     a,r1
                anl     a,r2
                jnz     szx_reset_preruseni
                ret

sza_normal:     mov     a,#p_svetelna_zavora_a
                jmp     get_a14_a21i

sza_r:          call    sza
                jnz     sza_reset
                mov     dps,#0
                mov     dptr,#t_zotrvacnost_a
                jmp     timer_running
sza_reset:      call    init_timer_f
                dw      t_zotrvacnost_a
                db      0,1,50
sza_1:          mov     a,#0ffh
                ret

szb_normal:     mov     a,#p_svetelna_zavora_b
                jmp     get_a14_a21i

szb_r:          call    szb
                jnz     szb_reset
                mov     dps,#0
                mov     dptr,#t_zotrvacnost_B
                jmp     timer_running
szb_reset:      call    init_timer_f
                dw      t_zotrvacnost_b
                db      0,1,50
szb_1:          mov     a,#0ffh
                ret

tlacitko_zatvarania_dveri:
                mov     a,#p_tlacitko_z_d
                jmp     get_a14_a21

ventilator_od_casu:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_vent_in
                movx    a,@dptr
                clr     c
                subb    a,#1+16+64+18
                jnc     vod_yes
                clr     a
                ret
vod_yes:        mov     a,#0ffh
                ret

je_ventilator:  mov     a,#p_vent_in
                jmp     get_a14_a21

je_ozivenie:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_ozivenie
                movx    a,@dptr
                ret

je_ozivenie2:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_ozivenie2
                movx    a,@dptr
                ret

ozivenie:       mov     a,#p_ozivenie
                jmp     get_a14_a21

; this could also be called "zakapanie"
ozivenie2:      mov     a,#p_ozivenie2
                jmp     get_a14_a21

output_zakapanie:
                ; reg3.d5
                mov     c,zakapanie
                mov     a,wr_can_reg5
                mov     acc.5,c
                mov     wr_can_reg5,a
                setb    can0_change2
                clr     a
                rlc     a
                ; output to bx
                mov     r0,#p_ozivenie_out
                jmp     trans_write

je_porucha_menica:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_porucha_menica
                movx    a,@dptr
                ret

porucha_menica: mov     a,#p_porucha_menica
                jmp     get_a14_a21

je_bezpecnost_menica:
                mov     dps,#0
                mov     dpx,#0
                mov     r0,#bola_zapnuta_jazda
                mov     a,@r0
                jz      jbm_ret
                mov     dptr,#enum_table+p_bezpecnost_menica
                movx    a,@dptr
jbm_ret:        ret

bezpecnost_menica:
                mov     a,#p_bezpecnost_menica
                jmp     get_a14_a21

typ_menica:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_typ_menica
                movx    a,@dptr
                ret

je_kontrola_menica:     
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_kontrola_menica
                movx    a,@dptr
                ret

kontrola_menica: 
                mov     a,#p_kontrola_menica
                jmp     get_a14_a21

if hydraulika_a3
                ; must not corrupt b
je_hydraulika_rdy:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_hydraulika_rdy
                movx    a,@dptr
                ret
                
hydraulika_rdy: mov     a,#p_hydraulika_rdy
                jmp     get_a14_a21
                
                ; must not corrupt b
je_hydraulika_run:  
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_hydraulika_run
                movx    a,@dptr
                ret

hydraulika_run: mov     a,#p_hydraulika_run
                jmp     get_a14_a21
else
                ; must not corrupt b
je_kontrola_brzdy1:  
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_kontrola_brzdy1
                movx    a,@dptr
                ret
                
kontrola_brzdy1:     
                mov     a,#p_kontrola_brzdy1
                jmp     get_a14_a21
                
                ; must not corrupt b
je_kontrola_brzdy2:  
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_kontrola_brzdy2
                movx    a,@dptr
                ret

kontrola_brzdy2:     
                mov     a,#p_kontrola_brzdy2
                jmp     get_a14_a21
endif
; must not corrupt b
je_modul_npk:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_kontrola_npk
                movx    a,@dptr
                ret

modul_npk:      mov     a,#p_kontrola_npk
                jmp     get_a14_a21
                
poziarna_jazda: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_poziarna_jazda
                movx    a,@dptr
                clr     c
                subb    a,#1+16+64+18
                jc      poz_jazd_ok
                cjne    a,others,poz_jazd_0
poz_jazd_ok:    mov     a,#p_poziarna_jazda
                call    get_a14_a21
                jnz     poz_jazd_ret
                mov     a,#p_poziarna_jazda2
                jmp     get_a14_a21
poz_jazd_0:     clr     a
poz_jazd_ret:   ret

store_poziarna_dest:
                mov     dps,#0
                mov     dpx,#0
                
                mov     a,#p_poziarna_jazda
                call    get_a14_a21
                jz      spd2_try2
                mov     dptr,#num_table+3
                sjmp    spd2_drain
                
spd2_try2:      mov     a,#p_poziarna_jazda2
                call    get_a14_a21
                jz      spd2_ret
                mov     dptr,#num_table+15

spd2_drain:     movx    a,@dptr
                mov     dptr,#poziarna_dest
                movx    @dptr,a
spd2_ret:       ret

je_vazenie_10:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_vazenie_10
                movx    a,@dptr
                ret

vazenie_10:     call    aka_nahrada
                jz      v_10_ok
                mov     c,nvazenie_10
                cpl     c
                sjmp    v_10_str
v_10_ok:        mov     a,#p_vazenie_10
                call    get_a14_a21
                clr     c
                jz      v_10_str
                setb    c
v_10_str:       mov     ovazenie_10,c
                ret

vazenie_80:     call    aka_nahrada
                jz      v_80_ok
                mov     c,nvazenie_80
                sjmp    v_80_str
v_80_ok:        mov     a,#p_vazenie_80
                call    get_a14_a21
                clr     c
                jz      v_80_str
                setb    c
v_80_str:       mov     ovazenie_80,c
if 0
                mov     a,vaz_80_state
                jnz     v_80_try1
                jnb     ovazenie_80,v_80_ret
                call    init_timer_f
                dw      t_vaz_80
                db      1,0,0
                mov     vaz_80_state,#1
                ret
v_80_try1:      cjne    a,#1,v_80_st2
                jnb     ovazenie_80,v_80_reset
                call    timer_running_f
                dw      t_vaz_80
                jnz     v_80_ret
                mov     vaz_80_state,#2
                ret
v_80_st2:       jnb     ovazenie_80,v_80_reset
                clr     ovazenie_80
v_80_ret:       ret
v_80_reset:     mov     vaz_80_state,#0
endif
                ret

vazenie_110:    mov     dps,#0
                mov     a,#p_vazenie_110
                call    get_a14_a21
                jz      v_110_no
                setb    ovazenie_110
                ret
v_110_no:       clr     ovazenie_110
                ret

revizna_vysoka: mov     a,#p_revizna_vysoka
                jmp     get_a14_a21

ranny_program:  mov     a,#p_ranny_program
                jmp     get_a14_a21

obednajsi_program:
                mov     a,#p_obednajsi_program
                jmp     get_a14_a21

prednostne_privolanie:
                mov     a,#p_prednostne_p
                call    get_a14_a21
                jnz     pp_ret
                mov     a,#p_prednostne_p2
                call    get_a14_a21
                jnz     pp_ret
                mov     a,#p_prednostne_p3
                call    get_a14_a21
                jnz     pp_ret
                clr     a
pp_ret:         ret

prednostna_stanica:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#prednostna_dest
                movx    a,@dptr
                ret
                
store_prednostna_dest:
                mov     dps,#0
                mov     dpx,#0
                
                mov     a,#p_prednostne_p
                call    get_a14_a21
                jz      spd_try2
                mov     dptr,#num_table+6
                sjmp    spd_drain
                
spd_try2:       mov     a,#p_prednostne_p2
                call    get_a14_a21
                jz      spd_try3
                mov     dptr,#num_table+16
                sjmp    spd_drain
                
spd_try3:       mov     a,#p_prednostne_p3
                call    get_a14_a21
                jz      spd_ret
                mov     dptr,#num_table+17
                sjmp    spd_drain

spd_drain:      movx    a,@dptr
                mov     dptr,#prednostna_dest
                movx    @dptr,a
spd_ret:        ret

nezavisla_jazda:
                mov     a,#p_nezavisla_jazda
                jmp     get_a14_a21

tlacitko_otvarania_dveri:
                mov     a,#p_tlacitko_o_d
                jmp     get_a14_a21

pocet_poschodi: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table
                movx    a,@dptr
                mov     r0,#2
                mov     r1,#no_of_floors
                jmp     adj_r0_r1

pocet_preruseni_sza:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+1
                movx    a,@dptr
                ret

parkovacia_stanica:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+2
                movx    a,@dptr
                ret

hlavna_stanica: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+3
                movx    a,@dptr
                ret

poziarna_stanica:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#poziarna_dest
                movx    a,@dptr
                ret
                
max_pocet_jazd: mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+4
                movx    a,@dptr
                ret

cislo_v_skupine:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+5
                movx    a,@dptr
                ret
                
teplota_zap:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+7
                movx    a,@dptr
                ret

teplota_vyp:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+8
                movx    a,@dptr
                ret

brzdenie_vys:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+9
                movx    a,@dptr
                ret

brzdenie_par:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+10
                movx    a,@dptr
                ret

posch_pod_ds:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+11
                movx    a,@dptr
                ret

je_pod_dolnym:  call    posch_pod_ds
                mov     r0,a
                mov     a,liftpos
                clr     c
                subb    a,r0
                jc      jpd_yes
                clr     a
                ret
jpd_yes:        mov     a,#0ffh
                ret

posch_nad_hs:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+12
                movx    a,@dptr
                ret

je_nad_hornym:  call    posch_nad_hs
                mov     r0,a
                mov     a,floor_no
                dec     a
                clr     c
                subb    a,r0
                clr     c
                subb    a,liftpos
                jc      jnh_yes
                clr     a
                ret
jnh_yes:        mov     a,#0ffh
                ret

zotrvacnost:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+13
                movx    a,@dptr
                ret

dojazd_do:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#num_table+14
                movx    a,@dptr
                ret

; a=index of timer in time_table
get_timer_data:   mov     dps,#0
                mov     dpx,#0
                mov     r0,a
                rl      a
                add     a,r0
                add     a,#low(time_table)
                mov     dpl,a
                clr     a
                addc    a,#high(time_table)
                mov     dph,a
                movx    a,@dptr
                mov     r0,a
                inc     dptr
                movx    a,@dptr
                mov     r1,a
                inc     dptr
                movx    a,@dptr
                mov     r2,a
                ret

je_poschodie_vypnute:
                mov     dps,#0
                mov     dpx,#0
                add     a,#low(floor_table)
                mov     dpl,a
                clr     a
                addc    a,#high(floor_table)
                mov     dph,a
                movx    a,@dptr
                anl     a,#1
                ret

su_dvere_a:     cjne    a,#0ffh,sda_ok
                ret
sda_ok:
if su_dvere_c
                cjne    a,#2,sda_ok_skip1
                clr     a
                ret
sda_ok_skip1:
endif
                mov     dps,#0
                mov     dpx,#0
                add     a,#low(floor_table)
                mov     dpl,a
                clr     a
                addc    a,#high(floor_table)
                mov     dph,a
                movx    a,@dptr
                anl     a,#3 shl 1
                xrl     a,#1 shl 1
                ret

su_dvere_b:     cjne    a,#0ffh,sdb_ok
                ret
sdb_ok:
if su_dvere_c
                cjne    a,#2,sdb_ok_skip1
                clr     a
                ret
sdb_ok_skip1:
endif
                mov     dps,#0
                mov     dpx,#0
                add     a,#low(floor_table)
                mov     dpl,a
                clr     a
                addc    a,#high(floor_table)
                mov     dph,a
                movx    a,@dptr
                anl     a,#3 shl 1
                ret

su_vobec_dvere_a_:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#floor_table
                mov     r0,floor_no
svda_lp:        movx    a,@dptr
                anl     a,#3 shl 1
                cjne    a,#(1 shl 1),svda_1
                inc     dptr
                djnz    r0,svda_lp
                clr     su_vobec_dvere_a
                ret
svda_1:         setb    su_vobec_dvere_a
                ret

su_vobec_dvere_b_:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#floor_table
                mov     r0,floor_no
svdb_lp:        movx    a,@dptr
                anl     a,#3 shl 1
                jnz     svdb_1
                inc     dptr
                djnz    r0,svdb_lp
                clr     su_vobec_dvere_b
                ret
svdb_1:         setb    su_vobec_dvere_b
                ret

ake_je_poschodie:
                mov     r0,a
                call    ake_riadenie
                jb      acc.0,ajp_ok
                call    aka_nahrada
                jz      ajp_ok
                clr     a
                ret
ajp_ok:         mov     a,r0
                add     a,#low(floor_table)
                mov     dpl,a
                clr     a
                addc    a,#high(floor_table)
                mov     dph,a
                movx    a,@dptr
                rl      a
                swap    a
                anl     a,#3
                ret

rychlost_z_poschodia:
                mov     dps,#0
                mov     dpx,#0
                add     a,#low(floor_table)
                mov     dpl,a
                clr     a
                addc    a,#high(floor_table)
                mov     dph,a
                movx    a,@dptr
                rr      a
                swap    a
                anl     a,#3
                cjne    a,#3,rzp_ret
                clr     a
rzp_ret:        ret
