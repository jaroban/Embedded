; version 2.0

def_name1:      db      'Nezname miesto 1'
def_name2:      db      'Nezname miesto 2'

; setc carry iff ok
test_connection:
                mov     wait_cnt,#10
tc_lp1:         call    puts_nf
                db      'AT',cr,0
                mov     a,#2
                call    do_events
                db      'OK',0
                dw      tc_done
                db      0
                djnz    wait_cnt,tc_lp1
                clr     c
                ret
tc_done:        call    cool_down
                setb    c
                ret

turn_gsm_on:    setb    pwr_key
                call    show_reset
                call    switch_gsm
                
                mov     a,#1
                call    relays
                
                call    wait4it_f
                db      0,0,45,0

tgo_again:      mov     a,#2
                call    relays

                call    test_connection
                jc      tgo_ret

                mov     a,#3
                call    relays
                
                ; send turning on
                ;setb    lift
                call    switch_out
                call    puts_nf
                db      'turning on...',0
                ;jbc     lift,tgo_again0
                call    switch_gsm

                mov     a,#4
                call    relays

                ; zapnutie
                clr     pwr_key
                call    wait4it_f
                db      0,0,3,0
                setb    pwr_key

                mov     a,#5
                call    relays

                ; cakanie na ready
                mov     a,#10
                call    do_events
                db      'RDY',0
                dw      tgo_ret
                db      0
                
                ; try again
                jmp     tgo_again

tgo_ret:        ;setb    lift
tgo_again2:     call    switch_out
                call    puts_nf
                db      'success',0
                ;jbc     lift,tgo_again2
                mov     a,#0
                call    relays
                ret

wait_for_ok:    mov     a,#7
                call    do_events
                db      'OK',0
                dw      wfo_done
                db      'ERROR',0
                dw      wfo_again
                db      0
                djnz    wait_cnt,wfo_again
                jmp     os_init
wfo_again:      call    cool_down
                clr     c
                ret
wfo_done:       call    cool_down
                setb    c
                ret

read_name_str:  call    switch_gsm
                mov     wait_cnt,#2
rns_again1:     call    cool_down
                call    puts_nf
                db      'AT+CPBR=',0
                call    insert_one
                call    puts_nf
                db      '8',cr,0
                mov     a,#3
                call    do_events
                db      '129,"',0
                dw      rns_skip1
                db      '145,"',0
                dw      rns_skip1
                db      'ERROR',0
                dw      rns_messed1
                db      0
rns_messed1:    djnz    wait_cnt,rns_again1
                sjmp    rns_default
rns_skip1:      call    get_name_str
                mov     tmp1,a
                mov     tmp2,#8
                mov     tmp3,#'"'
                call    read_string
                jnc     rns_messed1

                mov     wait_cnt,#2

                mov     a,#24
                call    trace

rns_again2:     call    cool_down
                call    puts_nf
                db      'AT+CPBR=',0
                call    insert_one
                call    puts_nf
                db      '9',cr,0
                mov     a,#3
                call    do_events
                db      '129,"',0
                dw      rns_skip2
                db      '145,"',0
                dw      rns_skip2
                db      'ERROR',0
                dw      rns_messed2
                db      0
rns_messed2:    djnz    wait_cnt,rns_again2
rns_default:    call    get_def_name
                call    get_name_str
                mov     r0,a
                mov     r1,#16
                jmp     copy_from_code
rns_skip2:      call    get_name_str
                add     a,#8
                mov     tmp1,a
                mov     tmp2,#8
                mov     tmp3,#'"'
                call    read_string
                jnc     rns_messed2
                ret

read_signal:    call    switch_gsm

                mov     a,#15
                call    trace

                call    puts_nf
                db      'AT+CSQ',cr,0
                mov     a,#3
                call    do_events
                db      '+CSQ: ##,',0
                dw      rsi_skip1
                db      '+CSQ: #,',0
                dw      rsi_skip2
                db      0
                ret
rsi_skip1:      inc     r0
                mov     a,@r0
                clr     c
                subb    a,#'0'
                mov     r1,a
                inc     r0
                mov     a,@r0
                clr     c
                subb    a,#'0'
                mov     b,#10
                mul     ab
                add     a,r1
                mov     signal,a
                ret
rsi_skip2:      inc     r0
                mov     a,@r0
                clr     c
                subb    a,#'0'
                mov     signal,a
                ret

; tmp='1','2',...
get_number:     call    switch_gsm

                mov     a,#16
                call    trace

                mov     wait_cnt,#2
gn_again:       call    cool_down
                call    puts_nf
                db      'AT+CPBR=',0
                call    insert_one
                mov     a,tmp1
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                db      '+CPBR: #,"',0
                dw      gn_skip2
                db      'ERROR',0
                dw      gn_messed
                db      0
gn_messed:      djnz    wait_cnt,gn_again
                clr     c
                ret
gn_skip2:       push    tmp1
                mov     tmp1,#number_str
                mov     tmp2,#16
                mov     tmp3,#'"'
                call    read_string
                pop     tmp1
                jnc     gn_messed
                setb    c
                ret

; tmp1='1','2',...
store_number:   call    switch_gsm

                mov     a,#17
                call    trace

                call    puts_nf
                db      'AT+CPBW=',0
                call    insert_one
                mov     a,tmp1
                call    put_chr
                mov     a,#','
                call    put_chr
                mov     a,#'"'
                call    put_chr
                mov     r0,#number_str
                mov     r1,#16
                call    puts_no_spaces
                call    puts_nf
                db      '",,"num',0
                mov     a,tmp1
                call    put_chr
                mov     a,#'"'
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                db      'OK',0
                dw      sn_yes
                db      'ERROR',0
                dw      sn_no
                db      0
sn_no:          clr     c
                ret
sn_yes:         setb    c
                ret

; tmp1='1','2',...
read_sms:       call    switch_gsm
                mov     wait_cnt,#2

                mov     a,#18
                call    trace

rs_again:       call    cool_down
                call    puts_nf
                db      'AT+CMGR=',0
                mov     a,tmp1
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                ;db      'kredit',0
                ;dw      rs_credit1
                ;db      'Status',0
                ;dw      rs_skip2
                ;db      'STATUS',0
                ;dw      rs_skip2
                db      'Reset',0
                dw      rs_skip3
                db      'RESET',0
                dw      rs_skip3
                db      'ERROR',0
                dw      rs_messed
                db      'OK',0
                dw      rs_cont
                db      0
rs_messed:      djnz    wait_cnt,rs_again
rs_cont:        mov     c,send_status
                orl     c,send_credit
                jnc     rs_ret2
                mov     wait_cnt,#2
rs_again2:      call    cool_down
                call    puts_nf
                db      'AT+CMGR=',0
                mov     a,tmp1
                call    put_chr
                mov     a,#cr
                call    put_chr

                jnb     send_status,rs_credit
                mov     a,#3
                call    do_events
                db      '#######"',0
                dw      rs_skip1
                db      'ERROR',0
                dw      rs_cont2
                db      'OK',0
                dw      rs_cont2
                db      0
                sjmp    rs_cont2
          
rs_credit:      mov     a,#3
                call    do_events
                db      ' #,##',0
                dw      rs_credit2
                db      ' #.##',0
                dw      rs_credit2
                db      'ERROR',0
                dw      rs_cont2
                db      'OK',0
                dw      rs_cont2
                db      0

rs_cont2:       call    print_fifos
                djnz    wait_cnt,rs_again2
                clr     send_status
                clr     send_credit
rs_ret2:        ret

rs_credit1:     setb    send_credit
                jmp     rs_cont
rs_skip2:       setb    send_status
                jmp     rs_cont
rs_skip3:       setb    send_reset
                ret

rs_skip1:       call    print_fifos
                inc     r0
                mov     r1,#number_str
                mov     r2,#16
                mov     a,#' '
rs_clr_lp1:     mov     @r1,a
                inc     r1
                djnz    r2,rs_clr_lp1
                dec     r1

                mov     r2,#16
rs_cpy_lp1:     mov     a,@r0
                xrl     a,#'"'
                jz      rs_cpy_done
                xrl     a,#'"'
                mov     @r1,a
                inc     r0
                dec     r1
                djnz    r2,rs_cpy_lp1
rs_cpy_done:    ret

rs_credit2:     call    print_fifos
                inc     r0
                inc     r0
                inc     r0
                mov     a,@r0
                clr     c
                subb    a,#7
                mov     send_credit,c
                ret

; tmp1='1','2',...
delete_sms:     call    switch_gsm
                mov     wait_cnt,#2

                mov     a,#19
                call    trace

ds_again:       call    cool_down
                call    puts_nf
                db      'AT+CMGD=',0
                mov     a,tmp1
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                db      'OK',0
                dw      ds_done
                db      'ERROR',0
                dw      ds_error
                db      0
ds_error:       djnz    wait_cnt,ds_again
ds_done:        ret

store_name:     call    switch_gsm

                mov     a,#25
                call    trace

                call    cool_down
                call    puts_nf
                db      'AT+CPBW=',0
                call    insert_one
                call    puts_nf
                db      '8,"0000111222",,"',0
                call    get_name_str
                mov     r0,a
                mov     r1,#8
                call    puts
                mov     a,#'"'
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                db      'OK',0
                dw      sn_next
                db      'ERROR',0
                dw      sn_no
                db      0
                clr     c
                ret
sn_next:        call    cool_down
                call    puts_nf
                db      'AT+CPBW=',0
                call    insert_one
                call    puts_nf
                db      '9,"0000111222",,"',0
                call    get_name_str
                add     a,#8
                mov     r0,a
                mov     r1,#8
                call    puts
                mov     a,#'"'
                call    put_chr
                mov     a,#cr
                call    put_chr
                mov     a,#3
                call    do_events
                db      'OK',0
                dw      sn_yes
                db      'ERROR',0
                dw      sn_no
                db      0
                clr     c
                ret

sms_new_line:   mov     a,#cr
                call    put_chr
                call    wait4it_f
                db      t_wait,0,1,0
                ret

send_sms_number:
                mov     a,#20
                call    trace

                call    puts_nf
                db      'AT+CMGS="',0
                jnb     send_plus,ssn_skip1
                mov     a,#'+'
                call    put_chr
ssn_skip1:      mov     r0,#number_str
                mov     r1,#16
                call    puts_no_spaces
                mov     a,#'"'
                call    put_chr
                call    sms_new_line
                call    get_name_str
                mov     r0,a
                mov     r1,#16
                call    puts
                jmp     sms_new_line

send_sms1:      clr     send_plus
                mov     tmp1,#'1'
                call    get_number
                jc      sst_entry
                ret

send_status_sms:
                clr     send_plus

                mov     a,#26
                call    trace

                call    lift_on
                jnc     sst_done
sst_entry:      mov     wait_cnt,#2

                mov     a,#27
                call    trace

sst_lp1:        call    switch_out
                call    puts_nf
                db      'stat',0
                call    clear_fifos
                mov     tmp1,#status_str
                mov     tmp2,#32
                mov     tmp3,#esc
                call    read_string
                jc      sst_skip1
                djnz    wait_cnt,sst_lp1

                mov     wait_cnt,#2
sst_lp2:        call    switch_gsm

                mov     a,#28
                call    trace

                call    cool_down
                call    send_sms_number
                call    puts_nf
                db      'Vytah neodpoveda.',0
                call    sms_new_line
                mov     a,#ctrl_z
                call    put_chr
                mov     a,#30
                call    do_events
                db      '+CMGS:',0
                dw      sst_done
                db      'ERROR',0
                dw      sst_drain2
                db      0
                mov     a,#esc
                call    put_chr
sst_drain2:     djnz    wait_cnt,sst_lp2
sst_done:       ret

sst_skip1:      mov     wait_cnt,#2
sst_lp3:        call    switch_gsm


                mov     a,#29
                call    trace

                call    cool_down
                call    send_sms_number
                mov     r0,#status_str
                mov     r1,#16
                call    puts
                call    sms_new_line
                mov     r0,#status_str+16
                mov     r1,#16
                call    puts
                call    sms_new_line
                mov     a,#ctrl_z
                call    put_chr
                mov     a,#30
                call    do_events
                db      '+CMGS:',0
                dw      sst_done
                db      'ERROR',0
                dw      sst_drain3
                db      0
                mov     a,#esc
                call    put_chr
sst_drain3:     djnz    wait_cnt,sst_lp3
                ret

send_credit_sms:
                clr     send_credit
                mov     tmp1,#'1'
                call    get_number
                jnc     ss2_done
                mov     wait_cnt,#2
                
ss2_lp:         call    send_sms_number
                call    puts_nf
                db      'Nizky kredit',0
                call    sms_new_line
                mov     a,#ctrl_z
                call    put_chr
                mov     a,#30
                call    do_events
                db      '+CMGS:',0
                dw      ss2_done
                db      'ERROR',0
                dw      ss2_drain
                db      0
                mov     a,#esc
                call    put_chr
ss2_drain:      djnz    wait_cnt,ss2_lp
ss2_done:       ret

send_sms3:      clr     send_plus
                mov     tmp1,#'1'
                call    get_number
                jnc     ss3_done
                mov     wait_cnt,#2

                mov     a,#30
                call    trace

ss3_lp:         call    send_sms_number
                call    puts_nf
                db      'Nap. baterky nizke.',0
                call    sms_new_line
                mov     a,#ctrl_z
                call    put_chr
                mov     a,#30
                call    do_events
                db      '+CMGS:',0
                dw      ss3_done
                db      'ERROR',0
                dw      ss3_drain
                db      0
                mov     a,#esc
                call    put_chr
ss3_drain:      djnz    wait_cnt,ss3_lp
ss3_done:       ret

send_sms4:      clr     send_plus
                mov     tmp1,#'1'
                call    get_number
                jnc     ss4_done
                mov     wait_cnt,#2
ss4_lp:         call    send_sms_number
                call    puts_nf
                db      'Nap. baterky OK.',0
                call    sms_new_line
                mov     a,#ctrl_z
                call    put_chr
                mov     a,#30
                call    do_events
                db      '+CMGS:',0
                dw      ss4_done
                db      'ERROR',0
                dw      ss4_drain
                db      0
                mov     a,#esc
                call    put_chr
ss4_drain:      djnz    wait_cnt,ss4_lp
ss4_done:       ret

hang_up:        call    cool_down
                call    puts_nf
                db      'ATH',cr,0
                call    wait4it_f
                db      t_wait,0,1,0
                call    puts_nf
                db      'ATH',cr,0
                call    wait4it_f
                db      t_wait,0,1,0
                jmp     cool_down

; junkyard
if 0
tgo_lp2_5:      call    do_them
                call    get_chr
                jnc     tgo_skip2
                setb    lift
tgo_again1:     call    switch_out
                call    put_chr
                jbc     lift,tgo_again1
                jmp     tgo_lp2_5
endif