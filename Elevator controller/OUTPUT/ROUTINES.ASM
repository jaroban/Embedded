; version 4.1

gong_nevidiaci_on:
                ; reg4.d4
                orl     wr_can_reg6,#10h
                setb    can0_change2
                ; start timer
                mov     dps,#0
                mov     dptr,#check_gong2
                mov     a,#1
                movx    @dptr,a
                call    init_timer_f
                dw      t_check_gong2
                db      0,2,0
                ret

gong_nevidiaci_off:
                ; reg4.d4
                anl     wr_can_reg6,#0efh
                setb    can0_change2
                
                mov     dps,#0
                mov     dptr,#check_gong2
                clr     a
                movx    @dptr,a
                ret

if su_dvere_c
zatvaraj_dvere_c:
                mov     a,wr_brd_reg2
                anl     a,#7fh
                mov     wr_brd_reg2,a
                setb    brd_change1
                ret

otvaraj_dvere_c:
                mov     a,wr_brd_reg2
                orl     a,#80h
                mov     wr_brd_reg2,a
                setb    brd_change1
                ret
endif

; called from int
write_brd_regs: mov     a,mux_state
                jz      wbr_skip
                clr     c
                subb    a,#7
                jc      wbr_ret
                jb      mux_all_32,wbr_ret
                mov     ckcon,#ck_pred
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#0
                mov     a,wr_brd_reg1
                xrl     a,blink_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg2
                xrl     a,blink_reg2
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                ret
wbr_skip:       mov     ckcon,#ck_pred
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#0
                mov     a,wr_brd_reg1
                xrl     a,blink_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg2
                xrl     a,blink_reg2
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg4
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
wbr_ret:        ret

init_blikanie:  clr     a
                mov     blink_reg1,a
                mov     blink_reg2,a
                mov     blink_reg3,a
                mov     blink_reg4,a
                mov     blink_old,#0ffh
                ret

do_blikanie:    call    je_blikanie
                jz      db_ret
                call    param_kabina
                jz      db_ret
                xrl     a,#3
                jz      db_can
                mov     a,liftpos
                mov     r0,a
                xrl     a,blink_old
                jz      db_skip1
                mov     blink_old,r0
                clr     a
                mov     blink_reg1,a
                mov     blink_reg2,a
                mov     blink_reg3,a
                mov     blink_reg4,a
                setb    brd_change1
db_skip1:       call    timer_running_reload_f
                dw      t_blikanie
                db      0,0,25
                jnz     db_ret
                mov     a,blink_old
                mov     r0,a
                clr     c
                subb    a,#8
                jnc     db_skip2
                mov     a,r0
                call    get_nrm_mask
                xrl     blink_reg1,a
                setb    brd_change1
                ret
db_skip2:       mov     r0,a
                subb    a,#8
                jnc     db_skip3
                mov     a,r0
                call    get_nrm_mask
                xrl     blink_reg2,a
                setb    brd_change1
                ret
db_skip3:       mov     r0,a
                subb    a,#8
                jnc     db_skip4
                mov     a,r0
                call    get_nrm_mask
                xrl     blink_reg3,a
                ret
db_skip4:       call    get_nrm_mask
                xrl     blink_reg4,a
                ret
db_can:         mov     a,liftpos
                mov     r0,a
                xrl     a,blink_old
                jz      db_ret
                mov     blink_old,r0
                setb    can0_change1
db_ret:         ret

end_blikanie:   call    je_blikanie
                jz      eb_ret
                mov     blink_old,#0ffh
                setb    can0_change1
                clr     a
                mov     blink_reg1,a
                mov     blink_reg2,a
                mov     blink_reg3,a
                mov     blink_reg4,a
                setb    brd_change1
eb_ret:         ret

jazda:          
ifn hydraulika_a3
                call    rele_jazda_kontrola_brzdy
endif
                jz      jzda_skip
                push    acc
                mov     r0,#bola_zapnuta_jazda
                mov     a,#0ffh
                mov     @r0,a
                pop     acc
jzda_skip:      mov     r0,#p_rele_jazda
                sjmp    relay_write

kopia_vystup:   mov     r0,#p_copy_out
                sjmp    relay_write

hviezda_trojuholnik:
                mov     r0,a
                call    je_rele_hv_tr
                cjne    a,#4,hv_tr_ok
                mov     a,r0
                mov     c,acc.1
                mov     rele_7,c
                mov     c,acc.0
                mov     rele_9,c
                ret
hv_tr_ok:       mov     a,r0
                mov     r0,#p_rele_hv_tr
                sjmp    relay_write

nizka_rychlost: mov     r0,#p_rele_nizka
                sjmp    relay_write

stredna_rychlost:
                mov     r0,#p_rele_stredna
                sjmp    relay_write

ventilator2:    mov     r0,#p_vent_out2
                sjmp    relay_write

rel_wr_table:   db      000001b,000000b
                db      000100b,000000b
                db      000000b,001000b
                db      010000b,000000b
                db      100000b,000000b

relay_write:    jz      relay_clear
                mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      rw_ret
                dec     a
rs_entry:       rl      a
                mov     r0,a
                mov     dptr,#rel_wr_table
                movc    a,@a+dptr
                orl     wr_rele_reg2,a
                mov     a,r0
                inc     a
                movc    a,@a+dptr
                orl     wr_rele_reg1,a
rw_ret:         ret
relay_clear:    mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      rw_ret
                dec     a
rc_entry:       rl      a
                mov     r0,a
                mov     dptr,#rel_wr_table
                movc    a,@a+dptr
                cpl     a
                anl     wr_rele_reg2,a
                mov     a,r0
                inc     a
                movc    a,@a+dptr
                cpl     a
                anl     wr_rele_reg1,a
                ret

write_rele_reg1:
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#5
                mov     a,wr_rele_reg1
if jednopovelove_dvere
                mov     a,rele_zat
                jnb     rele_zatvaranie_dveri_a,wrr1_skip1
                setb    acc.0
wrr1_skip1:     jnb     rele_otvaranie_dveri_a,wrr1_skip2
                clr     acc.0
wrr1_skip2:     mov     rele_zat,a
                mov     c,acc.0
                mov     a,wr_rele_reg1
                clr     acc.4
                mov     acc.5,c
endif
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                
                mov     a,wr_can_reg5

                ; reg3.d2
                mov     c,rele_otvaranie_dveri_a
                mov     acc.2,c
                
                ; reg3.d3
                mov     c,rele_zatvaranie_dveri_a
                mov     acc.3,c

                mov     wr_can_reg5,a
                
                setb    can0_change2
                ret

write_rele_regs:
                call    write_rele_reg1
write_rele_reg2:
                call    su_smerove_sipky
                cjne    a,#8,wrr2_ok
                mov     a,wr_rele_reg2
                anl     a,#0c0h;
                rr      a
                rr      a
                mov     r0,a
                mov     a,wr_rele_reg2
                anl     a,#0fh
                orl     a,r0
                sjmp    wrr2_chg
wrr2_ok:        mov     a,wr_rele_reg2
if jednopovelove_dvere
                mov     a,rele_zat
                jnb     rele_zatvaranie_dveri_b,wrr2_skip1
                setb    acc.1
wrr2_skip1:     jnb     rele_otvaranie_dveri_b,wrr2_skip2
                clr     acc.1
wrr2_skip2:     mov     rele_zat,a
                mov     c,acc.1
                mov     a,wr_rele_reg2
                clr     acc.4
                mov     acc.5,c
endif
wrr2_chg:       mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#6
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po

                mov     a,wr_can_reg5

                ; reg3.d0
                mov     c,rele_otvaranie_dveri_b
                mov     acc.0,c
                
                ; reg3.d1
                mov     c,rele_zatvaranie_dveri_b
                mov     acc.1,c

                mov     wr_can_reg5,a
                
                setb    can0_change2
                ret

; called from int!
write_trans_reg:
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#4
                mov     a,wr_trans_reg
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                ret

polohovka_on:   mov     a,r0
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_rvs_mask
                orl     a,@r1
                mov     @r1,a
                ret

polohovka_off:  mov     a,r0
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_rvs_cpl_mask
                anl     a,@r1
                mov     @r1,a
                ret

zapni_poruchu:  mov     a,porucha
                inc     a
                jnz     zapo_skip1
                dec     a
zapo_skip1:     mov     porucha,a
                jz      zapo_skip2
                call    gsm_porucha_on
                mov     r0,#pol_porucha
                call    polohovka_on
                anl     wr_can_reg6,#11011111b                
                setb    can0_change2
zapo_skip2:     mov     r0,#p_porucha
                mov     a,porucha
                call    write_b_k_inv
                jmp     vypis_poschodie

vypni_poruchu:  mov     a,porucha
                jnz     vypo_skip1
                inc     a
vypo_skip1:     dec     a
                mov     porucha,a
                jnz     vypo_skip2
                call    gsm_porucha_off
                mov     r0,#pol_porucha
                call    polohovka_off
                orl     wr_can_reg6,#00100000b
                setb    can0_change2
vypo_skip2:     mov     r0,#p_porucha
                mov     a,porucha
                call    write_b_k_inv
                jmp     vypis_poschodie

gong_on:        orl     wr_can_reg7,#00010000b
                setb    can0_change2
                mov     r0,#pol_gong
                call    polohovka_on
                mov     r0,#p_gong
                call    trans_set

                mov     r0,#lcom_output
                mov     a,@r0
                orl     a,#00100000b
                mov     @r0,a
                
                mov     r0,#banel_output
                mov     a,@r0
                orl     a,#00100000b
                mov     @r0,a

                ret

gong_off:       anl     wr_can_reg7,#11101111b
                setb    can0_change2
                mov     r0,#pol_gong
                call    polohovka_off
                mov     r0,#p_gong
                call    trans_clear

                mov     r0,#lcom_output
                mov     a,@r0
                anl     a,#11011111b
                mov     @r0,a

                mov     r0,#banel_output
                mov     a,@r0
                anl     a,#11011111b
                mov     @r0,a
                
                ret

ohrievanie:     mov     r0,#p_ohrievanie
                sjmp    trans_write

ventilator1:    mov     r0,#p_vent_out1
                sjmp    trans_write

nudzovy_dojazd: mov     r0,#p_nudzovy_dojazd
                sjmp    write_b_k

rele_baterka:   mov     r0,#p_rele_baterka
                sjmp    write_b_k
                
reset_menica:   mov     r0,#p_reset_menica
                sjmp    write_b_k

write_b_k_inv:  jz      set_b_k
                sjmp    clear_b_k
write_b_k:      jz      clear_b_k
set_b_k:        mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      wbk_ret
                dec     a
                mov     r0,a
                clr     c
                subb    a,#8
                jc      ts_b1_8
                jmp     rs_entry

clear_b_k:      mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      wbk_ret
                dec     a
                mov     r0,a
                clr     c
                subb    a,#8
                jc      tc_b1_8
                jmp     rc_entry
wbk_ret:        ret

trans_write_inv:
                jz      trans_set
                sjmp    trans_clear
trans_write:    jz      trans_clear
trans_set:      mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      tw_ret
                dec     a
                mov     r0,a
                clr     c
                subb    a,#8
                jc      ts_b1_8
                mov     r0,a
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_brd_reg1
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_nrm_mask
                orl     a,@r1
                mov     @r1,a
                setb    brd_change1
                ret
ts_b1_8:        mov     a,r0
set_bx:         call    get_nrm_mask
                orl     wr_trans_reg,a
                ret
trans_clear:    mov     dps,#0
                mov     dpx,#0
                mov     a,r0
                add     a,#low(enum_table)
                mov     dpl,a
                clr     a
                addc    a,#high(enum_table)
                mov     dph,a
                movx    a,@dptr
                jz      tw_ret
                dec     a
                mov     r0,a
                clr     c
                subb    a,#8
                jc      tc_b1_8
                mov     r0,a
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_brd_reg1
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_nrm_cpl_mask
                anl     a,@r1
                mov     @r1,a
                setb    brd_change1
                ret
tc_b1_8:        mov     a,r0
clear_bx:       call    get_nrm_cpl_mask
                anl     wr_trans_reg,a
tw_ret:         ret

pretazenie_on:  orl     wr_can_reg7,#00001000b
                setb    can0_change2
                mov     r0,#pol_pretazenie
                call    polohovka_on
                mov     r0,#p_pretazenie
                call    trans_set
                setb    pretazenie
                jmp     vypis_poschodie

pretazenie_off: anl     wr_can_reg7,#11110111b
                setb    can0_change2
                mov     r0,#pol_pretazenie
                call    polohovka_off
                mov     r0,#p_pretazenie
                call    trans_clear
                clr     pretazenie
                jmp     vypis_poschodie

clr_bepol_inc:
clr_pol_clk:    mov     r0,#p_seriovy_0
                jmp     trans_set

set_bepol_inc:
set_pol_clk:    mov     r0,#p_seriovy_0
                jmp     trans_clear

; called from int
set_lcom_data:
clr_bepol_dec:
clr_pol_data:   mov     r0,#p_seriovy_1
                jmp     trans_set

; called from int
clr_lcom_data:
set_bepol_dec:
set_pol_data:   mov     r0,#p_seriovy_1
                jmp     trans_clear

; a=data  r0=cnt  dptr -> table of bit addresses
pol_byte:       mov     r2,a
pb_lp:          clr     a
                movc    a,@a+dptr
                mov     r1,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                xch     a,r1
                anl     a,#7
                call    get_rvs_mask
                xch     a,r2
                rrc     a
                xch     a,r2
                jc      pb_set
                cpl     a
                anl     a,@r1
                sjmp    pb_str
pb_set:         orl     a,@r1
pb_str:         mov     @r1,a
                inc     dptr
                djnz    r0,pb_lp
                ret

vypis_smer:     anl     wr_can_reg5,#7fh
                anl     wr_can_reg6,#7fh
                mov     a,smer_hrd
                jnb     acc.0,vs_skip_fe
                orl     wr_can_reg6,#80h
vs_skip_fe:     jnb     acc.1,vs_skip_ff
                orl     wr_can_reg5,#80h
vs_skip_ff:     setb    can0_change2

                call    su_smerove_sipky
                jz      vs_skip3
                cjne    a,#8,vs_skip1
                mov     a,smer_hrd
                anl     a,#3
                rr      a
                rr      a
                mov     r0,a
                mov     a,wr_rele_reg2
                anl     a,#3fh
                orl     a,r0
                mov     wr_rele_reg2,a
                sjmp    vs_skip3
vs_skip1:       djnz    acc,vs_skip2
                anl     wr_trans_reg,#0fch
                mov     a,smer_hrd
                anl     a,#3
                orl     wr_trans_reg,a
                sjmp    vs_skip3
vs_skip2:       mov     r0,a
                call    get_nrm_cpl_mask2
                anl     wr_trans_reg,a
                mov     a,smer_hrd
                anl     a,#3
vs_lp1:         rl      a
                djnz    r0,vs_lp1
                orl     wr_trans_reg,a
                
vs_skip3:       ; sucik
                mov     a,smer_hrd
                mov     c,acc.0
                rlc     a
                mov     r0,#3
                mov     dptr,#pol_dir1
                call    pol_byte
                ; lcom/banel
                mov     a,smer_hrd
                anl     a,#3
                rr      a
                rr      a
                mov     r1,a
                ; lcom
                mov     r0,#lcom_output
                mov     a,@r0
                anl     a,#00111111b
                orl     a,r1
                mov     @r0,a
                ; banel
                mov     r0,#banel_output
                mov     a,@r0
                anl     a,#00111111b
                orl     a,r1
                mov     @r0,a
vs_ret:         ret

vypis_poschodie:
                call    aky_typ_bcd
                jnb     acc.3,vp_skip0
                anl     a,#7
                add     a,liftpos
                cpl     a
                mov     r2,a
                sjmp    vp_skip98
                
vp_skip0:       add     a,liftpos
                mov     r2,a
vp_skip98:
if vynechat_bcd_kod
                clr     c
                subb    a,#not(ktory_bcd_kod) and 1111b
                jc      vp_skip99
                inc     r2
vp_skip99:
endif
                call    je_grayov_kod
                jz      vp_skip1
                mov     a,r2
                mov     c,acc.7
                rrc     a
                xrl     a,r2
                mov     r2,a

vp_skip1:       
if 0
                call    je_kabina_po_cane       ; bcd kod do RDK
                jz      vp_skip2
                mov     b,r2
                mov     a,wr_can_reg5

                ; reg3.d2
                mov     c,b.0
                mov     acc.2,c
                
                ; reg3.d3
                mov     c,b.1
                mov     acc.3,c

                ; reg3.d5
                mov     c,b.2
                mov     acc.5,c
                
                ; reg3.d6
                mov     c,b.3
                mov     acc.6,c
                
                mov     wr_can_reg5,a
                setb    can0_change2
endif
vp_skip2:       mov     r3,#p_bcd_0
                mov     r4,#5
vp_bcd_lp:      mov     a,r3
                mov     r0,a
                mov     a,r2
                anl     a,#1
                call    trans_write
                mov     a,r2
                rr      a
                mov     r2,a
                inc     r3
                djnz    r4,vp_bcd_lp

                mov     r5,#0
                mov     r4,#8
                mov     r3,#p_1zn_0
                mov     r2,liftpos
vp_1zn_lp:      mov     a,r3
                mov     r0,a
                mov     a,r2
                xrl     a,r5
                call    trans_write_inv
                inc     r3
                inc     r5
                djnz    r4,vp_1zn_lp

                mov     a,liftpos
                inc     a
                add     a,#low(vypis_table)
                mov     dpl,a
                clr     a
                addc    a,#high(vypis_table)
                mov     dph,a
                movx    a,@dptr
                mov     r3,a
                clr     c
                rlc     a
                mov     r7,a
                mov     dptr,#vypis_str_table
                movc    a,@a+dptr
                xch     a,r7
                inc     a
                movc    a,@a+dptr
                mov     r6,a
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     r4,a
                mov     a,r7
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     r5,a
if 0
                call    je_kabina_po_cane
                jz      vp_serial
                mov     a,r4
                clr     acc.7
                anl     wr_can_reg5,#80h
                orl     wr_can_reg5,a
                mov     a,r5
                clr     acc.7
                anl     wr_can_reg6,#80h
                orl     wr_can_reg6,a
                setb    can0_change2
endif
vp_serial:      ; sucik
                mov     a,r4
                mov     r0,#7
                mov     dptr,#pol_dig0
                call    pol_byte
                mov     a,r6
                mov     r0,#8
                mov     dptr,#pol_ascii0
                call    pol_byte
                mov     a,r5
                mov     r0,#6
                mov     dptr,#pol_dig1
                call    pol_byte
                mov     a,r7
                mov     r0,#8
                mov     dptr,#pol_ascii1
                call    pol_byte

                ; bepol
                mov     a,r3
                mov     dptr,#bepol_table
                movc    a,@a+dptr
                mov     r0,#bepol_target
                mov     @r0,a
                
                ; lcom/banel
                mov     a,liftpos
                anl     a,#0fh
                mov     r1,a
                
                ; lift components
                mov     r0,#lcom_output
                mov     a,@r0
                anl     a,#0f0h
                orl     a,r1
                mov     @r0,a
                
                inc     r0
                mov     a,r3
                mov     dptr,#lcom_table
                movc    a,@a+dptr
                anl     a,#00111111b
                ;jnb     rele_svetlo,vp_skip2_1
                ;mov     a,#40           ; svetlo je vypnute -> tma
vp_skip2_1:     jnb     pretazenie,vp_skip3
                orl     a,#80h          ; pretazenie
vp_skip3:       mov     @r0,a
                
                ; banel
                mov     r0,#banel_output
                mov     a,@r0
                anl     a,#0f0h
                orl     a,r1
                mov     @r0,a
                
                inc     r0
                ;mov     a,porucha      ; vykomentovane lebo ak je porucha (fe) tak polohovka zomrie a neblika sipky
                ;jz      vp_skip4
                ;mov     a,#0feh     ; porucha
                ;sjmp    vp_store
vp_skip4:       ;jnb     rele_svetlo,vp_skip5
                ;mov     a,#40           ; svetlo je vypnute -> tma
                ;sjmp    vp_store
vp_skip5:       jnb     pretazenie,vp_skip6
                mov     a,#0ffh     ; pretazenie
                sjmp    vp_store
vp_skip6:       mov     a,r3
                mov     dptr,#lcom_table
                movc    a,@a+dptr
                anl     a,#00111111b
vp_store:       mov     @r0,a
vp_ret:         ret

lcom_int_busy:  clr     ea
                mov     a,lcom_shift1
                orl     a,lcom_shift2
                setb    ea
                ret

lcom_send_byte: clr     ea
                mov     c,p
                cpl     c                       ; parity bit
                push    psw
                add     a,acc                   ; add start bit
                mov     lcom_shift2,a
                mov     a,#00111100b            ; 4 stop bits
                mov     acc.0,c                 ; data bit 7
                pop     psw
                mov     acc.1,c                 ; parity bit
                mov     lcom_shift1,a
                setb    ea
                ret

uloz_jazyk:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#enum_table+p_jazyk
                mov     a,language
                movx    @dptr,a
                jmp     store_parameters

; r0 = new data
; dptr = old data
; r2 = length
pol_detect_change:
                mov     b,#0
pdc_lp:         mov     ar3,@r0
                movx    a,@dptr
                xrl     a,r3
                jz      pdc_next
                orl     b,a
                mov     a,r3
                movx    @dptr,a
pdc_next:       inc     r0
                inc     dptr
                djnz    r2,pdc_lp
                mov     a,b
                jnz     pdc_yes
                call    timer_running_f
                dw      t_polohovka
                jnz     pdc_no
pdc_yes:        call    init_timer_f
                dw      t_polohovka
                db      0,3,0
                mov     a,#0ffh
                ret
pdc_no:         clr     a
                ret

sucik_write_data:
                jnb     pol_writing,swd_try_change
                jbc     pol_clk_hi,swd_get_data
                call    set_pol_clk
                setb    pol_clk_hi
                ret
swd_get_data:   call    clr_pol_clk
                mov     a,pol_index
                jb      acc.7,swd_0
                jz      swd_1
                dec     a
                mov     r0,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#low(pol_table_old)
                mov     dpl,a
                clr     a
                addc    a,#high(pol_table_old)
                mov     dph,a
                clr     a
                mov     dps,a
                mov     dpx,a
                movx    a,@dptr
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_rvs_mask
                anl     a,r1
                jnz     swd_1
swd_0:          call    clr_pol_data
                sjmp    swd_inc
swd_1:          call    set_pol_data
swd_inc:        inc     pol_index
                mov     a,#36+1
                cjne    a,pol_index,swd_ret
                clr     pol_writing
swd_ret:        ret
swd_try_change: mov     r0,#pol_table
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#pol_table_old
                mov     r2,#5
                call    pol_detect_change
                jz      swd_ret
                setb    pol_writing
                setb    pol_clk_hi
                mov     pol_index,#-18
                ret

lcom_write_data:
                jnb     pol_writing,lwd_try_change
                ; is interrupt still writing?
                call    lcom_int_busy
                jnz     lwd_ret
                ; write next byte
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#lcom_output_old
                mov     a,pol_index
                mov     b,#3
                div     ab
                mov     r1,a
                mov     a,b
                jnz     lwd_skip1
                ; byte 1
                mov     a,r1
                mov     b,#3
                div     ab
                mov     a,b
                jnz     lwd_skip0_1
                
                ; message 1
                movx    a,@dptr
                anl     a,#11101111b
                mov     lcom_data,a
                sjmp    lwd_send
                
lwd_skip0_1:    cjne    a,#1,lwd_skip0_2
                ; message 2
                movx    a,@dptr
                anl     a,#11100000b
                orl     a,#1eh
                mov     lcom_data,a
                sjmp    lwd_send
                
lwd_skip0_2:    ; message 3
                movx    a,@dptr
                anl     a,#11100000b
                orl     a,#1fh
                mov     lcom_data,a
                sjmp    lwd_send

lwd_skip1:      cjne    a,#1,lwd_skip2
                ; byte 2
                inc     dptr
                movx    a,@dptr
                xrl     lcom_data,a
                sjmp    lwd_send
lwd_skip2:      ; byte 3
                mov     a,lcom_data
lwd_send:       call    lcom_send_byte
                inc     pol_index
                mov     a,pol_index
                clr     c
                subb    a,#3*3*2
                jc      lwd_ret
                clr     pol_writing
lwd_ret:        ret
lwd_try_change: ; wait for writing to finish
                mov     r0,#lcom_output
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#lcom_output_old
                mov     r2,#2
                call    pol_detect_change
                jz      lwd_ret
                setb    can0_change3
                setb    pol_writing
                mov     pol_index,#0
                ret
lwd_not_yet:    clr     a
                ret

lcom_write_data_banel:
                jnb     pol_writing,lwdb_try_change
                ; is interrupt still writing?
                call    lcom_int_busy
                jnz     lwdb_ret
                ; write next byte
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#banel_output_old
                mov     a,pol_index
                mov     b,#6
                div     ab
                mov     a,b
                jnz     lwdb_skip1
                ; byte 1
                movx    a,@dptr
                anl     a,#11100000b
                orl     a,#0eh
                mov     lcom_data,a
                sjmp    lwdb_send
lwdb_skip1:     cjne    a,#1,lwdb_skip2
                ; byte 2
                inc     dptr
                movx    a,@dptr
                xrl     lcom_data,a
                sjmp    lwdb_send
lwdb_skip2:     cjne    a,#2,lwdb_skip3
                ; byte 3
                mov     a,lcom_data
                sjmp    lwdb_send
lwdb_skip3:     ; dummy bytes
                mov     a,#0aah
lwdb_send:      call    lcom_send_byte
                inc     pol_index
                mov     a,pol_index
                clr     c
                subb    a,#6*2
                jc      lwdb_ret
                clr     pol_writing
lwdb_ret:       ret
lwdb_try_change: 
                ; wait for writing to finish
                mov     r0,#banel_output
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#banel_output_old
                mov     r2,#2
                call    pol_detect_change
                jz      lwdb_ret
                setb    can0_change3
                setb    pol_writing
                mov     pol_index,#0
                ret
lwdb_not_yet:   clr     a
                ret
                
; r0 -> bepol_current
; r1 -> bepol_zero
; r2 = target
; r3 = current
bepol_write_data:
                call    timer_running_f
                dw      t_bepol
                jnz     bwd_ret
                mov     r1,#bepol_zero
                mov     a,@r1
                jz      bwd_write_zero
                mov     r0,#bepol_target
                mov     ar2,@r0
                mov     r0,#bepol_current
                mov     ar3,@r0
                mov     a,r2
                xrl     a,r3
                jz      bwd_ret
                clr     a
                mov     @r1,a
                mov     a,r2
                xrl     a,#23
                jz      bwd_write_both
                mov     a,r2
                clr     c
                subb    a,r3
                jnc     bwd_write_inc
                dec     @r0
                call    clr_bepol_inc
                call    set_bepol_dec
                sjmp    bwd_drain
bwd_write_inc:  inc     @r0
                call    set_bepol_inc
                call    clr_bepol_dec
                sjmp    bwd_drain
bwd_write_both: mov     a,#23
                mov     @r0,a
                call    set_bepol_inc
                call    set_bepol_dec
                sjmp    bwd_drain
bwd_write_zero: mov     a,#1
                mov     @r1,a
                call    clr_bepol_inc
                call    clr_bepol_dec
bwd_drain:      call    init_timer_f
                dw      t_bepol
                db      0,0,7
bwd_ret:        ret
