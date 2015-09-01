; version 4.x

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
                db      can0+1,05h,0a0h,0,1,68h
                db      can0+2,15h,0a0h,0,1,40h
                db      can0+3,25h,0a0h,0,1,30h
                db      can0+5,35h,0a0h,0,1,60h
                db      0
                jmp     can0_clr_swint

can0_poll:      mov     a,c0c
                anl     a,#c_swint
                jnz     c0p_ret
                mov     r0,#can0+2
                call    can_get_msg_wtoe
                jz      c0p_ok1
                mov     wr_brd_reg1,db0
                mov     wr_brd_reg2,db1
                mov     wr_brd_reg5,db2
                mov     wr_brd_reg6,db3
                setb    can0_change2
c0p_ok1:        mov     r0,#can0+3
                call    can_get_msg_wtoe
                jz      c0p_ok2
                mov     wr_brd_reg3,db0
                
                mov     a,wr_brd_reg4
                anl     a,#3
                mov     r0,a
                mov     a,db1
                anl     a,#11111100b
                orl     a,r0
                mov     wr_brd_reg4,a

                mov     wr_brd_reg7,db2
                setb    can0_change2
c0p_ok2:        mov     r0,#can0+5
                call    can_get_msg_wtoe
                jz      c0p_ret
                mov     r0,#pol_table
                mov     @r0,db0
                inc     r0
                mov     @r0,db1
                inc     r0
                mov     @r0,db2
                inc     r0
                mov     @r0,db3
                inc     r0
                mov     @r0,db4
                mov     polohovka,db5
                setb    can0_change3
c0p_ret:        ret

can0_send:      mov     a,c0c
                anl     a,#c_swint
                jz      c0s_ok1
                call    can0_setup
                mov     r0,#can0+2
                call    can_send_rfr
                mov     r0,#can0+3
                call    can_send_rfr
                setb    can0_change1
c0s_ok1:        jnb     can0_change1,c0s_ret
                clr     can0_change1
                mov     db0,rd_brd_reg1
                mov     db1,rd_brd_reg2
                mov     db2,rd_brd_reg3
                mov     db3,rd_brd_reg4
                mov     db4,rd_brd_reg5
                mov     db5,rd_brd_reg6
                mov     r0,#can0+1
                jmp     can_send_data
c0s_ret:        ret
