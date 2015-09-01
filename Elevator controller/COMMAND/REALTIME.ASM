; version 4.0

rtm1_start:     mov     cgp0,#0
                mov     cgp1,#4
                mov     cgp2,#4
                mov     cgp3,#0
rtm1_main_lp:   call    lcd_clear
                mov     r0,#i2c_time
                mov     a,@r0
                call    lcd_hex
                mov     b,cgp0
                mov     a,#':'
                jb      b.2,rtm1_skip1
                mov     a,#' '
rtm1_skip1:     call    lcd_out
                mov     r0,#i2c_time+1
                mov     a,@r0
                call    lcd_hex
                mov     a,#' '
                call    lcd_out
                mov     a,#' '
                jnb     ovazenie_10,rtm1_vaz1
                mov     a,#'_'
rtm1_vaz1:      jnb     ovazenie_80,rtm1_vaz2
                clr     a
rtm1_vaz2:      jnb     ovazenie_110,rtm1_vaz3
                mov     a,#255
rtm1_vaz3:      jnb     zakapanie,rtm1_vaz4
                mov     a,#'Z'
rtm1_vaz4:      call    lcd_out
                mov     a,#' '
                call    lcd_out
                mov     a,liftpos
                inc     a
                jnz     rtm1_nie_zrov
                mov     a,#' '
                call    lcd_out
                mov     a,#'?'
                call    lcd_out
                sjmp    rtm1_sipka
rtm1_nie_zrov:  call    lcd_dec2
                mov     a,nextfloor
                cjne    a,liftpos,rtm1_sipka
                mov     a,#'='
                sjmp    rtm1_drain1
rtm1_sipka:     mov     a,#'>'
rtm1_drain1:    call    lcd_out
                mov     a,nextfloor
                inc     a
                call    lcd_dec2
                mov     a,#' '
                call    lcd_out
                jb      a1,rtm1_print_a
                mov     a,#'-'
                call    lcd_out
                mov     a,#'-'
                sjmp    rtm1_a_drain
rtm1_print_a:   mov     a,#'A'
                call    lcd_out
                mov     a,#'1'
                jnb     a2,rtm1_a_drain
                mov     a,#'2'
                jnb     a3,rtm1_a_drain
                mov     a,#'3'
                jnb     a4,rtm1_a_drain
                mov     a,#'4'
rtm1_a_drain:   call    lcd_out

                mov     lcd_ind,#16
if dr_state_debug
                mov     a,cgp3
                jz      rtm1_normal
                mov     a,dr_state
                mov     dptr,#dr_state_text
                call    puts_na
                jmp     rtm1_skip10
endif
rtm1_normal:    call    aka_je_chyba
                jz      rtm1_no_error
                dec     a
                mov     dptr,#zc_text
                call    puts_na
                jmp     rtm1_skip10

rtm1_no_error:  clr     c
                jnb     je_obed_program,rtm1_skip2
                mov     dptr,#obed_str
                setb    c
rtm1_skip2:     jnb     je_ranny_program,rtm1_skip3
                mov     dptr,#ran_str
                setb    c
rtm1_skip3:     jnb     je_nezavisla_jazda,rtm1_skip4
                mov     dptr,#nez_str
                setb    c
rtm1_skip4:     mov     a,je_poziarna_jazda
                xrl     a,#1
                jnz     rtm1_skip5
                mov     dptr,#poz_str
                setb    c
rtm1_skip5:     jnb     dorovnava_sa,rtm1_skip6
                mov     dptr,#dorov_str
                setb    c
rtm1_skip6:     jnb     uz_je_nudzova,rtm1_skip7
                mov     dptr,#nud_str
                setb    c
rtm1_skip7:     jnb     uz_je_revizna,rtm1_skip8
                mov     dptr,#rev_str
                setb    c
rtm1_skip8:     jnc     rtm1_liftstate
                call    puts_n
                sjmp    rtm1_skip10

rtm1_liftstate: mov     a,liftstate
                xrl     a,#s_dvere
                jz      rtm1_doors
                mov     a,liftstate
                mov     dptr,#status_text
                call    puts_na
                sjmp    rtm1_skip10

rtm1_doors:     mov     a,error_a
                jz      rtm1_a_noerr
                mov     dptr,#d_error_str
                mov     a,error_a
                dec     a
                call    puts_na
                djnz    cgp1,rtm1_try_b
                mov     cgp1,#4
                mov     error_a,#0
                sjmp    rtm1_try_b
rtm1_a_noerr:   mov     dptr,#dvere_str_a
                mov     a,dvere_a
                call    puts_na

rtm1_try_b:     mov     lcd_ind,#22
                mov     a,error_b
                jz      rtm1_b_noerr
                mov     dptr,#d_error_str
                mov     a,error_b
                dec     a
                call    puts_na
                djnz    cgp2,rtm1_skip10
                mov     cgp2,#4
                mov     error_b,#0
                sjmp    rtm1_skip10
rtm1_b_noerr:   mov     dptr,#dvere_str_b
                mov     a,dvere_b
                call    puts_na

rtm1_skip10:    mov     dptr,#lcd_table+29
                movx    a,@dptr
                cjne    a,#' ',rtm1_skip12
                mov     lcd_ind,#30
                mov     r0,#i2c_time+6
                mov     a,@r0
                jnb     acc.7,rtm1_skip11
                cpl     a
                inc     a
                push    acc
                mov     lcd_ind,#29
                mov     a,#'-'
                call    lcd_out
                pop     acc
rtm1_skip11:    call    lcd_dec2

rtm1_skip12:    call    init_timer_f
                dw      t_realtime
                db      0,0,25
if 0
                mov     lcd_ind,#16
                clr     ea
                mov     a,inc_cnt_hi
                call    lcd_hex
                mov     a,inc_cnt_lo
                call    lcd_hex
                setb    ea
endif 
rtm1_wait:      call    do_them
                call    do_vnts
                dw      m_up+j_,rtm1_done
                dw      m_down+j_,rtm2_start
                dw      m_enter+j_,rtm1_toggle
                db      0
                call    timer_running_f
                dw      t_realtime
                jnz     rtm1_wait
                inc     cgp0
                jmp     rtm1_main_lp

rtm1_toggle:    mov     a,cgp3
                jz      rtm1_t_skip1
                mov     cgp3,#0
                jmp     rtm1_main_lp
rtm1_t_skip1:   inc     cgp3
                jmp     rtm1_main_lp

rtm1_done:      mov     c_index,#0
                jmp     level0_menu

rtm2_top:       mov     r0,cgp2
                mov     a,cgp1
                add     a,#call_table
                mov     r1,a
rtm2_t_lp:      mov     a,@r1
                rr      a
                anl     a,#3
                jnz     rtm2_t_ok
                mov     a,#'-'
rtm2_t_ok:      call    lcd_out
                inc     r1
                djnz    r0,rtm2_t_lp
                ret

rtm2_bottom:    mov     r0,cgp2
                mov     a,cgp1
                mov     r2,a
                add     a,#call_table
                mov     r1,a
rtm2_b_lp:      mov     a,liftpos
                xrl     a,r2
                jz      rtm2_b_ok
                mov     a,@r1
                jnb     acc.0,rtm2_b_skip
                mov     a,#'X'
                sjmp    rtm2_b_ok
rtm2_b_skip:    mov     a,#'-'
rtm2_b_ok:      call    lcd_out
                inc     r2
                inc     r1
                djnz    r0,rtm2_b_lp
                ret

rtm2_start:     call    lcd_clear
                clr     a
                mov     cgp0,a
                mov     cgp1,a
                mov     a,call_no
                mov     cgp2,a
                setb    c
                subb    a,#16
                jc      rtm2_main_lp
                mov     cgp0,#2
                mov     cgp2,#14

rtm2_main_lp:   mov     lcd_ind,#0
                mov     a,cgp0
                jb      acc.1,rtm2_mode2
                call    rtm2_top
                mov     lcd_ind,#16
                sjmp    rtm2_drain1
rtm2_mode2:     mov     a,cgp1
                inc     a
                call    lcd_dec2
                call    rtm2_top
                mov     lcd_ind,#16
                mov     a,cgp0
                jb      acc.0,rtm2_mode3
                mov     a,cgp1
                add     a,#14
                call    lcd_dec2
                sjmp    rtm2_drain1
rtm2_mode3:     mov     a,cgp1
                add     a,cgp3
                inc     a
                call    lcd_dec2
rtm2_drain1:    call    rtm2_bottom
                call    init_timer_f
                dw      t_realtime
                db      0,0,25
rtm2_w4time:    call    timer_running_f
                dw      t_realtime
                jz      rtm2_main_lp
                mov     a,cgp0
                jz      rtm2_wait_lp0
                xrl     a,#1
                jz      rtm2_wait_lp1
                xrl     a,#2
                jnz     rtm2_wait_lp2

rtm2_wait_lp3:  call    do_them
                call    do_vnts
                dw      m_left+j_,rtm2_3_prev
                dw      m_right+j_,rtm2_3_next
                dw      m_up+c_,rtm2_1_hore
                dw      m_down+c_,rtm2_1_dole
                dw      m_enter+c_,rtm2_1_kabina
                db      0
                jmp     rtm2_w4time

rtm2_wait_lp2:  call    do_them
                call    do_vnts
                dw      m_left+j_,rtm2_2_sc_l
                dw      m_right+j_,rtm2_2_sc_r
                dw      m_up+j_,rtm1_start
                dw      m_down+j_,rtm3_start
                dw      m_enter+j_,rtm2_2_mode3
                db      0
                jmp     rtm2_w4time

rtm2_wait_lp1:  call    do_them
                call    do_vnts
                dw      m_left+j_,rtm2_1_prev
                dw      m_right+j_,rtm2_1_next
                dw      m_up+c_,rtm2_1_hore
                dw      m_down+c_,rtm2_1_dole
                dw      m_enter+c_,rtm2_1_kabina
                db      0
                jmp     rtm2_w4time

rtm2_wait_lp0:  call    do_them
                call    do_vnts
                dw      m_left+j_,rtm2_0_left
                dw      m_right+j_,rtm2_0_right
                dw      m_up+j_,rtm1_start
                dw      m_down+j_,rtm3_start
                db      0
                jmp     rtm2_w4time

rtm2_0_left:    mov     cgp0,#1
                mov     cgp3,#0
rtm2_0_move:    mov     a,cgp3
                call    lcd_move
rtm2_0_show:    clr     a
                setb    lcd_on
                setb    lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                jmp     rtm2_main_lp

rtm2_0_right:   mov     cgp0,#1
                mov     a,call_no
                dec     a
                mov     cgp3,a
                jmp     rtm2_0_move

rtm2_1_prev:    mov     a,cgp3
                jz      rtm2_1_hide
                dec     a
rtm2_1_entry:   mov     cgp3,a
                call    lcd_move
                jmp     rtm2_wait_lp1
rtm2_1_next:    mov     a,cgp3
                inc     a
                cjne    a,call_no,rtm2_1_entry
rtm2_1_hide:    clr     a
                mov     cgp0,a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                jmp     rtm2_main_lp

rtm2_1_hore:    mov     a,cgp1
                add     a,cgp3
                mov     r4,a
                mov     r3,#g_hore
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                jmp     snd_msg

rtm2_1_dole:    mov     a,cgp1
                add     a,cgp3
                mov     r4,a
                mov     r3,#g_dole
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                jmp     snd_msg

rtm2_1_kabina:  mov     a,cgp1
                add     a,cgp3
                mov     r4,a
                mov     r3,#g_kabina
                mov     r2,#2
                mov     r1,#m_new_call
                mov     r0,#id_group
                jmp     snd_msg

rtm2_2_sc_l:    mov     a,cgp1
                jz      rtm2_2_1
                dec     cgp1
                jmp     rtm2_main_lp

rtm2_2_sc_r:    mov     a,cgp1
                add     a,#14
                cjne    a,call_no,rtm2_2_2
rtm2_2_1:       jmp     rtm2_wait_lp2
rtm2_2_2:       inc     cgp1
                jmp     rtm2_main_lp

rtm2_2_mode3:   mov     cgp0,#3
                mov     cgp3,#6
                mov     a,cgp3
                add     a,#2
                call    lcd_move
                jmp     rtm2_0_show

rtm2_3_prev:    mov     a,cgp3
                jz      rtm2_3_sc_l
                dec     a
rtm2_3_entry:   mov     cgp3,a
                add     a,#2
                call    lcd_move
                jmp     rtm2_wait_lp3
rtm2_3_next:    mov     a,cgp3
                inc     a
                cjne    a,#14,rtm2_3_entry
                mov     a,cgp1
                add     a,#14
                cjne    a,call_no,rtm2_3_2
rtm2_3_hide:    mov     cgp0,#2
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode
                jmp     rtm2_main_lp
rtm2_3_2:       inc     cgp1
                jmp     rtm2_main_lp
rtm2_3_sc_l:    mov     a,cgp1
                jz      rtm2_3_hide
                dec     cgp1
                jmp     rtm2_main_lp

rtm3_start:     call    lcd_clear
                mov     dptr,#p_v_text
                call    puts_n
rtm3_main_lp:   mov     lcd_ind,#18
                clr     a
                mov     c,zakaz_pohon
                cpl     c
                rlc     a
                mov     dptr,#p_v_bool
                call    puts_na
                mov     lcd_ind,#26
                clr     a
                mov     c,zakaz_vonkajsie0
                cpl     c
                rlc     a
                mov     dptr,#p_v_bool
                call    puts_na
rtm3_wait:      call    do_them
                call    do_vnts
                dw      m_left+j_,rtm3_toggle1
                dw      m_right+j_,rtm3_toggle2
                dw      m_up+j_,rtm2_start
                dw      m_down+j_,rtm6_start
                db      0
                jmp     rtm3_wait

rtm3_toggle1:   cpl     zakaz_pohon
                jmp     rtm3_start

rtm3_toggle2:   cpl     zakaz_vonkajsie0
                jmp     rtm3_start

rtm6_start:     call    lcd_clear
                mov     dptr,#n_x_text
                call    puts_n
rtm6_main_lp:   mov     lcd_ind,#18
                mov     a,nahodne_volby
                anl     a,#1
                mov     dptr,#p_v_bool
                call    puts_na
if 0
                mov     lcd_ind,#26
                clr     a
                mov     c,zakaz_vonkajsie0
                cpl     c
                rlc     a
                mov     dptr,#p_v_bool
                call    puts_na
endif
rtm6_wait:      call    do_them
                call    do_vnts
                dw      m_left+j_,rtm6_toggle1
                ;dw      m_right+j_,rtm6_toggle2
                dw      m_up+j_,rtm3_start
                dw      m_down+j_,rtm4_start
                db      0
                jmp     rtm6_wait

rtm6_toggle1:   xrl     nahodne_volby,#1
                jmp     rtm6_start

;rtm6_toggle2:   cpl     zakaz_vonkajsie0
;                jmp     rtm6_start

rtm4_start:     call    lcd_clear
                mov     dptr,#p_j_text
                call    puts_n
rtm4_main_lp:   mov     lcd_ind,#21
                call    display_pocet_jazd
                call    init_timer_f
                dw      t_realtime
                db      0,0,25
rtm4_wait:      call    do_them
                call    do_vnts
                dw      m_up+j_,rtm3_start
                dw      m_down+j_,rtm5_start
                db      0
                call    timer_running_f
                dw      t_realtime
                jnz     rtm4_wait
                jmp     rtm4_main_lp

rtm5_start:     call    lcd_clear
                mov     dptr,#lang_text1
                call    puts_n
                mov     lcd_ind,#20
                mov     dptr,#lang_text2
                call    puts_n
rtm5_wait:      call    do_them
                call    do_vnts
                dw      m_left+j_,rtm5_dec
                dw      m_right+j_,rtm5_inc
                dw      m_up+j_,rtm5_prev
                dw      m_down+j_,rtm5_done
                db      0
                jmp     rtm5_wait

rtm5_dec:       mov     a,language
                mov     b,#no_of_languages
                call    dec_mod_b
                mov     language,a
                call    uloz_jazyk
                jmp     rtm5_start

rtm5_inc:       mov     a,language
                mov     b,#no_of_languages
                call    inc_mod_b
                mov     language,a
                call    uloz_jazyk
                jmp     rtm5_start

rtm5_prev:      mov     a,supervisor
                jz      rtm4_start
                dec     a
                jz      rtm5_prv_skp
                mov     c_index,#5
                jmp     level0_menu                
rtm5_prv_skp:   mov     c_index,#3
                jmp     level0_menu                

rtm5_done:      mov     c_index,#0
                jmp     level0_menu
