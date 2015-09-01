; version 4.0

can0_data:      db      c_mid0,c_ma0,c_mid1,c_ma1
                db      ((c_sjw-1) shl 6) or (c_brpv-1)
                db      (c_smp shl 7) or ((c_tseg2-1) shl 4) or (c_tseg1-1)
                dw      c_sgm shl 5
                dw      (c_egm0 shl 3) or (c_egm1 shr 13)
                dw      c_egm1 shl 3
                dw      (c_m15m0 shl 3) or (c_m15m1 shr 13)
                dw      c_m15m1 shl 3

can0_init:      clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                mov     c0c,#c_crst+c_swint
                mov     r0,#0
c0i_lp1:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c0c
                anl     a,#c_crst
                jnz     c0i_ok1
                djnz    r0,c0i_lp1

c0i_ok1:        clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                orl     p5cnt,#00001000b        ; p5.0 + p5.1 -> can 0
                mov     ta,#0aah
                mov     ta,#055h
                mov     c0c,#c_swint
                mov     r0,#0
c0i_lp2:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c0c
                anl     a,#c_crst
                jz      c0i_ok2
                djnz    r0,c0i_lp2

c0i_ok2:        mov     c0te,#0

                clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                anl     cor,#11100111b
                mov     ta,#0aah
                mov     ta,#055h
                orl     cor,#((c_brpv-1) shr 3) and 00011000b
                setb    ea
                mov     dps,#5
                clr     a
                mov     dpx,a
                mov     dph,#0eeh
                mov     dpl,a
                mov     dpx1,a
                mov     dptr,#can0_data
                mov     dps,#00100101b
                mov     r0,#16
c0i_lp3:        clr     a
                movc    a,@a+dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,c0i_lp3
                mov     dps,#0
                ret

can0_clr_swint: clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                anl     c0c,#not(c_swint)
                mov     r0,#0
c0cs_lp:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c0c
                anl     a,#c_swint
                jz      c0cs_ret
                djnz    r0,c0cs_lp
c0cs_ret:       ret
