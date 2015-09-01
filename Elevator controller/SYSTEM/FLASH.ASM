; version 4.1

error_offset    equ     8000h
error_size      equ     1+7
error_ceiling   equ     0eeh
error_rem       equ     (error_ceiling*256-error_offset) mod error_size

                bseg
f_in_use:       dbit    1
f_do_them:      dbit    1

                dseg
f_addr_lo:      ds      1
f_addr_hi:      ds      1
flash_type:     ds      1

                cseg
; driver layer
f_reset:        mov     dps,#0
                mov     dpx,#0
                mov     dptr,#0
                mov     a,#0f0h
                movx    @dptr,a
                ret

f_command:      push    acc
                mov     dps,#0
                mov     dpx,#0
                
                mov     a,flash_type
                cjne    a,#1,f_c_try_2
                ; a29010a
                mov     dptr,#555h
                mov     a,#0aah
                movx    @dptr,a
                
                mov     dptr,#2aah
                mov     a,#055h
                movx    @dptr,a
                
                mov     dptr,#555h
                sjmp    f_c_drain
f_c_try_2:      cjne    a,#2,f_c_unknown
                ; sst39sf010a
                mov     dptr,#5555h
                mov     a,#0aah
                movx    @dptr,a
                
                mov     dptr,#2aaah
                mov     a,#055h
                movx    @dptr,a
                
                mov     dptr,#5555h
f_c_drain:      pop     acc
                cjne    a,#030h,f_c_normal
                mov     dpl,f_addr_lo
                mov     dph,f_addr_hi
f_c_normal:     movx    @dptr,a
                ret
f_c_unknown:    pop     acc
                ret

f_identify:     call    f_reset
                mov     flash_type,#1
                mov     a,#090h
                call    f_command
                mov     dptr,#0
                movx    a,@dptr
                cjne    a,#037h,f_id_try_2
                inc     dptr
                movx    a,@dptr
                cjne    a,#0a4h,f_id_try_2
                inc     dptr
                inc     dptr
                movx    a,@dptr
                cjne    a,#07fh,f_id_try_2
                ; return with type == 1
                jmp     f_reset
f_id_try_2:     call    f_reset
                mov     flash_type,#2
                mov     a,#090h
                call    f_command
                ; wait 150 ns
                mov     acc,#10
                djnz    acc,$
                mov     dptr,#0
                movx    a,@dptr
                cjne    a,#0bfh,f_id_unknown
                inc     dptr
                movx    a,@dptr
                orl     a,#3
                cjne    a,#0b7h,f_id_unknown
                ; return with type == 2
                jmp     f_reset
f_id_unknown:   mov     flash_type,#0
                ; return with type == 0
                jmp     f_reset

f_wait4it:      movx    a,@dptr
                mov     r0,a
fw4i_lp:        jb      f_do_them,fw4i_skip1
                call    reset_watchdog
                sjmp    fw4i_skip2
fw4i_skip1:     push    ar0
                push    dpl
                push    dph
                call    do_them
                pop     dph
                pop     dpl
                pop     ar0
fw4i_skip2:     movx    a,@dptr
                xch     a,r0
                xrl     a,r0
                jnb     acc.6,fw4i_pass
                jnb     acc.5,fw4i_lp
                movx    a,@dptr
                mov     r0,a
                movx    a,@dptr
                xrl     a,r0
                jnb     acc.6,fw4i_pass
                call    f_reset
                clr     a
                ret
fw4i_pass:      mov     a,#0ffh
                ret

f_write:        mov     r0,a
f_write_lp:     mov     a,#0a0h
                call    f_command
                
                mov     dpl,f_addr_lo
                mov     dph,f_addr_hi
                mov     a,r0
                movx    @dptr,a
                
                push    ar0
                call    f_wait4it
                pop     ar0
                jz      f_write_lp
                ret

f_erase_chip:   mov     a,#080h
                call    f_command
                mov     a,#010h
                call    f_command

                mov     a,flash_type
                cjne    a,#1,f_ec_try_2
                ; a29010a
                call    f_wait4it
                jz      f_erase_chip
                jmp     f_reset
f_ec_try_2:     cjne    a,#2,f_ec_unknown
                ; sst39sf010a
                ; wait 100ms
                call    wait_for_timer_f
                dw      t_flash
                db      0,0,10
f_ec_unknown:   ret

; flash_type == 1 -> f_addr_hi = 00h, 80h
; flash_type == 2 -> f_addr_hi = 00h, 10h, 20h, ... f0h
f_erase_sector: mov     a,#080h
                call    f_command
                mov     a,#030h
                call    f_command
                
                mov     a,flash_type
                cjne    a,#1,f_es_try_2
                ; a29010a
                call    f_wait4it
                jz      f_erase_sector
                jmp     f_reset
f_es_try_2:     cjne    a,#2,f_es_unknown
                ; sst39sf010a
                ; wait 25ms
                call    wait_for_timer_f
                dw      t_flash
                db      0,0,3
f_es_unknown:   ret

; application layer
delete_errors:  call    f_acquire
                
                mov     a,flash_type
                cjne    a,#1,f_de_try_2
                ; a29010a - erase 1 sector
                mov     f_addr_hi,#080h
                call    f_erase_sector
                sjmp    f_de_ret
f_de_try_2:     cjne    a,#2,f_de_ret
                ; sst39sf010a - erase 8 sectors
                mov     f_addr_hi,#080h
f_de_delete_lp: call    f_erase_sector
                mov     a,f_addr_hi
                add     a,#010h
                mov     f_addr_hi,a
                anl     a,#0f0h
                cjne    a,#0f0h,f_de_delete_lp
f_de_ret:       jmp     f_release

f_move:         mov     f_addr_lo,dpl
                mov     f_addr_hi,dph
                ret

f_inc:          mov     a,f_addr_lo
                add     a,#1
                mov     f_addr_lo,a
                clr     a
                addc    a,f_addr_hi
                mov     f_addr_hi,a
                ret
                
f_check_block:  movx    a,@dptr
                mov     r7,a
                movx    a,@dptr
                xrl     a,r7
                jnz     fcb_bad
                inc     dptr
                inc     dptr
                djnz    r0,f_check_block
                ret
fcb_bad:        pop     b
                pop     b
                pop     b
                clr     a
                ret

f_read_block:   movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,f_read_block
                ret

f_write_block:  movx    a,@dptr
                push    ar0
                push    dpl
                push    dph
                call    f_write
                call    f_inc
                pop     dph
                pop     dpl
                pop     ar0
                inc     dptr
                djnz    r0,f_write_block
                ret

f_acquire_lp:   call    do_them
f_acquire:      jb      f_in_use,f_acquire_lp
                setb    f_in_use
                ret

f_release:      clr     f_in_use
                ret

write_error:    setb    f_do_them
                mov     dps,#0
                mov     dpx,#0
                push    ar4
                push    ar3
                call    f_acquire
we_again:       mov     dptr,#error_offset
                mov     r1,#0
                movx    a,@dptr
                mov     r0,a
                clr     acc.0
                jnz     we_ok2write
                mov     a,r0
                mov     r1,a
we_search_lp:   mov     a,dpl
                add     a,#error_size
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                xrl     a,#error_ceiling
                jz      we_on_top
                movx    a,@dptr
                xrl     a,r0
                jz      we_search_lp
                mov     a,dpl
                add     a,#error_size-1
                clr     a
                addc    a,dph
                cjne    a,#error_ceiling,we_ok2write
we_on_top:      mov     dptr,#error_offset
                mov     a,r0
                xrl     a,#1
                mov     r1,a
we_ok2write:    call    f_move
                movx    a,@dptr
                cpl     a
                jz      we_ok2write2
                call    f_erase_sector
                jmp     we_again
we_ok2write2:   mov     a,r1
                call    f_write
                call    f_inc
                pop     acc                     ; error id
                call    f_write
                call    f_inc
                pop     acc                     ; liftpos
                call    f_write
                call    f_inc
                mov     r0,#i2c_time            ; hour
                mov     a,@r0
                call    f_write
                call    f_inc
                mov     r0,#i2c_time+1          ; minute
                mov     a,@r0
                call    f_write
                call    f_inc
                mov     r0,#i2c_time+2          ; day of month
                mov     a,@r0
                call    f_write
                call    f_inc
                mov     r0,#i2c_time+3          ; month
                mov     a,@r0
                call    f_write
                call    f_inc
                mov     r0,#i2c_time+4          ; year
                mov     a,@r0
                call    f_write
                call    f_release
                clr     f_do_them
                jmp     f_reset

check_identity: call    f_acquire
                mov     dps,#0
                clr     a
                mov     dpx,a
                mov     dptr,#0
                mov     r6,#low(top_of_code_seg)
                mov     r7,#high(top_of_code_seg)
                inc     r6
                inc     r7
                djnz    r6,chi_main_lp
                djnz    r7,chi_main_lp
chi_main_lp:    movc    a,@a+dptr
                mov     r5,a
                movx    a,@dptr
                xrl     a,r5
                jnz     chi_ret_no
                inc     dptr
                djnz    r6,chi_main_lp
                djnz    r7,chi_main_lp
                call    f_release
                mov     a,#0ffh
                ret
chi_ret_no:     call    f_release
                clr     a
                ret

copy_the_code:  mov     dps,#0
                mov     dpx,#0
                call    f_acquire
                call    f_erase_chip
                mov     dptr,#0
                call    f_move
ctc_lp1:        clr     a
                movc    a,@a+dptr
                inc     dptr
                push    dpl
                push    dph
                call    f_write
                mov     a,f_addr_lo
                jnz     ctc_skip1
                call    do_them
                mov     a,f_addr_hi
                anl     a,#0fh
                jnz     ctc_skip1
                mov     a,f_addr_hi
                swap    a
                anl     a,#0fh
                add     a,#16
                mov     lcd_ind,a
                mov     a,#7
                call    lcd_out
ctc_skip1:      pop     dph
                pop     dpl
                mov     f_addr_lo,dpl
                mov     a,dph
                mov     f_addr_hi,a
                cjne    a,#high(top_of_code_seg),ctc_lp1
                mov     a,f_addr_lo
                cjne    a,#low(top_of_code_seg),ctc_lp1
                call    f_release
                jmp     f_reset

get_last_error: mov     dps,#0
                mov     dpx,#0
                call    f_acquire
                mov     dptr,#error_offset
                movx    a,@dptr
                mov     r0,a
                clr     acc.0
                jnz     gle_no
gle_lp:         mov     a,dpl
                add     a,#2*error_size-1
                clr     a
                addc    a,dph
                xrl     a,#error_ceiling
                jz      gle_yes
                mov     a,dpl
                add     a,#error_size
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                movx    a,@dptr
                xrl     a,r0
                jz      gle_lp
                clr     c
                mov     a,dpl
                subb    a,#error_size
                mov     dpl,a
                mov     a,dph
                subb    a,#0
                mov     dph,a
gle_yes:        mov     error_lo,dpl
                mov     error_hi,dph
                setb    c
                ret
gle_no:         clr     c
                ret

get_prev_error: mov     dps,#0
                mov     dpx,#0
                call    f_acquire
                mov     a,error_lo
                mov     dpl,a
                mov     a,error_hi
                mov     dph,a
                movx    a,@dptr
                mov     r0,a
                mov     a,error_lo
                clr     c
                subb    a,#low(error_offset+error_size)
                mov     a,error_hi
                subb    a,#high(error_offset+error_size)
                jc      gpe_from_top
                mov     a,dpl
                subb    a,#error_size
                mov     dpl,a
                mov     a,dph
                subb    a,#0
                mov     dph,a
                movx    a,@dptr
                xrl     a,r0
                jz      gpe_done
                ret
gpe_from_top:   mov     dptr,#error_ceiling*256-error_size-error_rem
                movx    a,@dptr
                xrl     a,r0
                cjne    a,#1,gpe_ret
gpe_done:       mov     error_lo,dpl
                mov     error_hi,dph
gpe_ret:        ret

get_next_error: mov     dps,#0
                mov     dpx,#0
                call    f_acquire
                mov     a,error_lo
                mov     dpl,a
                mov     a,error_hi
                mov     dph,a
                movx    a,@dptr
                mov     r0,a
                mov     a,error_lo
                add     a,#2*error_size-1
                clr     a
                addc    a,error_hi
                xrl     a,#error_ceiling
                jz      gne_from_start
                mov     a,dpl
                add     a,#error_size
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                movx    a,@dptr
                xrl     a,r0
                jz      gne_done
                ret
gne_from_start: mov     dptr,#error_offset
                movx    a,@dptr
                xrl     a,r0
                cjne    a,#1,gne_ret
gne_done:       mov     error_lo,dpl
                mov     error_hi,dph
gne_ret:        ret

read_parameters:
                mov     dps,#00100100b
                mov     dpx,#0
                mov     dpx1,#0

                mov     dptr,#0
                mov     dptr,#enum_table
                mov     r0,#enum_table_size
                call    f_read_block

                mov     dptr,#256
                mov     dptr,#num_table
                mov     r0,#num_table_size
                call    f_read_block

                mov     dptr,#256*2
                mov     dptr,#time_table
                mov     r0,#time_table_size
                call    f_read_block

                mov     dptr,#256*3
                mov     dptr,#floor_table
                mov     r0,#floor_table_size
                call    f_read_block

                mov     dptr,#256*4
                mov     dptr,#vypis_table
                mov     r0,#vypis_table_size
                call    f_read_block

                mov     dptr,#256*5
                mov     dptr,#hodiny_table
                mov     r0,#hodiny_table_size
                call    f_read_block

                mov     dptr,#256*6
                mov     dptr,#increment_table
                mov     r0,#increment_table_size
                call    f_read_block

                mov     dptr,#256*7
                mov     dptr,#gsm_table
                mov     r0,#gsm_table_size
                jmp     f_read_block

check_parameters:
                mov     dps,#00100100b
                mov     dpx,#0
                mov     dpx1,#0

                mov     r0,#enum_table_size
                mov     dptr,#enum_table
                mov     dptr,#0
                call    f_check_block

                mov     r0,#num_table_size
                mov     dptr,#num_table
                mov     dptr,#256
                call    f_check_block

                mov     r0,#time_table_size
                mov     dptr,#time_table
                mov     dptr,#256*2
                call    f_check_block

                mov     r0,#floor_table_size
                mov     dptr,#floor_table
                mov     dptr,#256*3
                call    f_check_block

                mov     r0,#vypis_table_size
                mov     dptr,#vypis_table
                mov     dptr,#256*4
                call    f_check_block

                mov     r0,#hodiny_table_size
                mov     dptr,#hodiny_table
                mov     dptr,#256*5
                call    f_check_block

                mov     r0,#increment_table_size
                mov     dptr,#increment_table
                mov     dptr,#256*6
                call    f_check_block

                mov     r0,#gsm_table_size
                mov     dptr,#gsm_table
                mov     dptr,#256*7
                call    f_check_block
                mov     a,#0ffh
                ret

store_parameters:
                call    f_acquire
                mov     f_addr_hi,#0
                call    f_erase_sector

                mov     dps,#0
                mov     dpx,#0

                mov     r0,#enum_table_size
                mov     dptr,#enum_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#0
                call    f_write_block

                mov     r0,#num_table_size
                mov     dptr,#num_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#1
                call    f_write_block

                mov     r0,#time_table_size
                mov     dptr,#time_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#2
                call    f_write_block

                mov     r0,#floor_table_size
                mov     dptr,#floor_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#3
                call    f_write_block

                mov     r0,#vypis_table_size
                mov     dptr,#vypis_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#4
                call    f_write_block

                mov     r0,#hodiny_table_size
                mov     dptr,#hodiny_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#5
                call    f_write_block

                mov     r0,#increment_table_size
                mov     dptr,#increment_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#6
                call    f_write_block

                mov     r0,#gsm_table_size
                mov     dptr,#gsm_table
                mov     f_addr_lo,#0
                mov     f_addr_hi,#7
                call    f_write_block

                call    f_release
                jmp     f_reset
                