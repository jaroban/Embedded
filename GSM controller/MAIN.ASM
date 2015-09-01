; version 1.0

initial_thread: mov     p0,#0
                mov     p1,#0ffh
                mov     p2,#0ffh
                mov     p3,#0ffh
                ;clr     lift
                call    switch_out
                call    serial_init
                call    turn_gsm_on
if testing
$include(testing.asm)
else
                ;clr     lift
                call    board_ok
                call    switch_out
                call    puts_nf
                db      ' again again ',0       ; have board resend data

                ;setb    lift
                ;call    board_ok
                ;call    switch_out
                ;call    puts_nf
                ;db      ' again again ',0       ; have board resend data

                mov     gsm_cnt,#2

                mov     state1,#st_disabled
                ;mov     state2,#st_disabled

                clr     get_signal
                clr     send_reset
                clr     send_status
                clr     low_voltage_sent
                mov     low_v_cnt,#0

                call    switch_gsm

                call    wait4it_f
                db      t_wait,0,5,0
                
                mov     wait_cnt,#5
mi_lpff:        call    puts_nf
                db      'AT+IPR=9600',cr,0      ; set baud rate to 9600
                call    wait_for_ok
                jnc     mi_lpff

                mov     wait_cnt,#3
mi_lp0:         call    puts_nf
                db      'AT+CFUN=1',cr,0        ; make sure power stays on
                call    wait_for_ok
                jnc     mi_lp0

                mov     wait_cnt,#3
mi_lp1:         call    puts_nf
                db      'ATE0',cr,0             ; turn off echo
                call    wait_for_ok
                jnc     mi_lp1

                mov     wait_cnt,#3
mi_lp2:         call    puts_nf
                db      'ATS0=3',cr,0           ; auto-answer calls after
                call    wait_for_ok             ;  three rings
                jnc     mi_lp2

                mov     wait_cnt,#3
mi_lp3:         call    puts_nf
                db      'AT+CPBS="SM"',cr,0     ; phone book on sim card
                call    wait_for_ok
                jnc     mi_lp3

                mov     wait_cnt,#3
mi_lp4:         call    puts_nf
                db      'AT+CMGF=1',cr,0        ; sms text mode
                call    wait_for_ok
                jnc     mi_lp4

                mov     wait_cnt,#3
mi_lp5:         call    puts_nf
                db      'AT&W',cr,0             ; store configuration
                call    wait_for_ok
                jnc     mi_lp5

                ; turn on output thread
                mov     thread_id,#'m'
                mov     dptr,#th_outputs
                call    run_it
                
                ; normal, reading from gsm module
main_init1:     call    switch_gsm
                call    tmr_int_f
                db      t_switch,0,3,0
                call    clear_fifos
                jnb     get_signal,main_lp1
                clr     get_signal
                call    read_signal
                jmp     main_init3

main_lp1:       ; big state-machine (read external inputs)
                ;setb    lift
ml1_again:      call    do_them

                mov     a,#3
                call    trace


ml1_button2:    call    lift_on
                jc      ml1_stm_skip1
                mov     a,#st_disabled
                call    store_state

ml1_stm_skip1:  call    get_state
                cjne    a,#st_disabled,ml1_try1
                call    lift_on
                jc      ml1_t0_skip1
                jmp     ml1_drain1
ml1_t0_skip1:   call    switch_out
                call    puts_nf
                db      ' again again ',0       ; have board resend data
                call    switch_gsm
                call    read_name_str
                mov     a,#st_ok
                jmp     ml1_store

ml1_try1:       cjne    a,#st_ok,ml1_try2
                call    is_board_ok
                jc      ml1_drain1
                mov     a,#st_dead
                call    store_state
                call    send_sms1
                jmp     ml1_drain1

ml1_try2:       cjne    a,#st_dead,ml1_try3
                call    is_board_ok
                jnc     ml1_t2_skip2
                ;call    send_sms2
                mov     a,#st_ok
                jmp     ml1_store
ml1_t2_skip2:   call    read_button
                jnc     ml1_drain1
                mov     a,#st_dialling
                call    store_state
                call    tmr_int_f
                db      t_no_call,3,0,0
                jmp     ml1_dial

ml1_try3:       mov     a,#t_no_call
                call    tmr_zro
                jc      ml1_go_dead
                call    is_board_ok
                jnc     ml1_drain1
                mov     a,#st_ok
                sjmp    ml1_store
ml1_go_dead:    mov     a,#st_dead

ml1_store:      call    store_state
ml1_drain1:     ;jnb     lift,ml1_drain2
                ;clr     lift
                ;jmp     ml1_again
;ml1_drain2:

                mov     a,#4
                call    trace

                ; send low voltage sms-es?
                mov     a,#t_low_v
                call    tmr_zro
                jnc     ml1_v_drain
                
                ; check every x seconds
                call    tmr_int_f
                db      t_low_v,1,0,0
                
                ; |count| > limit?
                mov     a,low_v_cnt
                jnb     acc.7,ml1_v_pos
                cpl     a
                inc     a
ml1_v_pos:      clr     c
                subb    a,#60
                jc      ml1_v_both
                
                ; |count| > limit
                ; count > 0 ?
                mov     a,low_v_cnt
                jnb     acc.7,ml1_v_send_lo
                
                ; send ok sms
                jnb     low_voltage_sent,ml1_v_inc
                clr     low_voltage_sent
                ;call    send_sms4
                sjmp    ml1_v_drain

                ; send low v sms
ml1_v_send_lo:  jb      low_voltage_sent,ml1_v_dec
                setb    low_voltage_sent
                ;call    send_sms3
                sjmp    ml1_v_drain

ml1_v_both:     jb      low_voltage,ml1_v_inc

ml1_v_dec:      jb      low_voltage,ml1_v_drain
                dec     low_v_cnt
                sjmp    ml1_v_drain

ml1_v_inc:      jnb     low_voltage,ml1_v_drain
                inc     low_v_cnt

ml1_v_drain:    mov     a,#5
                call    trace

                ; unsolicited stuff from gsm?
                call    read_serial
                jnc     ml1_skip1
                ;call    tmr_int_f
                ;db      t_switch,0,3,0
                call    find_nf
                db      'RING',0
                jnc     ml1_no_call
                call    puts_nf
                db      'ATA',cr,0
                jmp     ml1_ongoing_call

ml1_no_call:    call    find_nf
                db      '+CMTI: "SM", #',0
                jnc     ml1_skip1
                mov     a,@r0
                mov     tmp1,a
                call    check_sms

                mov     a,#6
                call    trace

ml1_skip1:      mov     a,#t_switch
                call    tmr_zro
                jc      ml1_skip2
                jmp     main_lp1
ml1_skip2:      djnz    gsm_cnt,main_init3
                mov     gsm_cnt,#2
                jmp     main_poll_gsm

                ; normal, reading from board(s)
main_init3:     ;setb    lift

                mov     a,#7
                call    trace

ml3_again:      call    switch_out
                call    lift_on
                jnc     ml3_drain
                call    puts_nf
                db      'ok?',0
                mov     a,#3            ; ako casto sa vysiela ok? - pyta sa ci doska je ok
                call    do_events
                db      'ok',0
                dw      ml3_skip1
                db      'dbg',0
                dw      ml3_skip2
                db      'num#',0
                dw      ml3_skip3
                db      'bad',0
                dw      ml3_skip4
                db      0
                call    no_reply
ml3_drain:      ;jbc     lift,ml3_again
                jmp     main_init1
ml3_drain2:     jmp     main_init3

ml3_skip1:      call    board_ok
                jmp     ml3_drain

ml3_skip2:      setb    get_signal
                call    puts_nf
                db      'sig',0
                mov     a,signal
                call    put_byte
                call    board_ok
                jmp     ml3_drain

ml3_skip3:      call    board_ok
                mov     a,@r0
                cjne    a,#'0',ml3_skip3_1
                call    get_name_str
                mov     tmp1,a
                mov     tmp2,#16
                mov     tmp3,#0
                call    read_string
                jnc     ml3_drain2
                call    store_name
                jnc     ml3_drain2
ml3_next:       call    switch_out
                call    puts_nf
                db      'next',0
                jmp     ml3_drain2
ml3_skip3_1:    push    acc
                mov     tmp1,#number_str
                mov     tmp2,#16
                mov     tmp3,#0
                call    read_string
                pop     tmp1
                jnc     ml3_drain2
                mov     r0,#number_str
                mov     r1,#16
                call    string_has_text
                jnc     ml3_next
                call    store_number
                jc      ml3_next
                jmp     ml3_drain2

ml3_skip4:      call    board_bad
                jmp     ml3_drain

                ; less frequently called stuff
check_sms:      
                mov     a,#8
                call    trace

                clr     send_status
                clr     send_reset
                clr     send_credit
                call    read_sms
                call    delete_sms
                ;jnb     send_status,cs_try_reset
                ;call    send_status_sms
cs_try_reset:   jnb     send_reset,cs_try_credit
                call    assert_reset
cs_try_credit:  ;jnb     send_credit,cs_ret
                ;call    send_credit_sms
cs_ret:         ret

                ; poll gsm module for incoming sms-es
main_poll_gsm:  call    switch_gsm
                mov     wait_cnt,#2
mpg_lp1:        call    puts_nf
                db      'AT',cr,0
                call    wait_for_ok
                jnc     mpg_lp1

                mov     a,#9
                call    trace

                mov     tmp1,#'1'
                call    check_sms
                
                ;mov     tmp1,#'2'
                ;call    check_sms
                ;mov     tmp1,#'3'
                ;call    check_sms
                ;mov     tmp1,#'4'
                ;call    check_sms
                ;mov     tmp1,#'5'
                ;call    check_sms

                
                mov     a,#10
                call    trace

                ; is there an ongoing call?
                call    cool_down
                call    puts_nf
                db      'AT+CLCC',cr,0
                mov     a,#3
                call    do_events
                db      '+CLCC: #,1,#',0
                dw      mpg_skip0
                db      0
                jmp     mpg_drain1

mpg_skip0:      mov     a,@r0
                cjne    a,#'0',mpg_skip1
                jmp     ml1_ongoing_call
mpg_skip1:      call    cool_down
                call    puts_nf
                db      'ATA',cr,0
                jmp     ml1_ongoing_call
mpg_drain1:

                mov     a,#11
                call    trace

; read the time
                jmp     mpg_drain2
                call    cool_down
                call    puts_nf
                db      'AT+CCLK?',cr,0
                mov     a,#3
                call    do_events
                db      '##/##/##,##',0
                dw      mpg_skip3
                db      0
                jmp     mpg_drain2

mpg_skip3:      mov     a,@r0
                mov     r7,a
                inc     r0
                mov     a,@r0
                mov     r6,a
                inc     r0
                inc     r0
                mov     a,@r0
                mov     day,a
                mov     a,r7
                clr     c
                subb    a,#'0'
                mov     r7,a
                mov     a,r6
                clr     c
                subb    a,#'0'
                mov     r6,a
                mov     b,#10
                mul     ab
                add     a,r7
                mov     hour,a

                mov     a,hour
                cjne    a,#12,mpg_skip4
                mov     a,ohour
                cjne    a,#11,mpg_skip4
                mov     a,day
                xrl     a,#'1'
                ;jz      ml1_dial
                mov     a,day
                xrl     a,#'4'
                ;jz      ml1_dial
                mov     a,day
                xrl     a,#'7'
                ;jz      ml1_dial
mpg_skip4:      mov     ohour,hour
mpg_drain2:     jmp     main_init1

; dial a number
ml1_dial:       call    switch_gsm
                
                mov     a,#12
                call    trace

                call    cool_down
                mov     wait_cnt,#2
smk_lp:         ;jb      lift,smk_skip1
                call    puts_nf
                db      'AT+CMIC=0,2',cr,0
                ;sjmp    smk_skip2
;smk_skip1:      call    puts_nf
;                db      'AT+CMIC=1,2',cr,0
smk_skip2:      call    wait_for_ok
                jnc     smk_lp

                setb    c
                call    set_relay1

ml1_dial_lp0:   mov     tmp1,#'1'
ml1_dial_lp1:   push    tmp1

                mov     a,#13
                call    trace

                ; vytocit cislo
                call    hang_up
                call    puts_nf
                db      'ATD>SM',0
                call    insert_one
                pop     acc
                push    acc
                call    put_chr
                mov     a,#';'
                call    put_chr
                mov     a,#cr
                call    put_chr

                mov     a,#10       ; cas aby gsm odpovedal ze zacal vytacat cislo
                call    do_events
                db      'ERROR',0
                dw      dn_error
                db      'NO DIALTONE',0
                dw      dn_error
                db      'NO CARRIER',0
                dw      dn_error
                db      'BUSY',0
                dw      dn_error
                db      'OK',0
                dw      dn_dialling
                db      0
dn_error_h:     call    hang_up

dn_error:       pop     tmp1
                inc     tmp1
                mov     a,tmp1
                cjne    a,#'8',ml1_dial_lp1
                jmp     ml1_dial_lp0

                ; answer was OK
dn_dialling:    call    tmr_int_f
                db      t_speak,0,40,0      ; dlzka vyzvanania
                
                mov     a,#22
                call    trace

dn_dial_lp1:    call    do_them
                call    cool_down
                mov     a,#t_speak
                call    tmr_zro
                jc      dn_error_h
                call    puts_nf
                db      'AT+CLCC',cr,0
                mov     a,#5
                call    do_events
                db      '+CLCC: #,0,#',0
                dw      dn_check
                db      0
                jmp     dn_dial_lp1

                ; zdvihol niekto?
dn_check:       mov     a,@r0
                cjne    a,#'0',dn_dial_lp1

                ; hovor prebieha
                pop     tmp1
ml1_ongoing_call:
                setb    c
                call    set_relay3
                call    tmr_int_f
                db      t_speak,1,0,0       ; dlzka hovoru 

                ; hovor prebieha
dn_wait_lp:     call    do_them
                call    cool_down
                mov     a,#t_speak
                call    tmr_zro
                jc      dnw_done
                call    puts_nf
                db      'AT+CLCC',cr,0
                mov     a,#5
                call    do_events
                db      '+CLCC: #,#,#',0
                dw      dnw_skip0
                db      0
                jmp     dn_wait_lp

                ; is call over?
dnw_skip0:      mov     a,@r0
                xrl     a,#'0'
                jz      dn_wait_lp

dnw_done:       call    hang_up
                clr     c
                call    set_relay1
                clr     c
                call    set_relay3
                jmp     main_init1

endif
