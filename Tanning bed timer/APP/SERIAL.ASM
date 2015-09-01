; version 1.0

si_format:      db      'total=##########',0
                db      'other=##########',0
                db      'delta=##',0
                db      'time1=####',0
                db      'time2=####',0
                db      'time3=####',0
                db      'pass=####',0
if 0
                db      'key1=############',0
                db      'key2=############',0
                db      'key3=############',0
endif

si_table:       ljmp    si_get_total1
                ljmp    si_get_total2
                ljmp    si_get_delta
                ljmp    si_get_time1
                ljmp    si_get_time2
                ljmp    si_get_time3
                ljmp    si_get_pass
if 0
                ljmp    si_get_key1
                ljmp    si_get_key2
                ljmp    si_get_key3
endif

si_init:        mov     r0,#si_index
                mov     r1,#si_no
                clr     a
sii_lp:         mov     @r0,a
                inc     r0
                djnz    r1,sii_lp
                ret

si_check:       cjne    a,#'#',sic_exact
                mov     a,b
                call    asc_hex
                clr     a
                rlc     a
                ret
sic_exact:      cjne    a,b,sic_diff
                mov     a,#1
                ret
sic_diff:       clr     a
                ret

si_process:     mov     b,a
                mov     r2,#si_history_no
                mov     r0,#si_history
sip_lp1:        xch     a,@r0
                inc     r0
                djnz    r2,sip_lp1
                mov     r0,#si_index
                mov     r1,#0
                mov     dptr,#si_format
                mov     r3,#si_no
sip_lp2:        mov     a,@r0
sip_first:      mov     r2,a
                movc    a,@a+dptr
                call    si_check
                jnz     sip_ok
                mov     a,r2
                jz      sip_lp3
                clr     a
                mov     @r0,a
                sjmp    sip_first
sip_ok:         mov     a,r2
                inc     a
                mov     @r0,a
                movc    a,@a+dptr
                jz      sip_exec
sip_lp3:        inc     dptr
                clr     a
                movc    a,@a+dptr
                jnz     sip_lp3
                inc     r0
                inc     r1
                inc     dptr
                djnz    r3,sip_lp2
                ret
sip_exec:       clr     a
                mov     @r0,a
                mov     a,r1
                rl      a
                add     a,r1
                mov     dptr,#si_table
                jmp     @a+dptr

si_byte:        mov     a,@r0
                inc     r0
                call    asc_hex
                mov     b,a
                mov     a,@r0
                inc     r0
                call    asc_hex
                swap    a
                orl     a,b
                ret

si_byte_bcd:    mov     a,@r0
                inc     r0
                call    asc_hex
                mov     r2,a
                mov     a,@r0
                inc     r0
                call    asc_hex
                rl      a
                mov     r1,a
                rl      a
                rl      a
                add     a,r1
                add     a,r2
                ret

si_get_total1:  mov     r0,#si_history
                call    si_byte_bcd
                mov     total1+4,a
                call    si_byte_bcd
                mov     total1+3,a
                call    si_byte_bcd
                mov     total1+2,a
                call    si_byte_bcd
                mov     total1+1,a
                call    si_byte_bcd
                mov     total1,a
                mov     a,addr_lo
                mov     a_total1,a
                mov     a_max,a
                ret

si_get_total2:  mov     r0,#si_history
                call    si_byte_bcd
                mov     total2+4,a
                call    si_byte_bcd
                mov     total2+3,a
                call    si_byte_bcd
                mov     total2+2,a
                call    si_byte_bcd
                mov     total2+1,a
                call    si_byte_bcd
                mov     total2,a
                mov     a,addr_lo
                mov     a_total2,a
                mov     a_max,a
                ret

si_get_delta:   mov     r0,#si_history
                call    si_byte_bcd
                mov     r7,a
                clr     c
                subb    a,#delta_no
                jnc     sgd_bad
                mov     delta,r7
sgd_bad:        mov     a,addr_lo
                mov     a_delta,a
                mov     a_max,a
                ret

si_get_time1:   mov     r0,#si_history
                call    si_byte_bcd
                mov     time1+1,a
                call    si_byte_bcd
                mov     time1,a
                mov     a,addr_lo
                mov     a_time1,a
                mov     a_max,a
                ret

si_get_time2:   mov     r0,#si_history
                call    si_byte_bcd
                mov     time2+1,a
                call    si_byte_bcd
                mov     time2,a
                mov     a,addr_lo
                mov     a_time2,a
                mov     a_max,a
                ret

si_get_time3:   mov     r0,#si_history
                call    si_byte_bcd
                mov     time3+1,a
                call    si_byte_bcd
                mov     time3,a
                mov     a,addr_lo
                mov     a_time3,a
                mov     a_max,a
                ret

si_get_pass:    mov     r0,#si_history
                mov     r1,#pass+1
                mov     r2,#2
sgp_lp:         call    si_byte
                mov     @r1,a
                dec     r1
                djnz    r2,sgp_lp
                mov     a,addr_lo
                mov     a_pass,a
                mov     a_max,a
                ret

if 0
si_get_key1:    mov     r0,#si_history
                mov     r1,#key1
                mov     r2,#6
sgk1_lp:        call    si_byte
                mov     @r1,a
                inc     r1
                djnz    r2,sgk1_lp
                mov     a_max,addr_lo
                ret

si_get_key2:    mov     r0,#si_history
                mov     r1,#key2
                mov     r2,#6
sgk2_lp:        call    si_byte
                mov     @r1,a
                inc     r1
                djnz    r2,sgk2_lp
                mov     a_max,addr_lo
                ret

si_get_key3:    mov     r0,#si_history
                mov     r1,#key3
                mov     r2,#6
sgk3_lp:        call    si_byte
                mov     @r1,a
                inc     r1
                djnz    r2,sgk3_lp
                mov     a_max,addr_lo
                ret
endif
