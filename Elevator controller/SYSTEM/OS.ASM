; version 4.2

; th_initial: a thread data table about thread to be run first
;
; a thread data table: information about a thread (code memory)
;  +0: code start address hi byte
;  +1: code start address lo byte
;  +2: stack start address hi byte
;  +3: stack start address lo byte
;  +4: thread id
;  +5: memory locations to save (see below)
;  +6: how much stack is reserved
;
; thread_save: memory locations to save (saved automatically: dps, psw)
;  |   |   |   | 35-34 | 33-32 |   |   | 15-8 |
;
; thread_table: stack allocation for each active thread (movx memory)
;  +0: thread id
;  +1: base of stack segment lo byte
;  +2: base of stack segment hi byte
;  +3: size of stack segment
;  +4: current stack pointer lo byte    <- thread_dph/dpl
;  +5: current stack pointer hi byte
;  +6: watchdog counter
;
; timer_table: current values of timers (movx memory)
;  +0: minutes
;  +1: seconds
;  +2: sub-seconds
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

ck_pred         equ     11011111b
ck_po           equ     11011001b

                dseg
thread_save:    ds      1       ; locations to save for running thread
thread_dpl:     ds      1       ;
thread_dph:     ds      1       ; these three are for speeding up do_them
thread_cnt:     ds      1       ;
thread_id:      ds      1       ; id of currently running thread
thread_wd:      ds      1       ; thread watchdog counter
thread_no:      ds      1       ; number of active threads
os_rst_src:     ds      1       ; source of reset
;tmr_lo:         ds      1       ; used for timer capture
;tmr_hi:         ds      1       ;

                xseg
thread_table:   ds      no_of_threads*7
data_table:     ds      no_of_data

                cseg
random:         mov     a,tl0
                xrl     a,tl1
                xrl     a,sp
                xrl     a,psw
                xrl     a,dpl
                xrl     a,dph
                xrl     a,b
                ret

reset_watchdog: mov     thread_wd,#0
                mov     ta,#0aah
                mov     ta,#055h
                orl     wdcon,#1
                ret
                
starting_point: clr     ea
                clr     a
                mov     r0,#0ffh
os_zero_lp:     mov     @r0,a
                djnz    r0,os_zero_lp

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
                mov     dps,#0
                clr     a
                mov     dpx,a
                mov     dpx1,a
                anl     psw,#11100111b
                mov     dptr,#data_table
                movx    @dptr,a
                mov     thread_no,a
                mov     dptr,#th_initial
                jmp     os_st_entry

; dptr0 -> thread data
run_it:         clr     ea
                push    psw
                setb    f0
                sjmp    os_dt_entry

; voluntary context switch
do_them:        clr     ea
                push    psw
                clr     f0
os_dt_entry:    push    dps
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
                jnb     f0,os_dt_normal
                ; add a new thread
os_st_entry:    clr     a
                mov     dps,a
                movc    a,@a+dptr
                mov     r1,a        ; r1r0 = code start
                mov     a,#1
                movc    a,@a+dptr
                mov     r0,a
                mov     a,#2
                movc    a,@a+dptr
                mov     r3,a        ; r3r2 = stack start
                mov     a,#3
                movc    a,@a+dptr
                mov     r2,a
                mov     a,#4
                movc    a,@a+dptr
                mov     thread_id,a
                mov     a,#5
                movc    a,@a+dptr
                mov     thread_save,a
                mov     a,#6
                movc    a,@a+dptr
                mov     r4,a        ; r4 = how much stack is reserved
                mov     dptr,#thread_table
                mov     a,thread_no
                mov     thread_cnt,a
                jz      os_st_add
os_st_lp1:      movx    a,@dptr
                xrl     a,thread_id
                jz      os_st_found
                mov     a,#7
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    thread_cnt,os_st_lp1
os_st_add:      inc     thread_no
                mov     thread_cnt,#1
os_st_found:    mov     a,thread_id
                movx    @dptr,a
                inc     dptr
                mov     a,r2
                movx    @dptr,a
                inc     dptr
                mov     a,r3
                movx    @dptr,a
                inc     dptr
                mov     a,r4
                movx    @dptr,a
                inc     dptr
                mov     thread_dpl,dpl
                mov     thread_dph,dph
                mov     thread_wd,#0
                mov     sp,r2
                mov     esp,r3
                pop     acc
                clr     a
                push    ar0
                push    ar1
                push    acc
                setb    ea
                ret
                ; switch to next thread
os_dt_lp:       movx    @dptr,a
os_dt_normal:   inc     dptr
                djnz    thread_cnt,os_not_last
os_ki_entry:    mov     a,thread_no
                jz      reset_mcu
                mov     thread_cnt,a
                mov     dptr,#thread_table
os_not_last:    movx    a,@dptr
                mov     thread_id,a
                inc     dptr
                inc     dptr
                inc     dptr
                inc     dptr
                mov     thread_dpl,dpl1
                mov     thread_dph,dph1
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
                ret

reset_mcu:      clr     ea
                anl     ckcon,#03fh
                mov     ta,#0aah
                mov     ta,#055h
                orl     wdcon,#3
                jmp     $

; a = thread id
is_thread_on:   push    ar0
                push    ar1
                mov     r0,a
                mov     a,thread_no
                jz      ito_ret
                mov     r1,a
                clr     a
                mov     dps,a
                mov     dpx,a
                mov     dptr,#thread_table
ito_lp:         movx    a,@dptr
                xrl     a,r0
                jz      ito_yes
                mov     a,#7
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    r1,ito_lp
                clr     a
                sjmp    ito_ret
ito_yes:        mov     a,#0ffh
ito_ret:        pop     ar1
                pop     ar0
                ret
                
; dptr0 -> null terminated list of ids of threads to kill
kill_em:        clr     a
                mov     dps,a
                mov     dpx,a
                mov     r7,a
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
                
; a = thread to kill
kill_me:        mov     a,thread_id
kill_it:        mov     r0,a
                call    is_thread_on
                jz      os_ki_ret
                mov     a,thread_no
                dec     a
                mov     thread_no,a
                mov     b,#7
                mul     ab
                add     a,#low(thread_table)
                mov     dpl1,a
                mov     a,b
                addc    a,#high(thread_table)
                mov     dph1,a
                mov     dpx1,#0
                mov     dps,#00100101b
                mov     r1,#7
os_ki_lp1:      movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r1,os_ki_lp1
                mov     a,r0
                call    delete_messages
                mov     a,thread_id
                call    is_thread_on
                jz      os_ki_skip1
                mov     a,#4
                add     a,dpl
                mov     thread_dpl,a
                clr     a
                addc    a,dph
                mov     thread_dph,a
                mov     thread_cnt,#1
os_ki_ret:      ret
os_ki_skip1:    anl     psw,#11100111b
                mov     dps,#5
                clr     ea
                jmp     os_ki_entry
