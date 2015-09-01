; version 3.0

lcd_on          bit     acc.2
lcd_cursor      bit     acc.1
lcd_blink       bit     acc.0

write_to_lcd:   mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#7
                movx    @dptr,a
                mov     dpx,#0
                ret

gonna_read_lcd: mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#7
                mov     a,#0ffh
                movx    @dptr,a
                mov     dpx,#0
                ret

read_from_lcd:  mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#4
                movx    a,@dptr
                mov     dpx,#0
                ret

lcd_delay:      nop
                nop
                nop
                nop
                nop
                nop
                nop
                ret

lcd_command:    clr     lcd_rs
                sjmp    lcd_write
lcd_data:       setb    lcd_rs
lcd_write:      clr     lcd_rw
                call    write_to_lcd
                call    lcd_delay
                setb    lcd_en
                call    lcd_delay
                clr     lcd_en
                call    lcd_delay
                clr     lcd_rs
                setb    lcd_rw
                call    gonna_read_lcd
                call    init_timer_f
                dw      t_lcd
                db      0,0,10
lw_lp:          call    do_them
                setb    lcd_en
                call    lcd_delay
                call    read_from_lcd
                clr     lcd_en
                jnb     acc.7,lw_ret
                call    timer_running_f
                dw      t_lcd
                jnz     lw_lp
lw_ret:         ret

lcd_clear_f:    mov     lcd_pos,#0
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table+34
                mov     a,#' '
                mov     r0,#32
lcf_lp:         movx    @dptr,a
                inc     dptr
                djnz    r0,lcf_lp
                mov     a,#1
                jmp     lcd_command

lcd_mode_f:     anl     a,#7
                orl     a,#8
                jmp     lcd_command

lcd_move_f:     anl     a,#31
                mov     lcd_pos,a
                jnb     acc.4,lmf_skip
                anl     a,#0fh
                orl     a,#40h
lmf_skip:       orl     a,#80h
                jmp     lcd_command

lcd_put_byte:   push    dpl
                push    dph
                call    lcd_data
                mov     a,lcd_pos
                add     a,#1
                mov     lcd_pos,a
                jnb     ac,lpb_ok
                anl     a,#31
                mov     lcd_pos,a
                rl      a
                rl      a
                orl     a,#80h
                call    lcd_command
lpb_ok:         pop     dph
                pop     dpl
                ret

lcd_init:       clr     lcd_en
                mov     a,#00111000b
                call    lcd_command
                mov     a,#00111000b
                call    lcd_command
                mov     a,#00010100b
                call    lcd_command
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                call    lcd_mode_f
                mov     a,#00000110b
                call    lcd_command
                jmp     lcd_clear_f

lcd_setup_f:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table+34
                mov     a,#' '
                mov     r0,#32
lsf_lp:         movx    @dptr,a
                inc     dptr
                djnz    r0,lsf_lp
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                movx    @dptr,a
                mov     a,#0ffh
                inc     dptr
                movx    @dptr,a
                ret

lcd_refresh:    clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#00100100b
                mov     dptr,#lcd_table         ; 0
                mov     dptr,#lcd_table+34      ; 1
                mov     r0,#32
                mov     r1,#0
                mov     r2,#0
lcd_r_lp1:      movx    a,@dptr                 ; 0
                xrl     a,#' '
                jz      lcd_r_skip1
                inc     r2
                mov     dps,#00100100b
                sjmp    lcd_r_skip2
lcd_r_skip1:    movx    a,@dptr                 ; 1
                xrl     a,#' '
                jz      lcd_r_skip2
                inc     r1
lcd_r_skip2:    inc     dptr                    ; 0
                inc     dptr                    ; 1
                djnz    r0,lcd_r_lp1
                mov     a,r2
                add     a,#2
                clr     c
                subb    a,r1
                jnc     lcd_r_skip3
                mov     dps,#0
                jmp     lcd_clear_f
lcd_r_skip3:    mov     dps,#00100100b
                mov     dptr,#lcd_table+34      ; 0
                mov     dptr,#lcd_table         ; 1
                mov     r0,#32
                mov     r1,#0
lcd_r_lp2:      movx    a,@dptr                 ; 0
                mov     b,a
                movx    a,@dptr                 ; 1
                cjne    a,b,lcd_r_change
                inc     dptr                    ; 0
                inc     dptr                    ; 1
                inc     r1
                djnz    r0,lcd_r_lp2
                movx    a,@dptr                 ; 0
                mov     b,a
                movx    a,@dptr                 ; 1
                cjne    a,b,lcd_r_mode
                anl     a,#3
                jz      lcd_r_done
                inc     dptr                    ; 0
                inc     dptr                    ; 1
                movx    a,@dptr                 ; 0
                mov     b,a
                movx    a,@dptr                 ; 1
                cjne    a,b,lcd_r_move1
                cjne    a,lcd_pos,lcd_r_move2
lcd_r_done:     mov     dps,#0
                ret
lcd_r_move1:    movx    @dptr,a                 ; 0
lcd_r_move2:    mov     dps,#0
                jmp     lcd_move_f
lcd_r_mode:     movx    @dptr,a                 ; 0
                mov     dps,#0
                jmp     lcd_mode_f
lcd_r_change:   mov     dps,#0
                movx    @dptr,a                 ; 0
                push    acc
                mov     a,lcd_pos
                xrl     a,r1
                jz      lcd_r_ok
                mov     a,r1
                call    lcd_move_f
lcd_r_ok:       pop     acc
                jmp     lcd_put_byte

lcd_setup:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table
                mov     a,#' '
                mov     r0,#32
lcd_setup_lp:   movx    @dptr,a
                inc     dptr
                djnz    r0,lcd_setup_lp
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                movx    @dptr,a
                inc     dptr
                mov     a,#0ffh
                movx    @dptr,a
                clr     scrolling
                ret

lcd_mode:       mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table+32
                anl     a,#7
                movx    @dptr,a
                ret

lcd_move:       mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table+33
                anl     a,#31
                movx    @dptr,a
                ret

lcd_clear:      mov     dps,#0
                mov     dpx,#0
                mov     dptr,#lcd_table
                mov     lcd_ind,#0
                mov     a,#' '
                mov     r0,#32
lcd_c_lp:       movx    @dptr,a
                inc     dptr
                djnz    r0,lcd_c_lp
                ret

lcd_out:        cjne    a,#n,lcd_o_ok
                mov     a,lcd_ind
                clr     c
                subb    a,#16
                jc      lcd_o_skip
                push    dpl
                push    dph
lcd_o_entry:    push    ar0
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#00100100b
                mov     dptr,#lcd_table         ; 0
                mov     dptr,#lcd_table+16      ; 1
                mov     r0,#16
lcd_o_lp:       mov     dps,#00100101b
                movx    a,@dptr                 ; 1
                movx    @dptr,a                 ; 0
                mov     a,#' '
                movx    @dptr,a                 ; 1
                inc     dptr                    ; 0
                inc     dptr                    ; 1
                djnz    r0,lcd_o_lp
                mov     dps,#0
                pop     ar0
                pop     dph
                pop     dpl
lcd_o_skip:     mov     lcd_ind,#16
                ret
lcd_o_ok:       push    dpl
                push    dph
                push    acc
                mov     dps,#0
                mov     dpx,#0
                mov     a,lcd_ind
                inc     a
                anl     a,#31
                xch     a,lcd_ind
                add     a,#low(lcd_table)
                mov     dpl,a
                clr     a
                addc    a,#high(lcd_table)
                mov     dph,a
                pop     acc
                movx    @dptr,a
                jnb     scrolling,lcd_o_ret
                mov     a,lcd_ind
                jz      lcd_o_entry
lcd_o_ret:      pop     dph
                pop     dpl
                ret

lcd_hex:        mov     b,a
                swap    a 
                call    hex_asc
                call    lcd_out
                mov     a,b
                call    hex_asc
                jmp     lcd_out     

lcd_dec0:       mov     b,#10
                div     ab
                push    b
                jz      ld0_only1
                mov     b,#10
                div     ab
                jz      ld0_only2
                add     a,#'0'
                call    lcd_out
ld0_only2:      mov     a,b
                add     a,#'0'
                call    lcd_out
ld0_only1:      pop     acc
                add     a,#'0'
                jmp     lcd_out

lcd_dec2:       mov     b,#10
                div     ab
                jz      ld2_only1
                add     a,#'0'
                sjmp    ld2_two
ld2_only1:      mov     a,#' '
ld2_two:        call    lcd_out                
                mov     a,b
                add     a,#'0'
                jmp     lcd_out

lcd_dec_ex2:    mov     b,#10
                div     ab
                add     a,#'0'
                call    lcd_out                
                mov     a,b
                add     a,#'0'
                jmp     lcd_out

lcd_dec3:       mov     b,#10
                div     ab
                jz      ld3_only1
                push    b
                mov     b,#10
                div     ab
                jz      ld3_only2
                add     a,#'0'
                call    lcd_out
ld3_middle:     mov     a,b
                add     a,#'0'
                call    lcd_out
                sjmp    ld3_last
ld3_only2:      mov     a,#' '
                call    lcd_out
                sjmp    ld3_middle
ld3_only1:      push    b
                mov     a,#' '
                call    lcd_out
                mov     a,#' '
                call    lcd_out
ld3_last:       pop     acc
                add     a,#'0'
                jmp     lcd_out

puts_n:         mov     a,language
                jz      pn_print
                push    dpl
                push    dph
                push    ar0
                mov     r0,a
pn_find_lp:     clr     a
                movc    a,@a+dptr
                jz      pn_default
                inc     dptr
                cjne    a,#language_separator,pn_find_lp
                djnz    r0,pn_find_lp
                pop     ar0
                pop     acc
                pop     acc
                sjmp    pn_print
pn_default:     pop     ar0
                pop     dph
                pop     dpl
                sjmp    pn_print
pn_p_lp:        call    lcd_out
                inc     dptr
pn_print:       clr     a
                movc    a,@a+dptr
                jz      pn_p_done
                cjne    a,#language_separator,pn_p_lp
pn_p_done:      ret

puts_na:        jz      puts_n
                mov     b,a
pna_lp:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     pna_lp
                djnz    b,pna_lp
                jmp     puts_n

puts_nf:        mov     dps,#0
                mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
                sjmp    pnf_entry
pnf_lp:         call    lcd_out
pnf_entry:      clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     pnf_lp
                jmp     @a+dptr

puts:           clr     a
                movc    a,@a+dptr
                call    lcd_out
                inc     dptr
                djnz    r0,puts
                ret

; string(2) at dptr+a*2 -> lcd
puts_2:         rl      a
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                mov     r0,#2
                jmp     puts

; string(3) at dptr+a*3 -> lcd
puts_3:         mov     r0,a
                rl      a
                add     a,r0
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                mov     r0,#3
                jmp     puts    

define_chars:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#char_table
                mov     r0,#0
                mov     r1,#64
def_ch_lp:      clr     a
                movc    a,@a+dptr
                push    ar0
                push    ar1
                push    dpl
                push    dph
                push    acc
                mov     a,r0
                anl     a,#3fh
                orl     a,#40h
                call    lcd_command
                pop     acc
                call    lcd_data
                pop     dph
                pop     dpl
                pop     ar1
                pop     ar0
                inc     dptr
                inc     r0
                djnz    r1,def_ch_lp
                ret
