; version 4.0

; initial_thread: a thread data table about thread to be run first
;
; a thread data table: information about a thread (code memory)
;  +0: starting address hi byte
;  +1: starting address lo byte
;  +2: thread id
;  +3: memory locations to save (see below)
;  +4: how much stack to reserve
;
; thread_save: memory locations to save (saved automatically: dps, psw)
;  |   |   |   | 35-34 | 33-32 |   |   | 15-8 |
;
; thread_table: stack allocation for each active thread (movx memory)
;  +0: thread id
;  +1: base of stack segment lo byte
;  +2: base of stack segment hi byte
;  +3: size of stack segment
;  +4: current stack pointer lo byte
;  +5: current stack pointer hi byte
;  +6: watchdog counter
;
; timer_table: current values of timers (movx memory)
;  +0: thread id
;  +1: timer id
;  +2: minutes
;  +3: seconds
;  +4: sub-seconds
;
; an event data table: responses to events (code memory)
;  +0: a non-zero value here terminates list
;  +1: message id
;  +2: address of routine hi byte
;  +3: address of routine lo byte
;
; data_table: null terminated list of messages (movx memory)
;  +0: offset of next entry
;  +1: thread id
;  +2: message id
;  +3: optional data

os_bank1        equ     1
os_bits0        equ     8
os_bits1        equ     16

r_              equ     1*256
j_              equ     2*256
c_              equ     3*256

ck_pred         equ     11000111b
ck_po           equ     11000001b

                dseg
thread_save:    ds      1       ; locations to save for running thread
thread_dpl:     ds      1       ;
thread_dph:     ds      1       ; these three are for speeding up do_them
thread_cnt:     ds      1       ;
thread_id:      ds      1       ; id of currently running thread
thread_wd:      ds      1       ; thread watchdog counter
thread_no:      ds      1       ; number of active threads
timer_no:       ds      1       ; number of running timers
os_rst_src:     ds      1       ; source of reset

                xseg
thread_table:   ds      no_of_threads*7
timer_table:    ds      no_of_timers*5
data_table:     ds      no_of_data

                cseg
starting_point: clr     ea
                clr     a
                jnb     por,os_rst_skip1
                mov     a,#1
os_rst_skip1:   jnb     wtrf,os_rst_skip2
                mov     a,#2
os_rst_skip2:   mov     b,pcon
                jnb     b.5,os_rst_skip3
                mov     a,#3
os_rst_skip3:   mov     os_rst_src,a
os_init:        mov     ie,#0
                mov     ip,#0
                mov     pcon,#00010000b
                mov     ta,#0aah
                mov     ta,#055h
                mov     acon,#5
                mov     ta,#0aah
                mov     ta,#055h
                mov     p5cnt,#7
                mov     ta,#0aah
                mov     ta,#055h
                mov     wdcon,#2
if double_speed
                mov     pmr,#10000111b
                mov     pmr,#10010111b
                mov     r0,#0
os_speed_lp:    mov     a,exif
                jb      acc.3,os_speed_ok
                djnz    r0,os_speed_lp
os_speed_ok:    mov     pmr,#00010111b
else
                mov     pmr,#10000111b
endif
                mov     ckcon,#ck_po
                mov     tcon,#0
                mov     tmod,#1
                mov     tl0,#low(-tmr0_period)
                mov     th0,#high(-tmr0_period)
                setb    tr0
                setb    et0
                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                anl     psw,#11100111b
                mov     dptr,#data_table
                movx    @dptr,a
                mov     thread_no,a
                mov     timer_no,a
                mov     dptr,#initial_thread
                jmp     os_st_entry

; dptr0 -> thread data
run_it:         clr     ea
                push    psw
                push    dps
                push    dpx
                push    dpx1
                mov     a,thread_save
                jnb     acc.0,os_ri_s0
                push    8
                push    9
                push    10
                push    11
                push    12
                push    13
                push    14
                push    15
os_ri_s0:       jnb     acc.3,os_ri_s3
                push    32
                push    33
os_ri_s3:       jnb     acc.4,os_ri_s4
                push    34
                push    35
os_ri_s4:       push    acc
                mov     dps,#5
                clr     a
                mov     dpx,a
                mov     dpx1,a
                anl     psw,#11100111b
                mov     dpl1,thread_dpl
                mov     dph1,thread_dph
                mov     a,sp
                movx    @dptr,a
                inc     dptr
                mov     a,esp
                anl     a,#3
                movx    @dptr,a
                inc     dptr
                mov     a,thread_wd
                movx    @dptr,a
                mov     dps,#4

; r0=counter, r1=stack requested
; r3r2=bottom of window
; r5r4=bottom of window+r1
; r7r6=top of window
os_st_entry:    clr     a
                movc    a,@a+dptr
                mov     thread_dph,a
                mov     a,#1
                movc    a,@a+dptr
                mov     thread_dpl,a
                mov     a,#2
                movc    a,@a+dptr
                mov     thread_id,a
                mov     a,#3
                movc    a,@a+dptr
                mov     thread_save,a
                mov     b,a
                mov     a,#4
                movc    a,@a+dptr
                add     a,#3+3+5+9      ; int+call+push+os_user_int
                jnb     b.0,os_st_0
                add     a,#8
os_st_0:        jnb     b.3,os_st_3
                add     a,#2
os_st_3:        jnb     b.4,os_st_4
                add     a,#2
os_st_4:        mov     thread_cnt,a
                mov     r1,a
                mov     r4,a
                clr     a
                mov     r2,a
                mov     r3,a
                mov     r5,a
                mov     dptr,#thread_table
                mov     a,thread_no
                mov     r0,a
                jz      os_st_finish
os_st_lp1:      inc     dptr
                movx    a,@dptr
                inc     dptr
                mov     r6,a
                clr     c
                subb    a,r4
                movx    a,@dptr
                mov     r7,a
                subb    a,r5
                jc      os_st_skip
                mov     dps,#01000100b
                inc     dptr
                inc     dptr
                mov     dps,#4
                sjmp    os_st_finish
os_st_skip:     inc     dptr
                movx    a,@dptr
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                add     a,r6
                mov     r4,a
                mov     r2,a
                clr     a
                addc    a,r7
                mov     r5,a
                mov     r3,a
                mov     a,r1
                add     a,r4
                mov     r4,a
                clr     a
                addc    a,r5
                mov     r5,a
                djnz    r0,os_st_lp1
                clr     c
                subb    a,#4
                jnc     os_st_rebuild
os_st_finish:   inc     thread_no
                mov     thread_cnt,#1
                mov     r4,thread_id
                mov     sp,r2
                mov     esp,r3
                pop     acc
                clr     a
                push    thread_dpl
                push    thread_dph
                push    acc
                mov     a,dpl
                add     a,#4
                mov     thread_dpl,a
                clr     a
                addc    a,dph
                mov     thread_dph,a
                clr     a
                mov     r7,a
                mov     thread_wd,a
                inc     r0
os_st_lp2:      movx    a,@dptr
                xch     a,r4
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r2
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r3
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r1
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r5
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r6
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                xch     a,r7
                movx    @dptr,a
                inc     dptr
                djnz    r0,os_st_lp2
                setb    ea
                reti

; r7r6=start of segment
; r3r2=sum of sizes, r5r4=-(r7r6-r3r2)
os_st_rebuild:  mov     dptr,#thread_table
                clr     a
                mov     r2,a
                mov     r3,a
                cpl     a
                mov     sp,a
                mov     esp,a
                mov     r0,thread_no
os_st_lp3:      inc     dptr
                movx    a,@dptr
                mov     r6,a
                mov     dpl1,a
                mov     a,r2
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                mov     r7,a
                orl     a,#0f0h
                mov     dph1,a
                mov     a,r3
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                inc     dptr
                mov     r1,a
                mov     a,r2
                clr     c
                subb    a,r6
                mov     r4,a
                mov     a,r3
                subb    a,r7
                mov     r5,a
                movx    a,@dptr
                add     a,r4
                movx    @dptr,a
                inc     dptr
                movx    a,@dptr
                addc    a,r5
                movx    @dptr,a
                inc     dptr
                inc     dptr
                mov     a,r2
                add     a,r1
                mov     r2,a
                clr     a
                addc    a,r3
                mov     r3,a
                mov     dps,#5
os_st_lp4:      movx    a,@dptr
                inc     dptr
                push    acc
                djnz    r1,os_st_lp4
                mov     dps,#4
                djnz    r0,os_st_lp3
                mov     r1,thread_cnt
                jmp     os_st_finish

do_them:        clr     ea
                push    psw
                push    dps
                push    dpx
                push    dpx1
                mov     a,thread_save
                jnb     acc.0,os_dt_s0
                push    8
                push    9
                push    10
                push    11
                push    12
                push    13
                push    14
                push    15
os_dt_s0:       jnb     acc.3,os_dt_s3
                push    32
                push    33
os_dt_s3:       jnb     acc.4,os_dt_s4
                push    34
                push    35
os_dt_s4:       push    acc
                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                anl     psw,#11100111b
                mov     dpl,thread_dpl
                mov     dph,thread_dph
                mov     a,sp
                movx    @dptr,a
                inc     dptr
                mov     a,esp
                anl     a,#3
                movx    @dptr,a
                inc     dptr
                mov     a,thread_wd
os_dt_lp:       movx    @dptr,a
                inc     dptr
                djnz    thread_cnt,os_not_last
os_ki_entry:    mov     thread_cnt,thread_no
                mov     dptr,#thread_table
os_not_last:    movx    a,@dptr
                mov     thread_id,a
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                mov     thread_dpl,dpl
                mov     thread_dph,dph
                movx    a,@dptr
                mov     sp,a
                inc     dptr
                movx    a,@dptr
                mov     esp,a
                inc     dptr
                movx    a,@dptr
                clr     c
                subb    a,#os_wd1
                jnc     os_dt_lp
                clr     a
                movx    @dptr,a
                mov     thread_wd,a
                pop     acc
                jnb     acc.4,os_dt_l4
                pop     35
                pop     34
os_dt_l4:       jnb     acc.3,os_dt_l3
                pop     33
                pop     32
os_dt_l3:       jnb     acc.0,os_dt_l0
                pop     15
                pop     14
                pop     13
                pop     12
                pop     11
                pop     10
                pop     9
                pop     8
os_dt_l0:       mov     thread_save,a
                pop     dpx1
                pop     dpx
                pop     dps
                pop     psw
                setb    ea
                reti

; b=thread id
del_thread:     mov     dptr,#thread_table
                mov     a,thread_no
                jz      os_dth_ret
                mov     r0,a
                mov     dpl1,dpl
                mov     dph1,dph
os_dth_lp1:     movx    a,@dptr
                cjne    a,b,os_dth_ok
                mov     a,dpl
                add     a,#7
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                dec     thread_no
                sjmp    os_dth_no
os_dth_ok:      mov     dps,#00100100b
                mov     r1,#7
os_dth_lp2:     movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r1,os_dth_lp2
                mov     dps,#4
os_dth_no:      djnz    r0,os_dth_lp1
os_dth_ret:     ret

; b=thread id
del_timers:     mov     dptr,#timer_table
                mov     a,timer_no
                jz      os_dti_ret
                mov     r0,a
                mov     dpl1,dpl
                mov     dph1,dph
os_dti_lp1:     movx    a,@dptr
                cjne    a,b,os_dti_ok
                mov     a,dpl
                add     a,#5
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                dec     timer_no
                sjmp    os_dti_no
os_dti_ok:      mov     dps,#00100100b
                mov     r1,#5
os_dti_lp2:     movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r1,os_dti_lp2
                mov     dps,#4
os_dti_no:      djnz    r0,os_dti_lp1
os_dti_ret:     ret

; b=thread id
del_null:       mov     dps,#00100100b
                mov     dptr,#data_table
                mov     dptr,#data_table
                mov     dps,#4
os_dn_lp1:      movx    a,@dptr
                jz      os_dn_ret
                mov     r2,a
                inc     dptr
os_dn_entry:    movx    a,@dptr
                cjne    a,b,os_dn_copy
                mov     a,r2
                dec     a
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                jmp     os_dn_lp1
os_dn_copy:     mov     dps,#00100101b
                mov     a,r2
os_dn_lp2:      movx    @dptr,a
                movx    a,@dptr
                inc     dptr
                inc     dptr
                djnz    r2,os_dn_lp2
                jz      os_dn_ret
                mov     r2,a
                mov     dps,#4
                jmp     os_dn_entry
os_dn_ret:      mov     dps,#5
                movx    @dptr,a
                mov     dps,#4
                ret

del_msg:        clr     ea
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     b,thread_id
                call    del_null
                setb    ea
                ret

; a=thread to kill
kill_me:        mov     a,thread_id
kill_it:        clr     ea
                mov     b,a
                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                anl     psw,#11100111b
                call    del_thread
                call    del_timers
                call    del_null
                mov     dptr,#thread_table
                mov     r0,thread_no
os_ki_lp:       movx    a,@dptr
                xrl     a,thread_id
                jz      os_ki_found
                mov     a,dpl
                add     a,#7
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r0,os_ki_lp
                jmp     os_ki_entry
os_ki_found:    mov     a,dpl
                add     a,#4
                mov     thread_dpl,a
                clr     a
                addc    a,dph
                mov     thread_dph,a
                mov     thread_cnt,#1
                setb    ea
                ret

; dptr0 -> null terminated kill list
kill_em:        mov     dps,#4
                mov     dpx,#0
                mov     r7,#0
os_ke_lp:       clr     a
                movc    a,@a+dptr
                jz      os_ke_done
                inc     dptr
                cjne    a,thread_id,os_ke_ok
                mov     r7,#0ffh
                jmp     os_ke_lp
os_ke_ok:       push    dpl
                push    dph
                call    kill_it
                pop     dph
                pop     dpl
                jmp     os_ke_lp
os_ke_done:     mov     a,r7
                jnz     kill_me
                ret
