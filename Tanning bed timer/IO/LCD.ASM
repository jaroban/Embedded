; version 1.0

lcd_on          bit     acc.2
lcd_cursor      bit     acc.1
lcd_blink       bit     acc.0

; waste ~ 2304 * count cycles (plus any interrupts)
; 2304 cycles == 1ms @ 9216000, 1/4 osc
wait_ms:        inc     a
                mov     dpl,a
                djnz    dpl,wms_ok
                ret                     ; cycles spent per count
wms_ok:         push    b
wms_lp1:        mov     a,#121          ; 1 * count
                mov     b,#5            ; 2 * count
wms_lp2:        djnz    acc,wms_lp2     ; 2 * (a + (b - 1) * 256) * count
                djnz    b,wms_lp2       ; 2 * b * count
                djnz    dpl,wms_lp1     ; 2 * count
                pop     b
                ret                     ; total ~ (5 + 2 * a + 514 * b - 512) * count
                                        ; 5 + 2 * a + 514 * b - 512 = 2304
                                        ; a + 257 * b = 1405.5
                                        ; b = 5, a = 120.5

write_to_lcd:   mov     p0,a
                ret

gonna_read_lcd: mov     p0,#0ffh
                ret

read_from_lcd:  mov     a,p0
                ret

lcd_delay:      nop
                nop
                nop
                nop
                nop
                nop
                nop
                ret

lcd_command2:   clr     lcd_rs
                clr     lcd_rw
                call    write_to_lcd
                call    lcd_delay
                setb    lcd_en
                call    lcd_delay
                clr     lcd_en
                call    lcd_delay
                clr     lcd_rs
                setb    lcd_rw
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
                call    tmr_int_f
                db      t_lcd,0,0,2
lw_lp:          call    do_them
                setb    lcd_en
                call    lcd_delay
                call    read_from_lcd
                clr     lcd_en
                jnb     acc.7,lw_ret
                mov     a,#t_lcd
                call    tmr_zro
                jnc     lw_lp
lw_ret:         ret

lcd_clear_f:    mov     lcd_pos,#0
                mov     r0,#lcd_table+34
                mov     a,#' '
                mov     r1,#32
lcf_lp:         mov     @r0,a
                inc     r0
                djnz    r1,lcf_lp
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

lcd_put_byte:   call    lcd_data
                mov     a,lcd_pos
                add     a,#1
                mov     lcd_pos,a
                jnb     ac,lpb_ret
                anl     a,#31
                mov     lcd_pos,a
                rl      a
                rl      a
                orl     a,#80h
                jmp     lcd_command
lpb_ret:        ret

lcd_init:       mov     a,#40
                call    wait_ms
                clr     lcd_en
                mov     a,#00111000b
                call    lcd_command2
                mov     a,#5
                call    wait_ms
                mov     a,#00111000b
                call    lcd_command2
                mov     a,#1
                call    wait_ms
                mov     a,#00111000b
                call    lcd_command2
                mov     a,#40
                call    wait_ms

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

lcd_setup_f:    mov     r0,#lcd_table+34
                mov     a,#' '
                mov     r1,#32
lsf_lp:         mov     @r0,a
                inc     r0
                djnz    r1,lsf_lp
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                mov     @r0,a
                mov     a,#0ffh
                inc     r0
                mov     @r0,a
                ret

lcd_refresh:    mov     r0,#lcd_table
                mov     r1,#lcd_table+34
                mov     r2,#32
                mov     r6,#0
                mov     r7,#0
lcd_r_lp1:      mov     a,@r0
                xrl     a,#' '
                jz      lcd_r_skip1
                inc     r7
                sjmp    lcd_r_skip2
lcd_r_skip1:    mov     a,@r1
                xrl     a,#' '
                jz      lcd_r_skip2
                inc     r6
lcd_r_skip2:    inc     r0
                inc     r1
                djnz    r2,lcd_r_lp1
                mov     a,r7
                add     a,#2
                clr     c
                subb    a,r6
                jnc     lcd_r_skip3
                jmp     lcd_clear_f
lcd_r_skip3:    mov     r0,#lcd_table
                mov     r1,#lcd_table+34
                mov     r2,#0
                mov     r3,#32
lcd_r_lp2:      mov     a,@r1
                mov     b,a
                mov     a,@r0
                cjne    a,b,lcd_r_change
                inc     r0
                inc     r1
                inc     r2
                djnz    r3,lcd_r_lp2
                mov     a,@r1
                mov     b,a
                mov     a,@r0
                cjne    a,b,lcd_r_mode
                anl     a,#3
                jz      lcd_r_done
                inc     r0
                inc     r1
                mov     a,@r1
                mov     b,a
                mov     a,@r0
                cjne    a,b,lcd_r_move1
                cjne    a,lcd_pos,lcd_r_move2
lcd_r_done:     ret
lcd_r_move1:    mov     @r1,a
lcd_r_move2:    jmp     lcd_move_f
lcd_r_mode:     mov     @r1,a
                jmp     lcd_mode_f
lcd_r_change:   mov     @r1,a
                push    acc
                mov     a,lcd_pos
                xrl     a,r2
                jz      lcd_r_ok
                mov     a,r2
                call    lcd_move_f
lcd_r_ok:       pop     acc
                jmp     lcd_put_byte

lcd_setup:      mov     r0,#lcd_table
                mov     a,#' '
                mov     r1,#32
ls_lp:          mov     @r0,a
                inc     r0
                djnz    r1,ls_lp
                clr     a
                setb    lcd_on
                clr     lcd_cursor
                clr     lcd_blink
                mov     @r0,a
                inc     r0
                mov     a,#0ffh
                mov     @r0,a
                ret

lcd_mode:       mov     r0,#lcd_table+32
                anl     a,#7
                mov     @r0,a
                ret

lcd_move:       mov     r0,#lcd_table+33
                anl     a,#31
                mov     @r0,a
                ret

lcd_clear:      mov     r0,#lcd_table
                mov     lcd_ind,#0
                mov     a,#' '
                mov     r1,#32
lcd_c_lp:       mov     @r0,a
                inc     r0
                djnz    r1,lcd_c_lp
                ret

lcd_out:        cjne    a,#n,lcd_o_ok
                mov     a,lcd_ind
                clr     c
                subb    a,#16
                jc      lcd_o_skip
                push    ar0
                push    ar1
                push    ar2
                mov     r0,#lcd_table
                mov     r1,#lcd_table+16
                mov     r2,#16
lcd_o_lp:       mov     a,#' '
                xch     a,@r1
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,lcd_o_lp
                pop     ar2
                pop     ar1
                pop     ar0
lcd_o_skip:     mov     lcd_ind,#16
                ret
lcd_o_ok:       push    ar0
                push    acc
                mov     a,lcd_ind
                inc     a
                anl     a,#31
                xch     a,lcd_ind
                add     a,#lcd_table
                mov     r0,a
                pop     acc
                mov     @r0,a
                pop     ar0
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

pn_nxt:         call    lcd_out
                inc     dptr
puts_n:         clr     a
                movc    a,@a+dptr
                jnz     pn_nxt
                ret

puts_na:        jz      puts_n
                mov     b,a
pna_lp:         clr     a
                movc    a,@a+dptr                
                inc     dptr
                jnz     pna_lp
                djnz    b,pna_lp
                jmp     puts_n

puts_nf:        pop     dph
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

define_chars:   mov     dptr,#char_table
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
                call    rst_wd
                pop     dph
                pop     dpl
                pop     ar1
                pop     ar0
                inc     dptr
                inc     r0
                djnz    r1,def_ch_lp
                ret
