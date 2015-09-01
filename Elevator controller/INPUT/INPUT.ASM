; version 4.1

th_initial:     dw      input_setup, st_input
                db      id_input, 0, st_input_size

timer0_int:     clr     ea
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
                anl     psw,#11100111b

                ; hw watchdog
                mov     ta,#0aah
                mov     ta,#055h
                orl     wdcon,#1
                
                ; sw watchdog
t0_again:       inc     thread_wd
                mov     a,thread_wd
                add     a,#-os_wd2
                jnc     t0_os_wd_ok
                ; sw reset
                mov     os_rst_src,#4
                jmp     os_init
t0_os_wd_ok:
                ; ticks
                inc     timer0_events
                
                ; a/c indices
                djnz    ac_index1,t0_ac_skip1
                mov     ac_index1,#20
t0_ac_skip1:    djnz    ac_index2,t0_ac_skip2
                mov     ac_index2,#20
t0_ac_skip2:    djnz    ac_index3,t0_ac_skip3
                mov     ac_index3,#20
t0_ac_skip3:
                ; reload timer
                clr     tr0
                mov     a,tl0                           ; 1
                add     a,#low(-tmr0_period + 7)        ; 1
                mov     tl0,a                           ; 1
                mov     a,th0                           ; 1
                addc    a,#high(-tmr0_period + 7)       ; 1
                mov     th0,a                           ; 1
                setb    tr0                             ; 1
                jc      t0_again
                
                ; read a/c values
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#5
                movx    a,@dptr
                mov     dpx,#0
                mov     r1,a

                mov     a,ac_index1
                add     a,#ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#11001111b
                orl     a,@r0
                mov     @r0,a
                
                mov     a,ac_index2
                add     a,#ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#10101111b
                orl     a,@r0
                mov     @r0,a
                
                mov     a,ac_index3
                add     a,#ac_table - 1
                mov     r0,a
                mov     a,r1
                anl     a,#10011111b
                orl     a,@r0
                mov     @r0,a

                ; counter
                djnz    ac_cnt,t0_ac_done
                mov     ac_cnt,#40              ; pocet 1ms period ako dlho sa citaju AC vstupy
                
                ; evaluation
                push    ar2
                push    ar3
                clr     a
                mov     r0,#ac_table
                mov     r1,a
                mov     r2,a
                mov     r3,#20
                mov     ac_rd,a
t0_eval_lp1:    mov     a,@r0
                orl     ac_rd,a
                anl     a,#01110000b
                jnz     t0_eval_nz
                inc     r1
t0_eval_nz:     xrl     a,#01110000b
                jnz     t0_eval_nff
                inc     r2
t0_eval_nff:    clr     a
                mov     @r0,a
                inc     r0
                djnz    r3,t0_eval_lp1
                mov     a,#5                    ; min pocet '000' z 20
                setb    c
                subb    a,r1
                jnc     t0_eval_bad
                mov     a,#2                    ; min pocet '111' z 20
                subb    a,r2
t0_eval_bad:    mov     a,ac_maj
                rlc     a
                mov     ac_maj,a
                mov     r0,#0
                mov     r1,#8
t0_eval_lp2:    rlc     a
                xch     a,r0
                addc    a,#0
                xch     a,r0
                djnz    r1,t0_eval_lp2
                mov     a,#4                    ; min pocet '1' z 8
                setb    c
                subb    a,r0
                mov     poradie_faz,c
                ;jnb     ac_ignore,oui_eval_done
                ;mov     a,ac_rd
                ;orl     a,oac_rd
                ;mov     ac_rd,a
t0_eval_done:   pop     ar3
                pop     ar2

t0_ac_done:     jnb     inc_running,t0_inc_done
                clr     a
                mov     c,inc_toggle
                rlc     a
                mov     c,inc_otoggle
                rlc     a
                jnb     p,t0_inc_done
                cpl     inc_otoggle
                jb      inc_dir,t0_inc_up
                clr     c
                mov     a,inc_cnt_lo
                subb    a,#1
                mov     inc_cnt_lo,a
                mov     a,inc_cnt_hi
                subb    a,#0
                mov     inc_cnt_hi,a
                sjmp    t0_inc_done
t0_inc_up:      mov     a,inc_cnt_lo
                add     a,#1
                mov     inc_cnt_lo,a
                clr     a
                addc    a,inc_cnt_hi
                mov     inc_cnt_hi,a
t0_inc_done:

t0_ret:         pop     ckcon
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

do_majority5:   mov     r3,a
                mov     dps,#5
                mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
                mov     r2,#5
do_maj5_lp1:    movx    a,@dptr
                xch     a,r3
                movx    @dptr,a
                mov     @r0,a
                mov     @r1,a
                inc     dptr
                inc     r0
                inc     r1
                djnz    r2,do_maj5_lp1
                mov     dps,#0
                mov     b,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
do_maj5_lp2:    mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     b,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp2
                mov     a,b
                ret

refresh_inputs: mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_spolu
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg1
                call    do_majority5
                mov     rd_brd_reg1,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg2
                call    do_majority5
                mov     rd_brd_reg2,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg3,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg4,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     kb_data,a
                mov     dptr,#6
                movx    a,@dptr
                xrl     a,#00111101b
                call    do_majority5
                mov     rd_24v_reg1,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_24v_reg2,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                ret

refresh_inputs3:
                mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_kabina
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg1
                call    do_majority5
                mov     rd_brd_reg1,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg2
                call    do_majority5
                mov     rd_brd_reg2,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                ret

decide_majority5:
                mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
                mov     r2,#5
dc_maj5_lp1:    movx    a,@dptr
                mov     @r0,a
                mov     @r1,a
                inc     dptr
                inc     r0
                inc     r1
                djnz    r2,dc_maj5_lp1
                mov     b,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
dc_maj5_lp2:    mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     b,a
                dec     r1
                dec     r1
                djnz    r2,dc_maj5_lp2
                mov     a,b
                ret

refresh_inputs_k:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#mjrt_kabina
                call    decide_majority5
                mov     r0,#rd_kabina
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_kabina+1
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_kabina+2
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_kabina+3
                mov     @r0,a
                ret

refresh_inputs_d1:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#mjrt_dole
                call    decide_majority5
                mov     r0,#rd_dole
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_dole+1
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_dole+2
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_dole+3
                mov     @r0,a
                ret

refresh_inputs_d2:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#mjrt_dole
                call    decide_majority5
                mov     r0,#rd_dole
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_dole+1
                mov     @r0,a
                jnb     mux_all_32,rid2_ret
                call    decide_majority5
                mov     r0,#rd_dole+2
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_dole+3
                mov     @r0,a
rid2_ret:       ret

refresh_inputs_h:
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#mjrt_hore
                call    decide_majority5
                mov     r0,#rd_hore
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_hore+1
                mov     @r0,a
                jnb     mux_all_32,rih_ret
                call    decide_majority5
                mov     r0,#rd_hore+2
                mov     @r0,a
                call    decide_majority5
                mov     r0,#rd_hore+3
                mov     @r0,a
rih_ret:        ret

refresh_snimace:
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#6
                movx    a,@dptr
                mov     r0,a
                mov     ckcon,#ck_po
                call    inverzia_h_d
                jz      rs_skip1
                mov     a,r0
                cpl     a
                mov     r0,a
rs_skip1:       clr     a
                mov     c,c_snimac
                rlc     a
                mov     c,b_snimac_n
                cpl     c
                rlc     a
                mov     c,a_snimac_n
                cpl     c
                rlc     a
                mov     r1,a
                call    inverzia_a_b
                jz      rs_skip2
                mov     r2,#00000011b
                call    c_vedla_a_b
                jz      rs_skip1_1
                mov     r2,#00000111b
rs_skip1_1:     mov     a,r1
                xrl     a,r2
                mov     r1,a
rs_skip2:       mov     a,r1
                anl     a,#00000111b
                xch     a,r0
                anl     a,#11000000b
                orl     a,r0
                mov     r1,a
                mov     r0,#snimace_table
                xch     a,@r0
                mov     r2,a
                inc     r0
                xch     a,@r0
                mov     r3,a
                anl     a,r2
                mov     r4,a
                mov     a,r2
                orl     a,r3
                anl     a,r1
                orl     a,r4
                mov     snimace,a
                ret

if 0
start_ac_ignore:
                mov     a,ac_rd
                anl     a,#10001111b
                mov     oac_rd,a
                setb    ac_ignore
                call    init_timer_f
                dw      t_ac_ignore
                db      0,2,0
                ret
endif

revizna_volby:  mov     c,uz_je_nudzova
                orl     c,uz_je_revizna
                jc      rv_ret
                mov     a,rev_old
                mov     c,hore24
                mov     acc.0,c
                mov     c,dole24
                mov     acc.1,c
                mov     r0,a
                cpl     a
                anl     a,rev_old
                mov     rev_old,r0
                jnb     acc.0,rv_try_dole
                push    acc
                mov     a,liftpos
                inc     a
                mov     r4,a
                xrl     a,floor_no
                jz      rv_skip1
                mov     r3,#g_kabina
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                call    ovr_msg
rv_skip1:       pop     acc
rv_try_dole:    jnb     acc.1,rv_ret
                mov     a,liftpos
                jz      rv_ret
                dec     a
                mov     r4,a
                mov     r3,#g_kabina
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                jmp     ovr_msg
rv_ret:         ret

input_setup:    clr     ea
                ;clr     ac_ignore
                mov     ac_index1,#1
                mov     ac_index2,#1 + 7
                mov     ac_index3,#1 + 7 + 7
                mov     ac_cnt,#40
                clr     a
                mov     ac_rd,a
                mov     ac_maj,a
                mov     mux_state,a
                mov     timer0_events,a
                clr     inc_running
                clr     im_da_boss
                setb    ea

                call    initialize_timers
                clr     f_in_use
                clr     f_do_them
                call    f_identify
                call    f_reset
                call    read_parameters
                call    f_reset
                call    read_parameters

                call    pocet_poschodi
                call    update_floorno

                call    aky_jazyk
                mov     language,a

                call    inc_init
                call    mux_init

                clr     a
                mov     rd_brd_reg1,a
                mov     rd_brd_reg2,a
                mov     rd_brd_reg3,a
                mov     rd_brd_reg4,a
                mov     rd_can_reg5,a
                mov     rd_can_reg6,a

                mov     r0,#bola_zapnuta_jazda
                clr     a
                mov     @r0,a

                mov     dptr,#rd_kabina_o
                mov     r0,#4
                call    clear_movx
                
                mov     dptr,#mjrt_spolu
                mov     r0,#35
                call    clear_movx

                mov     dptr,#mjrt_kabina
                mov     r0,#20
                call    clear_movx

                mov     dptr,#mjrt_dole
                mov     r0,#20
                call    clear_movx

                mov     dptr,#mjrt_hore
                mov     r0,#20
                call    clear_movx

                call    init_volby
                clr     blokuj_volby
                clr     uz_mame_volbu
                clr     uz_mame_vonkajsiu_volbu
                clr     zakaz_vonkajsie
                clr     zakaz_vonkajsie0
                clr     zakaz_pohon
                mov     nahodne_volby,#0

                call    su_vobec_dvere_a_
                call    su_vobec_dvere_b_

                mov     liftpos,#0ffh
                clr     a
                mov     error_no,a
                mov     nextfloor,a
                mov     liftstate,#s_dvere
                mov     dvere_a,#d_nie_su
                mov     dvere_b,#d_nie_su
                mov     error_a,a
                mov     error_b,a
                mov     tlac_otv_state,a
if 0
                mov     vaz_80_state,a
endif
                mov     dptr,#th_serial
                call    run_it
                mov     dptr,#th_output
                call    run_it
                mov     dptr,#th_group
                call    run_it
                mov     dptr,#th_commander
                call    run_it

                mov     a,os_rst_src
                jz      input_main_lp
                cjne    a,#1,in_st_err1
                mov     a,#e_por_reset
                sjmp    in_st_end
in_st_err1:     cjne    a,#2,in_st_err2
                mov     a,#e_wd_reset
                sjmp    in_st_end
in_st_err2:     cjne    a,#3,in_st_err3
                mov     a,#e_osc_reset
                sjmp    in_st_end
in_st_err3:     cjne    a,#4,in_st_err4
                mov     a,#e_os_reset
                sjmp    in_st_end
in_st_err4:
in_st_end:      call    zapis_chybu

input_main_lp:  call    do_them

                clr     ea
                mov     a,timer0_events
                add     a,#-10
                jnc     iml_skip0_1
                mov     timer0_events,a
                setb    ea
                call    decrement_timers
iml_skip0_1:    setb    ea

                call    timer_running_reload_f
                dw      t_refresh
                db      0,0,4
                jnz     iml_skip2
                call    vazenie_10
                call    vazenie_80
                call    vazenie_110
                call    refresh_inputs
                mov     a,mux_state
                jnz     iml_skip1
                call    in_kabina
                call    in_dole
                call    in_hore
                setb    poll_calls
if auto_vytah and not auto_vytah_special
                call    au_update_in
                call    au_out_outside
                call    au_out_open
                call    au_out_wall
endif
                sjmp    iml_skip2
iml_skip1:      clr     c
                subb    a,#7
                jc      iml_skip2
                jb      mux_all_32,iml_skip2
                call    refresh_inputs3
                call    in_kabina
                setb    poll_calls
iml_skip2:      mov     a,mux_state
                jz      iml_skip6
                jnb     mux_new_k,iml_skip3
                clr     mux_new_k
                call    refresh_inputs_k
                setb    poll_calls
iml_skip3:      jnb     mux_new_d1,iml_skip4
                clr     mux_new_d1
                call    refresh_inputs_d1
                setb    poll_calls
iml_skip4:      jnb     mux_new_d2,iml_skip5
                clr     mux_new_d2
                call    refresh_inputs_d2
                setb    poll_calls
iml_skip5:      jnb     mux_new_h,iml_skip6
                clr     mux_new_h
                call    refresh_inputs_h
                setb    poll_calls
iml_skip6:      call    refresh_snimace
                call    revizna_volby
                ;jnb     ac_ignore,iml_skip7
                ;call    timer_running_f
                ;dw      t_ac_ignore
                ;jnz     iml_skip7
                ;clr     ac_ignore
iml_skip7:      mov     a,nahodne_volby
                jnb     acc.0,iml_skip8
                jnb     acc.1,iml_skip7_1
                ; got a call
                call    je_nejaka_volba
                jnz     iml_skip8
                ; call done
                xrl     nahodne_volby,#2
                call    init_timer_f
                dw      t_nahodne
                db      1,0,0
                sjmp    iml_skip8
iml_skip7_1:    ; no call
                call    timer_running_f
                dw      t_nahodne
                jnz     iml_skip8
                ; add random call
                xrl     nahodne_volby,#2
                call    random
                mov     b,floor_no
                div     ab
                mov     a,b
                ; add call
                mov     r4,a
                mov     r3,#g_kabina
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                call    ovr_msg
                call    do_them
                call    do_them
                call    do_them
iml_skip8:      mov     a,tlac_otv_state
                jnz     iml_skip8_1
                ; off
                call    tlacitko_otvarania_dveri
                jz      iml_skip9
                ; 0 -> 1
                call    init_timer_f
                dw      t_tlac_otv
                db      0,10,0
                inc     tlac_otv_state
                sjmp    iml_skip9
iml_skip8_1:    cjne    a,#1,iml_skip8_2
                ; on, counting 5s
                call    tlacitko_otvarania_dveri
                jz      iml_skip8_0
                call    timer_running_reload_f
                dw      t_tlac_otv
                db      0,5,0
                jnz     iml_skip9
                ; 1 -> 2
                inc     tlac_otv_state
                sjmp    iml_skip9
iml_skip8_2:    cjne    a,#2,iml_skip8_3
                ; on, 5s dead time
                call    timer_running_reload_f
                dw      t_tlac_otv
                db      5,0,0
                jnz     iml_skip9
                ; 2 -> 3
                inc     tlac_otv_state
                sjmp    iml_skip9
iml_skip8_3:    cjne    a,#3,iml_skip8_0
                ; on, nezavisla active for 5 mins
                call    tlacitko_otvarania_dveri
                jnz     iml_skip8_0
                call    timer_running_f
                dw      t_tlac_otv
                jnz     iml_skip9
                ; 3 -> 0
iml_skip8_0:    mov     tlac_otv_state,#0
iml_skip9:
if reset_ak_volby_a_nejazdi
                ; if there are calls but elevator is not moving -> reset
                ; watchdog feature
                call    aka_je_chyba
                jnz     iml_skip9_no
                mov     c,je_obed_program
                orl     c,je_ranny_program
                orl     c,je_nezavisla_jazda
                orl     c,dorovnava_sa
                orl     c,uz_je_nudzova
                orl     c,uz_je_revizna
                jc      iml_skip9_no
                mov     a,je_poziarna_jazda
                jnz     iml_skip9_no
                mov     a,liftstate
                xrl     a,#s_dvere
                jnz     iml_skip9_no
                mov     a,error_a
                orl     a,error_b
                jnz     iml_skip9_no
                mov     a,dvere_a
                orl     a,dvere_b
                jnz     iml_skip9_no
                call    je_nejaka_volba
                jz      iml_skip9_no
                jb      ovazenie_80,iml_skip9_no
                mov     a,#id_stopped
                call    is_thread_on
                jz      iml_skip9_no
                ; yes
                call    timer_running_f
                dw      t_not_moving
                jnz     iml_skip10
                ; reset
                jmp     reset_mcu
iml_skip9_no:   ; no
                call    init_timer_f
                dw      t_not_moving
                db      1,0,0
iml_skip10:
endif
                jmp     input_main_lp
