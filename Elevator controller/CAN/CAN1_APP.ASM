; version 4.1

c_mid0          set     0               ; media id mask 0
c_mid1          set     0               ; media id mask 1
c_ma0           set     0               ; media arbitration 0
c_ma1           set     0               ; media arbitration 1
c_sjw           set     1               ; synchronization jump width (1-4)
if double_speed
  c_brpv        set     18              ; baud rate prescaler value
else
  c_brpv        set     9               ; baud rate prescaler value
endif
c_smp           set     1               ; sampling rate (0-1)
c_tseg1         set     13              ; time segment 1 length (2-16)
c_tseg2         set     2               ; time segment 2 length (2-8)
c_sgm           set     0               ; standard global mask (11 bits)
c_egm0          set     0               ; extended global mask hi (13 bits)
c_egm1          set     0               ; extended global mask lo (16 bits)
c_m15m0         set     0               ; msg cntr 15 mask hi (13 bits)
c_m15m1         set     0               ; msg cntr 15 mask lo (16 bits)

$include(.\can\can1.asm)

can1_setup:     call    can1_init
                mov     r0,#can1+1
                mov     r3,#6
c1s_lp1:        mov     r1,#6
                call    can_get_dptr
                mov     dps,#5
                mov     a,#8
                movx    @dptr,a
                mov     dps,#0
                clr     a
                call    can_set_sfr
                inc     r0
                djnz    r3,c1s_lp1

                mov     r0,#can1+7
                mov     r3,#9
c1s_lp2:        mov     r1,#6
                call    can_get_dptr
                mov     dps,#5
                mov     a,#2
                movx    @dptr,a
                mov     dps,#0
                mov     a,#c_msrdy
                call    can_set_sfr
                inc     r0
                djnz    r3,c1s_lp2
                jmp     can1_clr_swint

can1_poll:      mov     a,c1c
                anl     a,#c_swint
                jnz     c1p_ret
                mov     r1,#9
                mov     r0,#can1+7
c1p_lp1:        push    ar0
                push    ar1
                call    can_get_msg
                jz      c1p_next
                mov     r0,#id_group
                mov     a,r3
                mov     r1,a
                mov     a,r7
                swap    a
                anl     a,#0fh
                mov     r2,a
                mov     r3,db0
                mov     r4,db1
                mov     r5,db2
                mov     r6,db3
                mov     r7,db4
                jnb     can_debug,c1p_ok
                push    ar1
                push    ar2
                call    snd_msg
                pop     ar2
                pop     ar1
                mov     lcd_ind,#16
                mov     a,r1
                call    lcd_hex
                mov     r0,#3
                mov     r1,#4
c1p_lp2:        mov     a,#' '
                call    lcd_out
                mov     a,@r0
                call    lcd_hex
                inc     r0
                djnz    r1,c1p_lp2
                sjmp    c1p_next
c1p_ok:         call    snd_msg
c1p_next:       pop     ar1
                pop     ar0
                inc     r0
                djnz    r1,c1p_lp1
c1p_ret:        ret

can1_write:     mov     a,c1c
                anl     a,#c_swint
                jz      c1w_skip1
                call    can1_setup
c1w_skip1:      mov     r0,#can1+1
                mov     r1,#6
c1w_lp:         call    can_is_msg_sent
                jnz     c1w_ok
                inc     r0
                djnz    r1,c1w_lp
c1w_ret:        ret
c1w_ok:         push    ar0
                call    get_msg
                pop     ar0
                jnc     c1w_ret
                mov     db0,r3
                mov     db1,r4
                mov     db2,r5
                mov     db3,r6
                mov     db4,r7
                mov     a,r2
                anl     a,#0fh
                swap    a
                orl     a,#8
                mov     r7,a
                mov     a,r1
                mov     r3,a
                call    cislo_v_skupine
                anl     a,#7
                rl      a
                swap    a
                mov     r4,a
                jmp     can_send_msg
