; version 1.0

inc_time:       mov     dptr,#delta_table
                mov     a,delta
                rl      a
                mov     r5,a
                inc     a
                movc    a,@a+dptr
                xch     a,r5
                movc    a,@a+dptr
                mov     r4,a
                mov     a,time_sec
                add     a,r5
                mov     time_sec,a
                clr     c
                subb    a,#60
                jc      it_skip1
                mov     time_sec,a
it_skip1:       cpl     c
                mov     a,time_min
                addc    a,r4
                mov     time_min,a
                clr     c
                subb    a,#60
                jc      it_ret
                mov     time_min,#60
                mov     time_sec,#0
it_ret:         ret

dec_time:       mov     dptr,#delta_table
                mov     a,delta
                rl      a
                mov     r5,a
                inc     a
                movc    a,@a+dptr
                xch     a,r5
                movc    a,@a+dptr
                mov     r4,a
                mov     a,time_sec
                clr     c
                subb    a,r5
                mov     time_sec,a
                jnc     dt_skip1
                add     a,#60
                mov     time_sec,a
dt_skip1:       mov     a,time_min
                subb    a,r4
                mov     time_min,a
                jnc     dt_ret
                clr     a
                mov     time_min,a
                mov     time_sec,a
dt_ret:         ret

keyboard:       mov     a,inputs
                anl     a,#31
                mov     c,k_start
                mov     o_start2,c
                anl     c,/o_start1
                mov     k_start,c
                mov     c,o_start2
                mov     o_start1,c
                jz      kb_reset
                mov     r7,a
                mov     a,kb_state
                jnz     kb_try_1
                call    tmr_int_f
                db      t_keyboard,0,1,0
                mov     kb_count,#10
                inc     kb_state
kb_send:        call    vypni_svetlo
                mov     a,r7
                ret
kb_try_1:       cjne    a,#1,kb_try_2
                mov     a,#t_keyboard
                call    tmr_zro
                jnc     kb_zero
                call    tmr_int_f
                db      t_keyboard,0,0,16
                djnz    kb_count,kb_send
                inc     kb_state
                call    vypni_svetlo
                mov     a,r7
                ret
kb_try_2:       cjne    a,#2,kb_reset
                mov     a,#t_keyboard
                call    tmr_zro
                jnc     kb_zero
                call    tmr_int_f
                db      t_keyboard,0,0,8
                call    vypni_svetlo
                mov     a,r7
                ret
kb_reset:       mov     kb_state,#0
kb_zero:        clr     a
                ret

show_time_s:    mov     a,time_min
                mov     b,#10
                div     ab
                jnz     sts_big
                mov     a,b
                add     a,#'0'
                call    lcd_out
                mov     a,#':'
                call    lcd_out
                mov     a,time_sec
                jmp     lcd_dec_ex2
sts_big:        call    puts_nf
                db      '>10m',0
                ret

show_time:      mov     a,time_min
                call    lcd_dec2
                mov     a,#':'
                call    lcd_out
                mov     a,time_sec
                jmp     lcd_dec_ex2

commander:      mov     kb_state,#0
                call    lcd_setup
                call    lcd_clear
                mov     dptr,#init_text
                call    puts_n
                call    wait4it_f
                db      t_com,0,1,0
                mov     dptr,#follower
                call    run_it

menu_main:
mm_lp1:         mov     lcd_ind,#0
                mov     dptr,#mm_text
                mov     a,state
                call    puts_na
                mov     dptr,#mm_blank
                call    puts_n
                mov     a,state
                jnz     mm_try_1
                mov     lcd_ind,#16
                mov     time_min,time1
                mov     time_sec,time1+1
mm_entry_1:     call    show_time_s
                mov     lcd_ind,#21
                mov     time_min,time2
                mov     time_sec,time2+1
mm_entry_2:     call    show_time
                mov     lcd_ind,#27
                mov     time_min,time3
                mov     time_sec,time3+1
                call    show_time
                jmp     mm_lp2
mm_try_1:       cjne    a,#1,mm_try_2
                mov     lcd_ind,#16
                mov     a,#t_state
                call    get_tmr
                mov     time_min,r4
                mov     time_sec,r5
                jmp     mm_entry_1
mm_try_2:       cjne    a,#2,mm_try_3
                mov     lcd_ind,#21
                mov     a,#t_state
                call    get_tmr
                mov     time_min,r4
                mov     time_sec,r5
                jmp     mm_entry_2
mm_try_3:       cjne    a,#3,mm_lp2
                mov     lcd_ind,#27
                mov     a,#t_state
                call    get_tmr
                mov     time_min,r4
                mov     time_sec,r5
                call    show_time
mm_lp2:         call    do_them
                call    keyboard
                jb      k_start,mm_start
                jb      k_stop,mm_stop
                jb      k_up,mm_up
                jb      k_down,mm_down
                jb      k_menu,menu1_time1
                jbc     k_access,mm_access
                mov     a,#t_com
                call    tmr_zro
                jnc     mm_lp2
                call    tmr_int_f
                db      t_com,0,0,8
                jmp     mm_lp1
mm_access:      jmp     menu_total

mm_start:       setb    u_start
                jmp     mm_lp2

mm_stop:        setb    u_stop
                jmp     mm_lp2

mm_up:          mov     a,state
                clr     acc.0
                jnz     mm_lp2
                mov     time_min,time2
                mov     time_sec,time2+1
                call    inc_time
                mov     time2,time_min
                mov     time2+1,time_sec
                jmp     mm_lp1

mm_down:        mov     a,state
                clr     acc.0
                jnz     mm_lp2
                mov     time_min,time2
                mov     time_sec,time2+1
                call    dec_time
                mov     time2,time_min
                mov     time2+1,time_sec
                jmp     mm_lp1

menu1_time1:    call    lcd_clear
                mov     dptr,#cas_prip_txt
                call    puts_n
                mov     time_min,time1
                mov     time_sec,time1+1
                clr     changed
m1t1_lp1:       mov     lcd_ind,#22
                call    show_time
m1t1_lp2:       call    do_them
                call    keyboard
                jb      k_up,m1t1_up
                jb      k_down,m1t1_down
                jb      k_menu,m1t1_menu
                jbc     k_access,m1t1_access
                jmp     m1t1_lp2
m1t1_access:    jmp     menu_total

m1t1_up:        call    inc_time
                setb    changed
                jmp     m1t1_lp1

m1t1_down:      call    dec_time
                setb    changed
                jmp     m1t1_lp1

m1t1_menu:      jnb     changed,menu1_time3
                mov     time1,time_min
                mov     time1+1,time_sec
                setb    w_time1

menu1_time3:    call    lcd_clear
                mov     dptr,#cas_chlad_txt
                call    puts_n
                mov     time_min,time3
                mov     time_sec,time3+1
                clr     changed
m1t3_lp1:       mov     lcd_ind,#22
                call    show_time
m1t3_lp2:       call    do_them
                call    keyboard
                jb      k_up,m1t3_up
                jb      k_down,m1t3_down
                jb      k_menu,m1t3_menu
                jbc     k_access,m1t3_access
                jmp     m1t3_lp2
m1t3_access:    jmp     menu_total

m1t3_up:        call    inc_time
                setb    changed
                jmp     m1t3_lp1

m1t3_down:      call    dec_time
                setb    changed
                jmp     m1t3_lp1

m1t3_menu:      jnb     changed,menu1_delta
                mov     time3,time_min
                mov     time3+1,time_sec
                setb    w_time3

menu1_delta:    call    lcd_clear
                mov     dptr,#cas_zmena_txt
                call    puts_n
                clr     changed
m1d_lp1:        mov     lcd_ind,#17
                mov     dptr,#delta_text
                mov     a,delta
                call    puts_na
m1d_lp2:        call    do_them
                call    keyboard
                jb      k_up,m1d_up
                jb      k_down,m1d_down
                jb      k_menu,m1d_menu
                jbc     k_access,m1d_access
                jmp     m1d_lp2
m1d_access:     jmp     menu_total

m1d_up:         mov     b,#delta_no
                mov     a,delta
                call    inc_mod_b
                mov     delta,a
                setb    changed
                jmp     m1d_lp1

m1d_down:       mov     b,#delta_no
                mov     a,delta
                call    dec_mod_b
                mov     delta,a
                setb    changed
                jmp     m1d_lp1

m1d_menu:       jnb     changed,menu1_get_pass
                setb    w_delta

menu1_get_pass: call    lcd_clear
                mov     dptr,#chr_zona_txt
                call    puts_n
m1gp_lp1:       call    do_them
                call    keyboard
                jb      k_start,menu2_get_pass
                jb      k_menu,m1gp_menu
                jbc     k_access,m1gp_access
                jmp     m1gp_lp1
m1gp_access:    jmp     menu_total
m1gp_menu:      jmp     menu_main

menu2_get_pass: call    lcd_clear
                mov     dptr,#zad_heslo_txt
                call    puts_n
                call    menu_get_heslo
                jz      menu1_get_pass
                mov     r0,#pass
                mov     r1,#heslo
                mov     r2,#2
m2gp_lp1:       mov     a,@r0
                xrl     a,@r1
                jnz     m2gp_bad
                inc     r0
                inc     r1
                djnz    r2,m2gp_lp1
                jmp     menu_total
m2gp_bad:       call    lcd_clear
                mov     dptr,#nesp_heslo_txt
                call    puts_n
                call    wait4it_f
                db      t_com,0,1,0
                jmp     menu1_get_pass

menu_total:     call    lcd_clear
                mov     dptr,#cas_celk_txt
                call    puts_n
                mov     lcd_ind,#18
                mov     a,total1
                call    lcd_dec_ex2
                mov     a,total1+1
                call    lcd_dec_ex2
                mov     a,total1+2
                call    lcd_dec_ex2
                mov     a,#':'
                call    lcd_out
                mov     a,total1+3
                call    lcd_dec_ex2
                mov     a,#':'
                call    lcd_out
                mov     a,total1+4
                call    lcd_dec_ex2
mt_lp1:         call    do_them
                call    keyboard
                jb      k_up,mt_up
                jb      k_down,mt_down
                jb      k_menu,mt_down
                jmp     mt_lp1
mt_up:          jmp     menu_return
mt_down:        jmp     menu_vymaz

menu_vymaz:     call    lcd_clear
                mov     dptr,#vym_cas_txt
                call    puts_n
mv_lp1:         call    do_them
                call    keyboard
                jb      k_start,mv_confirm
                jb      k_up,mv_up
                jb      k_down,mv_down
                jb      k_menu,mv_down
                jmp     mv_lp1
mv_up:          jmp     menu_total
mv_down:        jmp     menu_total2

mv_confirm:     clr     a
                mov     total1,a
                mov     total1+1,a
                mov     total1+2,a
                mov     total1+3,a
                mov     total1+4,a
                setb    w_total1
                call    lcd_clear
                mov     dptr,#mazem_cas_txt
                call    puts_n
                call    wait4it_f
                db      t_com,0,1,0
                jmp     menu_vymaz

menu_total2:    call    lcd_clear
                mov     dptr,#cas_celk_txt2
                call    puts_n
                mov     lcd_ind,#18
                mov     a,total2
                call    lcd_dec_ex2
                mov     a,total2+1
                call    lcd_dec_ex2
                mov     a,total2+2
                call    lcd_dec_ex2
                mov     a,#':'
                call    lcd_out
                mov     a,total2+3
                call    lcd_dec_ex2
                mov     a,#':'
                call    lcd_out
                mov     a,total2+4
                call    lcd_dec_ex2
mt2_lp1:        call    do_them
                call    keyboard
                jb      k_up,mt2_up
                jb      k_down,mt2_down
                jb      k_menu,mt2_down
                jmp     mt2_lp1
mt2_up:         jmp     menu_vymaz
mt2_down:       jmp     menu_vymaz2

menu_vymaz2:    call    lcd_clear
                mov     dptr,#vym_cas_txt2
                call    puts_n
mv2_lp1:        call    do_them
                call    keyboard
                jb      k_start,mv2_confirm
                jb      k_up,mv2_up
                jb      k_down,mv2_down
                jb      k_menu,mv2_down
                jmp     mv2_lp1
mv2_up:         jmp     menu_total
mv2_down:       jmp     menu1_ch_pass

mv2_confirm:    clr     a
                mov     total2,a
                mov     total2+1,a
                mov     total2+2,a
                mov     total2+3,a
                mov     total2+4,a
                setb    w_total2
                call    lcd_clear
                mov     dptr,#mazem_cas_txt2
                call    puts_n
                call    wait4it_f
                db      t_com,0,1,0
                jmp     menu_vymaz2

menu1_ch_pass:  call    lcd_clear
                mov     dptr,#zmena_hesla_txt
                call    puts_n
m1cp_lp1:       call    do_them
                call    keyboard
                jb      k_start,menu2_ch_pass
                jb      k_up,m1cp_up
                jb      k_down,m1cp_down
                jb      k_menu,m1cp_down
                jmp     m1cp_lp1
m1cp_up:        jmp     menu_vymaz
m1cp_down:      jmp     menu_return

menu2_ch_pass:  call    lcd_clear
                mov     dptr,#nove_heslo_txt
                call    puts_n
                call    menu_get_heslo
                jz      menu1_ch_pass
                mov     r0,#pass
                mov     r1,#heslo
                mov     r2,#2
m2cp_lp1:       mov     a,@r1
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,m2cp_lp1
                setb    w_pass
                jmp     menu1_ch_pass

menu_return:    call    lcd_clear
                mov     dptr,#navrat_txt
                call    puts_n
mr_lp1:         call    do_them
                call    keyboard
                jb      k_start,mr_back
                jb      k_up,mr_up
                jb      k_down,mr_down
                jb      k_menu,mr_down
                jmp     mr_lp1
mr_up:          jmp     menu1_ch_pass
mr_down:        jmp     menu_total
mr_back:        jmp     menu_main

mgh_cursor:     clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                jmp     lcd_mode

menu_get_heslo: clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                clr     a
                mov     time_sec,a
                mov     time_min,a
mgh_lp1:        mov     a,time_sec
                add     a,#22
                mov     lcd_ind,a
                call    lcd_move
                mov     a,time_min
                add     a,#'0'
                call    lcd_out
mgh_lp2:        call    do_them
                call    keyboard
                jb      k_start,mgh_next
                jb      k_stop,mgh_cancel
                jb      k_up,mgh_up
                jb      k_down,mgh_down
                jmp     mgh_lp2

mgh_up:         mov     a,time_min
                mov     b,#10
                call    inc_mod_b
                mov     time_min,a
                jmp     mgh_lp1

mgh_down:       mov     a,time_min
                mov     b,#10
                call    dec_mod_b
                mov     time_min,a
                jmp     mgh_lp1

mgh_cancel:     call    mgh_cursor
                clr     a
                ret

mgh_next:       mov     a,time_sec
                jbc     acc.0,mgh_odd
                rr      a
                add     a,#heslo
                mov     r0,a
                mov     a,@r0
                anl     a,#0fh
                mov     r1,a
                mov     a,time_min
                anl     a,#0fh
                swap    a
                orl     a,r1
                mov     @r0,a
                sjmp    mgh_inc_it
mgh_odd:        rr      a
                add     a,#heslo
                mov     r0,a
                mov     a,@r0
                anl     a,#0f0h
                mov     r1,a
                mov     a,time_min
                anl     a,#0fh
                orl     a,r1
                mov     @r0,a
mgh_inc_it:     mov     a,time_sec
                cjne    a,#3,mgh_ok
                call    mgh_cursor
                mov     a,#0ffh
                ret
mgh_ok:         inc     time_sec
                mov     time_min,#0
                jmp     mgh_lp1
