; version 1.0

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

do_crc:         mov     r6,#8
                mov     r7,a
crc_loop:       xrl     a,crc
                rrc     a
                mov     a,crc
                jnc     crc_zero
                xrl     a,#18h
crc_zero:       rrc     a
                mov     crc,a
                mov     a,r7
                rr      a
                mov     r7,a
                djnz    r6,crc_loop
                ret
