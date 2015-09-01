; version 4.1

lf              equ     10              ; line feed
cr              equ     13              ; carriage return
esc             equ     27              ; escape

srl_rcv_size    equ     200
srl_xmt_size    equ     200

th_serial:      dw      serial_com, st_serial
                db      id_serial, os_bank1, st_serial_size

srl_in_no       equ     18
srl_history_no  equ     8
srl_in_format:  db      'reset',0
                db      'msg0####',0
                db      'msg1######',0
                db      'msg2########',0
                db      'debug on',0
                db      'debug off',0
                db      'cmp########',0
                db      'del####',0
                db      'zak####',0
                db      'loc####',0
                db      'boss',0
                db      'download',0
                db      'parameters',0
                db      'ok?',cr,lf,0
                db      'sig##',0
                db      'stat',cr,lf,0
                db      'next',0
                db      'again',0

srl_in_table:   ljmp    starting_point
                ljmp    srl_get_msg0
                ljmp    srl_get_msg1
                ljmp    srl_get_msg2
                ljmp    srl_dbg_on
                ljmp    srl_dbg_off
                ljmp    srl_get_cmp
                ljmp    srl_get_del
                ljmp    srl_get_zak
                ljmp    srl_get_loc
                ljmp    srl_get_boss
                ljmp    do_download
                ljmp    do_parameters
                ljmp    srl_gsm_ok
                ljmp    srl_gsm_sig
                ljmp    srl_gsm_stat
                ljmp    srl_gsm_next
                ljmp    srl_gsm_again

; 0 single ram byte
; 1 variable length ram table
; 2 fixed length ram table
; 3 variable length movx table
; 4 fixed length movx table

dbg_max_txt     equ     20
dbg_max_mul     equ     7
debug_table:    db      'floors'
                db          0,0,floor_no
                db      'lpos'
                db          0,0,my_liftpos
                db      'lsub'
                db          0,0,liftsub
                db      'rele1'
                db          0,0,wr_rele_reg1
                db      'rele2'
                db          0,0,wr_rele_reg2
                db      'smer'
                db          0,0,smer
                db      'calls'
                db          0,1,1,floor_no,call_table
                db      'lcds'
                db          0,4,34
                dw          lcd_table
                db      'thread table'
                db          0,3,7,thread_no
                dw          thread_table
                db      'cs table'
                db          0,3,3,floor_no
                dw          g_cs_table
                db      'cs timeout'
                db          0,3,3,floor_no
                dw          g_cs_timeout
                db      'errors'
                db          0,3,1,error_no
                dw          error_table
                db      0

dbg_synch_txt:  db      ' <>< ',0

                bseg
srl_ready:      dbit    1

dbg_state       data    8
dbg_dpl         data    9
dbg_dph         data    10
dbg_mul         data    11
dbg_size        data    12
dbg_base_lo     data    13
dbg_base_hi     data    14
dbg_ind         data    15

dwn_state       data    9
dwn_save        data    10
dwn_cnt         data    11
dwn_sum         data    12

                dseg
srl_rcv_wr:     ds      1
srl_rcv_rd:     ds      1
srl_xmt_wr:     ds      1
srl_xmt_rd:     ds      1

                xseg
srl_rcv_buffer: ds      srl_rcv_size
srl_xmt_buffer: ds      srl_xmt_size
srl_in_index:   ds      srl_in_no
srl_in_history: ds      srl_history_no

                cseg
serial_init:    mov     a,#srl_rcv_size
                mov     srl_rcv_wr,a
                mov     srl_rcv_rd,a
                mov     a,#srl_xmt_size
                mov     srl_xmt_wr,a
                mov     srl_xmt_rd,a
                setb    srl_ready
                mov     scon,#50h
                mov     a,#low(-srl_period)
                mov     tl2,a
                mov     rcap2l,a
                mov     a,#high(-srl_period)
                mov     th2,a
                mov     rcap2h,a
                mov     t2mod,#0
                mov     t2con,#00110100b
                setb    es
                clr     serial_debug
                ret

serial_int:     clr     ea
                push    psw
                push    acc
                push    dpl
                push    dph
                push    dpx
                push    dps
                mov     dps,#0
                mov     dpx,#0
                jnb     ri,srl_rcv_end
                clr     ri
                mov     a,srl_rcv_wr
                djnz    acc,srl_rcv_skip1
                mov     a,#srl_rcv_size
srl_rcv_skip1:  cjne    a,srl_rcv_rd,srl_rcv_skip2
                sjmp    srl_rcv_end
srl_rcv_skip2:  xch     a,srl_rcv_wr
                add     a,#low(srl_rcv_buffer-1)
                mov     dpl,a
                clr     a
                addc    a,#high(srl_rcv_buffer-1)
                mov     dph,a
                mov     a,sbuf
                movx    @dptr,a
srl_rcv_end:    jnb     ti,srl_xmt_end
                clr     ti
                mov     a,srl_xmt_rd
                cjne    a,srl_xmt_wr,srl_xmt_skip
                setb    srl_ready
                sjmp    srl_xmt_end
srl_xmt_skip:   add     a,#low(srl_xmt_buffer-1)
                mov     dpl,a
                clr     a
                addc    a,#high(srl_xmt_buffer-1)
                mov     dph,a
                movx    a,@dptr
                mov     sbuf,a
                djnz    srl_xmt_rd,srl_xmt_end
                mov     srl_xmt_rd,#srl_xmt_size
srl_xmt_end:    pop     dps
                pop     dpx
                pop     dph
                pop     dpl
                pop     acc
                pop     psw
                setb    ea
                reti

get_chr:        mov     dps,#0
                mov     dpx,#0
                mov     a,srl_rcv_rd
                cjne    a,srl_rcv_wr,gch_something
                clr     c
                ret
gch_something:  mov     a,srl_rcv_rd
                add     a,#low(srl_rcv_buffer-1)
                mov     dpl,a
                clr     a
                addc    a,#high(srl_rcv_buffer-1)
                mov     dph,a
                movx    a,@dptr
                djnz    srl_rcv_rd,gch_debug
                mov     srl_rcv_rd,#srl_rcv_size
gch_debug:      jnb     serial_debug,gch_ret
                push    acc
                call    lcd_out
                pop     acc
gch_ret:        setb    c
                ret

put_chr:        jbc     srl_ready,put_chr_now
                push    dpl
                push    dph
                push    acc
                mov     dps,#0
                mov     dpx,#0
                mov     a,srl_xmt_wr
                djnz    acc,put_chr_ok1
                mov     a,#srl_xmt_size
put_chr_ok1:    cjne    a,srl_xmt_rd,put_chr_ok2
                pop     acc
                pop     dph
                pop     dpl
                ret
put_chr_ok2:    xch     a,srl_xmt_wr
                add     a,#low(srl_xmt_buffer-1)
                mov     dpl,a
                clr     a
                addc    a,#high(srl_xmt_buffer-1)
                mov     dph,a
                pop     acc
                movx    @dptr,a
                pop     dph
                pop     dpl
                ret
put_chr_now:    mov     sbuf,a
                ret

put_chr_lft:    mov     a,srl_xmt_wr
                setb    c
                subb    a,srl_xmt_rd
                jnc     put_chr_ret
                add     a,#srl_xmt_size
put_chr_ret:    mov     c,srl_ready
                addc    a,#0
                ret

put_cr:         mov     a,#cr
                jmp     put_chr

put_str_nxt:    call    put_chr
                inc     dptr
put_str:        clr     a
                movc    a,@a+dptr
                jnz     put_str_nxt
                inc     dptr
                ret

put_str_a:      jz      put_str
                mov     b,a
put_str_a_lp:   clr     a
                movc    a,@a+dptr                
                inc     dptr
                jnz     put_str_a_lp
                djnz    b,put_str_a_lp
                jmp     put_str

puts_nfs:       mov     dps,#0
                mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
                sjmp    pnfs_entry
pnfs_lp:        call    put_chr
pnfs_entry:     clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     pnfs_lp
                jmp     @a+dptr

put_byte:       mov     b,a
                swap    a   
                call    hex_asc
                call    put_chr
                mov     a,b
                call    hex_asc
                jmp     put_chr

put_dec0:       mov     b,#10
                div     ab
                push    b
                jz      pd0_only1
                mov     b,#10
                div     ab
                jz      pd0_only2
                add     a,#'0'
                call    put_chr
pd0_only2:      mov     a,b
                add     a,#'0'
                call    put_chr
pd0_only1:      pop     acc
                add     a,#'0'
                jmp     put_chr

srl_in_init:    mov     dptr,#srl_in_index
                mov     r0,#srl_in_no
                clr     a
srl_in_init_lp: movx    @dptr,a
                inc     dptr
                djnz    r0,srl_in_init_lp
                ret

srl_in_check:   cjne    a,#'#',srl_in_exact
                mov     a,b
                call    asc_hex
                clr     a
                rlc     a
                ret
srl_in_exact:   cjne    a,b,srl_in_diff
                mov     a,#1
                ret
srl_in_diff:    clr     a
srl_in_ret:     ret

serial_input:   call    get_chr
                jnc     srl_in_ret
                mov     b,a
                mov     r1,a
                mov     r0,#srl_history_no
                mov     dptr,#srl_in_history
srl_in_lp0:     movx    a,@dptr
                xch     a,r1
                movx    @dptr,a
                inc     dptr
                djnz    r0,srl_in_lp0
                mov     dps,#00100100b
                mov     dptr,#srl_in_index
                mov     dptr,#srl_in_format
                mov     r0,#srl_in_no
                mov     r1,#0
srl_in_lp1:     movx    a,@dptr
srl_in_first:   mov     r2,a
                movc    a,@a+dptr
                call    srl_in_check
                jnz     srl_in_ok
                mov     a,r2
                jz      srl_in_next
                clr     a
                movx    @dptr,a
                sjmp    srl_in_first
srl_in_ok:      mov     a,r2
                inc     a
                movx    @dptr,a
                movc    a,@a+dptr
                jz      srl_in_exec
srl_in_next:    mov     dps,#5
srl_in_next_lp: inc     dptr
                clr     a
                movc    a,@a+dptr
                jnz     srl_in_next_lp
                mov     dps,#00100100b
                inc     r1
                inc     dptr
                inc     dptr
                djnz    r0,srl_in_lp1
                jmp     serial_input
srl_in_exec:    mov     dps,#0
                call    srl_in_init
                mov     a,#low(serial_input)
                push    acc
                mov     a,#high(serial_input)
                push    acc
                clr     a
                push    acc
                mov     a,r1
                rl      a
                add     a,r1
                mov     dptr,#srl_in_table
                jmp     @a+dptr

; state: 0-off 1-synch 2-string 3-type 4-0 6-1 7-ram 8-2 10-3 11-movx 12-4

srl_dbg_on:     mov     dbg_state,#1
                mov     dbg_dpl,#low(debug_table)
                mov     dbg_dph,#high(debug_table)
                ret

srl_dbg_off:    mov     dbg_state,#0
                ret

debug_init:     mov     dbg_state,#0
                ret

dbg_min_free:   db      1,4
                db      2,dbg_max_txt
                db      3,1
                db      4,1
                db      6,2
                db      7,dbg_max_mul
                db      8,1
                db      10,2
                db      11,dbg_max_mul
                db      12,1
                db      0

dbg_ret:        ret
do_debug:       mov     dps,#0
                mov     dpx,#0
                mov     a,dbg_state
                jz      dbg_ret
                mov     dptr,#dbg_min_free
                call    xlat_byte
                mov     b,a
                call    put_chr_lft
                subb    a,b
                jc      dbg_ret
                mov     dpl,dbg_dpl
                mov     dph,dbg_dph
                mov     a,dbg_state
                cjne    a,#1,dbg_try_2
                clr     a
                movc    a,@a+dptr
                jz      srl_dbg_on
                mov     dbg_state,#2
                mov     dptr,#dbg_synch_txt
                jmp     put_str
dbg_try_2:      cjne    a,#2,dbg_try_3
                call    put_str
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#3
                clr     a
                jmp     put_chr
dbg_try_3:      cjne    a,#3,dbg_try_4
                clr     a
                movc    a,@a+dptr
                mov     b,a
                add     a,#2
                rl      a
                mov     dbg_state,a
                mov     a,b
                jmp     put_chr
dbg_try_4:      cjne    a,#4,dbg_try_6
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     r0,a
                inc     dptr
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#1
                mov     a,@r0
                jmp     put_chr
dbg_try_6:      cjne    a,#6,dbg_try_7
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_mul,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     r0,a
                mov     a,@r0
                mov     dbg_size,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_lo,a
                inc     dptr
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#7
                mov     dbg_ind,#0
                ret
dbg_try_7:      cjne    a,#7,dbg_try_8
                mov     a,dbg_ind
                cjne    a,dbg_size,dbg_7_ok
                mov     dbg_state,#1
                ret
dbg_7_ok:       mov     a,dbg_ind
                mov     b,dbg_mul
                mul     ab
                add     a,dbg_base_lo
                mov     r0,a
                mov     r1,dbg_mul
dbg_7_lp:       mov     a,@r0
                call    put_chr
                inc     r0
                djnz    r1,dbg_7_lp
                inc     dbg_ind
                ret
dbg_try_8:      cjne    a,#8,dbg_try_10
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_size,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_lo,a
                inc     dptr
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#7
                mov     dbg_mul,#1
                mov     dbg_ind,#0
                ret
dbg_try_10:     cjne    a,#10,dbg_try_11
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_mul,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     r0,a
                mov     a,@r0
                mov     dbg_size,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_hi,a
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_lo,a
                inc     dptr
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#11
                mov     dbg_ind,#0
                ret
dbg_try_11:     cjne    a,#11,dbg_try_12
                mov     a,dbg_ind
                cjne    a,dbg_size,dbg_11_ok
                mov     dbg_state,#1
                ret
dbg_11_ok:      mov     a,dbg_ind
                mov     b,dbg_mul
                mul     ab
                add     a,dbg_base_lo
                mov     dpl,a
                mov     a,b
                addc    a,dbg_base_hi
                mov     dph,a
                mov     r1,dbg_mul
dbg_11_lp:      movx    a,@dptr
                call    put_chr
                inc     dptr
                djnz    r1,dbg_11_lp
                inc     dbg_ind
                ret
dbg_try_12:     cjne    a,#12,dbg_wrong
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_size,a
                call    put_chr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_hi,a
                inc     dptr
                clr     a
                movc    a,@a+dptr
                mov     dbg_base_lo,a
                inc     dptr
                mov     dbg_dpl,dpl
                mov     dbg_dph,dph
                mov     dbg_state,#11
                mov     dbg_mul,#1
                mov     dbg_ind,#0
                ret
dbg_wrong:      jmp     srl_dbg_on

dwn_error_text: db      cr,lf
                db      'download completed',0
                db      cr,lf
                db      'download aborted',0
                db      cr,lf
                db      'non-hex character found',0
                db      cr,lf
                db      'incorrect checksum',0

dwn_table:      ljmp    dwn_w4colon
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_count
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_add_hi
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_add_lo
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_rec
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_data
                ljmp    dwn_hi_nibble
                ljmp    dwn_get_sum

dwn_hi_nibble:  mov     a,b
                call    asc_hex
                jnc     dwn_not_a_hex
                swap    a
                mov     dwn_save,a
                inc     dwn_state
                sjmp    dwn_w4char
dwn_not_a_hex2: pop     b
                pop     b
                pop     b
dwn_not_a_hex:  mov     a,#2
                jmp     dwn_finished

dwn_lo_nibble:  mov     a,b
                call    asc_hex
                jnc     dwn_not_a_hex2
                orl     a,dwn_save
                mov     dwn_save,a
                add     a,dwn_sum
                mov     dwn_sum,a
                ret

do_download:    clr     a
                mov     wr_rele_reg1,a
                mov     wr_rele_reg2,a
                call    write_rele_regs

                mov     dbg_state,#0
                call    puts_nfs
                db          cr,lf
                db          'erasing flash...'
                db          cr,lf,0
                call    f_acquire
                call    f_erase_chip
                call    puts_nfs
                db          'ready to download'
                db          cr,lf,0
                mov     dwn_state,#0
dwn_w4char_lp:  call    reset_watchdog
dwn_w4char:     call    get_chr
                jnc     dwn_w4char_lp
                mov     b,a
                xrl     a,#esc
                jz      dwn_found_esc
                mov     dptr,#dwn_table
                mov     a,dwn_state
                rl      a
                add     a,dwn_state
                jmp     @a+dptr
dwn_found_esc:  mov     a,#1
                jmp     dwn_finished

dwn_get_data:   call    dwn_lo_nibble
                mov     a,dwn_save
                call    f_write
                call    f_inc
                mov     a,f_addr_lo
                jnz     dgd_ok2
                call    puts_nfs
                db          cr,lf
                db          'page ',0
                mov     a,f_addr_hi
                call    put_byte
dgd_ok2:        dec     dwn_state
                djnz    dwn_cnt,dwn_w4char
                mov     dwn_state,#11
                jmp     dwn_w4char

dwn_w4colon:    mov     a,b
                cjne    a,#':',dwn_w4char
                inc     dwn_state
                mov     dwn_sum,#0
                jmp     dwn_w4char

dwn_get_count:  call    dwn_lo_nibble
                mov     dwn_cnt,dwn_save
                inc     dwn_state
                jmp     dwn_w4char

dwn_get_add_hi: call    dwn_lo_nibble
                mov     f_addr_hi,dwn_save
                inc     dwn_state
                jmp     dwn_w4char

dwn_get_add_lo: call    dwn_lo_nibble
                mov     f_addr_lo,dwn_save
                inc     dwn_state
                jmp     dwn_w4char

dwn_get_rec:    call    dwn_lo_nibble
                mov     a,dwn_save
                jnz     dwn_no_error
                mov     a,dwn_cnt
                jz      dwn_zero_len
                inc     dwn_state
                jmp     dwn_w4char
dwn_zero_len:   mov     dwn_state,#11
                jmp     dwn_w4char

dwn_get_sum:    call    dwn_lo_nibble
                mov     a,dwn_sum
                jnz     dwn_bad_sum
                mov     dwn_state,a
                jmp     dwn_w4char
dwn_bad_sum:    mov     a,#3
dwn_finished:   mov     dptr,#dwn_error_text
                call    put_str_a
                jmp     f_release

dwn_no_error:   mov     dptr,#dwn_error_text
                call    put_str
                jmp     f_release

do_parameters:  mov     dps,#0
                mov     dpx,#0
                mov     dptr,#0
dp_wait_lp:     push    dpl
                push    dph
                call    do_them
                pop     dph
                pop     dpl
dp_main_lp:     call    put_chr_lft
                subb    a,#10
                jc      dp_wait_lp
                movx    a,@dptr
                call    put_chr
                inc     dptr
                mov     a,dph
                xrl     a,#8
                jnz     dp_main_lp
                ret

serial_com:     clr     ea
                call    serial_init
                call    srl_in_init
                call    debug_init
                call    gsm_init
                setb    ea
srl_com_lp:     call    do_them
                call    serial_input
                call    do_debug
if debug_vstupov
                call    reg_debug
endif
                call    put_chr_lft
                subb    a,#30
                jc      srl_skip_send
                call    do_vnts
                dw      m_cmp+c_,srl_send_cmp
                dw      m_del+c_,srl_send_del
                dw      m_zak+c_,srl_send_zak
                dw      m_loc+c_,srl_send_loc
                dw      m_boss+c_,srl_send_boss
                db      0
srl_skip_send:  jmp     srl_com_lp

srl_in_byte:    movx    a,@dptr
                inc     dptr
                call    asc_hex
                mov     b,a
                movx    a,@dptr
                inc     dptr
                call    asc_hex
                swap    a
                orl     a,b
                ret

srl_get_msg0:   mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r1,a
                call    srl_in_byte
                mov     r0,a
                mov     r2,#0
                jmp     ovr_msg

srl_get_msg1:   mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r3,a
                call    srl_in_byte
                mov     r1,a
                call    srl_in_byte
                mov     r0,a
                mov     r2,#1
                jmp     ovr_msg

srl_get_msg2:   mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r4,a
                call    srl_in_byte
                mov     r3,a
                call    srl_in_byte
                mov     r1,a
                call    srl_in_byte
                mov     r0,a
                mov     r2,#2
                jmp     ovr_msg

srl_send_cmp:   push    ar0
                mov     r0,#2
srl_s_cmp_lp:   push    ar0
                mov     a,#'c'
                call    put_chr
                mov     a,#'m'
                call    put_chr
                mov     a,#'p'
                call    put_chr
                mov     a,r3
                dec     a
                rrc     a
                mov     a,r4
                rlc     a
                mov     r7,a
                call    put_byte
                mov     a,r5
                call    put_byte
                mov     a,r6
                call    put_byte
                mov     a,r5
                add     a,r6
                add     a,r7
                cpl     a
                inc     a
                call    put_byte
                pop     ar0
                djnz    r0,srl_s_cmp_lp
                pop     ar0
                ret

srl_get_cmp:    mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r7,a
                call    srl_in_byte
                mov     r6,a
                call    srl_in_byte
                mov     r5,a
                call    srl_in_byte
                mov     r4,a
                add     a,r5
                add     a,r6
                add     a,r7
                jnz     sgc_ret
                mov     a,r4
                clr     c
                rrc     a
                mov     r4,a
                clr     a
                rlc     a
                inc     a
                mov     r3,a
                mov     r2,#4
                mov     r1,#m_cmp
                mov     r0,#id_group
                jmp     snd_msg
sgc_ret:        ret

srl_send_del:   mov     a,#'d'
                call    put_chr
                mov     a,#'e'
                call    put_chr
                mov     a,#'l'
                call    put_chr
                mov     a,r3
                dec     a
                rrc     a
                mov     a,r4
                rlc     a
                mov     r7,a
                call    put_byte
                mov     a,r7
                cpl     a
                inc     a
                jmp     put_byte

srl_get_del:    mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r7,a
                call    srl_in_byte
                mov     r4,a
                add     a,r7
                jnz     sgd_ret
                mov     a,r4
                clr     c
                rrc     a
                mov     r4,a
                clr     a
                rlc     a
                inc     a
                mov     r3,a
                mov     r2,#2
                mov     r1,#m_del
                mov     r0,#id_group
                jmp     snd_msg
sgd_ret:        ret

srl_send_zak:   mov     a,#'z'
                call    put_chr
                mov     a,#'a'
                call    put_chr
                mov     a,#'k'
                call    put_chr
                mov     a,r3
                dec     a
                rrc     a
                mov     a,r4
                rlc     a
                mov     r7,a
                call    put_byte
                mov     a,r7
                cpl     a
                inc     a
                jmp     put_byte
                
srl_get_zak:    mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r7,a
                call    srl_in_byte
                mov     r4,a
                add     a,r7
                jnz     sgz_ret
                mov     a,r4
                clr     c
                rrc     a
                mov     r4,a
                clr     a
                rlc     a
                inc     a
                mov     r3,a
                mov     r2,#2
                mov     r1,#m_zak
                mov     r0,#id_group
                jmp     snd_msg
sgz_ret:        ret

srl_send_loc:   mov     a,#'l'
                call    put_chr
                mov     a,#'o'
                call    put_chr
                mov     a,#'c'
                call    put_chr
                mov     a,r4
                call    put_byte
                mov     a,r4
                cpl     a
                inc     a
                jmp     put_byte

srl_get_loc:    mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r7,a
                call    srl_in_byte
                mov     r4,a
                add     a,r7
                jnz     sgl_ret
                mov     r3,#0
                mov     r2,#2
                mov     r1,#m_loc
                mov     r0,#id_group
                jmp     snd_msg
sgl_ret:        ret

srl_send_boss:  mov     a,#'b'
                call    put_chr
                mov     a,#'o'
                call    put_chr
                mov     a,#'s'
                call    put_chr
                mov     a,#'s'
                jmp     put_chr

srl_get_boss:   mov     r2,#0
                mov     r1,#m_boss
                mov     r0,#id_group
                jmp     snd_msg

b_gsm_debug     bit     acc.4
b_gsm_porucha   bit     acc.5
b_gsm_nums      bit     acc.6

gsm_init:       clr     a
                ; don't send gsm numbers
                clr     b_gsm_nums
                mov     gsm_state,a
                ret

gsm_porucha_on: mov     a,gsm_state
                setb    b_gsm_porucha
                mov     gsm_state,a
                ret

gsm_porucha_off:
                mov     a,gsm_state
                clr     b_gsm_porucha
                mov     gsm_state,a
                ret

gsm_debug_on:   mov     a,gsm_state
                setb    b_gsm_debug
                mov     gsm_state,a
                ret

gsm_debug_off:  mov     a,gsm_state
                clr     b_gsm_debug
                mov     gsm_state,a
                ret

srl_gsm_ok:     mov     a,gsm_state
                jnb     b_gsm_porucha,sgo_skip1
                mov     a,#'b'
                call    put_chr
                mov     a,#'a'
                call    put_chr
                mov     a,#'d'
                jmp     sgo_drain
sgo_skip1:      jnb     b_gsm_nums,sgo_skip2
                jmp     gsm_send_number
sgo_skip2:      jnb     b_gsm_debug,sgo_skip3
                mov     a,#'d'
                call    put_chr
                mov     a,#'b'
                call    put_chr
                mov     a,#'g'
                jmp     sgo_drain
sgo_skip3:      mov     a,#'o'
                call    put_chr
                mov     a,#'k'
sgo_drain:      call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#lf
                jmp     put_chr

srl_gsm_sig:    mov     dptr,#srl_in_history
                call    srl_in_byte
                mov     r3,a
                mov     r2,#1
                mov     r1,#m_gsm
                mov     r0,#id_commander
                jmp     ovr_msg

gsm_send_number:
                mov     a,#'n'
                call    put_chr
                mov     a,#'u'
                call    put_chr
                mov     a,#'m'
                call    put_chr
                mov     a,gsm_state
                anl     a,#0fh
                add     a,#'0'
                call    put_chr
                mov     dptr,#gsm_table
                mov     a,gsm_state
                anl     a,#0fh
                call    add_16a_to_dptr
                mov     r1,#16
gsn_lp:         movx    a,@dptr
                call    put_chr
                inc     dptr
                djnz    r1,gsn_lp
gsn_crlf:       mov     a,#cr
                call    put_chr
                mov     a,#lf
                jmp     put_chr

srl_gsm_next:   mov     a,gsm_state
                anl     a,#0fh
                inc     a
                cjne    a,#no_of_gsms,sgn_skip
                mov     a,gsm_state
                anl     a,#0f0h
                clr     b_gsm_nums
                mov     gsm_state,a
                ret
sgn_skip:       inc     gsm_state
                ret

srl_gsm_stat:   mov     dptr,#lcd_table
                mov     r1,#32
sgs_lp:         movx    a,@dptr
                call    put_chr
                inc     dptr
                djnz    r1,sgs_lp
                sjmp    gsn_crlf

srl_gsm_again:  mov     a,gsm_state
                ; don't send gsm numbers
                clr     b_gsm_nums
                anl     a,#0f0h
                mov     gsm_state,a
                ret

if debug_vstupov
rd_byte:        push    dpl
                push    dph
                mov     r1,a
                mov     r0,#8
rdb_lp:         mov     a,r1
                rlc     a
                mov     r1,a
                clr     a
                addc    a,#'0'
                call    put_chr
                djnz    r0,rdb_lp
                mov     a,#' '
                call    put_chr
                pop     dph
                pop     dpl
                ret

reg_debug:      call    put_chr_lft
                subb    a,#75
                jc      rd_ret
                mov     dps,#0
                mov     dptr,#0
                mov     r2,#8
rd_lp:          mov     dpx,#10h
                movx    a,@dptr
                mov     dpx,#0
                call    rd_byte
                inc     dptr
                djnz    r2,rd_lp
                mov     a,#cr
                call    put_chr
                mov     a,#lf
                jmp     put_chr
rd_ret:         ret

;reg_debug:      call    put_chr_lft
                subb    a,#75
                jc      rd_ret

                mov     a,inc_cnt_hi
                call    put_byte
                mov     a,inc_cnt_lo
                call    put_byte
                mov     a,#' '
                call    put_chr
                mov     a,inc_snimace
                call    put_byte

                mov     a,#' '
                call    put_chr

                mov     a,nextfloor
                call    get_inc_data
                mov     a,r4
                call    put_byte
                mov     a,r3
                call    put_byte




                mov     a,#cr
                call    put_chr
                mov     a,#lf
                jmp     put_chr
                ret
endif
