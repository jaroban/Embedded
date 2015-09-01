; version 4.x

write_brd_regs1:
                mov     ckcon,#ck_pred
                mov     dps,#4
                mov     dpx,#10h
                mov     dptr,#0
                mov     a,wr_brd_reg1
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg2
                movx    @dptr,a
                mov     dptr,#4
                mov     a,wr_brd_reg5
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg6
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                ret

write_brd_regs2:
                mov     ckcon,#ck_pred
                mov     dps,#4
                mov     dpx,#10h
                mov     dptr,#2
                mov     a,wr_brd_reg3
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg4
                movx    @dptr,a
                mov     dpx,#0
                mov     ckcon,#ck_po
                mov     a,wr_brd_reg7
                anl     a,#00111000b
                orl     a,#11000111b
                mov     p3,a
                ret
                
set_pol_clk:    anl     wr_brd_reg4,#11111110b
                jmp     write_brd_regs2

clr_pol_clk:    orl     wr_brd_reg4,#1
                jmp     write_brd_regs2

clr_lcom_data:
set_pol_data:   anl     wr_brd_reg4,#11111101b
                jmp     write_brd_regs2

set_lcom_data:
clr_pol_data:   orl     wr_brd_reg4,#2
                jmp     write_brd_regs2
                
sucik_wait:     call    rst_wd
                mov     r1,#2
                mov     r0,#0
sucik_wait_lp:  djnz    r0,sucik_wait_lp
                djnz    r1,sucik_wait_lp
                ret

sucik_write_data:
                jnb     pol_writing,swd_try_change
                jbc     pol_clk_hi,swd_get_data
                call    set_pol_clk
                setb    pol_clk_hi
                ret
swd_get_data:   call    clr_pol_clk
                mov     a,pol_index
                jb      acc.7,swd_0
                jz      swd_1
                dec     a
                mov     r0,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                xch     a,r0
                anl     a,#7
                call    get_rvs_mask
                anl     a,@r0
                jnz     swd_1
swd_0:          call    clr_pol_data
                sjmp    swd_inc
swd_1:          call    set_pol_data
swd_inc:        call    sucik_wait
                inc     pol_index
                mov     a,#36+1
                cjne    a,pol_index,swd_ret
                clr     pol_writing
swd_ret:        ret
swd_try_change: jnb     can0_change3,swd_ret
                clr     can0_change3  
                setb    pol_writing
                setb    pol_clk_hi
                mov     pol_index,#-18
                ret
                
lcom_wait_1010: call    rst_wd
                ; 1521 x djnz = 5 * 256 + 241
                mov     r1,#5+1
                mov     r0,#241-5
lcom_wait_lp:   djnz    r0,lcom_wait_lp
                djnz    r1,lcom_wait_lp
                ret

lcom_send_byte: clr     ea
                push    acc
                call    clr_lcom_data
                call    lcom_wait_1010
                mov     r1,#8
lsb_lp:         pop     acc
                rr      a
                push    acc
                push    ar1
                jb      acc.7,lsb_skip1
                call    clr_lcom_data
                sjmp    lsb_skip2
lsb_skip1:      call    set_lcom_data
lsb_skip2:      call    lcom_wait_1010
                pop     ar1
                djnz    r1,lsb_lp
                pop     acc
                jnb     p,lsb_skip3
                call    clr_lcom_data
                sjmp    lsb_skip4
lsb_skip3:      call    set_lcom_data
lsb_skip4:      call    lcom_wait_1010
                call    set_lcom_data
                call    lcom_wait_1010
                call    lcom_wait_1010                
                setb    ea
                ret

lcom_write_data:
                jnb     pol_writing,lwd_try_change
                mov     r0,#pol_table
                mov     a,pol_index
                mov     b,#3
                div     ab
                mov     r1,a
                mov     a,b
                jnz     lwd_skip1
                ; byte 1
                mov     a,r1
                mov     b,#3
                div     ab
                mov     a,b
                jnz     lwd_skip0_1
                ; message 1
                mov     a,@r0
                anl     a,#11101111b
                mov     lcom_data,a
                sjmp    lwd_send
lwd_skip0_1:    cjne    a,#1,lwd_skip0_2
                ; message 2
                mov     a,@r0
                anl     a,#11100000b
                orl     a,#1eh
                mov     lcom_data,a
                sjmp    lwd_send
lwd_skip0_2:    ; message 3
                mov     a,@r0
                anl     a,#11100000b
                orl     a,#1fh
                mov     lcom_data,a
                sjmp    lwd_send
lwd_skip1:      cjne    a,#1,lwd_skip2
                ; byte 2
                inc     r0
                mov     a,@r0
                xrl     lcom_data,a
                sjmp    lwd_send
lwd_skip2:      ; byte 3
                mov     a,lcom_data
lwd_send:       call    lcom_send_byte
                inc     pol_index
                mov     a,pol_index
                clr     c
                subb    a,#3*3*2
                jc      lwd_ret
                clr     pol_writing
lwd_ret:        ret
lwd_try_change: jnb     can0_change3,lwd_ret
                clr     can0_change3
                setb    pol_writing
                mov     pol_index,#0
                ret

lcom_write_data_banel:
                jnb     pol_writing,lwdb_try_change
                mov     r0,#pol_table
                mov     a,pol_index
                mov     b,#6
                div     ab
                mov     a,b
                jnz     lwdb_skip1
                ; byte 1
                mov     a,@r0
                anl     a,#11100000b
                orl     a,#0eh
                mov     lcom_data,a
                sjmp    lwdb_send
lwdb_skip1:     cjne    a,#1,lwdb_skip2
                ; byte 2
                inc     r0
                mov     a,@r0
                xrl     lcom_data,a
                sjmp    lwdb_send
lwdb_skip2:     cjne    a,#2,lwdb_skip3
                ; byte 3
                mov     a,lcom_data
                sjmp    lwdb_send
lwdb_skip3:     ; dummy bytes
                mov     a,#0aah
lwdb_send:      call    lcom_send_byte
                inc     pol_index
                mov     a,pol_index
                clr     c
                subb    a,#6*2
                jc      lwdb_ret
                clr     pol_writing
lwdb_ret:       ret
lwdb_try_change:
                jnb     can0_change3,lwdb_ret
                clr     can0_change3
                setb    pol_writing
                mov     pol_index,#0
                ret
