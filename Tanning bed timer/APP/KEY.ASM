; version 1.0

cmp_key:        mov     r1,#buffer
                mov     r2,#6
ck_lp:          mov     a,@r0
                xrl     a,@r1
                jnz     ck_not_eq
                inc     r0
                inc     r1
                djnz    r2,ck_lp
                setb    c
                ret
ck_not_eq:      clr     c
                ret

touch_key:      setb    data_bit
                clr     k_access

tk_main_lp:     call    do_them
                mov     a,#t_key
                call    tmr_zro
                jnc     tk_main_lp
                call    tmr_int_f
                db      t_key,0,0,16
                clr     k_access
                call    rst_wd
                mov     r0,#3
tk_wait_lp:     call    touch_reset
                jnc     tk_main_lp
                push    ar0
                call    do_them
                pop     ar0
                djnz    r0,tk_wait_lp
                mov     crc,#0
                mov     a,#33h
                call    touch_byte
                call    do_them
                mov     a,#0ffh
                call    touch_byte
                call    do_crc
                call    do_them
                mov     r1,#6
                mov     r0,#buffer
tk_read_lp:     mov     a,#0ffh
                call    touch_byte
                mov     @r0,a
                call    do_crc
                push    ar0
                push    ar1
                call    do_them
                pop     ar1
                pop     ar0
                inc     r0
                djnz    r1,tk_read_lp
                mov     a,#0ffh
                call    touch_byte
                cjne    a,crc,tk_main_lp
                call    do_them
                mov     r0,#key1
                call    cmp_key
                jc      tk_got_it
                mov     r0,#key2
                call    cmp_key
                jc      tk_got_it
                mov     r0,#key3
                call    cmp_key
                jc      tk_got_it
                jmp     tk_main_lp
tk_got_it:      setb    k_access
                jmp     tk_main_lp
