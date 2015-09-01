; version 4.1

mux_init:       clr     mux_new_k
                clr     mux_new_d1
                clr     mux_new_d2
                clr     mux_new_h
                call    je_multiplex
                jz      mi_ret
                dec     a
                mov     r0,a
                call    get_nrm_mask
                mov     mux_mask1,a
                mov     a,r0
                call    get_nrm_cpl_mask2
                mov     mux_mask3,a

                mov     mux_timer,#3
                mov     mux_state,#6
                call    param_dole
                cjne    a,#5,mi_ret
                mov     mux_state,#12
                mov     a,#16
                clr     c
                subb    a,call_no
                mov     mux_all_32,c
mi_ret:         ret

mux_clock_0:    mov     mux_timer,#3

                mov     a,mux_mask3
                anl     wr_trans_reg,a
                ret

mux_clock_1:    inc     mux_state
                mov     mux_timer,#12

                mov     a,mux_mask3
                anl     wr_trans_reg,a
                mov     a,mux_mask1
                orl     wr_trans_reg,a
                ret

mux_clock_2:    inc     mux_state
                mov     mux_timer,#12

                mov     a,mux_mask3
                anl     wr_trans_reg,a
                mov     a,mux_mask1
                rl      a
                orl     wr_trans_reg,a
                ret

mux_wr_kabina:  mov     dpx,#10h
                mov     dptr,#0
                mov     r0,#wr_kabina
                mov     a,@r0
                orl     a,wr_brd_reg1
                xrl     a,blink_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg2
                xrl     a,blink_reg2
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg3
                xrl     a,blink_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg4
                xrl     a,blink_reg4
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                ret

mux_wr_dole1:   mov     dpx,#10h
                mov     dptr,#0
                mov     r0,#wr_dole
                mov     a,@r0
                orl     a,wr_brd_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg2
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg4
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                ret

mux_wr_dole2:   mov     dpx,#10h
                mov     dptr,#2
                mov     r0,#wr_dole
                mov     a,@r0
                orl     a,wr_brd_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg4
                cpl     a
                movx    @dptr,a
                jnb     mux_all_32,mwrd2_ret
                mov     dptr,#0
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg2
                cpl     a
                movx    @dptr,a
mwrd2_ret:      mov     dpx,#0
                ret

mux_wr_hore:    mov     dpx,#10h
                mov     dptr,#2
                mov     r0,#wr_hore
                mov     a,@r0
                orl     a,wr_brd_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg4
                cpl     a
                movx    @dptr,a
                jnb     mux_all_32,mwrh_ret
                mov     dptr,#0
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                inc     r0
                mov     a,@r0
                orl     a,wr_brd_reg2
                cpl     a
                movx    @dptr,a
mwrh_ret:       mov     dpx,#0
                ret

mux_wr_zero:    mov     dpx,#10h
                mov     dptr,#0
                mov     a,wr_brd_reg1
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg2
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg3
                cpl     a
                movx    @dptr,a
                inc     dptr
                mov     a,wr_brd_reg4
                cpl     a
                movx    @dptr,a
                mov     dpx,#0
                ret

shift_majority5:
                mov     r0,a
                mov     dps,#5
                mov     r1,#5
sh_maj5_lp:     movx    a,@dptr
                xch     a,r0
                movx    @dptr,a
                inc     dptr
                djnz    r1,sh_maj5_lp
                mov     dps,#0
                ret

mux_rd_kabina:  push    dpl1
                push    dph1
                push    dpx1
                mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_kabina
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg1
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg2
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg3
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                xrl     a,blink_reg4
                call    shift_majority5
                mov     dpx,#0
                pop     dpx1
                pop     dph1
                pop     dpl1
                ret

mux_rd_dole1:   push    dpl1
                push    dph1
                push    dpx1
                mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_dole
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                mov     dpx,#0
                pop     dpx1
                pop     dph1
                pop     dpl1
                ret

mux_rd_dole2:   push    dpl1
                push    dph1
                push    dpx1
                mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_dole
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#2
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                jnb     mux_all_32,mrdd2_ret
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
mrdd2_ret:      mov     dpx,#0
                pop     dpx1
                pop     dph1
                pop     dpl1
                ret

mux_rd_hore:    push    dpl1
                push    dph1
                push    dpx1
                mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_hore
                mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#2
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                jnb     mux_all_32,mrdh_ret
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                call    shift_majority5
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    shift_majority5
mrdh_ret:       mov     dpx,#0
                pop     dpx1
                pop     dph1
                pop     dpl1
                ret

t1_mux_table:   sjmp    t1_mux_1
                sjmp    t1_mux_2
                sjmp    t1_mux_3
                sjmp    t1_mux_4
                sjmp    t1_mux_5
                sjmp    t1_mux_6
                sjmp    t1_mux_7
                sjmp    t1_mux_8
                sjmp    t1_mux_9
                sjmp    t1_mux_10
                sjmp    t1_mux_11
                sjmp    t1_mux_12

t1_mux_1:       call    mux_clock_1
                jmp     t1_ret
t1_mux_2:       inc     mux_state
                call    mux_rd_kabina
                setb    mux_new_k
                call    mux_clock_0
                jmp     t1_ret
t1_mux_3:       inc     mux_state
                mov     mux_timer,#3
                call    mux_wr_dole1
                jmp     t1_ret
t1_mux_4:       call    mux_clock_2
                jmp     t1_ret
t1_mux_5:       inc     mux_state
                call    mux_rd_dole1
                setb    mux_new_d1
                call    mux_clock_0
                jmp     t1_ret
t1_mux_6:       mov     mux_state,#1
                mov     mux_timer,#3
                call    mux_wr_kabina
                jmp     t1_ret

t1_mux_7:       call    mux_clock_1
                jmp     t1_ret
t1_mux_8:       inc     mux_state
                call    mux_rd_dole2
                setb    mux_new_d2
                call    mux_clock_0
                jmp     t1_ret
t1_mux_9:       inc     mux_state
                mov     mux_timer,#3
                call    mux_wr_hore
                jmp     t1_ret
t1_mux_10:      call    mux_clock_2
                jmp     t1_ret
t1_mux_11:      inc     mux_state
                call    mux_rd_hore
                setb    mux_new_h
                call    mux_clock_0
                jmp     t1_ret
t1_mux_12:      mov     mux_state,#7
                mov     mux_timer,#3
                call    mux_wr_dole2
                jmp     t1_ret
