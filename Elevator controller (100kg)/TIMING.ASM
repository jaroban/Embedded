; version 2.0

timer0_int:     clr     ea
                push    psw
                push    acc
                anl     psw,#11100111b
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
os_tm_again:    djnz    wd_cnt,os_tm_start
                jmp     os_init
os_tm_start:    mov     a,timer_no
                jz      os_tm_end
                push    ar0
                push    ar1
                push    ar2
                push    ar3
                mov     r2,a
                rl      a
                rl      a
                add     a,#timer_table-1
                mov     r0,a
                mov     r1,a
os_tm_lp1:      mov     r3,#4
                mov     a,@r0
                djnz    acc,os_tm_skip1
                mov     @r0,#tmr_per_sec
                dec     r0
                dec     r3
                mov     a,@r0
                djnz    acc,os_tm_skip1
                mov     @r0,#60
                dec     r0
                dec     r3
                mov     a,@r0
                djnz    acc,os_tm_skip1
                dec     timer_no
                inc     r0
                inc     r0
                mov     r3,#4
os_tm_lp2:      mov     a,@r1
                mov     @r0,a
                dec     r0
                dec     r1
                djnz    r3,os_tm_lp2
                sjmp    os_tm_skip2
os_tm_skip1:    mov     @r0,a
                mov     a,r0
                clr     c
                subb    a,r3
                mov     r0,a
os_tm_skip2:    djnz    r2,os_tm_lp1
                pop     ar3
                pop     ar2
                pop     ar1
                pop     ar0
os_tm_end:      clr     tr0
                mov     a,tl0                   ; 1
                add     a,#low(-tmr0_period+7)  ; 1
                mov     tl0,a                   ; 1
                mov     a,th0                   ; 1
                addc    a,#high(-tmr0_period+7) ; 1
                mov     th0,a                   ; 1
                setb    tr0                     ; 1
                jc      os_tm_again
                pop     acc
                pop     psw
                setb    ea
                reti

rst_wd:         clr     ea
                mov     wd_cnt,#wd_max
                mov     wdtrst,#01eh
                mov     wdtrst,#0e1h
                setb    ea
                ret

; timer id, minutes, seconds, sub-seconds
tmr_int_f:      clr     ea
                pop     dph
                pop     dpl
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r3,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r4,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r5,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r6,a
                push    dpl
                push    dph
                sjmp    ti_entry_f

; a=timer id  r4=minutes  r5=seconds  r6=sub-seconds
tmr_int:        clr     ea
                mov     r3,a
ti_entry_f:     inc     r6
                inc     r5
                inc     r4
                djnz    r6,ti_adj
                mov     r6,#tmr_per_sec
                djnz    r5,ti_adj
                mov     r5,#60
                djnz    r4,ti_adj
                sjmp    zt_entry_ti
ti_adj:         mov     r0,#timer_table
                mov     a,timer_no
                jz      ti_ok
                mov     r1,a
ti_lp:          mov     a,@r0
                xrl     a,r3
                jz      ti_wr
                inc     r0
                inc     r0
                inc     r0
                inc     r0
                djnz    r1,ti_lp
                mov     a,timer_no
                xrl     a,#no_of_timers
                jz      ti_ret
ti_ok:          inc     timer_no
                mov     a,r3
                mov     @r0,a
ti_wr:          inc     r0
                mov     a,r4
                mov     @r0,a
                inc     r0
                mov     a,r5
                mov     @r0,a
                inc     r0
                mov     a,r6
                mov     @r0,a
ti_ret:         setb    ea
                ret

; a=timer id
zro_tmr:        clr     ea
                mov     r3,a
zt_entry_ti:    mov     r0,#timer_table
                mov     a,timer_no
                jz      zt_ret
                mov     r2,a
zt_lp1:         mov     a,@r0
                xrl     a,r3
                jz      zt_found
                inc     r0
                inc     r0
                inc     r0
                inc     r0
                djnz    r2,zt_lp1
zt_ret:         setb    ea
                ret
zt_found:       mov     a,timer_no
                rl      a
                rl      a
                add     a,#timer_table-4
                mov     r1,a
                mov     r2,#4
zt_lp2:         mov     a,@r1
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,zt_lp2
                dec     timer_no
                setb    ea
                ret

; a=timer id  c=timer is zero
tmr_zro:        clr     ea
                mov     r3,a
                mov     r0,#timer_table
                mov     a,timer_no
                jz      tz_yes
                mov     r1,a
tz_lp:          mov     a,@r0
                xrl     a,r3
                jz      tz_no
                inc     r0
                inc     r0
                inc     r0
                inc     r0
                djnz    r1,tz_lp
tz_yes:         setb    c
                setb    ea
                ret
tz_no:          clr     c
                setb    ea
                ret

; a=timer id  r4=minutes  r5=seconds  r6=sub-seconds
get_tmr:        clr     ea
                mov     r3,a
                mov     r0,#timer_table
                mov     a,timer_no
                jz      gt_zero
                mov     r1,a
gt_lp:          mov     a,@r0
                xrl     a,r3
                jz      gt_found
                inc     r0
                inc     r0
                inc     r0
                inc     r0
                djnz    r1,gt_lp
gt_zero:        clr     a
                mov     r4,a
                mov     r5,a
                mov     r6,a
                setb    ea
                ret
gt_found:       inc     r0
                mov     a,@r0
                mov     r4,a
                inc     r0
                mov     a,@r0
                mov     r5,a
                inc     r0
                mov     a,@r0
                mov     r6,a
                cjne    a,#tmr_per_sec,gt_skip1
                mov     r6,#0
                mov     a,r5
                cjne    a,#60,gt_skip2
                mov     r5,#0
                sjmp    gt_done
gt_skip1:       dec     r5
gt_skip2:       dec     r4
gt_done:        setb    ea
                ret

wait4it_f:      clr     ea
                pop     dph
                pop     dpl
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r3,a
                mov     r7,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r4,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r5,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r6,a
                push    dpl
                push    dph
                call    ti_entry_f
w4if_lp:        push    ar7
                call    do_them
                pop     ar7
                mov     a,r7
                call    tmr_zro
                jnc     w4if_lp
                ret

wait4it:        mov     r7,a
                call    tmr_int
w4i_lp:         push    ar7
                call    do_them
                pop     ar7
                mov     a,r7
                call    tmr_zro
                jnc     w4i_lp
                ret
