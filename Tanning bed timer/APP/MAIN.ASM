; version 1.0

vypni_svetlo:   call    tmr_int_f
                db      t_svetlo,1,0,0
                setb    lites_off
                clr     svetlo
                ret

initial_thread: setb    ready
                setb    k1
                setb    k2
                clr     svetlo
                mov     p2,#0ffh
                call    cs_enter_0

                mov     dptr,#commander
                call    run_it
                mov     dptr,#display
                call    run_it
                ;mov     dptr,#touch_key
                ;call    run_it
                setb    data_bit
                clr     k_access

main_main_lp:   call    do_them       
                call    check_state
                jnb     lites_off,mm_skip1
                mov     a,#t_svetlo
                call    tmr_zro
                jnc     mm_skip1
                clr     lites_off
                setb    svetlo
mm_skip1:       mov     a,#t_vstupy
                call    tmr_zro
                jnc     mm_skip2
                call    tmr_int_f
                db      t_vstupy,0,0,1
                call    read_inputs
mm_skip2:       jmp     main_main_lp

read_inputs:    mov     a,p2
                mov     c,ready
                mov     acc.7,c
                cpl     a
                mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
                mov     @r1,a
                inc     r1
                xch     a,@r0
                inc     r0
                mov     @r1,a
                inc     r1
                xch     a,@r0
                inc     r0
                mov     @r1,a
                xch     a,@r0
                inc     r0
                xch     a,@r0
                inc     r0
                mov     @r0,a
                mov     inputs,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
do_maj5_lp:     mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     inputs,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp
                ret

cs_enter_1:     mov     state,#1
                mov     a,#t_state
                mov     r4,time1
                mov     r5,time1+1
                mov     r6,#0
                call    tmr_int
                clr     u_start
                clr     u_stop
                setb    k1
                setb    k2
                ret

cs_enter_2:     mov     state,#2
                call    add_total_time2
                mov     a,#t_state
                mov     r4,time2
                mov     r5,time2+1
                mov     r6,#0
                call    tmr_int
                clr     u_start
                clr     u_stop
                clr     k1
                clr     k2
                ret

cs_enter_3_stop:
                call    sub_total_time2
cs_enter_3:     setb    w_total1
                setb    w_total2
                mov     state,#3
                mov     a,#t_state
                mov     r4,time3
                mov     r5,time3+1
                mov     r6,#0
                call    tmr_int
                clr     u_start
                clr     u_stop
                setb    k1
                clr     k2
                ret

check_state:    mov     a,state
                jnz     cs_try_1
                setb    k1
                setb    k2
                jb      u_start,cs_enter_1
                ret
cs_try_1:       cjne    a,#1,cs_try_2
                setb    k1
                setb    k2
                clr     svetlo
                jb      u_stop,cs_enter_0
                jb      k_ready,cs_enter_2
                mov     a,#t_state
                call    tmr_zro
                jc      cs_enter_2
                ret
cs_try_2:       cjne    a,#2,cs_try_3
                clr     k1
                clr     k2
                clr     svetlo
                jb      u_stop,cs_enter_3_stop
                mov     a,#t_state
                call    tmr_zro
                jc      cs_enter_3
                ret
cs_try_3:       cjne    a,#3,cs_enter_0
                setb    k1
                clr     k2
                clr     svetlo
                mov     a,#t_state
                call    tmr_zro
                jc      cs_enter_0
cs_ret:         ret

cs_enter_0:     mov     state,#0
                clr     u_start
                clr     u_stop
                setb    k1
                setb    k2
                jmp     vypni_svetlo

add_total_time2:
                mov     a,total1+4
                add     a,time2+1
                mov     total1+4,a
                clr     c
                subb    a,#60
                jc      att_skip1
                mov     total1+4,a
att_skip1:      cpl     c
                mov     a,total1+3
                addc    a,time2
                mov     total1+3,a
                clr     c
                subb    a,#60
                jc      att_skip2
                mov     total1+3,a
att_skip2:      cpl     c
                mov     a,total1+2
                addc    a,#0
                mov     total1+2,a
                clr     c
                subb    a,#100
                jc      att_skip3
                mov     total1+2,a
att_skip3:      cpl     c
                mov     a,total1+1
                addc    a,#0
                mov     total1+1,a
                clr     c
                subb    a,#100
                jc      att_skip4
                mov     total1+1,a
att_skip4:      cpl     c
                mov     a,total1
                addc    a,#0
                mov     total1,a
                clr     c
                subb    a,#100
                jc      att_skip5
                mov     total1,a
att_skip5:

                mov     a,total2+4
                add     a,time2+1
                mov     total2+4,a
                clr     c
                subb    a,#60
                jc      att_skip6
                mov     total2+4,a
att_skip6:      cpl     c
                mov     a,total2+3
                addc    a,time2
                mov     total2+3,a
                clr     c
                subb    a,#60
                jc      att_skip7
                mov     total2+3,a
att_skip7:      cpl     c
                mov     a,total2+2
                addc    a,#0
                mov     total2+2,a
                clr     c
                subb    a,#100
                jc      att_skip8
                mov     total2+2,a
att_skip8:      cpl     c
                mov     a,total2+1
                addc    a,#0
                mov     total2+1,a
                clr     c
                subb    a,#100
                jc      att_skip9
                mov     total2+1,a
att_skip9:      cpl     c
                mov     a,total2
                addc    a,#0
                mov     total2,a
                clr     c
                subb    a,#100
                jc      att_skip10
                mov     total2,a
att_skip10:     ret

sub_total_time2:
                mov     a,#t_state
                call    get_tmr
                mov     a,total1+4
                clr     c
                subb    a,r5
                mov     total1+4,a
                jnc     stt_skip1
                add     a,#60
                mov     total1+4,a
stt_skip1:      mov     a,total1+3
                subb    a,r4
                mov     total1+3,a
                jnc     stt_skip2
                add     a,#60
                mov     total1+3,a
stt_skip2:      mov     a,total1+2
                subb    a,#0
                mov     total1+2,a
                jnc     stt_skip3
                add     a,#100
                mov     total1+2,a
stt_skip3:      mov     a,total1+1
                subb    a,#0
                mov     total1+1,a
                jnc     stt_skip4
                add     a,#100
                mov     total1+1,a
stt_skip4:      mov     a,total1
                subb    a,#0
                mov     total1,a
                jnc     stt_skip5
                add     a,#100
                mov     total1,a
stt_skip5:

                mov     a,total2+4
                clr     c
                subb    a,r5
                mov     total2+4,a
                jnc     stt_skip6
                add     a,#60
                mov     total2+4,a
stt_skip6:      mov     a,total2+3
                subb    a,r4
                mov     total2+3,a
                jnc     stt_skip7
                add     a,#60
                mov     total2+3,a
stt_skip7:      mov     a,total2+2
                subb    a,#0
                mov     total2+2,a
                jnc     stt_skip8
                add     a,#100
                mov     total2+2,a
stt_skip8:      mov     a,total2+1
                subb    a,#0
                mov     total2+1,a
                jnc     stt_skip9
                add     a,#100
                mov     total2+1,a
stt_skip9:      mov     a,total2
                subb    a,#0
                mov     total2,a
                jnc     stt_skip10
                add     a,#100
                mov     total2,a
stt_skip10:     ret
