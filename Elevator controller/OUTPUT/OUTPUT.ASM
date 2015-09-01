; version 4.1

th_output:      dw      output_setup, st_output
                db      id_output, os_bits0, st_output_size

pol_writing     bit     0
pol_clk_hi      bit     1
ohrievame       bit     2

pol_index       data    21h

                bseg
check_svetlo:   dbit    1
check_nizka:    dbit    1
check_kruz_1:   dbit    1
check_kruz_2:   dbit    1
check_gong:     dbit    1

                xseg
call_table_old: ds      no_of_floors

                cseg
                
timer1_int:     clr     ea
                push    psw
                push    acc
                push    dpl
                push    dph
                push    dpx
                push    dps
                push    ar0
                push    ar1
                push    ckcon
                
                mov     dps,#0
                mov     dpx,#0
                anl     psw,#11100111b

                ; reload timer
t1_again:       clr     tr1
                mov     a,tl1                           ; 1
                add     a,#low(-tmr1_period + 7)        ; 1
                mov     tl1,a                           ; 1
                mov     a,th1                           ; 1
                addc    a,#high(-tmr1_period + 7)       ; 1
                mov     th1,a                           ; 1
                setb    tr1                             ; 1
                jc      t1_again
                
                ; 1010 baud polohovka
                mov     a,lcom_shift1
                orl     a,lcom_shift2
                jz      t1_lcom_done
                mov     a,lcom_shift1
                clr     c
                rrc     a
                mov     lcom_shift1,a
                mov     a,lcom_shift2
                rrc     a
                mov     lcom_shift2,a
                jc      t1_lcom_1
                call    clr_lcom_data
                sjmp    t1_lcom_out
t1_lcom_1:      call    set_lcom_data
t1_lcom_out:    jnb     brd_change1,t1_lcom_done
                clr     brd_change1
                call    write_brd_regs
t1_lcom_done:

                ; mux
                jnb     im_da_boss,t1_ret
                mov     a,mux_state
                jz      t1_ret
                djnz    mux_timer,t1_ret
                mov     a,mux_state
                dec     a
                rl      a
                mov     dptr,#t1_mux_table
                jmp     @a+dptr
t1_ret:         
                mov     a,wr_trans_reg
                xch     a,owr_trans_reg
                xrl     a,owr_trans_reg
                jz      t1_ret2
                call    write_trans_reg
t1_ret2:        
                pop     ckcon
                pop     ar1
                pop     ar0
                pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     acc
                pop     psw
                setb    ea
                reti
                
gong_vysoka:    call    do_them
                call    do_them
                call    kedy_je_gong
                mov     c,acc.0
                orl     c,acc.1
                jnc     zapni_gong
                ret

gong_zastavenie:
                call    kedy_je_gong
                jb      acc.0,zapni_gong
                ret

gong_otvorenie: call    kedy_je_gong
                jb      acc.1,zapni_gong
                ret

zapni_gong:     call    gong_on
                setb    check_gong
                call    init_timer_f
                dw      t_check_gong
                db      0,1,0
                ret

zapni_hv_tr:    call    je_rele_hv_tr
                jz      zht_ret
                cjne    a,#4,zht_normal
                mov     a,#2
                call    hviezda_trojuholnik
zht_normal:     mov     check_hv_tr,#1
                mov     a,#t_zapni_hv_tr
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_check_hv_tr
                jmp     init_timer
zht_ret:        ret

prestan_hv_tr:  mov     check_hv_tr,#0
                clr     check_kruz_1
                clr     check_kruz_2
                ret

zapni_nizka:    call    je_rele_nizka
                jz      zn_ret
                setb    check_nizka
                call    init_timer_f
                dw      t_check_nizka
                db      0,0,25
zn_ret:         ret

prestan_nizka:  clr     check_nizka
                ret

output_setup:   orl     tmod,#10h
                clr     tr1
                mov     tl1,#low(-tmr1_period)
                mov     th1,#high(-tmr1_period)
                setb    tr1
                setb    et1
                
                call    init_blikanie

                setb    can0_change1
                setb    can0_change2
                setb    can0_change3
                
                clr     a
                mov     lcom_shift1,a
                mov     lcom_shift2,a
                mov     wr_brd_reg1,a
                mov     wr_brd_reg2,a
                mov     wr_brd_reg3,a
                mov     wr_brd_reg4,a
                mov     wr_trans_reg,a
                mov     owr_trans_reg,a
                mov     wr_can_reg5,a
                mov     wr_can_reg6,a
                mov     wr_can_reg7,a
                mov     wr_rele_reg1,a
                mov     wr_rele_reg2,a
                mov     owr_rele_reg1,a
                mov     owr_rele_reg2,a

                call    write_brd_regs
                call    write_trans_reg
                call    write_rele_regs

                mov     r0,#call_table
                mov     r1,#no_of_floors
                call    clear_ram

                mov     r1,#no_of_floors
                mov     dptr,#call_table_old
                mov     a,#70h
out_stp_lp:     movx    @dptr,a
                inc     dptr
                djnz    r1,out_stp_lp

                call    init_volby2
                clr     check_svetlo
                clr     check_nizka
                clr     pol_writing
                clr     check_kruz_1
                clr     check_kruz_2
                clr     check_gong
                clr     ohrievame
                clr     pretazenie
                setb    nezapinaj_fazy  ;clr nezapinaj_fazy  aby necvakalo rele fazy
                setb    brd_change1
                
                clr     a
                mov     r0,#bepol_target
                mov     @r0,a
                mov     r0,#bepol_current
                mov     @r0,a
                mov     r0,#bepol_zero
                mov     @r0,a
                
if snimac_c_reset_po_10_min
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#reset_me
                clr     a
                movx    @dptr,a
endif

                clr     a
                mov     osmer,#0ffh
                mov     oliftpos,#0aah
                mov     check_hv_tr,a
                mov     vent_state,a
                mov     porucha,a
                mov     pol_div,a

                call    pretazenie_off
                call    vypni_poruchu
                call    gong_off
                call    gong_nevidiaci_off

output_main_lp: call    do_them
                call    show_calls
                mov     a,check_hv_tr
                jz      out_skip1
                call    timer_running_f
                dw      t_check_hv_tr
                jnz     out_skip1
                call    je_rele_hv_tr
                cjne    a,#4,out_skip0
                mov     a,check_hv_tr
                cjne    a,#1,out_skip0
                inc     check_hv_tr
                call    init_timer_f
                dw      t_check_hv_tr
                db      0,0,10
                clr     a
                call    hviezda_trojuholnik
                sjmp    out_skip1

out_skip0:      mov     check_hv_tr,#0
                mov     a,#1
                call    hviezda_trojuholnik
                setb    check_kruz_1
                mov     a,#t_cas_kruz_1
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_kruzkovy
                call    init_timer

out_skip1:      jnb     check_nizka,out_skip2
                call    timer_running_f
                dw      t_check_nizka
                jnz     out_skip2
                clr     check_nizka
                mov     a,#1
                call    nizka_rychlost

out_skip2:      mov     a,smer
                jb      acc.2,out_skip2_1
                xch     a,osmer
                xrl     a,osmer
                jz      out_skip3
                mov     smer_hrd,smer
                call    vypis_smer
                sjmp    out_skip3
out_skip2_1:    xch     a,osmer
                xrl     a,osmer
                jnz     out_skip2_2
                call    timer_running_f
                dw      t_smer_blink
                jnz     out_skip3
                ; blinking
                mov     a,smer
                cjne    a,#alt_blink,out_skip2_10
                ; alternate
                mov     a,smer_hrd
                cjne    a,#1,out_skip2_11
                mov     a,#2
                sjmp    out_skip2_3
out_skip2_11:   mov     a,#1
                sjmp    out_skip2_3
out_skip2_10:   ; up down or both
                mov     a,smer_hrd
                jz      out_skip2_2
                clr     a
                sjmp    out_skip2_3
out_skip2_2:    mov     a,smer
                clr     acc.2
out_skip2_3:    mov     smer_hrd,a
                call    init_timer_f
                dw      t_smer_blink
                db      0,2,0
                call    vypis_smer

out_skip3:      clr     a
                mov     c,pretazenie
                rrc     a
                ;mov     c,rele_svetlo
                ;rrc     a
                xrl     a,liftpos
                rr      a
                xrl     a,porucha
                
                xch     a,oliftpos
                xrl     a,oliftpos
                jnz     out_skip3_send
                call    timer_running_f
                dw      t_poschodie
                jnz     out_skip4
out_skip3_send: call    init_timer_f
                dw      t_poschodie
                db      0,3,0
                call    vypis_poschodie
                setb    can0_change1
                setb    can0_change2
                setb    can0_change3
                mov     c,blokuj_volby
                orl     c,zakaz_vonkajsie
                jc      out_skip4
                call    aka_skupina
                jz      out_skip4
                call    je_zdochnutie
                jnz     out_skip4
                call    g_send_loc
out_skip4:
if kruzkovy_motor
                jnb     check_kruz_1,out_skip5
                call    timer_running_f
                dw      t_kruzkovy
                jnz     out_skip5
                clr     check_kruz_1
                setb    rele_kruzkovy_1
                setb    check_kruz_2
                mov     a,#t_cas_kruz_2
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_kruzkovy
                call    init_timer

out_skip5:      jnb     check_kruz_2,out_skip6
                call    timer_running_f
                dw      t_kruzkovy
                jnz     out_skip6
                clr     check_kruz_2
                setb    rele_kruzkovy_2
out_skip6:
endif
                jnb     check_gong,out_skip7_1
                call    timer_running_f
                dw      t_check_gong
                jnz     out_skip7_1
                clr     check_gong
                call    gong_off

out_skip7_1:    mov     dps,#0
                mov     dptr,#check_gong2
                movx    a,@dptr
                jz      out_skip7_2
                call    timer_running_f
                dw      t_check_gong2
                jnz     out_skip7_2
                call    gong_nevidiaci_off

out_skip7_2:    call    aky_seriovy_kod
                jz      out_skip8
                cjne    a,#1,out_skip7_try2
                ; sucik
                inc     pol_div
                mov     a,#5
                cjne    a,pol_div,out_skip8
                mov     pol_div,#0
                call    sucik_write_data
                sjmp    out_skip8

out_skip7_try2: cjne    a,#2,out_skip7_try3
                ; liftcomponents
                call    lcom_write_data
                sjmp    out_skip8

out_skip7_try3: cjne    a,#3,out_skip7_try4
                ; banel
                call    lcom_write_data_banel
                sjmp    out_skip8
                
out_skip7_try4: cjne    a,#4,out_skip8
                ; bepol
                call    bepol_write_data

out_skip8:      mov     a,vent_state
                jnz     out_skip8_1
                call    je_ventilator
                jz      out_skip9
                mov     a,#0ffh
                call    ventilator1
                mov     a,#0ffh
                call    ventilator2
                orl     wr_can_reg6,#01000000b
                setb    can0_change2
out_skip8_ent:  call    init_timer_f
                dw      t_ventilator
                db      0,5,0
                inc     vent_state
                sjmp    out_skip9
out_skip8_1:    cjne    a,#1,out_skip8_2
                call    ventilator_od_casu
                jz      out_skip8_1_1
                call    je_ventilator
                jnz     out_skip9
                sjmp    out_skip8_off
out_skip8_1_1:  call    timer_running_reload_f
                dw      t_ventilator
                db      2,0,0
                jnz     out_skip9
                inc     vent_state
                sjmp    out_skip9
out_skip8_2:    cjne    a,#2,out_skip8_3
                call    je_ventilator
                jz      out_skip8_tm
                clr     a
                call    ventilator1
                clr     a
                call    ventilator2
                anl     wr_can_reg6,#10111111b
                setb    can0_change2
                jmp     out_skip8_ent
out_skip8_tm:   call    timer_running_f
                dw      t_ventilator
                jnz     out_skip9
out_skip8_off:  clr     a
                call    ventilator1
                clr     a
                call    ventilator2
                anl     wr_can_reg6,#10111111b
                setb    can0_change2
                mov     vent_state,#0
                sjmp    out_skip9
out_skip8_3:    call    timer_running_f
                dw      t_ventilator
                jnz     out_skip9
                mov     vent_state,#0

out_skip9:      
if auto_vytah and auto_vytah_special
                call    au_special
endif
                jnb     brd_change1,out_skip10
                clr     brd_change1
                call    write_brd_regs

out_skip10:     mov     a,wr_trans_reg
                xch     a,owr_trans_reg
                xrl     a,owr_trans_reg
                jz      out_skip11
                call    write_trans_reg

out_skip11:     jb      nezapinaj_fazy,out_skip12
                call    param_fazy
                jz      out_skip12
                mov     c,poradie_faz
                clr     a
                rlc     a
                call    nudzovy_dojazd
out_skip12:
if snimac_c_reset_po_10_min
                ; pribram
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#reset_me
                movx    a,@dptr
                jz      out_skip13
                call    timer_running_f
                dw      t_reset_me
                jnz     out_skip13
                jmp     starting_point
endif
out_skip13:
                call    je_ohrievanie
                jz      out_skip16
                mov     r0,#i2c_time+6
                mov     a,@r0
                mov     r0,a
                jb      acc.7,out_skip14
                jb      ohrievame,out_skip15
                call    teplota_zap
                clr     c
                subb    a,r0
                jc      out_skip16

out_skip14:     mov     a,#1
                call    ohrievanie
                setb    ohrievame
                sjmp    out_skip16

out_skip15:     call    teplota_vyp
                clr     c
                subb    a,r0
                jnc     out_skip16
                clr     a
                call    ohrievanie
                clr     ohrievame
                
out_skip16:     call    je_kopia_vstup
                jz      out_skip17
                call    kopia_vstup
                call    kopia_vystup

out_skip17:     
if eurovea
                ; specialne eurovea
                mov     c,a2
                cpl     c
                orl     c,uz_je_revizna
                orl     c,uz_je_nudzova
                mov     rele_10,c
endif

                ; refresh relay outputs
out_skip18:     mov     a,wr_rele_reg1
                xch     a,owr_rele_reg1
                xrl     a,owr_rele_reg1
                jz      out_skip18_1
                call    write_rele_reg1
                
out_skip18_1:   mov     a,wr_rele_reg2
                xch     a,owr_rele_reg2
                xrl     a,owr_rele_reg2
                jz      out_skip18_2
                call    write_rele_reg2
out_skip18_2:

                jmp     output_main_lp
