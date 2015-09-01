; version 1.0

clear_fifos:    mov     a,#fifo0
                mov     fifo0_wr,a
                mov     fifo0_rd,a
                mov     fifo1_valid,#0
                ret

serial_init:    call    clear_fifos
                mov     scon,#50h
                mov     a,#low(-srl_period)
                mov     tl2,a
                mov     rcap2l,a
                mov     a,#high(-srl_period)
                mov     th2,a
                mov     rcap2h,a
                mov     t2mod,#0
                mov     t2con,#00110100b
                clr     srl_sent_data
                setb    es
                ret

serial_int:     clr     ea
                push    psw
                push    acc
                anl     psw,#11100111b
                jnb     ri,si_try_ti
                clr     ri
                push    ar0
                mov     r0,fifo0_wr
                mov     a,sbuf
                mov     @r0,a
                mov     a,fifo0_wr
                inc     a
                cjne    a,#fifo0_end,si_ri_done
                mov     a,#fifo0
si_ri_inc:      cjne    a,fifo0_rd,si_ri_done
                mov     a,fifo0_wr
si_ri_done:     mov     fifo0_wr,a
                pop     ar0
si_try_ti:      jnb     ti,si_done
                clr     ti
                setb    srl_sent_data
si_done:        pop     acc
                pop     psw
                setb    ea
                reti

read_serial:    mov     a,fifo0_rd
                cjne    a,fifo0_wr,rs_something
                clr     c
                ret
rs_something:   mov     r0,a
                inc     a
                cjne    a,#fifo0_end,rs_done
                mov     a,#fifo0
rs_done:        mov     fifo0_rd,a
                mov     a,@r0
                mov     r0,#fifo1
                mov     r1,#fifo1_size
rs_lp1:         xch     a,@r0
                inc     r0
                djnz    r1,rs_lp1
                mov     a,fifo1_valid
                cjne    a,#fifo1_size,rs_inc
                dec     a
rs_inc:         inc     a
                mov     fifo1_valid,a
                setb    c
                ret

get_chr:        mov     a,fifo1_valid
                jz      gc_ret
                dec     a
                mov     fifo1_valid,a
                add     a,#fifo1
                mov     r0,a
                mov     a,@r0
                setb    c
                ret
gc_ret:         clr     c
                ret

switch_gsm:     setb    direction
                mov     mask,#mask_gsm
                mov     p3,#mask_gsm
                ret

switch_out:     clr     direction
                ;jb      lift,so_lift2
                mov     mask,#mask_out1
                mov     p3,#mask_out1
                ret
;so_lift2:       mov     mask,#mask_out2
;                mov     p3,#mask_out2
;                ret

cool_down:      jnb     direction,cd_done
                call    tmr_int_f
                db      t_cool,0,1,0
cd_lp1:         call    do_them
                call    read_serial
                jnc     cd_skip1
                call    get_chr
                ;call    tmr_int_f
                ;db      t_cool,0,1,0
                jmp     cd_lp1
cd_skip1:       mov     a,#t_cool
                call    tmr_zro
                jnc     cd_lp1
cd_done:        ret

put_chr:        jnb     direction,pc_ok
if debug
                push    acc
                call    switch_out
                call    pc_ok
                call    switch_gsm
                pop     acc
endif
                push    acc
                push    ar0
                mov     r0,#100
pc_lp3:         call    rst_wd
                djnz    r0,pc_lp3
                pop     ar0
                pop     acc

pc_ok:          mov     sbuf,a
pc_lp2:         push    acc
                call    rst_wd
                pop     acc
                jnb     srl_sent_data,pc_lp2
                clr     srl_sent_data
                ret

put_byte:       mov     b,a
                swap    a   
                call    hex_asc
                call    put_chr
                mov     a,b
                call    hex_asc
                jmp     put_chr

puts:           mov     a,@r0
                call    put_chr
                inc     r0
                djnz    r1,puts
                ret

puts_no_spaces: mov     a,@r0
                cjne    a,#' ',pns_skip1
                sjmp    pns_skip2
pns_skip1:      call    put_chr
pns_skip2:      inc     r0
                djnz    r1,puts_no_spaces
                ret

puts_nf:        pop     dph
                pop     dpl
                sjmp    pnf_entry
pnf_lp:         call    put_chr
pnf_entry:      clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     pnf_lp
                jmp     @a+dptr

; print out fifo contents
print_fifos:     
if 0        
                push    ar0
                push    ar1
                push    mask
                push    bits1
                push    bits2

                call    switch_out
                call    puts_nf
                db      cr,'gsm: ',0

                ; mov     r0,#fifo0
                ; mov     r1,#fifo0_size
; pf_lp1:         mov     a,@r0
                ; call    put_chr
                ; inc     r0
                ; djnz    r1,pf_lp1

                mov     r0,#fifo1
                mov     r1,#fifo1_size
pf_lp2:         mov     a,@r0
                call    put_chr
                inc     r0
                djnz    r1,pf_lp2

                mov     a,#cr
                call    put_chr
                
                pop     bits2
                pop     bits1
                pop     mask
                mov     p3,mask
                pop     ar1
                pop     ar0
endif
                ret
