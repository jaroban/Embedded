; version 4.x

t_read          equ     0

initial_thread: dw      input_setup
                db      id_input,0,30

do_majority5:   mov     r3,a
                mov     dps,#5
                mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
                mov     r2,#5
do_maj5_lp1:    movx    a,@dptr
                xch     a,r3
                movx    @dptr,a
                mov     @r0,a
                mov     @r1,a
                inc     dptr
                inc     r0
                inc     r1
                djnz    r2,do_maj5_lp1
                mov     dps,#4
                mov     b,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
do_maj5_lp2:    mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     b,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp2
                mov     a,b
                ret

refresh_inputs: mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#mjrt_table
                mov     dps,#4
                mov     dpx,#10h
                mov     dptr,#0
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg1,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg2,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg3,a
                inc     dptr
                movx    a,@dptr
                cpl     a
                call    do_majority5
                mov     rd_brd_reg4,a
                mov     dpx,#0
                mov     a,p1
                cpl     a
                call    do_majority5
                mov     rd_brd_reg5,a
                mov     a,p3
                cpl     a
                anl     a,#4
                call    do_majority5
                mov     rd_brd_reg6,a
                ret

detect_change:  mov     b,#0
                mov     r1,#6
                mov     r0,#rd_brd_reg1
dch_lp:         mov     a,@r0
                inc     r0
                xch     a,@r0
                xrl     a,@r0
                orl     b,a
                inc     r0
                djnz    r1,dch_lp
                mov     a,b
                jz      dch_ret
                setb    can0_change1
dch_ret:        ret

input_setup:    clr     a
                mov     r1,#12
                mov     r0,#rd_brd_reg1
inpt_stp_lp1:   mov     @r0,a
                inc     r0
                djnz    r1,inpt_stp_lp1

                mov     p1,#0ffh
                orl     p3,#4

                mov     dps,#4
                mov     dpx,#0
                mov     dptr,#th_output
                call    run_it

                call    wait4it_f
                db      0,0,2,0

input_main_lp:  call    do_them
                mov     a,#t_read
                call    tmr_zro
                jnc     input_skip1
                call    tmr_int_f
                db      t_read,0,0,3
                call    refresh_inputs
                call    detect_change
input_skip1:    call    can0_send
                jmp     input_main_lp
