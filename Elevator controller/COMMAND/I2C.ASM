; version 3.0

i2c_delay:      nop
                nop
                nop
                nop
                nop
                nop
                nop
                ret

scl_hi:         setb    scl_pin
                jmp     i2c_delay

scl_lo:         clr     scl_pin
                jmp     i2c_delay

sda_hi:         setb    sda_pin
                jmp     i2c_delay

sda_lo:         clr     sda_pin
                jmp     i2c_delay

i2c_send_byte:  mov     r2,#8
i2c_sb_lp:      rlc     a
                mov     sda_pin,c
                call    i2c_delay
                call    scl_hi
                anl     c,/sda_pin
                call    scl_lo
                jc      i2c_sb_ret
                djnz    r2,i2c_sb_lp
                call    sda_hi
                call    scl_hi
                mov     c,sda_pin
                jmp     scl_lo
i2c_sb_ret:     ret

i2c_transmit:   call    sda_lo
                call    scl_lo
                mov     a,slv_adr
                clr     acc.0
                call    i2c_send_byte
                jc      i2c_xmt_error
                mov     r0,#i2c_xmt_buffer
                mov     r1,i2c_cnt
i2c_xmt_lp:     mov     a,@r0
                call    i2c_send_byte
                jc      i2c_xmt_error
                inc     r0
                djnz    r1,i2c_xmt_lp
i2c_xmt_error:  call    sda_lo
                call    scl_hi
                jmp     sda_hi

i2c_receive:    call    sda_lo
                call    scl_lo
                mov     a,slv_adr
                setb    acc.0
                call    i2c_send_byte
                jc      i2c_rcv_error
                mov     r0,#i2c_rcv_buffer
                mov     r1,i2c_cnt
i2c_rcv_lp1:    mov     r2,#8
                call    sda_hi
i2c_rcv_lp2:    call    scl_hi
                mov     c,sda_pin
                call    scl_lo
                rlc     a
                djnz    r2,i2c_rcv_lp2
                mov     @r0,a
                inc     r0
                mov     a,r1
                clr     c
                subb    a,#2
                mov     sda_pin,c
                call    i2c_delay
                call    scl_hi
                anl     c,/sda_pin
                call    scl_lo
                djnz    r1,i2c_rcv_lp1
i2c_rcv_error:  call    sda_lo
                call    scl_hi
                jmp     sda_hi

i2c_init:       mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#0ach
                inc     r0
                mov     @r0,#0c1h
i2c_i_lp:       call    do_them
                mov     i2c_cnt,#2
                call    i2c_transmit
                jc      i2c_i_lp
                mov     r0,#10
i2c_init_50ms:  push    ar0
                call    do_them
                pop     ar0
                djnz    r0,i2c_init_50ms
                ret

i2c_get_time:   mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#0c0h
                inc     r0
                mov     @r0,a
i2c_gt_lp:      call    do_them
                mov     i2c_cnt,#2
                call    i2c_transmit
                jc      i2c_gt_lp
                mov     i2c_cnt,#1
                call    i2c_receive
                jc      i2c_gt_lp
                mov     r0,#i2c_rcv_buffer
                mov     a,@r0
                ret

i2c_put_time:   mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#0c0h
                inc     r0
                mov     @r0,a
                inc     r0
                mov     @r0,b
i2c_pt_lp:      call    do_them
                mov     i2c_cnt,#3
                call    i2c_transmit
                jc      i2c_pt_lp
                ret

i2c_get_tmpr:   mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#0aah
i2c_gt_lp1:     call    do_them
                mov     i2c_cnt,#1
                call    i2c_transmit
                jc      i2c_gt_lp1
                mov     i2c_cnt,#1
                call    i2c_receive
                jc      i2c_gt_lp1
                mov     r0,#i2c_rcv_buffer
                mov     a,@r0
                push    acc
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#0eeh
i2c_gt_lp2:     call    do_them
                mov     i2c_cnt,#1
                call    i2c_transmit
                jc      i2c_gt_lp2
                pop     acc
                ret

i2c_get_byte:   mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#17h
                inc     r0
                mov     @r0,a
i2c_gb_lp:      call    do_them
                mov     i2c_cnt,#2
                call    i2c_transmit
                jc      i2c_gb_lp
                mov     i2c_cnt,#1
                call    i2c_receive
                jc      i2c_gb_lp
                mov     r0,#i2c_rcv_buffer
                mov     a,@r0
                ret

i2c_put_byte:   mov     slv_adr,#9eh
                mov     r0,#i2c_xmt_buffer
                mov     @r0,#17h
                inc     r0
                mov     @r0,a
                inc     r0
                mov     @r0,b
i2c_pb_lp:      call    do_them
                mov     i2c_cnt,#3
                call    i2c_transmit
                jc      i2c_pb_lp
                ret
