; version 1.0

wait_10ms:      mov     r0,#4  ; 15
                mov     r1,#0
delay_lp:       call    rst_wd
                djnz    r1,delay_lp
                djnz    r0,delay_lp
                ret

i2c_delay:      push    ar0
                mov     r0,#10
                djnz    r0,$
                pop     ar0
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
i2c_sb_lp:      call    rst_wd
                rlc     a
                mov     sda_pin,c
                call    i2c_delay
                call    scl_hi
                call    scl_lo
                djnz    r2,i2c_sb_lp
                call    sda_hi
                call    scl_hi
                mov     c,sda_pin
                jmp     scl_lo

i2c_rcv_byte:   call    rst_wd
                mov     r2,#8
                call    sda_hi
i2c_rb_lp:      call    rst_wd
                call    scl_hi
                mov     c,sda_pin
                call    scl_lo
                rlc     a
                djnz    r2,i2c_rb_lp
                ret

poll_for_ack:   call    rst_wd
                call    sda_lo
                call    scl_lo
                mov     a,#0a1h
                call    i2c_send_byte
                call    sda_lo
                call    scl_hi
                call    sda_hi
                jc      poll_for_ack
                ret

i2c_transmit:   call    sda_lo
                call    scl_lo
                mov     a,slv_adr
                clr     acc.0
                call    i2c_send_byte
                jc      i2c_xmt_stop
                mov     r0,#i2c_buffer
                mov     r1,i2c_cnt
i2c_xmt_lp:     call    rst_wd
                mov     a,@r0
                call    i2c_send_byte
                jc      i2c_xmt_stop
                inc     r0
                djnz    r1,i2c_xmt_lp
                clr     c
i2c_xmt_stop:   mov     i2c_error,c
                call    sda_lo
                call    scl_hi
                call    sda_hi
                jb      i2c_error,i2c_transmit
                ret

i2c_receive:    call    sda_lo
                call    scl_lo
                mov     a,slv_adr
                setb    acc.0
                call    i2c_send_byte
                jc      i2c_rcv_stop
                mov     r0,#i2c_buffer
                mov     r1,i2c_cnt
i2c_rcv_lp:     call    rst_wd
                call    i2c_rcv_byte
                mov     @r0,a
                inc     r0
                mov     a,r1
                clr     c
                subb    a,#2
                mov     sda_pin,c
                call    i2c_delay
                call    scl_hi
                call    scl_lo
                djnz    r1,i2c_rcv_lp
                clr     c
i2c_rcv_stop:   mov     i2c_error,c
                call    sda_lo
                call    scl_hi
                call    sda_hi
                jb      i2c_error,i2c_receive
                ret

i2c_init:       mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#0ach
                inc     r0
                mov     @r0,#0c1h
                mov     i2c_cnt,#2
                call    i2c_transmit
                mov     r0,#15  ; 75
                mov     r1,#0
i2c_init_50ms:  call    rst_wd
                djnz    r1,i2c_init_50ms
                djnz    r0,i2c_init_50ms
                ret

i2c_get_time:   mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#0c0h
                inc     r0
                mov     @r0,addr_lo
                mov     i2c_cnt,#2
                call    i2c_transmit
                mov     i2c_cnt,#1
                call    i2c_receive
                mov     r0,#i2c_buffer
                mov     a,@r0
                ret

i2c_put_time:   mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#0c0h
                inc     r0
                mov     @r0,addr_lo
                inc     r0
                mov     @r0,a
                mov     i2c_cnt,#3
                jmp     i2c_transmit

i2c_get_tmpr:   mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#0aah
                mov     i2c_cnt,#1
                call    i2c_transmit
                mov     i2c_cnt,#1
                call    i2c_receive
                mov     r0,#i2c_buffer
                mov     a,@r0
                push    acc
                mov     @r0,#0eeh
                mov     i2c_cnt,#1
                call    i2c_transmit
                pop     acc
                ret

; 0-31
i2c_get_sram:   mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#17h
                inc     r0
                mov     @r0,addr_lo
                mov     i2c_cnt,#2
                call    i2c_transmit
                mov     i2c_cnt,#1
                call    i2c_receive
                mov     r0,#i2c_buffer
                mov     a,@r0
                ret

i2c_put_sram:   mov     slv_adr,#9eh
                mov     r0,#i2c_buffer
                mov     @r0,#17h
                inc     r0
                mov     @r0,addr_lo
                inc     r0
                mov     @r0,a
                mov     i2c_cnt,#3
                jmp     i2c_transmit

i2c_get_ram:    mov     a,addr_hi
                rl      a
                anl     a,#0eh
                orl     a,#0a0h
                mov     slv_adr,a
                setb    wc
                mov     r0,#i2c_buffer
                mov     @r0,addr_lo
                mov     i2c_cnt,#1
                call    i2c_transmit
                mov     i2c_cnt,#1
                call    i2c_receive
                mov     r0,#i2c_buffer
                mov     a,@r0
                ret

; returns in acc byte at address addr_hi & addr_lo
get_byte:       push    ar0
                push    ar1
                push    ar2
gb_lp:          call    rst_wd
                call    i2c_get_ram
                push    acc
                call    i2c_get_ram
                pop     b
                cjne    a,b,gb_lp
                pop     ar2
                pop     ar1
                pop     ar0
                ret

i2c_put_ram:    mov     a,addr_hi
                rl      a
                anl     a,#0eh
                orl     a,#0a0h
                mov     slv_adr,a
                mov     r0,#i2c_buffer
                mov     @r0,addr_lo
                inc     r0
                mov     @r0,b
                mov     i2c_cnt,#2
                jmp     i2c_transmit

; writes the byte in acc to address addr_hi & addr_lo
put_byte:       push    ar0
                push    ar1
                push    ar2
                mov     b,a
                clr     wc
pb_lp:          push    b
                call    rst_wd
                call    i2c_put_ram
                call    wait_10ms
                call    poll_for_ack
                call    get_byte
                pop     b
                cjne    a,b,pb_lp
                setb    wc
                pop     ar2
                pop     ar1
                pop     ar0
                ret
