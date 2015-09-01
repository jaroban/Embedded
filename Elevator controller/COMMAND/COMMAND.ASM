; version 4.1

th_commander:   dw      commander, st_commander
                db      id_commander, os_bank1, st_commander_size

m_left          equ     0
m_right         equ     1
m_up            equ     2
m_down          equ     3
m_enter         equ     4
m_author        equ     5
m_gsm           equ     6

c_index         data    8
cgp0            data    9
cgp1            data    10
cgp2            data    11
cgp3            data    12
cgp4            data    13
cgp5            data    14
cgp6            data    15
error_lo        data    9
error_hi        data    10

                dseg
lcd_ind:        ds      1

                cseg
password_len    equ     4
password:       db      m_enter,m_down,m_up,m_right

commander:      mov     supervisor,#0
                call    lcd_setup
                call    lcd_clear
                mov     dptr,#th_follower
                call    run_it
                call    wait_for_timer_f
                dw      t_command
                db      0,0,10
                ; initial text
                mov     dptr,#init_text
                call    puts_n
                ; delay for poland
                call    wait_for_timer_f
                dw      t_command
                db      0,4,0
                ; flash type
                call    lcd_clear
                mov     dptr,#flash_text1
                call    puts_n
                mov     lcd_ind,#16
                mov     a,flash_type
                mov     dptr,#flash_text2
                call    puts_na
                ; more delay
                call    wait_for_timer_f
                dw      t_command
                db      0,3,0
                clr     a
                mov     cgp0,a
                mov     cgp1,a
                mov     kb_data,a
com_int_lp:     call    do_them
                mov     a,kb_data
                orl     cgp1,a
                call    get_msg
                jnc     com_int_skip3
                mov     a,r1
                xrl     a,#m_author
                jz      com_passed
                mov     dptr,#password
                mov     a,cgp0
                movc    a,@a+dptr
                xrl     a,r1
                inc     cgp0
                jz      com_int_skip2
                mov     cgp0,#0
com_int_skip2:  mov     a,cgp0
                xrl     a,#password_len
                jz      com_passed
                call    init_timer_f
                dw      t_command
                db      0,2,0
com_int_skip3:  call    timer_running_f
                dw      t_command
                jnz     com_int_lp
                mov     a,cgp1
                jnb     acc.4,com_normal
                mov     supervisor,#1
                sjmp    com_passed2
com_passed:     mov     supervisor,#2
com_passed2:    mov     dptr,#th_can_test
                call    run_it
                call    lcd_clear
                mov     dptr,#author_text
                call    puts_n
                call    wait_for_timer_f
                dw      t_command
                db      0,1,50
                call    delete_my_messages
                mov     c_index,#0
                jmp     level0_menu
com_normal:     call    lcd_clear
                call    aky_vypis
                jz      com_int_skip4
                dec     a
                mov     dptr,#init_text2
                call    puts_na
                call    wait_for_timer_f
                dw      t_command
                db      0,2,0
com_int_skip4:  mov     dptr,#th_can
                call    run_it
                clr     je_nahravacia
                mov     dptr,#th_safety
                call    run_it
                call    lcd_clear
                call    param_fazy
                jz      com_nie_fazy
                mov     dptr,#f_z_text1
                call    puts_n
                mov     lcd_ind,#16
                jb      poradie_faz,com_fazy_dobre
                mov     dptr,#f_z_text2
                call    puts_n
                call    wait_for_timer_f
                dw      t_command
                db      0,1,50
com_fazy_lp:    call    do_them
                jb      uz_je_nudzova,com_nie_fazy
                jnb     poradie_faz,com_fazy_lp
                sjmp    com_nie_fazy
com_fazy_dobre: mov     dptr,#f_z_text3
                call    puts_n
                call    wait_for_timer_f
                dw      t_command
                db      0,1,50
com_nie_fazy:   jmp     rtm1_start

level0_menu:    call    lcd_clear
                mov     a,c_index
                mov     dptr,#level0_text
                call    puts_na
level0_wait:    call    do_them
                call    do_vnts
                dw      m_up+j_,level0_prev
                dw      m_down+j_,level0_next
                dw      m_enter+j_,level0_exec
                db      0
                jmp     level0_wait

level0_prev:    mov     a,supervisor
                jnz     lvl0_prv_skp
                jmp     rtm5_start
lvl0_prv_skp:   mov     a,c_index
                jnz     lvl0_prv_skp2
                jmp     rtm5_start
lvl0_prv_skp2:  dec     c_index
                jmp     level0_menu

level0_next:    mov     a,supervisor
                jnz     lvl0_nxt_skp
                jmp     rtm1_start
lvl0_nxt_skp:   cjne    a,#1,lvl0_nxt_2
                mov     a,c_index
                cjne    a,#3,lvl0_nxt_skp2
                jmp     rtm5_start
lvl0_nxt_skp2:  inc     c_index
                jmp     level0_menu
lvl0_nxt_2:     mov     a,c_index
                cjne    a,#5,lvl0_nxt_skp2
                jmp     rtm5_start

level0_exec:    push    c_index
                mov     dptr,#level0_ret
                clr     a
                push    dpl
                push    dph
                push    acc
                xch     a,c_index
                mov     r0,a
                rl      a
                add     a,r0
                mov     dptr,#level0_table
                jmp     @a+dptr
level0_table:   ljmp    zobraz_chyby
                ljmp    com_servisna_jazda
                ljmp    test_rezim
                ljmp    prikazovy_rezim
                ljmp    parametre
                ljmp    com_nahravacia_jazda
level0_ret:     pop     c_index
                jmp     level0_menu

zobraz_chyby:   call    get_last_error
                jc      zc_output
                call    f_release
                call    lcd_clear
                mov     dptr,#n_e_text
                call    puts_n
zc_wait_lp1:    call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+r_,0
                db      0
                jmp     zc_wait_lp1
zc_output:      mov     dpl,error_lo
                mov     dph,error_hi
                inc     dptr
                movx    a,@dptr
                mov     r1,a
                clr     c
                subb    a,#no_of_errors
                jc      zc_ok
                call    f_release
                call    lcd_clear
                mov     dptr,#n_c_text
                call    puts_n
                sjmp    zc_wait_lp1
zc_ok:          inc     dptr
                movx    a,@dptr
                mov     r2,a
                inc     dptr
                movx    a,@dptr
                mov     r3,a
                inc     dptr
                movx    a,@dptr
                mov     r4,a
                inc     dptr
                movx    a,@dptr
                mov     r5,a
                inc     dptr
                movx    a,@dptr
                mov     r6,a
                inc     dptr
                movx    a,@dptr
                mov     r7,a
                call    f_release
                call    lcd_clear
                mov     a,r1
                mov     dptr,#zc_text
                call    puts_na
                mov     lcd_ind,#13
                mov     a,#'P'
                call    lcd_out
                mov     a,r2
                call    lcd_dec2
                mov     a,r3
                call    lcd_hex
                mov     a,#':'
                call    lcd_out
                mov     a,r4
                call    lcd_hex
                mov     lcd_ind,#24
                mov     a,r5
                call    lcd_hex
                mov     a,#'.'
                call    lcd_out
                mov     a,r6
                call    lcd_hex
                mov     a,#'.'
                call    lcd_out
                mov     a,r7
                call    lcd_hex
zc_wait_lp2:    call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,zc_prev
                dw      m_down+j_,zc_next
                db      0
                jmp     zc_wait_lp2

zc_prev:        call    get_prev_error
                jmp     zc_output

zc_next:        call    get_next_error
                jmp     zc_output

com_servisna_jazda:
                clr     nezapinaj_fazy
                call    wait_for_timer_f
                dw      t_command
                db      0,1,0
                clr     a
                mov     sj_data,a
                mov     cgp0,a
                mov     cgp1,a
                mov     dptr,#th_servisna_jazda
                call    run_it
csj_lp:         call    lcd_clear
                mov     dptr,#s_s_text1
                call    puts_n
                mov     a,cgp0
                mov     dptr,#s_s_text2
                call    puts_na
                mov     lcd_ind,#16
                mov     dptr,#s_s_text3
                call    puts_n
                mov     a,cgp1
                mov     dptr,#s_s_text4
                call    puts_na
csj_wait:       call    do_them
                call    do_vnts
                dw      m_left+j_,csj_done
                dw      m_up+j_,csj_smer
                dw      m_down+j_,csj_rychlost
                db      0
                mov     a,kb_data
                jb      acc.4,csj_ok
                mov     sj_data,#0
                jmp     csj_wait
csj_ok:         mov     a,sj_data
                jb      acc.7,csj_wait
                mov     a,cgp0
                anl     a,#1
                rl      a
                rl      a
                mov     r0,a
                mov     a,cgp1
                anl     a,#3
                orl     a,r0
                setb    acc.7
                mov     sj_data,a
                jmp     csj_wait

csj_smer:       mov     a,cgp0
                mov     b,#2
                call    inc_mod_b
                mov     cgp0,a
                jmp     csj_lp

csj_rychlost:   mov     a,cgp1
                mov     b,#4
                call    inc_mod_b
                mov     cgp1,a
                jmp     csj_lp

csj_done:       mov     sj_data,#64
                ret

com_nahravacia_jazda:
                call    lcd_clear
                setb    je_nahravacia
                mov     dptr,#th_safety
                call    run_it
cnj_wait:       call    do_them
                call    do_vnts
                dw      m_left+j_,cnj_stop
                db      0
                jb      je_nahravacia,cnj_wait
                mov     a,#id_safety
                call    kill_it
                jmp     zapis_confirm
cnj_stop:       mov     a,#id_zrovnavacia
                call    kill_it
                call    nulovanie_rele
                mov     a,#id_safety
                jmp     kill_it

test_rezim:     call    lcd_clear
                mov     a,c_index
                mov     dptr,#test_text
                call    puts_na
test_wait:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,test_prev
                dw      m_down+j_,test_next
                dw      m_enter+j_,test_exec
                db      0
                jmp     test_wait

test_prev:      mov     a,c_index
                mov     b,#11
                call    dec_mod_b
                mov     c_index,a
                jmp     test_rezim

test_next:      mov     a,c_index
                mov     b,#11
                call    inc_mod_b
                mov     c_index,a
                jmp     test_rezim

test_exec:      push    c_index
                mov     dptr,#test_ret
                clr     a
                push    dpl
                push    dph
                push    acc
                xch     a,c_index
                mov     r0,a
                rl      a
                add     a,r0
                mov     dptr,#test_table
                jmp     @a+dptr
test_table:     ljmp    test_vstupov1
                ljmp    test_vstupov2
                ljmp    test_vstupov_can
                ljmp    test_termistor
                ljmp    test_rele
                ljmp    test_b1_b8
                ljmp    test_a101_a216
                ljmp    test_rs232
                ljmp    test_can
                ljmp    test_poloh
                ljmp    test_gsm
test_ret:       pop     c_index
                jmp     test_rezim

test_vstupov1:  setb    scrolling
                call    lcd_clear

                mov     r0,#test_data
                mov     dps,#0
                mov     ckcon,#ck_pred
                mov     dpx,#10h
                mov     dptr,#6
                movx    a,@dptr
                cpl     a
                mov     @r0,a
                inc     dptr
                inc     r0
                movx    a,@dptr
                cpl     a
                mov     @r0,a
                inc     r0
                mov     dpx,#0
                mov     ckcon,#ck_po

                mov     a,ac_rd
                mov     @r0,a
                inc     r0
                mov     a,rd_can_reg5
                mov     @r0,a
                inc     r0
                mov     a,rd_can_reg6
                mov     c,acc.2
                clr     a
                rrc     a
                mov     c,a_snimac_n
                rrc     a
                mov     c,b_snimac_n
                rrc     a
                mov     c,c_snimac
                rrc     a
                mov     c,inc_dir
                rrc     a
                mov     c,inc_toggle
                rrc     a
                rrc     a
                rrc     a
                xrl     a,#00110110b
                mov     @r0,a

                mov     dptr,#test_list
                mov     r1,#38
                mov     r2,#0
tvst1_lp1:      mov     a,r2
                swap    a
                rl      a
                anl     a,#0fh
                add     a,#test_data
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                jz      tvst1_lp2
                call    puts_n
                inc     dptr
                mov     a,#' '
                call    lcd_out
                sjmp    tvst1_skip1
tvst1_lp2:      clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     tvst1_lp2
tvst1_skip1:    inc     r2
                djnz    r1,tvst1_lp1

                call    init_timer_f
                dw      t_command
                db      0,0,12
                clr     scrolling
tvst1_lp3:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                db      0
                call    timer_running_f
                dw      t_command
                jnz     tvst1_lp3
                jmp     test_vstupov1

test_vstupov2:  setb    blokuj_volby
                call    vymaz_volby
                setb    scrolling

tvst2_again:    call    lcd_clear

                mov     r0,#test_data

                mov     a,rd_brd_reg1
                mov     @r0,a
                orl     wr_brd_reg1,a
                inc     r0
                mov     a,rd_brd_reg2
                mov     @r0,a
                orl     wr_brd_reg2,a
                inc     r0
                mov     a,rd_brd_reg3
                mov     @r0,a
                orl     wr_brd_reg3,a
                inc     r0
                mov     a,rd_brd_reg4
                mov     @r0,a
                orl     wr_brd_reg4,a

                call    write_brd_regs

                mov     r1,#32
                mov     r2,#0
tvst2_lp1:      mov     a,r2
                swap    a
                rl      a
                anl     a,#7
                add     a,#test_data
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                jz      tvst2_skip1
                mov     a,#'A'
                call    lcd_out
                mov     a,r2
                swap    a
                anl     a,#1
                add     a,#'1'
                call    lcd_out
                mov     a,r2
                anl     a,#0fh
                inc     a
                call    lcd_dec_ex2
                mov     a,#' '
                call    lcd_out
tvst2_skip1:    inc     r2
                djnz    r1,tvst2_lp1

                call    init_timer_f
                dw      t_command
                db      0,0,12
                clr     scrolling
tvst2_lp2:      call    do_them
                call    do_vnts
                dw      m_left+j_,tvst2_ret
                db      0
                call    timer_running_f
                dw      t_command
                jnz     tvst2_lp2
                jmp     tvst2_again
tvst2_ret:      clr     a
                mov     wr_brd_reg1,a
                mov     wr_brd_reg2,a
                mov     wr_brd_reg3,a
                mov     wr_brd_reg4,a
                jmp     write_brd_regs

test_vstupov_can:
                clr     blokuj_volby
                call    vymaz_volby
tvstc_again:    call    lcd_clear
                setb    scrolling
                mov     r0,#test_data
                mov     r1,#rd_kabina
                mov     r2,#4
tvstc_lp0:      mov     a,@r1
                mov     @r0,a
                inc     r1
                inc     r0
                djnz    r2,tvstc_lp0

                mov     r1,#32
                mov     r2,#0
tvstc_lp1:      mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#test_data
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                jz      tvstc_skip1
                mov     a,r2
                anl     a,#1fh
                inc     a
                call    lcd_dec_ex2
                mov     a,#' '
                call    lcd_out
tvstc_skip1:    inc     r2
                djnz    r1,tvstc_lp1

                call    init_timer_f
                dw      t_command
                db      0,0,12
                clr     scrolling
tvstc_lp2:      call    do_them
                call    do_vnts
                dw      m_left+j_,vymaz_volby
                db      0
                call    timer_running_f
                dw      t_command
                jnz     tvstc_lp2
                jmp     tvstc_again

shine_a_bit:    mov     r3,a
                mov     r0,#test_data
                mov     r1,#8
                clr     a
sab_lp1:        mov     @r0,a
                inc     r0
                djnz    r1,sab_lp1
                mov     a,r3
                swap    a
                rl      a
                anl     a,#7
                add     a,#test_data
                mov     r0,a
                mov     a,r3
                anl     a,#7
                call    get_nrm_mask
                mov     @r0,a
                ret

test_termistor:
tterm_lp:       call    do_them
                call    do_vnts
                dw      m_left+r_,0
                db      0
                call    timer_running_reload_f
                dw      t_command
                db      0,0,12
                jnz     tterm_lp
                mov     lcd_ind,#22
                clr     a
                mov     c,termistor_n
                cpl     c
                rlc     a
                mov     dptr,#enum_bool+1
                call    puts_na
                jmp     test_termistor

test_rele:      mov     liftpos,#0
trele_lp1:      mov     a,liftpos
                call    shine_a_bit
                mov     r0,#test_data
                mov     a,@r0
                mov     wr_rele_reg1,a
                inc     r0
                mov     a,@r0
                mov     wr_rele_reg2,a
                call    write_rele_reg1
                call    wrr2_ok
                mov     a,liftpos
                inc     a
                cjne    a,#6,trele_ok
                mov     a,#8
                cjne    a,#14,trele_ok
                clr     a
trele_ok:       mov     liftpos,a

                call    init_timer_f
                dw      t_command
                db      0,1,0
trele_lp2:      call    do_them
                call    do_vnts
                dw      m_left+j_,trele_ret
                db      0
                call    timer_running_f
                dw      t_command
                jnz     trele_lp2
                jmp     trele_lp1
trele_ret:      mov     a,#0c0h
                anl     wr_rele_reg1,a
                anl     wr_rele_reg2,a
                call    write_rele_reg1
                jmp     wrr2_ok

test_b1_b8:     mov     liftpos,#0
tbb_lp1:        mov     a,liftpos
                call    shine_a_bit
                inc     liftpos
                mov     a,liftpos
                clr     c
                subb    a,#12
                jc      tbb_skip1
                mov     liftpos,#0
tbb_skip1:      call    init_timer_f
                dw      t_command
                db      0,1,0

tbb_lp2:        call    do_them
                mov     r0,#test_data
                mov     a,@r0
                mov     wr_trans_reg,a
                call    write_trans_reg
                mov     r0,#test_data+1
                mov     a,@r0
                swap    a
                rr      a
                mov     wr_can_reg7,a
                setb    can0_change2

                call    do_vnts
                dw      m_left+j_,tbb_ret
                db      0
                call    timer_running_f
                dw      t_command
                jnz     tbb_lp2
                jmp     tbb_lp1
tbb_ret:        mov     wr_can_reg7,#0
                setb    can0_change2
                clr     a
                mov     wr_trans_reg,a
                jmp     write_trans_reg

test_a101_a216: mov     liftpos,#0
taa_lp1:        mov     a,liftpos
                call    shine_a_bit
                mov     r0,#test_data
                mov     a,@r0
                mov     wr_brd_reg1,a
                inc     r0
                mov     a,@r0
                mov     wr_brd_reg2,a
                inc     r0
                mov     a,@r0
                mov     wr_brd_reg3,a
                inc     r0
                mov     a,@r0
                mov     wr_brd_reg4,a
                call    write_brd_regs
                mov     a,liftpos
                inc     a
                anl     a,#31
                mov     liftpos,a

                call    init_timer_f
                dw      t_command
                db      0,0,50
taa_lp2:        call    do_them
                call    do_vnts
                dw      m_left+j_,taa_ret
                db      0
                call    timer_running_f
                dw      t_command
                jnz     taa_lp2
                jmp     taa_lp1
taa_ret:        clr     a
                mov     wr_brd_reg1,a
                mov     wr_brd_reg2,a
                mov     wr_brd_reg3,a
                mov     wr_brd_reg4,a
                jmp     write_brd_regs

test_rs232:     call    lcd_clear
                setb    serial_debug
                setb    scrolling
trs232_lp:      call    do_them
                call    get_msg
                jnc     trs232_lp
                mov     a,r1
                cjne    a,#m_left,trs232_lp
                clr     serial_debug
                clr     scrolling
                ret

test_can:       call    lcd_clear
                setb    can_debug
tc_lp1:         call    do_them
                call    get_msg
                jnc     tc_lp1
                mov     a,r1
                xrl     a,#m_left
                jz      tc_end
                mov     a,r1
                cjne    a,#m_enter,tc_try_up
                call    lcd_clear
                jmp     tc_lp1
tc_try_up:      cjne    a,#m_up,tc_try_down
                mov     a,cgp0
                inc     cgp0
                mov     wr_can_reg5,a
                setb    can0_change2
                jmp     tc_lp1
tc_try_down:    cjne    a,#m_down,tc_lp1
                mov     a,cgp0
                inc     cgp0
                mov     r3,a
                call    g_send_test
                jmp     tc_lp1
tc_end:         clr     can_debug
                ret

tp_wait:        mov     r1,a
                clr     a
                mov     r0,a
                mov     r2,a
                mov     dps,#0
                mov     dptr,#t_command
                jmp     wait_for_timer
                
test_poloh:     mov     liftpos,#0ffh

                ; poschodia + sipky
tp_lp1:         call    init_timer_f
                dw      t_command
                db      0,5,0
tp_wait_lp1:    call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+j_,test_poloh
                db      0
                call    timer_running_f
                dw      t_command
                jnz     tp_wait_lp1
                
                mov     a,smer
                inc     a
                anl     a,#3
                mov     smer,a
                
                call    zapni_gong
                
                mov     a,liftpos
                inc     a
                mov     liftpos,a
                cjne    a,floor_no,tp_lp1
                
                setb    pretazenie
                mov     a,#2
                call    tp_wait
                clr     pretazenie
                mov     a,#8
                call    tp_wait
                
                mov     porucha,#1
                mov     a,#2
                call    tp_wait
                mov     porucha,#0
                mov     a,#8
                call    tp_wait
                
                jmp     test_poloh

test_gsm:       call    gsm_debug_on
                call    lcd_clear
                mov     dptr,#t_g_text
                call    puts_n
tgsm_lp1:       call    do_them
                call    do_vnts
                dw      m_gsm+j_,tgsm_show
                dw      m_left+j_,gsm_debug_off
                db      0
                jmp     tgsm_lp1

tgsm_show:      mov     lcd_ind,#16
                mov     a,r3
                cjne    a,#99,tgsm_skip0
                mov     r1,#16
tgsm_lp0:       mov     a,#'?'
                call    lcd_out
                djnz    r1,tgsm_lp0
                jmp     tgsm_lp1
tgsm_skip0:     rr      a
                anl     a,#0fh
                mov     r3,a
                mov     r0,#0
                mov     r1,#16
tgsm_lp2:       mov     a,r0
                setb    c
                subb    a,r3
                jc      tgsm_skip1
                mov     a,#' '
                sjmp    tgsm_skip2
tgsm_skip1:     mov     a,#7
tgsm_skip2:     call    lcd_out
                inc     r0
                djnz    r1,tgsm_lp2
                jmp     tgsm_lp1

prikazovy_rezim:
                call    lcd_clear
                mov     a,c_index
                mov     dptr,#prikaz_text
                call    puts_na
prikaz_wait:    call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,prikaz_prev
                dw      m_down+j_,prikaz_next
                dw      m_enter+j_,prikaz_exec
                db      0
                jmp     prikaz_wait

prikaz_prev:    mov     a,c_index
                mov     b,#5
                call    dec_mod_b
                mov     c_index,a
                jmp     prikazovy_rezim

prikaz_next:    mov     a,c_index
                mov     b,#5
                call    inc_mod_b
                mov     c_index,a
                jmp     prikazovy_rezim

prikaz_exec:    push    c_index     
                mov     dptr,#prikaz_ret
                clr     a
                push    dpl
                push    dph
                push    acc
                xch     a,c_index
                mov     r0,a
                rl      a
                add     a,r0
                mov     dptr,#prikaz_table
                jmp     @a+dptr
prikaz_table:   ljmp    reset_pocet_jazd
                ljmp    precitaj_cas
                ljmp    nastav_cas
                ljmp    vymaz_chyby
                ljmp    oziv_vytah
prikaz_ret:     pop     c_index
                jmp     prikazovy_rezim

precitaj_cas:   mov     lcd_ind,#16
                mov     r0,#i2c_time
                mov     a,@r0
                call    lcd_hex
                mov     a,#':'
                call    lcd_out                         ; output hour
                mov     r0,#i2c_time+1
                mov     a,@r0
                call    lcd_hex
                mov     a,#' '
                call    lcd_out                         ; output minute
                mov     r0,#i2c_time+2
                mov     a,@r0
                call    lcd_hex
                mov     a,#'.'
                call    lcd_out                         ; output day
                inc     r0
                mov     a,@r0
                call    lcd_hex
                mov     a,#'.'
                call    lcd_out                         ; output month
                inc     r0
                mov     a,@r0
                call    lcd_hex                         ; output year
pc_lp:          call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+r_,0
                db      0
                jmp     pc_lp

nc_range:       db      0,23
                db      0,59
                db      1,31
                db      1,12
                db      0,99

nastav_cas:     call    lcd_clear
                mov     dptr,#s_t_text
                call    puts_n
                setb    dont_refresh_time
                mov     dptr,#nc_range
                mov     r0,#i2c_time
                mov     r1,#cgp0
                mov     r3,#5
nc_lp0:         mov     a,@r0
                push    ar0
                push    ar1
                call    bcd_hex
                mov     r4,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r0,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r1,a
                mov     a,r4
                call    adj_r0_r1
                pop     ar1
                pop     ar0
                mov     @r1,a
                inc     r0
                inc     r1
                djnz    r3,nc_lp0
                mov     cgp5,#0
nc_lp1:         mov     lcd_ind,#17
                mov     a,cgp0
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out                         ; output hour
                mov     a,cgp1
                call    lcd_dec2
                mov     a,#' '
                call    lcd_out                         ; output minute
                mov     a,cgp2
                call    lcd_dec2
                mov     a,#'.'
                call    lcd_out                         ; output day
                mov     a,cgp3
                call    lcd_dec2
                mov     a,#'.'
                call    lcd_out                         ; output month
                mov     a,cgp4
                call    lcd_dec2                        ; output year
nc_lp2:         clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,cgp5
                rl      a
                add     a,cgp5
                add     a,#18
                call    lcd_move
nc_lp3:         call    do_them
                call    do_vnts
                dw      m_left+j_,nc_left
                dw      m_right+j_,nc_right
                dw      m_up+j_,nc_inc
                dw      m_down+j_,nc_dec
                dw      m_enter+j_,nc_edit_ok
                db      0
                jmp     nc_lp3

nc_left:        mov     a,cgp5
                mov     b,#5
                call    dec_mod_b
                mov     cgp5,a
                jmp     nc_lp2

nc_right:       mov     a,cgp5
                mov     b,#5
                call    inc_mod_b
                mov     cgp5,a
                jmp     nc_lp2

nc_inc:         mov     a,cgp5
                add     a,#cgp0
                mov     r0,a
                push    ar0
                mov     a,@r0
                mov     r2,a
                mov     dptr,#nc_range
                mov     a,cgp5
                rl      a
                movc    a,@a+dptr
                mov     r0,a
                mov     a,cgp5
                rl      a
                inc     a
                movc    a,@a+dptr
                mov     r1,a
                mov     a,r2
                call    inc_r0_r1
                pop     ar0
                mov     @r0,a
                jmp     nc_lp1

nc_dec:         mov     a,cgp5
                add     a,#cgp0
                mov     r0,a
                push    ar0
                mov     a,@r0
                mov     r2,a
                mov     dptr,#nc_range
                mov     a,cgp5
                rl      a
                movc    a,@a+dptr
                mov     r0,a
                mov     a,cgp5
                rl      a
                inc     a
                movc    a,@a+dptr
                mov     r1,a
                mov     a,r2
                call    dec_r0_r1
                pop     ar0
                mov     @r0,a
                jmp     nc_lp1

nc_edit_ok:     clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     r0,#i2c_time
                mov     r1,#cgp0
                mov     r2,#5
nc_lp4:         mov     a,@r1
                call    hex_bcd
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,nc_lp4
                mov     r0,#id_follower
                mov     r1,#m_store_time
                mov     r2,#0
                jmp     ovr_msg

vymaz_chyby:    call    lcd_clear
                mov     dptr,#m_c_text1
                call    puts_n
                call    delete_errors
                call    lcd_clear
                mov     dptr,#m_c_text2
                call    puts_n
vymaz_wait:     call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+r_,0
                db      0
                jmp     vymaz_wait

oziv_vytah:     call    lcd_clear
                clr     zakapanie
                call    output_zakapanie
                call    zapis_zakapanie
                mov     dptr,#o_v_text
                call    puts_n
oziv_wait:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+r_,0
                db      0
                jmp     oziv_wait

parametre:      call    lcd_clear
                mov     a,c_index
                mov     dptr,#para_text
                call    puts_na
para_wait:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,para_prev
                dw      m_down+j_,para_next
                dw      m_enter+j_,para_exec
                db      0
                jmp     para_wait

para_prev:      mov     a,c_index
                mov     b,#11
                call    dec_mod_b
                mov     c_index,a
                jmp     parametre

para_next:      mov     a,c_index
                mov     b,#11
                call    inc_mod_b
                mov     c_index,a
                jmp     parametre

para_exec:      push    c_index
                mov     dptr,#para_ret
                clr     a
                push    dpl
                push    dph
                push    acc
                xch     a,c_index
                mov     r0,a
                rl      a
                add     a,r0
                mov     dptr,#para_table
                jmp     @a+dptr
para_table:     ljmp    enum_para
                ljmp    num_para
                ljmp    time_para
                ljmp    poschodia
                ljmp    vypis_para
                ljmp    hodiny_para
                ljmp    ink_para
                ljmp    gsm_para
                ljmp    para_zapis
                ljmp    default_para
                ljmp    copy_program
para_ret:       pop     c_index
                jmp     parametre

enum_special:   mov     a,cgp0
                jnz     es_ok
                inc     dptr
                jmp     puts_n
es_ok:          dec     a
                clr     c
                
                mov     r0,a
                subb    a,#16
                jc      es_a14_21
                
                mov     r0,a
                subb    a,#64
                jc      es_a101_216
                
                mov     r0,a
                subb    a,#18
                jc      es_can1_9
                
                mov     r0,a
                subb    a,#4
                jc      es_t0_3
                
                mov     r0,a
                subb    a,#2
                jc      es_a5
                
                mov     a,#'?'
                jmp     lcd_out
                
es_a5:          mov     a,#'A'
                call    lcd_out
                mov     a,#'5'
                call    lcd_out
                sjmp    es_drain
                
es_a14_21:      mov     a,#'A'
                call    lcd_out
                mov     a,r0
                clr     c
                rrc     a
                add     a,#14
                call    lcd_dec0
                sjmp    es_drain
                
es_a101_216:    mov     a,#'A'
                call    lcd_out
                mov     a,r0
                mov     c,acc.5
                clr     a
                addc    a,#'1'
                call    lcd_out
                mov     a,r0
                rr      a
                anl     a,#0fh
                inc     a
                call    lcd_dec_ex2
                sjmp    es_drain
                
es_can1_9:      call    puts_nf
                db      'CAN',0
                mov     a,r0
                rr      a
                anl     a,#0fh
                inc     a
                call    lcd_dec0
es_drain:       mov     a,r0
                anl     a,#1
                jz      es_nula
                mov     dptr,#enum_rozp
                jmp     puts_n
es_nula:        mov     dptr,#enum_spin
                jmp     puts_n

es_t0_3:        mov     r0,a
                mov     a,#'T'
                call    lcd_out
                mov     a,r0
                jmp     lcd_dec0
                
enum_special_b: mov     a,cgp0
                jnz     esb_ok
                inc     dptr
                jmp     puts_n
esb_ok:         dec     a
                mov     r0,a
                clr     c
                subb    a,#8
                jc      esb_b1_8
                mov     r0,a
                mov     a,#'A'
                call    lcd_out
                mov     a,r0
                mov     c,acc.4
                clr     a
                addc    a,#'1'
                call    lcd_out
                mov     a,r0
                anl     a,#0fh
                inc     a
                jmp     lcd_dec_ex2
esb_b1_8:       mov     a,#'B'
                call    lcd_out
                mov     a,r0
                add     a,#'1'
                jmp     lcd_out

enum_para:      mov     dptr,#enum_text
                mov     a,c_index
                jz      enum_found
                mov     r0,a
enum_lp1:       inc     dptr
                clr     a
                movc    a,@a+dptr
                jnz     enum_lp1
                inc     dptr
                inc     dptr
                inc     dptr
                djnz    r0,enum_lp1
enum_found:     clr     a
                movc    a,@a+dptr
                mov     cgp6,a
                inc     dptr
                mov     cgp2,dpl
                mov     cgp3,dph
enum_lp3:       clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     enum_lp3
                clr     a
                movc    a,@a+dptr
                mov     cgp5,a
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     cgp4,a
                mov     dpl,a
                mov     dph,cgp5
                clr     a
                movc    a,@a+dptr
                mov     cgp1,a
                mov     a,cgp6
                mov     dptr,#enum_table
                call    add_a_to_dptr
                movx    a,@dptr
                mov     cgp0,a
                clr     c
                subb    a,cgp1
                jc      enum_para_lp
                mov     cgp0,#0
enum_para_lp:   call    lcd_clear
                mov     dpl,cgp2
                mov     dph,cgp3
                call    puts_n
                mov     lcd_ind,#16
                mov     dpl,cgp4
                mov     dph,cgp5
                mov     a,dpl
                cjne    a,#low(enum_a_1),enum_try_b
                mov     a,dph
                cjne    a,#high(enum_a_1),enum_try_b
                call    enum_special
                sjmp    enum_wait
enum_try_b:     mov     a,dpl
                cjne    a,#low(enum_b_1),enum_ok
                mov     a,dph
                cjne    a,#high(enum_b_1),enum_ok
                call    enum_special_b
                sjmp    enum_wait
enum_ok:        inc     dptr
                mov     a,cgp0
                call    puts_na
enum_wait:      call    do_them
                call    do_vnts
                dw      m_left+j_,enum_dec
                dw      m_right+j_,enum_inc
                dw      m_up+j_,enum_prev
                dw      m_down+j_,enum_next
                dw      m_enter+j_,enum_done
                db      0
                jmp     enum_wait

enum_done:      mov     a,cgp6
                mov     dptr,#enum_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                ret

enum_dec:       mov     a,cgp0
                mov     b,cgp1
                call    dec_mod_b
                mov     cgp0,a
                jmp     enum_para_lp

enum_inc:       mov     a,cgp0
                mov     b,cgp1
                call    inc_mod_b
                mov     cgp0,a
                jmp     enum_para_lp

enum_prev:      mov     a,cgp6
                mov     dptr,#enum_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,#no_of_enums
                call    dec_mod_b
                mov     c_index,a
                jmp     enum_para

enum_next:      mov     a,cgp6
                mov     dptr,#enum_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,#no_of_enums
                call    inc_mod_b
                mov     c_index,a
                jmp     enum_para

num_para:       mov     a,c_index
                rl      a
                mov     dptr,#num_range
                call    add_a_to_dptr
                clr     a
                movc    a,@a+dptr
                mov     cgp1,a
                mov     a,#1
                movc    a,@a+dptr
                mov     cgp2,a
                mov     a,c_index
                mov     dptr,#num_table
                call    add_a_to_dptr
                movx    a,@dptr
                mov     r0,cgp1
                mov     r1,cgp2
                call    adj_r0_r1
                mov     cgp0,a
                call    lcd_clear
                mov     a,c_index
                mov     dptr,#num_text
                call    puts_na
num_para_lp:    mov     lcd_ind,#22
                mov     a,cgp0
                call    lcd_dec3
num_wait:       call    do_them
                call    do_vnts
                dw      m_left+j_,num_dec
                dw      m_right+j_,num_inc
                dw      m_up+j_,num_prev
                dw      m_down+j_,num_next
                dw      m_enter+j_,num_done
                db      0
                jmp     num_wait

num_done:       mov     a,c_index
                mov     dptr,#num_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                call    pocet_poschodi
                jmp     update_floorno

num_dec:        mov     a,cgp0
                mov     r0,cgp1
                mov     r1,cgp2
                call    dec_r0_r1
                mov     cgp0,a
                jmp     num_para_lp

num_inc:        mov     a,cgp0
                mov     r0,cgp1
                mov     r1,cgp2
                call    inc_r0_r1
                mov     cgp0,a
                jmp     num_para_lp

num_prev:       mov     a,c_index
                mov     dptr,#num_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,#no_of_nums
                call    dec_mod_b
                mov     c_index,a
                jmp     num_para

num_next:       mov     a,c_index
                mov     dptr,#num_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,#no_of_nums
                call    inc_mod_b
                mov     c_index,a
                jmp     num_para

tmr_lcd_out:    mov     a,cgp0
                call    lcd_dec3
                mov     a,#':'
                call    lcd_out
                mov     a,cgp1
                call    lcd_dec_ex2
                mov     a,#'.'
                call    lcd_out
                mov     a,cgp2
                jmp     lcd_dec_ex2

tmr_inc:        mov     a,cgp3
                jnz     tmr_inc_1
tmr_inc_0a:     inc     cgp0
                ret
tmr_inc_1:      cjne    a,#1,tmr_inc_2
tmr_inc_1a:     inc     cgp1
                mov     a,cgp1
                xrl     a,#60
                jnz     tmr_inc_ret
                mov     cgp1,a
                jmp     tmr_inc_0a
tmr_inc_2:      cjne    a,#2,tmr_inc_3
                inc     cgp2
                mov     a,cgp2
                xrl     a,#100
                jnz     tmr_inc_ret
                mov     cgp2,a
                jmp     tmr_inc_1a
tmr_inc_3:      mov     cgp3,#1
tmr_inc_ret:    ret

tmr_dec:        mov     a,cgp3
                jnz     tmr_dec_1
tmr_dec_0a:     dec     cgp0
                ret
tmr_dec_1:      cjne    a,#1,tmr_dec_2
tmr_dec_1a:     mov     a,cgp1
                dec     cgp1
                jnz     tmr_dec_ret
                mov     cgp1,#59
                jmp     tmr_dec_0a
tmr_dec_2:      cjne    a,#2,tmr_dec_3
                mov     a,cgp2
                dec     cgp2
                jnz     tmr_dec_ret
                mov     cgp2,#99
                jmp     tmr_dec_1a
tmr_dec_3:      mov     cgp3,#1
tmr_dec_ret:    ret

time_para:      call    lcd_clear
                mov     a,c_index
                mov     dptr,#time_text
                call    puts_na
                mov     a,c_index
                mov     dptr,#time_table
                call    add_3a_to_dptr
                movx    a,@dptr
                mov     cgp0,a
                inc     dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#59
                call    adj_r0_r1
                mov     cgp1,a
                inc     dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#99
                call    adj_r0_r1
                mov     cgp2,a
                mov     cgp3,#1
                mov     lcd_ind,#20
                call    tmr_lcd_out
time_wait:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,time_prev
                dw      m_down+j_,time_next
                dw      m_enter+j_,time_edit_lp1
                db      0
                jmp     time_wait

time_prev:      mov     a,c_index
                mov     b,#no_of_times
                call    dec_mod_b
                mov     c_index,a
                jmp     time_para

time_next:      mov     a,c_index
                mov     b,#no_of_times
                call    inc_mod_b
                mov     c_index,a
                jmp     time_para

time_edit:      mov     lcd_ind,#20
                call    tmr_lcd_out
time_edit_lp1:  clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,cgp3
                rl      a
                add     a,cgp3
                add     a,#22
                call    lcd_move
time_edit_lp2:  call    do_them
                call    do_vnts
                dw      m_left+j_,time_left
                dw      m_right+j_,time_right
                dw      m_up+j_,time_inc
                dw      m_down+j_,time_dec
                dw      m_enter+j_,time_edit_ok
                db      0
                jmp     time_edit_lp2

time_left:      mov     a,cgp3
                mov     b,#3
                call    dec_mod_b
                mov     cgp3,a
                jmp     time_edit_lp1

time_right:     mov     a,cgp3
                mov     b,#3
                call    inc_mod_b
                mov     cgp3,a
                jmp     time_edit_lp1

time_inc:       call    tmr_inc
                jmp     time_edit

time_dec:       call    tmr_dec
                jmp     time_edit

time_edit_ok:   clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,c_index
                mov     dptr,#time_table
                call    add_3a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                inc     dptr
                mov     a,cgp1
                movx    @dptr,a
                inc     dptr
                mov     a,cgp2
                movx    @dptr,a
                mov     cgp3,#1
                jmp     time_wait

posch_unpack:   mov     cgp0,#1
                mov     cgp1,#3
                mov     cgp2,#3
                mov     cgp3,#3
                anl     cgp0,a
                rr      a
                anl     cgp1,a
                rr      a
                rr      a
                anl     cgp2,a
                rr      a
                rr      a
                anl     cgp3,a
                ret
        
posch_pack:     anl     cgp0,#1
                anl     cgp1,#3
                anl     cgp2,#3
                anl     cgp3,#3
                mov     a,cgp3
                rl      a
                rl      a
                orl     a,cgp2
                rl      a
                rl      a
                orl     a,cgp1
                rl      a
                orl     a,cgp0
                ret

posch_output:   mov     a,cgp0
                mov     dptr,#vyp_str
                call    puts_na
                mov     a,cgp1
                mov     dptr,#dve_str
                call    puts_na
                mov     a,cgp2
                mov     dptr,#kra_str
                call    puts_na
                mov     a,cgp3
                mov     dptr,#rych_str
                jmp     puts_na

posch_inc_4:    mov     cgp4,#0
posch_inc_it:   mov     a,cgp4
                mov     b,#2
                jnz     posch_inc_1
                mov     a,cgp0
                call    inc_mod_b
                mov     cgp0,a
                ret
posch_inc_1:    inc     b
                cjne    a,#1,posch_inc_2
                mov     a,cgp1
                call    inc_mod_b
                mov     cgp1,a
                ret
posch_inc_2:    cjne    a,#2,posch_inc_3
                mov     a,cgp2
                call    inc_mod_b
                mov     cgp2,a
                ret
posch_inc_3:    cjne    a,#3,posch_inc_4
                mov     a,cgp3
                call    inc_mod_b
                mov     cgp3,a
                ret

posch_dec_4:    mov     cgp4,#0
posch_dec_it:   mov     a,cgp4
                mov     b,#2
                jnz     posch_dec_1
                mov     a,cgp0
                call    dec_mod_b
                mov     cgp0,a
                ret
posch_dec_1:    inc     b
                cjne    a,#1,posch_dec_2
                mov     a,cgp1
                call    dec_mod_b
                mov     cgp1,a
                ret
posch_dec_2:    cjne    a,#2,posch_dec_3
                mov     a,cgp2
                call    dec_mod_b
                mov     cgp2,a
                ret
posch_dec_3:    cjne    a,#3,posch_dec_4
                mov     a,cgp3
                call    dec_mod_b
                mov     cgp3,a
                ret

poschodia:      call    lcd_clear
                mov     dptr,#posch_text
                call    puts_n
posch_lp1:      mov     lcd_ind,#16
                mov     a,c_index
                mov     dptr,#floor_table
                call    add_a_to_dptr
                movx    a,@dptr
                call    posch_unpack
                mov     cgp4,#0
                mov     a,c_index
                inc     a
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out
                call    posch_output
posch_wait:     call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,posch_prev
                dw      m_down+j_,posch_next
                dw      m_enter+j_,posch_edit_lp1
                db      0
                jmp     posch_wait

posch_prev:     mov     a,c_index
                mov     b,floor_no
                call    dec_mod_b
                mov     c_index,a
                jmp     posch_lp1

posch_next:     mov     a,c_index
                mov     b,floor_no
                call    inc_mod_b
                mov     c_index,a
                jmp     posch_lp1

posch_edit:     mov     lcd_ind,#16
                mov     a,c_index
                inc     a
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out
                call    posch_output
posch_edit_lp1: clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,cgp4
                rl      a
                add     a,cgp4
                add     a,#20
                call    lcd_move
posch_edit_lp2: call    do_them
                call    do_vnts
                dw      m_left+j_,posch_left
                dw      m_right+j_,posch_right
                dw      m_up+j_,posch_inc
                dw      m_down+j_,posch_dec
                dw      m_enter+j_,posch_edit_ok
                db      0
                jmp     posch_edit_lp2

posch_edit_ok:  clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,c_index
                mov     dptr,#floor_table
                call    add_a_to_dptr
                call    posch_pack
                movx    @dptr,a
                mov     cgp4,#0
                jmp     posch_wait

posch_left:     mov     a,cgp4
                mov     b,#4
                call    dec_mod_b
                mov     cgp4,a
                jmp     posch_edit_lp1

posch_right:    mov     a,cgp4
                mov     b,#4
                call    inc_mod_b
                mov     cgp4,a
                jmp     posch_edit_lp1

posch_inc:      call    posch_inc_it
                jmp     posch_edit

posch_dec:      call    posch_dec_it
                jmp     posch_edit

vypis_para:     call    lcd_clear
                mov     dptr,#vypis_text
                call    puts_n
vyp_p_lp1:      mov     a,c_index
                mov     dptr,#vypis_table
                call    add_a_to_dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#no_vypis_strings-1
                call    adj_r0_r1
                mov     cgp0,a
                mov     lcd_ind,#19
                mov     a,c_index
                call    lcd_dec2
vyp_p_lp2:      mov     lcd_ind,#26
                mov     dptr,#vypis_str_table
                mov     a,cgp0
                call    puts_2
vyp_p_wait:     call    do_them
                call    do_vnts
                dw      m_left+j_,vyp_p_dec
                dw      m_right+j_,vyp_p_inc
                dw      m_up+j_,vyp_p_prev
                dw      m_down+j_,vyp_p_next
                dw      m_enter+j_,vyp_p_done
                db      0
                jmp     vyp_p_wait

vyp_p_done:     mov     a,c_index
                mov     dptr,#vypis_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                ret

vyp_p_dec:      mov     a,cgp0
                mov     b,#no_vypis_strings
                call    dec_mod_b
                mov     cgp0,a
                jmp     vyp_p_lp2

vyp_p_inc:      mov     a,cgp0
                mov     b,#no_vypis_strings
                call    inc_mod_b
                mov     cgp0,a
                jmp     vyp_p_lp2

vyp_p_prev:     mov     a,c_index
                mov     dptr,#vypis_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,floor_no
                inc     b
                call    dec_mod_b
                mov     c_index,a
                jmp     vyp_p_lp1

vyp_p_next:     mov     a,c_index
                mov     dptr,#vypis_table
                call    add_a_to_dptr
                mov     a,cgp0
                movx    @dptr,a
                mov     a,c_index
                mov     b,floor_no
                inc     b
                call    inc_mod_b
                mov     c_index,a
                jz      vyp_p_next_ok
                mov     a,cgp0
                clr     c
                subb    a,#no_vypis_special
                jc      vyp_p_next_ok
                mov     a,floor_no
                clr     c
                subb    a,c_index
                jc      vyp_p_next_ok
                jz      vyp_p_next_ok
                inc     a
                mov     r0,a
                mov     r1,cgp0
                mov     a,c_index
                mov     dptr,#vypis_table
                call    add_a_to_dptr
vyp_p_next_lp:  inc     r1
                cjne    r1,#no_vypis_strings,vyp_p_next_sp
                mov     r1,#no_vypis_special
vyp_p_next_sp:  mov     a,r1
                movx    @dptr,a
                inc     dptr
                djnz    r0,vyp_p_next_lp
vyp_p_next_ok:  jmp     vyp_p_lp1

hod_lcd_out:    mov     a,cgp0
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out
                mov     a,cgp1
                call    lcd_dec2
                mov     a,#'-'
                call    lcd_out
                mov     a,cgp2
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out
                mov     a,cgp3
                jmp     lcd_dec2

hod_inc_it:     mov     a,cgp4
                jnz     hod_inc_1
hod_inc_0a:     inc     cgp0
                mov     a,cgp0
                xrl     a,#24
                jnz     hod_inc_ret
                mov     cgp0,a
                ret
hod_inc_1:      cjne    a,#1,hod_inc_2
                inc     cgp1
                mov     a,cgp1
                xrl     a,#60
                jnz     hod_inc_ret
                mov     cgp1,a
                jmp     hod_inc_0a
hod_inc_2:      cjne    a,#2,hod_inc_3
hod_inc_2a:     inc     cgp2
                mov     a,cgp2
                xrl     a,#24
                jnz     hod_inc_ret
                mov     cgp2,a
                ret
hod_inc_3:      cjne    a,#3,hod_inc_bad
                inc     cgp3
                mov     a,cgp3
                xrl     a,#60
                jnz     hod_inc_ret
                mov     cgp3,a
                jmp     hod_inc_2a
hod_inc_bad:    mov     cgp4,#0
hod_inc_ret:    ret

hod_dec_it:     mov     a,cgp4
                jnz     hod_dec_1
hod_dec_0a:     mov     a,cgp0
                dec     cgp0
                jnz     hod_dec_ret
                mov     cgp0,#23
                ret
hod_dec_1:      cjne    a,#1,hod_dec_2
                mov     a,cgp1
                dec     cgp1
                jnz     hod_dec_ret
                mov     cgp1,#59
                jmp     hod_dec_0a
hod_dec_2:      cjne    a,#2,hod_dec_3
hod_dec_2a:     mov     a,cgp2
                dec     cgp2
                jnz     hod_dec_ret
                mov     cgp2,#23
                ret
hod_dec_3:      cjne    a,#3,hod_dec_4
                mov     a,cgp3
                dec     cgp3
                jnz     hod_dec_ret
                mov     cgp3,#59
                jmp     hod_dec_2a
hod_dec_4:      mov     cgp4,#0
hod_dec_ret:    ret

hodiny_para:    call    lcd_clear
                mov     a,#'T'
                call    lcd_out
                mov     a,c_index
                call    lcd_dec0
                mov     a,c_index
                mov     dptr,#hodiny_table
                call    add_4a_to_dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#59
                call    adj_r0_r1
                mov     cgp1,a
                inc     dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#23
                call    adj_r0_r1
                mov     cgp0,a
                inc     dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#59
                call    adj_r0_r1
                mov     cgp3,a
                inc     dptr
                movx    a,@dptr
                mov     r0,#0
                mov     r1,#23
                call    adj_r0_r1
                mov     cgp2,a
                mov     cgp4,#0
                mov     lcd_ind,#18
                call    hod_lcd_out
hod_wait:       call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,hod_prev
                dw      m_down+j_,hod_next
                dw      m_enter+j_,hod_edit_lp1
                db      0
                jmp     hod_wait

hod_prev:       mov     a,c_index
                mov     b,#no_of_hodiny
                call    dec_mod_b
                mov     c_index,a
                jmp     hodiny_para

hod_next:       mov     a,c_index
                mov     b,#no_of_hodiny
                call    inc_mod_b
                mov     c_index,a
                jmp     hodiny_para

hod_edit:       mov     lcd_ind,#18
                call    hod_lcd_out
hod_edit_lp1:   clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,cgp4
                rl      a
                add     a,cgp4
                add     a,#19
                call    lcd_move
hod_edit_lp2:   call    do_them
                call    do_vnts
                dw      m_left+j_,hod_left
                dw      m_right+j_,hod_right
                dw      m_up+j_,hod_inc
                dw      m_down+j_,hod_dec
                dw      m_enter+j_,hod_edit_ok
                db      0
                jmp     hod_edit_lp2

hod_left:       mov     a,cgp4
                mov     b,#4
                call    dec_mod_b
                mov     cgp4,a
                jmp     hod_edit_lp1

hod_right:      mov     a,cgp4
                mov     b,#4
                call    inc_mod_b
                mov     cgp4,a
                jmp     hod_edit_lp1

hod_inc:        call    hod_inc_it
                jmp     hod_edit

hod_dec:        call    hod_dec_it
                jmp     hod_edit

hod_edit_ok:    clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,c_index
                mov     dptr,#hodiny_table
                call    add_4a_to_dptr
                mov     a,cgp1
                movx    @dptr,a
                inc     dptr
                mov     a,cgp0
                movx    @dptr,a
                inc     dptr
                mov     a,cgp3
                movx    @dptr,a
                inc     dptr
                mov     a,cgp2
                movx    @dptr,a
                mov     cgp4,#0
                jmp     hod_wait

ink_para:       call    lcd_clear
                mov     dptr,#ink_text
                call    puts_n
ink_para_lp1:   mov     lcd_ind,#10
                mov     a,c_index
                call    lcd_dec2
                mov     a,c_index
                call    get_inc_data
                mov     cgp1,r4
                mov     cgp2,r3
ink_para_lp2:   mov     lcd_ind,#22
                mov     a,cgp1
                call    lcd_hex
                mov     a,cgp2
                call    lcd_hex
ink_wait:       call    do_them
                call    do_vnts
                dw      m_left+j_,ink_dec
                dw      m_right+j_,ink_inc
                dw      m_up+j_,ink_prev
                dw      m_down+j_,ink_next
                dw      m_enter+j_,ink_done
                db      0
                jmp     ink_wait

ink_done:       mov     r4,cgp1
                mov     r3,cgp2
                mov     a,c_index
                jmp     put_inc_data

ink_dec:        clr     c
                mov     a,cgp2
                subb    a,#1
                mov     cgp2,a
                mov     a,cgp1
                subb    a,#0
                mov     cgp1,a
                jmp     ink_para_lp2

ink_inc:        mov     a,cgp2
                add     a,#1
                mov     cgp2,a
                clr     a
                addc    a,cgp1
                mov     cgp1,a
                jmp     ink_para_lp2

ink_prev:       mov     r4,cgp1
                mov     r3,cgp2
                mov     a,c_index
                call    put_inc_data
                mov     a,c_index
                mov     b,floor_no
                call    dec_mod_b
                mov     c_index,a
                jmp     ink_para_lp1

ink_next:       mov     r4,cgp1
                mov     r3,cgp2
                mov     a,c_index
                call    put_inc_data
                mov     a,c_index
                mov     b,floor_no
                call    inc_mod_b
                mov     c_index,a
                jmp     ink_para_lp1

gsm_lcd_out:    mov     lcd_ind,#16
                mov     a,c_index
                mov     dptr,#gsm_table
                call    add_16a_to_dptr
                mov     r1,#16
glo_lp:         movx    a,@dptr
                clr     acc.7
                mov     r0,a
                clr     c
                subb    a,#' '
                jnc     glo_ok
                mov     r0,#' '
glo_ok:         mov     a,r0
                movx    @dptr,a
                call    lcd_out
                inc     dptr
                djnz    r1,glo_lp
                ret

gsm_para:       call    lcd_clear
                mov     cgp4,#0
                mov     a,c_index
                jnz     gsm_skip1
                mov     dptr,#gsm_text1
                call    puts_n
                call    gsm_lcd_out
                sjmp    gsm_wait
gsm_skip1:      mov     dptr,#gsm_text2
                call    puts_n
                mov     a,c_index
                call    lcd_dec0
                call    gsm_lcd_out
gsm_wait:       call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_up+j_,gsm_prev
                dw      m_down+j_,gsm_next
                dw      m_enter+j_,gsm_edit_lp1
                db      0
                jmp     gsm_wait

gsm_prev:       mov     a,c_index
                mov     b,#no_of_gsms
                call    dec_mod_b
                mov     c_index,a
                jmp     gsm_para

gsm_next:       mov     a,c_index
                mov     b,#no_of_gsms
                call    inc_mod_b
                mov     c_index,a
                jmp     gsm_para

gsm_edit:       call    gsm_lcd_out
gsm_edit_lp1:   clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     a,cgp4
                add     a,#16
                call    lcd_move
gsm_edit_lp2:   call    do_them
                call    do_vnts
                dw      m_left+j_,gsm_left
                dw      m_right+j_,gsm_right
                dw      m_up+j_,gsm_inc
                dw      m_down+j_,gsm_dec
                dw      m_enter+j_,gsm_edit_ok
                db      0
                jmp     gsm_edit_lp2

gsm_left:       mov     a,cgp4
                mov     b,#16
                call    dec_mod_b
                mov     cgp4,a
                jmp     gsm_edit_lp1

gsm_right:      mov     a,cgp4
                mov     b,#16
                call    inc_mod_b
                mov     cgp4,a
                jmp     gsm_edit_lp1

gsm_inc:        mov     a,c_index
                mov     dptr,#gsm_table
                call    add_16a_to_dptr
                mov     a,cgp4
                call    add_a_to_dptr
                movx    a,@dptr
                cjne    a,#' ',gsmi_1
                mov     a,#'0'
                sjmp    gsmi_drain
gsmi_1:         cjne    a,#'9',gsmi_2
                mov     a,#'A'
                sjmp    gsmi_drain
gsmi_2:         cjne    a,#'Z',gsmi_3
                mov     a,#' '
                sjmp    gsmi_drain
gsmi_3:         inc     a
gsmi_drain:     movx    @dptr,a
                jmp     gsm_edit

gsm_dec:        mov     a,c_index
                mov     dptr,#gsm_table
                call    add_16a_to_dptr
                mov     a,cgp4
                call    add_a_to_dptr
                movx    a,@dptr
                cjne    a,#'0',gsmd_1
                mov     a,#' '
                sjmp    gsmd_drain
gsmd_1:         cjne    a,#'A',gsmd_2
                mov     a,#'9'
                sjmp    gsmd_drain
gsmd_2:         cjne    a,#' ',gsmd_3
                mov     a,#'Z'
                sjmp    gsmd_drain
gsmd_3:         dec     a
gsmd_drain:     movx    @dptr,a
                jmp     gsm_edit

gsm_edit_ok:    clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     cgp4,#0
                jmp     gsm_wait

para_zapis:     call    lcd_clear
                mov     dptr,#p_z_text1
                call    puts_n
zapis_wait1:    call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+j_,zapis_confirm
                db      0
                jmp     zapis_wait1

zapis_confirm:  call    check_parameters
                jnz     zapis_ok
                call    lcd_clear
                mov     dptr,#p_z_text2
                call    puts_n
                call    store_parameters
                call    check_parameters
                jnz     zapis_ok
                call    lcd_clear
                mov     dptr,#p_z_text4
                call    puts_n
                sjmp    zapis_wait2
zapis_ok:       call    lcd_clear
                mov     dptr,#p_z_text3
                call    puts_n
zapis_wait2:    call    do_them
                call    do_vnts
                dw      m_enter+r_,0
                db      0
                jmp     zapis_wait2

default_para:   call    lcd_clear
                mov     dptr,#d_p_text1
                call    puts_n
def_wait1:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+j_,def_confirm
                db      0
                jmp     def_wait1

def_wr_lp:      clr     a
                movc    a,@a+dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,def_wr_lp
                ret

def_wr_lp2:     movx    @dptr,a
                inc     dptr
                djnz    r0,def_wr_lp2
                ret

def_confirm:    clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#00100101b

                mov     dptr,#default_enums
                mov     dptr,#enum_table
                mov     r0,#enum_table_size
                call    def_wr_lp

                mov     dptr,#default_nums
                mov     dptr,#num_table
                mov     r0,#num_table_size
                call    def_wr_lp

                mov     dptr,#default_times
                mov     dptr,#time_table
                mov     r0,#time_table_size
                call    def_wr_lp

                mov     dptr,#default_vypisy
                mov     dptr,#vypis_table
                mov     r0,#vypis_table_size
                call    def_wr_lp

                mov     dps,#0

                mov     dptr,#floor_table
                mov     r0,#floor_table_size
                mov     a,#8
                call    def_wr_lp2

                mov     dptr,#hodiny_table
                mov     r0,#hodiny_table_size
                clr     a
                call    def_wr_lp2
                
                mov     dptr,#increment_table
                mov     r0,#increment_table_size
                clr     a
                call    def_wr_lp2

                mov     dptr,#gsm_table
                mov     r0,#gsm_table_size
                mov     a,#' '
                call    def_wr_lp2

                call    lcd_clear
                mov     dptr,#d_p_text2
                call    puts_n
def_wait2:      call    do_them
                call    do_vnts
                dw      m_enter+r_,0
                db      0
                jmp     def_wait2

copy_program:   call    lcd_clear
                mov     dptr,#c_p_text0
                call    puts_n
cpy_wait1:      call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+j_,cpy_confirm
                db      0
                jmp     cpy_wait1

cpy_confirm:    call    lcd_clear
                call    check_identity
                jnz     cp_all_right
                call    lcd_clear
                mov     dptr,#c_p_text1
                call    puts_n
                call    copy_the_code
                call    check_identity
                jnz     cp_all_right
                call    lcd_clear
                mov     dptr,#c_p_text2
                call    puts_n
                sjmp    cp_lp1
cp_all_right:   call    lcd_clear
                mov     dptr,#c_p_text3
                call    puts_n
cp_lp1:         call    do_them
                call    do_vnts
                dw      m_left+r_,0
                dw      m_enter+r_,0
                db      0
                jmp     cp_lp1
