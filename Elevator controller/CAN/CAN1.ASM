; version 4.0

can1_data:      db      c_mid0,c_ma0,c_mid1,c_ma1
                db      ((c_sjw-1) shl 6) or (c_brpv-1)
                db      (c_smp shl 7) or ((c_tseg2-1) shl 4) or (c_tseg1-1)
                dw      c_sgm shl 5
                dw      (c_egm0 shl 3) or (c_egm1 shr 13)
                dw      c_egm1 shl 3
                dw      (c_m15m0 shl 3) or (c_m15m1 shr 13)
                dw      c_m15m1 shl 3

can1_init:      clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                mov     c1c,#c_crst+c_swint
                mov     r0,#0
c1i_lp1:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c1c
                anl     a,#c_crst
                jnz     c1i_ok1
                djnz    r0,c1i_lp1

c1i_ok1:        clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                orl     p5cnt,#00010000b        ; p5.2 + p5.3 -> can 1
                mov     ta,#0aah
                mov     ta,#055h
                mov     c1c,#c_swint
                mov     r0,#0
c1i_lp2:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c1c
                anl     a,#c_crst
                jz      c1i_ok2
                djnz    r0,c1i_lp2

c1i_ok2:        mov     c1te,#0

                clr     ea
                mov     ta,#0aah
                mov     ta,#055h
                anl     cor,#10011111b
                mov     ta,#0aah
                mov     ta,#055h
                orl     cor,#((c_brpv-1) shr 1) and 01100000b
                setb    ea
                mov     dps,#5
                clr     a
                mov     dpx,a
                mov     dph,#0efh
                mov     dpl,a
                mov     dpx1,a
                mov     dptr,#can1_data
                mov     dps,#00100101b
                mov     r0,#16
c1i_lp3:        clr     a
                movc    a,@a+dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,c1i_lp3
                mov     dps,#0
                ret

can1_clr_swint: clr     ea
                mov     ta,#0aah
                mov     ta,#055h      
                anl     c1c,#not(c_swint)
                mov     r0,#0
c1cs_lp:        push    ar0
                call    do_them
                pop     ar0
                mov     a,c1c
                anl     a,#c_swint
                jz      c1cs_ret
                djnz    r0,c1cs_lp
c1cs_ret:       ret
