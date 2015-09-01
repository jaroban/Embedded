; version 4.1

init_volby2:    mov     r0,#wr_kabina
                mov     r1,#4
                call    clear_ram
                mov     r0,#wr_dole
                mov     r1,#4
                call    clear_ram
                mov     r0,#wr_hore
                mov     r1,#4
                jmp     clear_ram

out_kabina:     call    param_kabina
                jz      ok_ret
                cjne    a,#1,ok_try_2
ok_normal:      mov     a,call_no
                call    get_lo_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg1
                mov     r2,a
                mov     r0,#wr_kabina
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg1,a

                mov     a,call_no
                call    get_hi_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg2
                mov     r2,a
                mov     r0,#wr_kabina+1
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg2,a
                setb    brd_change1
                ret
ok_try_2:       cjne    a,#2,ok_try_3
                jmp     ok_normal
ok_try_3:       cjne    a,#3,ok_ret
                setb    can0_change1
ok_ret:         ret

out_dole:       call    param_dole
                jz      od_ret
                cjne    a,#1,od_try_2
                mov     a,call_no
                call    get_lo_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg3
                mov     r2,a
                mov     r0,#wr_dole
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg3,a

                mov     a,call_no
                call    get_dole_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg2
                mov     r2,a
                mov     r0,#wr_dole+1
                mov     a,@r0
                swap    a
                rr      a
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg2,a
                setb    brd_change1
od_ret:         ret

od_try_2:       cjne    a,#2,od_try_3
                mov     a,call_no
                call    get_lo_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg3
                mov     r2,a
                mov     r0,#wr_dole
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg3,a

                mov     a,call_no
                call    get_hi_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg4
                mov     r2,a
                mov     r0,#wr_dole+1
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg4,a
                setb    brd_change1
                ret

od_try_3:       cjne    a,#3,od_ret
                mov     a,call_no
                call    get_a_mask_32
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg1
                mov     r2,a
                mov     r0,#wr_dole
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg1,a

                mov     a,call_no
                call    get_b_mask_32
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg2
                mov     r2,a
                mov     r0,#wr_dole+1
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg2,a

                mov     a,call_no
                call    get_c_mask_32
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg3
                mov     r2,a
                mov     r0,#wr_dole+2
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg3,a

                mov     a,call_no
                call    get_d_mask_32
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg4
                mov     r2,a
                mov     r0,#wr_dole+3
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg4,a
                setb    brd_change1
                ret

out_hore:       call    param_hore
                jz      oh_ret
                cjne    a,#1,oh_try_2
                mov     a,call_no
                call    get_lo_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg4
                mov     r2,a
                mov     r0,#wr_hore
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg4,a

                mov     a,call_no
                call    get_hore_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg2
                mov     r2,a
                mov     r0,#wr_hore+1
                mov     a,@r0
                rr      a
                rr      a
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg2,a
                setb    brd_change1
                ret

oh_try_2:       cjne    a,#2,oh_ret
                mov     a,call_no
                call    get_lo_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg1
                mov     r2,a
                mov     r0,#wr_hore
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg1,a

                mov     a,call_no
                call    get_hi_mask_16
                mov     r1,a
                cpl     a
                anl     a,wr_brd_reg2
                mov     r2,a
                mov     r0,#wr_hore+1
                mov     a,@r0
                anl     a,r1
                orl     a,r2
                mov     wr_brd_reg2,a
                setb    brd_change1
oh_ret:         ret

add_kabina:     mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_kabina
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                orl     a,@r0
                mov     @r0,a
                ret

del_kabina:     mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_kabina
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_cpl_mask
                anl     a,@r0
                mov     @r0,a
                ret

add_dole:       mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_dole
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                orl     a,@r0
                mov     @r0,a
                ret

del_dole:       mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_dole
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_cpl_mask
                anl     a,@r0
                mov     @r0,a
                ret

add_hore:       mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_hore
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_mask
                orl     a,@r0
                mov     @r0,a
                ret

del_hore:       mov     a,r2
                swap    a
                rl      a
                anl     a,#3
                add     a,#wr_hore
                mov     r0,a
                mov     a,r2
                anl     a,#7
                call    get_nrm_cpl_mask
                anl     a,@r0
                mov     @r0,a
                ret

show_calls:     mov     dps,#0
                mov     dpx,#0
                mov     dptr,#call_table_old
                mov     r1,#call_table
                mov     r2,#0
                mov     r3,#0
                mov     r7,call_no
scs_lp1:        movx    a,@dptr
                anl     a,#70h
                mov     r6,a
                mov     a,@r1
                anl     a,#70h
                mov     r5,a
                movx    @dptr,a
                cpl     a
                anl     a,r6
                mov     r4,a
                mov     a,r6
                cpl     a
                anl     a,r5
                jz      scs_on_ret
                orl     ar3,a
                mov     b,a
                jnb     b.4,scs_on_dn
                call    add_kabina
scs_on_dn:      jnb     b.5,scs_on_up
                call    add_dole
scs_on_up:      jnb     b.6,scs_on_ret
                call    add_hore
scs_on_ret:     mov     a,r4
                jz      scs_off_ret
                orl     ar3,a
                mov     b,a
                jnb     b.4,scs_off_dn
                call    del_kabina
scs_off_dn:     jnb     b.5,scs_off_up
                call    del_dole
scs_off_up:     jnb     b.6,scs_off_ret
                call    del_hore
scs_off_ret:    inc     r1
                inc     r2
                inc     dptr
                djnz    r7,scs_lp1

                mov     b,r3
                jnb     b.4,scs_ch_dn
                call    out_kabina
scs_ch_dn:      jnb     b.5,scs_ch_up
                call    out_dole
scs_ch_up:      jnb     b.6,scs_ch_ret
                jmp     out_hore
scs_ch_ret:     ret
