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

$include(.\can\can0.asm)

can0_setup:     call    can0_init
                call    can_config_msg
                db      can0+1,05h,0a0h,0,1,60h
                db      can0+2,15h,0a0h,0,1,48h
                db      can0+3,25h,0a0h,0,1,38h
                db      can0+4,0,0,0,0,2
                db      can0+5,35h,0a0h,0,1,68h
                db      0
                jmp     can0_clr_swint

can0_poll:      mov     a,c0c
                anl     a,#c_swint
                jnz     c0p_ret
                mov     r0,#can0+1
                call    can_get_msg_wtoe
                jz      c0p_skip1
                mov     r0,#rd_kabina
                mov     @r0,db0
                inc     r0
                mov     @r0,db1
                inc     r0
                mov     @r0,db2
                inc     r0
                mov     @r0,db3
                mov     rd_can_reg5,db4
                mov     rd_can_reg6,db5
                setb    poll_calls
c0p_skip1:      jnb     can_debug,c0p_ret
                mov     r0,#can0+4
                call    can_get_msg
                jz      c0p_ret
                mov     lcd_ind,#0
                mov     a,r3
                call    lcd_hex
                mov     r0,#8
                mov     r1,#4
c0p_lp:         mov     a,#' '
                call    lcd_out
                mov     a,@r0
                call    lcd_hex
                inc     r0
                djnz    r1,c0p_lp
c0p_ret:        ret

can0_write:     mov     a,c0c
                anl     a,#c_swint
                jz      c0w_ok1
                call    can0_setup
                ;mov     r0,#can0+1
                ;call    can_send_rfr
                setb    can0_change1
                setb    can0_change2
c0w_ok1:        jnb     can0_change1,c0w_ok2
                clr     can0_change1
                mov     r0,#wr_kabina
                mov     db0,@r0
                inc     r0
                mov     db1,@r0
                inc     r0
                mov     db2,@r0
                inc     r0
                mov     db3,@r0
                mov     r0,#can0+2
                call    can_send_data
c0w_ok2:        jnb     can0_change2,c0w_ok3
                clr     can0_change2
                mov     db0,wr_can_reg5
                mov     db1,wr_can_reg6
                mov     db2,wr_can_reg7
                mov     r0,#can0+3
                call    can_send_data
c0w_ok3:        jnb     can0_change3,c0w_ret
                clr     can0_change3
                
                call    aky_seriovy_kod_rdk
                jz      c0w_ret
                mov     db5,a
                cjne    a,#1,c0w_try_2
                mov     r0,#pol_table
                sjmp    c0w_drain
c0w_try_2:      cjne    a,#2,c0w_try_3
                mov     r0,#lcom_output
                sjmp    c0w_drain
c0w_try_3:      cjne    a,#3,c0w_ret
                mov     r0,#banel_output
                
c0w_drain:      mov     db0,@r0
                inc     r0
                mov     db1,@r0
                inc     r0
                mov     db2,@r0
                inc     r0
                mov     db3,@r0
                inc     r0
                mov     db4,@r0

                mov     r0,#can0+5
                call    can_send_data
c0w_ret:        ret
