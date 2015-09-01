; version 4.0

timer0_int:     clr     ea
                push    psw
                push    acc
                push    dps
                push    dpl
                push    dph
                push    dpx
                mov     dps,#4
                mov     dpx,#0
                anl     psw,#11100111b
                mov     ta,#0aah
                mov     ta,#055h
                orl     wdcon,#1
os_tm_again:    inc     thread_wd
                mov     a,thread_wd
                add     a,#-os_wd2
                jnc     os_tm_start
                mov     os_rst_src,#4
                jmp     os_init
os_tm_start:    mov     a,timer_no
                jz      os_tm_end
                push    ar0
                push    ar1
                push    dpl1
                push    dph1
                push    dpx1
                mov     r1,a
                rl      a
                rl      a
                add     a,r1
                add     a,#low(timer_table-1)
                mov     dpl,a
                mov     dpl1,a
                clr     a
                addc    a,#high(timer_table-1)
                mov     dph,a
                mov     dph1,a
                mov     dpx1,#0
                mov     dps,#01000100b
os_tm_lp1:      mov     r0,#5
                movx    a,@dptr
                djnz    acc,os_tm_skip1
                mov     a,#tmr_per_sec
                movx    @dptr,a
                inc     dptr
                dec     r0
                movx    a,@dptr
                djnz    acc,os_tm_skip1
                mov     a,#60
                movx    @dptr,a
                inc     dptr
                dec     r0
                movx    a,@dptr
                djnz    acc,os_tm_skip1
                dec     timer_no
                mov     dps,#4
                inc     dptr
                inc     dptr
                mov     dps,#11100101b
                mov     r0,#5
os_tm_lp3:      movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,os_tm_lp3
                mov     dps,#01000100b
                sjmp    os_tm_skip2
os_tm_skip1:    movx    @dptr,a
                mov     a,dpl
                clr     c
                subb    a,r0
                mov     dpl,a
                mov     a,dph
                subb    a,#0
                mov     dph,a
os_tm_skip2:    djnz    r1,os_tm_lp1
                pop     dpx1
                pop     dph1
                pop     dpl1
                pop     ar1
                pop     ar0
                mov     dps,#4
os_tm_end:      clr     tr0
                mov     a,tl0                   ; 8
                add     a,#low(-tmr0_period+5)  ; 8
                mov     tl0,a                   ; 8
                mov     a,th0                   ; 8
                addc    a,#high(-tmr0_period+5) ; 8
                mov     th0,a                   ; 8
                setb    tr0                     ; 8 -> 56/12=4.67
                jnc     os_tm_done
                jmp     os_tm_again
os_tm_done:     pop     dpx
                pop     dph
                pop     dpl
                pop     dps
                pop     acc
                pop     psw
                setb    ea
                reti

random:         mov     a,tl0
                xrl     a,tl1
                xrl     a,sp
                xrl     a,psw
                xrl     a,dpl
                xrl     a,dph
                xrl     a,b
                ret

rst_wd:         mov     thread_wd,#0
                ret

; returns r1r0=captured value of timer0
tmr_capture:    clr     ea
                mov     a,th0
                mov     r1,a
                mov     a,tl0
                mov     r0,a
                mov     a,th0
                xch     a,r1
                xrl     a,r1
                jz      tmr_c_ret
                mov     a,tl0
                mov     r0,a
tmr_c_ret:      setb    ea
                ret

; r1r0=starting time, returns r3r2=elapsed time
tmr_elapsed:    clr     ea
                mov     a,th0
                mov     r3,a
                mov     a,tl0
                mov     r2,a
                mov     a,th0
                xch     a,r3
                xrl     a,r3
                jz      tmr_e_skip
                mov     a,tl0
                mov     r2,a
tmr_e_skip:     clr     c
                mov     a,r2
                subb    a,r0
                mov     r2,a
                mov     a,r3
                subb    a,r1
                mov     r3,a
                jnc     tmr_e_ret
                mov     a,r2
                add     a,#low(tmr0_period)
                mov     r2,a
                mov     a,r3
                addc    a,#high(tmr0_period)
                mov     r3,a
                jc      tmr_e_ret
                clr     a
                mov     r2,a
                mov     r3,a
tmr_e_ret:      setb    ea
                ret

; returns c=(r3r2>r5r4)
tmr_compare:    clr     c
                mov     a,r4
                subb    a,r2
                mov     a,r5
                subb    a,r3
                ret

; thread id, timer id, minutes, seconds, sub-seconds
tmr_int_fs:     clr     ea
                mov     dps,#4
                mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     b,a
                sjmp    tif_entry_s

; timer id, minutes, seconds, sub-seconds
tmr_int_f:      clr     ea
                mov     b,thread_id
                mov     dps,#4
                mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
tif_entry_s:    clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r3,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r0,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r1,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r2,a
                clr     a
                push    dpl
                push    dph
                push    acc
                sjmp    ti_entry_f

; b=thread id  a=timer id  r0=minutes  r1=seconds  r2=sub-seconds
tmr_int_s:      clr     ea
                sjmp    ti_entry_s

; a=timer id  r0=minutes  r1=seconds  r2=sub-seconds
tmr_int:        clr     ea
                mov     b,thread_id
ti_entry_s:     mov     dps,#4
                mov     dpx,#0
                mov     r3,a
ti_entry_f:     inc     r2
                inc     r1
                inc     r0
                djnz    r2,ti_adj
                mov     r2,#tmr_per_sec
                djnz    r1,ti_adj
                mov     r1,#60
                djnz    r0,ti_adj
                mov     a,r3
                jmp     zt_entry_ti
ti_adj:         mov     dptr,#timer_table
                mov     a,timer_no
                jz      ti_ok
                mov     r4,a
ti_lp:          movx    a,@dptr
                inc     dptr
                cjne    a,b,ti_nxt
                movx    a,@dptr
                xrl     a,r3
                jz      ti_wr
ti_nxt:         mov     a,dpl
                add     a,#4
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r4,ti_lp
                mov     a,timer_no
                xrl     a,#no_of_timers
                jz      ti_ret
ti_ok:          inc     timer_no
                mov     a,b
                movx    @dptr,a
                inc     dptr
                mov     a,r3
                movx    @dptr,a
ti_wr:          inc     dptr
                mov     a,r0
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                mov     a,r2
                movx    @dptr,a
ti_ret:         setb    ea
                ret

; b=thread id  a=timer id
zro_tmr_s:      clr     ea
                sjmp    zt_entry_s

; a=timer id
zro_tmr:        clr     ea
                mov     b,thread_id
zt_entry_s:     mov     dps,#4
                mov     dpx,#0
zt_entry_ti:    mov     dptr,#timer_table
                mov     r0,a
                mov     a,timer_no
                jz      zt_ret
                mov     r1,a
zt_lp1:         movx    a,@dptr
                inc     dptr
                cjne    a,b,zt_nxt
                movx    a,@dptr
                xrl     a,r0
                jz      zt_found
zt_nxt:         mov     a,dpl
                add     a,#4
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r1,zt_lp1
zt_ret:         setb    ea
                ret
zt_found:       mov     a,timer_no
                rl      a
                rl      a
                add     a,timer_no
                add     a,#low(timer_table-5)
                mov     dpl1,a
                clr     a
                addc    a,#high(timer_table-5)
                mov     dph1,a
                mov     dpx1,#0
                mov     dps,#01000100b
                inc     dptr
                mov     dps,#00100101b
                mov     r0,#5
zt_lp2:         movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,zt_lp2
                mov     dps,#4
                dec     timer_no
                setb    ea
                ret

; b=thread id  a=timer id  c=timer is zero
tmr_zro_s:      clr     ea
                sjmp    tz_entry_s

; a=timer id  c=timer is zero
tmr_zro:        clr     ea
                mov     b,thread_id
tz_entry_s:     mov     dps,#4
                mov     dpx,#0
                mov     dptr,#timer_table
                mov     r0,a
                mov     a,timer_no
                jz      tz_yes
                mov     r1,a
tz_lp:          movx    a,@dptr
                inc     dptr
                cjne    a,b,tz_nxt
                movx    a,@dptr
                xrl     a,r0
                jz      tz_no
tz_nxt:         mov     a,dpl
                add     a,#4
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r1,tz_lp
tz_yes:         setb    c
                setb    ea
                ret
tz_no:          clr     c
                setb    ea
                ret

if 0
; b=thread id  a=timer id  r0=minutes  r1=seconds  r2=sub-seconds
get_tmr_s:      clr     ea
                sjmp    gt_entry_s

; a=timer id  r0=minutes  r1=seconds  r2=sub-seconds
get_tmr:        clr     ea
                mov     b,thread_id
gt_entry_s:     mov     dps,#4
                mov     dpx,#0
                mov     dptr,#timer_table
                mov     r0,a
                mov     a,timer_no
                jz      gt_zero
                mov     r1,a
gt_lp:          movx    a,@dptr
                inc     dptr
                cjne    a,b,gt_nxt
                movx    a,@dptr
                xrl     a,r0
                jz      gt_found
gt_nxt:         mov     a,dpl
                add     a,#4
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r1,gt_lp
gt_zero:        clr     a
                mov     r0,a
                mov     r1,a
                mov     r2,a
                setb    ea
                ret
gt_found:       inc     dptr
                movx    a,@dptr
                mov     r0,a
                inc     dptr
                movx    a,@dptr
                mov     r1,a
                inc     dptr
                movx    a,@dptr
                mov     r2,a
                cjne    a,#tmr_per_sec,gt_skip1
                mov     r2,#0
                mov     a,r1
                cjne    a,#60,gt_skip2
                mov     r1,#0
                sjmp    gt_done
gt_skip1:       dec     r1
gt_skip2:       dec     r0
gt_done:        setb    ea
                ret
endif

wait4it_f:      clr     ea
                mov     b,thread_id
                mov     dps,#4
                mov     dpx,#0
                pop     acc
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
                mov     r0,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r1,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     r2,a
                clr     a
                push    dpl
                push    dph
                push    acc
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
