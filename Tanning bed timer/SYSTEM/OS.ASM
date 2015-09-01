; version 2.0

os_init:        mov     ie,#0
                mov     ip,#0
                anl     psw,#11100111b
                mov     tcon,#0
                mov     tmod,#1
                mov     tl0,#low(-tmr0_period)
                mov     th0,#high(-tmr0_period)
                setb    tr0
                setb    et0
                mov     to_kill,#0
                mov     wd_cnt,#wd_max
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
                mov     timer_no,#0
                mov     sp,#brick_floor-1
                mov     a,#brick_ceiling
                mov     brick_next,a
                mov     r0,a
                clr     a
                mov     @r0,a
                push    acc
                mov     brick_top,sp
                mov     dps,#0
                mov     auxr,#00001001b
                setb    ea
                jmp     initial_thread

; dptr -> thread's starting point
run_it:         clr     ea
                push    psw
                push    thread_id
                mov     wd_cnt,#wd_max
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
                mov     a,sp
                inc     a
                clr     c
                subb    a,brick_top
                push    acc
                mov     brick_top,sp
                push    dpl
                push    dph
                setb    ea
                ret

do_them:        clr     ea
                push    psw
                push    thread_id
                anl     psw,#11100111b
                mov     wd_cnt,#wd_max
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
                mov     a,sp
                inc     a
                clr     c
                subb    a,brick_top
                push    acc
                mov     brick_top,sp
os_dt_entry:    mov     r0,brick_next
                mov     a,@r0
                jnz     os_dt_next
os_dt_lp3:      pop     acc
                mov     r2,a
                xch     a,brick_top
                clr     c
                subb    a,brick_top
                mov     brick_top,a
                mov     r1,a
                mov     a,@r1
                jz      os_dt_done
                mov     a,r2
                dec     a
                mov     r1,a
os_dt_lp2:      dec     r0
                pop     acc
                mov     @r0,a
                djnz    r1,os_dt_lp2
                dec     r0
                mov     a,r2
                mov     @r0,a
                jmp     os_dt_lp3
os_dt_next:     dec     a
                mov     r1,a
os_dt_lp1:      inc     r0
                mov     a,@r0
                push    acc
                djnz    r1,os_dt_lp1
                inc     r0
os_dt_done:     mov     brick_next,r0
                pop     thread_id
                mov     a,to_kill
                jz      os_dt_live
                cjne    a,thread_id,os_dt_live
                mov     to_kill,#0
                sjmp    kill_me
os_dt_live:     pop     psw
                setb    ea
                reti

kill_me:        clr     ea
                anl     psw,#11100111b
                mov     wd_cnt,#wd_max
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
                mov     a,brick_top
                mov     sp,a
                pop     acc
                jnz     os_km_ok
                push    acc
                mov     brick_top,sp
                jmp     os_dt_entry
os_km_ok:       xch     a,brick_top
                clr     c
                subb    a,brick_top
                mov     brick_top,a
                pop     thread_id
                pop     psw
                setb    ea
                ret

kill_him:       mov     b,a
kh_lp:          mov     a,to_kill
                jz      kh_nothing
                push    b
                call    do_them
                pop     b
                jmp     kh_lp
kh_nothing:     mov     to_kill,b
                ret
