; version 1.0

keyboard:       mov     a,inputs
                anl     a,#1fh
                jz      kb_reset
                mov     r7,a
                mov     a,kb_state
                jnz     kb_try_1
                call    tmr_int_f
                db      t_keyboard,0,1,0
                mov     kb_count,#10
                inc     kb_state
kb_send:        mov     a,r7
                ret
kb_try_1:       cjne    a,#1,kb_try_2
                mov     a,#t_keyboard
                call    tmr_zro
                jnc     kb_zero
                call    tmr_int_f
                db      t_keyboard,0,0,16
                djnz    kb_count,kb_send
                inc     kb_state
                mov     a,r7
                ret
kb_try_2:       cjne    a,#2,kb_reset
                mov     a,#t_keyboard
                call    tmr_zro
                jnc     kb_zero
                call    tmr_int_f
                db      t_keyboard,0,0,8
                mov     a,r7
                ret
kb_reset:       mov     kb_state,#0
kb_zero:        clr     a
                ret

swz_out:        anl     a,#0fh
                add     a,#'0'
                jmp     lcd_out

show_word_z:    mov     a,@r0
                swap    a
                call    swz_out
                mov     a,@r0
                inc     r0
                call    swz_out
                mov     a,@r0
                swap    a
                call    swz_out
                mov     a,@r0
                dec     r0
                jmp     swz_out

sw_out:         anl     a,#0fh
                jnb     zero_sup,sw_show
                jz      sw_ret
                clr     zero_sup
sw_show:        add     a,#'0'
                jmp     lcd_out
sw_ret:         ret

show_word:      setb    zero_sup
                mov     a,@r0
                swap    a
                call    sw_out
                mov     a,@r0
                inc     r0
                call    sw_out
                mov     a,@r0
                swap    a
                call    sw_out
                mov     a,@r0
                dec     r0
                jmp     swz_out

swnz_out:       anl     a,#0fh
                jnb     zero_sup,swnz_show
                jz      swnz_space
                clr     zero_sup
swnz_show:      add     a,#'0'
                jmp     lcd_out
swnz_space:     mov     a,#' '
                jmp     lcd_out

show_word_nz:   setb    zero_sup
                mov     a,@r0
                swap    a
                call    swnz_out
                mov     a,@r0
                inc     r0
                call    swnz_out
                mov     a,@r0
                swap    a
                call    swnz_out
                mov     a,@r0
                dec     r0
                jmp     swz_out

how_many_digits:
                mov     r7,#4
                mov     a,@r0
                anl     a,#0f0h
                jnz     hmd_ret
                dec     r7
                mov     a,@r0
                anl     a,#0fh
                jnz     hmd_ret
                dec     r7
                inc     r0
                mov     a,@r0
                dec     r0
                anl     a,#0f0h
                jnz     hmd_ret
                dec     r7
hmd_ret:        ret

commander:      mov     kb_state,#0
                call    lcd_setup
                call    lcd_clear
                call    puts_nf
                db      'BANEL Pocitadlo 2.0',n
                db      '     2010-05-31',0
                call    wait4it_f
                db      t_wait,0,2,0
                call    reset_counter
                clr     a
                mov     early_cnt,a
                mov     early_pre,a
                mov     r0,#cmp_table
                mov     r1,#16
com_init_lp:    mov     @r0,a
                inc     r0
                djnz    r1,com_init_lp

menu0_main:     call    lcd_clear
                jnb     at_least_one,mm0_skip0
                mov     lcd_ind,#16
                mov     a,cmp_ind
                mov     r1,a
                rl      a
                add     a,#cmp_table
                mov     r0,a
mm0_lp1:        call    how_many_digits
                mov     a,lcd_ind
                clr     c
                subb    a,r7
                mov     r2,a
                dec     r2
                inc     a
                mov     lcd_ind,a
                jb      acc.7,mm0_skip0
                call    show_word
                mov     a,r2
                jb      acc.7,mm0_skip0
                mov     lcd_ind,a
mm0_lp2:        mov     a,r1
                inc     a
                anl     a,#7
                mov     r1,a
                rl      a
                add     a,#cmp_table
                mov     r0,a
                call    is_word_nz
                jz      mm0_lp2
                jmp     mm0_lp1
mm0_skip0:      mov     lcd_ind,#20
                mov     a,#'#'
                call    lcd_out
                mov     a,cmp_ind
                add     a,#'1'
                call    lcd_out
                clr     cmp_changed
mm0_skip1:      mov     lcd_ind,#23
                mov     dptr,#mode_text
                clr     a
                mov     c,at_least_one
                rlc     a
                call    puts_na
mm0_skip2:      mov     lcd_ind,#33
                mov     r0,#counted
                call    show_word_nz
                mov     dptr,#frac_text
                mov     a,prescaler
                call    puts_na
                clr     cnt_changed
mm0_lp3:        call    do_them
                call    keyboard
                jb      k_start,mm0_start
                jb      k_stop,mm0_stop
                jb      k_up,mm0_up
                jb      k_down,mm0_down
                jb      k_menu,mm0_menu
                jb      cnt_changed,mm0_skip2
                jnb     cmp_changed,mm0_lp3
                jmp     menu0_main

mm0_menu:       jmp     menu1_main

mm0_start:      jb      running,mm0_done
                call    reset_counter
                clr     na_sekundu
                clr     overflow
                setb    running
                clr     k1
                setb    k2
mm0_done:       jmp     menu0_main

mm0_stop:       jnb     running,mm0_zero
                clr     running
                setb    k1
                call    zapni_na_sekundu
                jmp     menu0_main
                
mm0_up:         mov     a,cmp_ind
                inc     a
                anl     a,#7
                mov     cmp_ind,a
                rl      a
                add     a,#cmp_table
                mov     r0,a
                call    is_word_nz
                jz      mm0_up
                setb    cmp_changed
                jmp     menu0_main

mm0_down:       mov     a,cmp_ind
                dec     a
                anl     a,#7
                mov     cmp_ind,a
                rl      a
                add     a,#cmp_table
                mov     r0,a
                call    is_word_nz
                jz      mm0_down
                setb    cmp_changed
                jmp     menu0_main

mm0_zero:       call    lcd_clear
                call    puts_nf
                db      '  Naozaj vynulovat',n
                db      '     pocitadlo?',0
mm0s_lp:        call    do_them
                call    keyboard
                jb      k_start,mm0s_confirm
                jb      k_stop,mm0s_cancel
                jmp     mm0s_lp
mm0s_confirm:   call    reset_counter
mm0s_cancel:    jmp     menu0_main

menu1_main:     mov     edit_ind,#0
                clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
mm1_skip1:      call    lcd_clear
                mov     lcd_ind,#2
                mov     r1,#4
                mov     r0,#1
                mov     a,edit_ind
                jnb     acc.4,mm1_lp1
                mov     r0,#5
mm1_lp1:        mov     a,r0
                add     a,#'0'
                call    lcd_out
                mov     a,lcd_ind
                add     a,#4
                mov     lcd_ind,a
                inc     r0
                djnz    r1,mm1_lp1
mm1_skip2:      mov     lcd_ind,#20
                mov     r1,#4
                mov     r0,#cmp_table
                mov     a,edit_ind
                jnb     acc.4,mm1_lp2
                mov     r0,#cmp_table+8
mm1_lp2:        call    show_word_z
                mov     a,#' '
                call    lcd_out
                inc     r0
                inc     r0
                djnz    r1,mm1_lp2
                mov     a,edit_ind
                anl     a,#0fh
                mov     r0,a
                anl     a,#0ch
                rr      a
                rr      a
                add     a,r0
                add     a,#20
                call    lcd_move
mm1_lp3:        call    do_them
                call    keyboard
                jb      k_start,mm1_right
                jb      k_stop,mm1_left
                jb      k_up,mm1_inc
                jb      k_down,mm1_dec
                jb      k_menu,mm1_menu
                jmp     mm1_lp3

mm1_menu:       clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                mov     r0,#cmp_table
                mov     r1,#8
                mov     r2,#0
mm1m_lp1:       call    is_word_nz
                jnz     mm1m_skip1
                inc     r0
                inc     r0
                inc     r2
                djnz    r1,mm1m_lp1
                clr     at_least_one
                jmp     menu3_main
mm1m_skip1:     setb    at_least_one
                mov     cmp_ind,r2
                jmp     menu3_main

mm1_right:      mov     a,edit_ind
                inc     a
                anl     a,#31
                mov     edit_ind,a
                jmp     mm1_skip1

mm1_left:       mov     a,edit_ind
                dec     a
                anl     a,#31
                mov     edit_ind,a
                jmp     mm1_skip1

mm1_inc:        mov     a,edit_ind
                jbc     acc.0,mm1i_odd
                rr      a
                add     a,#cmp_table
                mov     r0,a
                mov     a,@r0
                mov     r1,a
                anl     a,#0f0h
                swap    a
                mov     b,#10
                call    inc_mod_b
                swap    a
                mov     r2,a
                mov     a,r1
                anl     a,#0fh
                orl     a,r2
                mov     @r0,a
                jmp     mm1_skip2
mm1i_odd:       rr      a
                add     a,#cmp_table
                mov     r0,a
                mov     a,@r0
                mov     r1,a
                anl     a,#0fh
                mov     b,#10
                call    inc_mod_b
                mov     r2,a
                mov     a,r1
                anl     a,#0f0h
                orl     a,r2
                mov     @r0,a
                jmp     mm1_skip2

mm1_dec:        mov     a,edit_ind
                jbc     acc.0,mm1d_odd
                rr      a
                add     a,#cmp_table
                mov     r0,a
                mov     a,@r0
                mov     r1,a
                anl     a,#0f0h
                swap    a
                mov     b,#10
                call    dec_mod_b
                swap    a
                mov     r2,a
                mov     a,r1
                anl     a,#0fh
                orl     a,r2
                mov     @r0,a
                jmp     mm1_skip2
mm1d_odd:       rr      a
                add     a,#cmp_table
                mov     r0,a
                mov     a,@r0
                mov     r1,a
                anl     a,#0fh
                mov     b,#10
                call    dec_mod_b
                mov     r2,a
                mov     a,r1
                anl     a,#0f0h
                orl     a,r2
                mov     @r0,a
                jmp     mm1_skip2

menu3_main:     call    lcd_clear
                call    puts_nf
                db      '   Spomalit o',n
                db      'otacky pred vypnutim',0
mm3_lp1:        mov     lcd_ind,#14
                mov     a,early_cnt
                add     a,#'0'
                call    lcd_out
                mov     dptr,#frac_text
                mov     a,early_pre
                call    puts_na
mm3_lp2:        call    do_them
                call    keyboard
                jb      k_up,mm3_inc
                jb      k_down,mm3_dec
                jb      k_menu,mm3_menu
                jmp     mm3_lp2

mm3_menu:       jmp     menu0_main

mm3_inc:        inc     early_pre
                mov     a,early_pre
                cjne    a,#no_of_spots,mm3i_ok
                mov     early_pre,#0
                inc     early_cnt
                mov     a,early_cnt
                cjne    a,#10,mm3i_ok
                mov     early_cnt,#0
mm3i_ok:        jmp     mm3_lp1

mm3_dec:        mov     a,early_pre
                jnz     mm3d_ok1
                mov     early_pre,#no_of_spots-1
                mov     a,early_cnt
                jnz     mm3d_ok2
                mov     early_cnt,#9
                jmp     mm3_lp1
mm3d_ok1:       dec     early_pre
                jmp     mm3_lp1
mm3d_ok2:       dec     early_cnt
                jmp     mm3_lp1
