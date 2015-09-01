; version 1.0

do_crc:         mov     r6,#8
                mov     r7,a
dc_lp:          xrl     a,crc
                rrc     a
                mov     a,crc
                jnc     dc_zero
                xrl     a,#18h
dc_zero:        rrc     a
                mov     crc,a
                mov     a,r7
                rr      a
                mov     r7,a
                djnz    r6,dc_lp
                ret

is_crc_ok:      mov     crc,#0
                mov     r1,#8
                mov     a,#0ffh
ico_lp1:        anl     a,@r0
                inc     r0
                djnz    r1,ico_lp1
                cpl     a
                jz      ico_bad
                dec     r0
                mov     r1,#7
ico_lp2:        mov     a,@r0
                call    do_crc
                dec     r0
                djnz    r1,ico_lp2
                mov     a,@r0
                xrl     a,crc
                jz      ico_ok
ico_bad:        clr     a
                ret
ico_ok:         cpl     a
                ret

touch_reset:    clr     ea
                mov     a,#3
                clr     data_bit
                mov     r7,#185
                djnz    r7,$
                setb    data_bit
                mov     r7,#133
                clr     c
tr_lo_lp:       jb      data_bit,tr_skip
                djnz    r7,tr_lo_lp
                djnz    acc,tr_lo_lp
                jmp     tr_end
tr_skip:        mov     r7,#93
tr_hi_lp:       orl     c,/data_bit
                djnz    r7,tr_hi_lp
tr_end:         setb    ea
                ret

touch_byte:     clr     ea
                mov     r6,#8
bit_loop:       rrc     a
                clr     data_bit
                nop
                nop
                nop
                nop
                mov     data_bit,c
                nop
                nop
                nop
                nop
                nop
                mov     c,data_bit
                mov     r7,#18
                djnz    r7,$
                setb    data_bit
                djnz    r6,bit_loop
                rrc     a
                setb    ea
                ret

; returns in buffer the read key
wait_for_key:
w4k_lp1:        call    do_them
                call    touch_reset
                jc      w4k_yes
                setb    yled
                jmp     w4k_lp1

w4k_yes:        mov     r0,#redundancy1
w4k_lp2:        push    ar0
                call    do_them
                pop     ar0
                call    touch_reset
                jnc     w4k_lp1
                djnz    r0,w4k_lp2

                mov     a,#33h
                call    touch_byte
                mov     r1,#8
                mov     r0,#buffer_1w+7
w4k_lp3:        mov     a,#0ffh
                call    touch_byte
                mov     @r0,a
                dec     r0
                djnz    r1,w4k_lp3

                mov     r0,#buffer_1w
                call    is_crc_ok
                jz      w4k_lp1
                mov     a,#0ffh
                ret

; same as above, with time limit
wait_for_key2:  call    tmr_int_f
                db      t_delay,0,10,0
w4k2_lp1:       call    do_them
                call    touch_reset
                jc      w4k2_yes
                setb    yled
                mov     a,#t_delay
                call    tmr_zro
                jnc     w4k2_lp1
                clr     a
                ret

w4k2_yes:       mov     r0,#redundancy1
w4k2_lp2:       push    ar0
                call    do_them
                pop     ar0
                call    touch_reset
                jnc     w4k2_lp1
                djnz    r0,w4k2_lp2

                mov     a,#33h
                call    touch_byte
                mov     r1,#8
                mov     r0,#buffer_1w+7
w4k2_lp3:       mov     a,#0ffh
                call    touch_byte
                mov     @r0,a
                dec     r0
                djnz    r1,w4k2_lp3

                mov     r0,#buffer_1w
                call    is_crc_ok
                jz      w4k2_lp1
                mov     a,#0ffh
                ret
