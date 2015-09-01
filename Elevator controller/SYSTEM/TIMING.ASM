; version 4.2
                cseg
                
initialize_timers:
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#timer_table
                mov     r0,#no_of_timers
init_tm_lp1:    mov     r1,#timer_size 
init_tm_lp2:    movx    @dptr,a
                inc     dptr
                djnz    r1,init_tm_lp2
                djnz    r0,init_tm_lp1
                
                ; one byte timers
                mov     dptr,#timer_table2
                mov     r0,#no_of_timers2
init_tm_lp3:    movx    @dptr,a
                inc     dptr
                djnz    r0,init_tm_lp3
                ret

decrement_timers:
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#00100100b
                mov     dptr,#timer_table
                mov     dptr,#timer_table
                mov     r0,#no_of_timers
dec_tm_lp1:     mov     dps,#00000100b
                movx    a,@dptr
                inc     dptr
                mov     r3,a
                movx    a,@dptr
                inc     dptr
                mov     r2,a
                movx    a,@dptr
                inc     dptr
                mov     r1,a
                orl     a,r2
                orl     a,r3
                mov     dps,#00000101b
                jz      dec_tm_move3
                
                mov     a,r3
                jnz     dec_tm_dec3
                
                mov     a,#tmr_per_sec-1
                movx    @dptr,a
                inc     dptr
                mov     a,r2
                jnz     dec_tm_dec2
                
                mov     a,#59
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                jz      dec_tm_move1
                dec     a
                movx    @dptr,a
                sjmp    dec_tm_move1
                
dec_tm_dec2:    dec     a
                movx    @dptr,a
                sjmp    dec_tm_move2
                
dec_tm_dec3:    dec     a
                movx    @dptr,a
dec_tm_move3:   inc     dptr
dec_tm_move2:   inc     dptr
dec_tm_move1:   inc     dptr
                djnz    r0,dec_tm_lp1
                mov     dps,#0
                
                ; one byte timers
                mov     dps,#0
                mov     dptr,#timer_table2
                mov     r0,#no_of_timers2
dec_tm_lp2:     movx    a,@dptr
                jz      dec_tm_move4
                dec     a
                movx    @dptr,a
dec_tm_move4:   inc     dptr
                djnz    r0,dec_tm_lp2
                ret

; followed by (in code segment):
; timer address, minutes, seconds, sub-seconds
init_timer_f:   mov     dps,#1
                pop     dpx1
                pop     dph1
                pop     dpl1
                mov     dpx1,#0
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl,a
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
                push    dpl1
                push    dph1
                push    dpx1

; dptr0 -> timer
; r0 = minutes, r1 = seconds, r2 = sub-seconds
; preserves dptr0
init_timer:     clr     a
                mov     dps,a
                mov     dpx,a
                mov     a,r2
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                mov     a,r0
                movx    @dptr,a
                mov     dps,#01000100b
                inc     dptr
                inc     dptr
                mov     dps,#0
                ret

; dptr0 -> timer
; r2 = sub-seconds
; preserves dptr0
init_timer2:    clr     a
                mov     dps,a
                mov     dpx,a
                mov     a,r2
                movx    @dptr,a
                ret
                
; followed by (in code segment): 
; timer address
timer_running_f:
                mov     dps,#1
                pop     dpx1
                pop     dph1
                pop     dpl1
                mov     dpx1,#0
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl,a
                push    dpl1
                push    dph1
                push    dpx1
                
; dptr0 -> timer
; returns acc = timer is non-zero = running
; preserves dptr0
timer_running:  clr     a
                mov     dps,a
                mov     dpx,a
                movx    a,@dptr
                jnz     tmr_r_move0
                inc     dptr
                movx    a,@dptr
                jnz     tmr_r_move1
                inc     dptr
                movx    a,@dptr
                mov     dps,#01000100b
                inc     dptr
tmr_r_move1:    mov     dps,#01000100b
                inc     dptr
                mov     dps,#0
tmr_r_move0:    ret

; dptr0 -> timer
; returns acc = timer is non-zero = running
; preserves dptr0
timer_running2: clr     a
                mov     dps,a
                mov     dpx,a
                movx    a,@dptr
                ret

; followed by (in code segment):
; timer address, minutes, seconds, sub-seconds
wait_for_timer_f:
                mov     dps,#1
                pop     dpx1
                pop     dph1
                pop     dpl1
                mov     dpx1,#0
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl,a
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
                push    dpl1
                push    dph1
                push    dpx1

; dptr0 -> timer
; r0 = minutes, r1 = seconds, r2 = sub-seconds
; preserves dptr0
wait_for_timer: call    init_timer
w4t_lp:         push    dpl
                push    dph
                call    do_them
                pop     dph
                pop     dpl
                call    timer_running
                jnz     w4t_lp
                ret

; followed by (in code segment):
; timer address
; minutes, seconds, sub-seconds
; returns acc = timer was zero and got reloaded
; preserves dptr0
timer_running_reload_f:
                mov     dps,#1
                pop     dpx1
                pop     dph1
                pop     dpl1
                mov     dpx1,#0
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl,a
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
                push    dpl1
                push    dph1
                push    dpx1

                call    timer_running
                jnz     tzrf_ret
                call    init_timer
                clr     a
tzrf_ret:       ret
