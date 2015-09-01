; version 1.0

pnf_nxt:        push    dpl
                push    dph
                call    put_byte
                inc     addr_lo
                pop     dph
                pop     dpl
                inc     dptr
puts_n_fram:    clr     a
                movc    a,@a+dptr
                jnz     pnf_nxt
                ret

puts_na_fram:   jz      puts_n_fram
                mov     b,a
pnaf_lp:        clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     pnaf_lp
                djnz    b,pnaf_lp
                jmp     puts_n_fram

; r0=address  r1=count
write_data_fram:
                push    ar0
                push    ar1
                mov     a,@r0
                mov     b,#10
                div     ab
                push    acc
                mov     a,b
                call    hex_asc
                call    put_byte
                dec     addr_lo
                pop     acc
                call    hex_asc
                call    put_byte
                dec     addr_lo
                call    rst_wd
                pop     ar1
                pop     ar0
                dec     r0
                djnz    r1,write_data_fram
                ret

; r0=address  r1=count
write_data_fram2:
                push    ar0
                push    ar1
                mov     a,@r0
                mov     b,a
                swap    a
                anl     a,#0fh
                push    acc
                mov     a,b
                anl     a,#0fh
                call    hex_asc
                call    put_byte
                dec     addr_lo
                pop     acc
                call    hex_asc
                call    put_byte
                dec     addr_lo
                call    rst_wd
                pop     ar1
                pop     ar0
                dec     r0
                djnz    r1,write_data_fram2
                ret

follower:       setb    wc
                setb    scl_pin
                setb    sda_pin

                clr     a
                mov     total1,a
                mov     total1+1,a
                mov     total1+2,a
                mov     total1+3,a
                mov     total1+4,a
                mov     total2,a
                mov     total2+1,a
                mov     total2+2,a
                mov     total2+3,a
                mov     total2+4,a
                mov     delta,#delta_default
                mov     time1,#2
                mov     time1+1,a
                mov     time2,#10
                mov     time2+1,a
                mov     time3,#5
                mov     time3+1,a
                mov     pass,a
                mov     pass+1,a
                mov     pass+2,a
                mov     pass+3,a
                mov     a_total1,a
                mov     a_total2,a
                mov     a_delta,a
                mov     a_time1,a
                mov     a_time2,a
                mov     a_time3,a
                mov     a_pass,a
                mov     a_max,a
                clr     w_total1
                clr     w_total2
                clr     w_delta
                clr     w_time1
                clr     w_time2
                clr     w_time3
                clr     w_pass
                mov     addr_lo,a
                mov     addr_hi,a
                call    si_init

fol_read_lp:    call    rst_wd
                call    get_byte
                call    si_process
                inc     addr_lo
                mov     a,addr_lo
                jnz     fol_read_lp

                call    rst_wd
                inc     a_max
                mov     a,a_total1
                jnz     fol_try_0
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                clr     a
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_total1,a
                setb    w_total1
fol_try_0:      call    do_them
                mov     a,a_total2
                jnz     fol_try_1
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#1
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_total2,a
                setb    w_total2
fol_try_1:      call    do_them
                mov     a,a_delta
                jnz     fol_try_2
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#2
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_delta,a
                setb    w_delta
fol_try_2:      call    do_them
                mov     a,a_time1
                jnz     fol_try_3
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#3
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_time1,a
                setb    w_time1
fol_try_3:      call    do_them
                mov     a,a_time2
                jnz     fol_try_4
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#4
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_time2,a
                setb    w_time2
fol_try_4:      call    do_them
                mov     a,a_time3
                jnz     fol_try_5
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#5
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_time3,a
                setb    w_time3
fol_try_5:      call    do_them
                mov     a,a_pass
                jnz     fol_all_ok
                mov     addr_lo,a_max
                mov     a,#' '
                call    put_byte
                inc     addr_lo
                mov     dptr,#si_format
                mov     a,#6
                call    puts_na_fram
                mov     a,addr_lo
                mov     a_max,a
                dec     a
                mov     a_pass,a
                setb    w_pass
fol_all_ok:

fol_main_lp:    call    do_them
                jnb     w_total1,fml_skip0
                clr     w_total1
                mov     addr_hi,#0
                mov     addr_lo,a_total1
                mov     r0,#total1+4
                mov     r1,#5
                call    write_data_fram
fml_skip0:      jnb     w_total2,fml_skip1
                clr     w_total2
                mov     addr_hi,#0
                mov     addr_lo,a_total2
                mov     r0,#total2+4
                mov     r1,#5
                call    write_data_fram
fml_skip1:      jnb     w_delta,fml_skip2
                clr     w_delta
                mov     addr_hi,#0
                mov     addr_lo,a_delta
                mov     r0,#delta
                mov     r1,#1
                call    write_data_fram
fml_skip2:      jnb     w_time1,fml_skip3
                clr     w_time1
                mov     addr_hi,#0
                mov     addr_lo,a_time1
                mov     r0,#time1+1
                mov     r1,#2
                call    write_data_fram
fml_skip3:      jnb     w_time2,fml_skip4
                clr     w_time2
                mov     addr_hi,#0
                mov     addr_lo,a_time2
                mov     r0,#time2+1
                mov     r1,#2
                call    write_data_fram
fml_skip4:      jnb     w_time3,fml_skip5
                clr     w_time3
                mov     addr_hi,#0
                mov     addr_lo,a_time3
                mov     r0,#time3+1
                mov     r1,#2
                call    write_data_fram
fml_skip5:      jnb     w_pass,fml_skip6
                clr     w_pass
                mov     addr_hi,#0
                mov     addr_lo,a_pass
                mov     r0,#pass+1
                mov     r1,#2
                call    write_data_fram2
fml_skip6:      jmp     fol_main_lp
