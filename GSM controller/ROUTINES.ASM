; version 2.0

show_reset:     setb    rele1
                setb    rele2
                setb    rele3
                setb    rele4
                setb    rele5
                call    wait4it_f
                db      0,0,1,0
                clr     rele1
                clr     rele2
                clr     rele3
                clr     rele4
                clr     rele5
                ret

get_state:      ;jb      lift,gs_skip1
                mov     a,state1
                ret
;gs_skip1:       mov     a,state2
;                ret

store_state:    ;jb      lift,ss_skip1
                mov     state1,a
                ret
;ss_skip1:       mov     state2,a
;                ret

read_button:    ;jb      lift,rb_skip1
                mov     c,button1
                cpl     c
                ret
;rb_skip1:       mov     c,button2
;                cpl     c
;                ret

set_relay1:     
ifn debug
                ;jb      lift,sr1_skip1
                mov     rele1,c
                ret
;sr1_skip1:      mov     rele3,c
endif
                ret

set_relay2:     
ifn debug
                ;jb      lift,sr2_skip1
                mov     rele2,c
                ret
;sr2_skip1:      mov     rele4,c
endif
                ret

set_relay3:     mov     rele3,c
                mov     rele4,c
                mov     rele5,c
                ret

is_error_timer_zero:
                ;jb      lift,ietz_skip1
                mov     a,#t_error1
                jmp     tmr_zro
;ietz_skip1:     mov     a,#t_error2
;                jmp     tmr_zro

reset_error_timer:
                ;jb      lift,rept_skip1
                call    tmr_int_f
                db      t_error1,1,0,0
                ret
;rept_skip1:     call    tmr_int_f
;                db      t_error2,1,0,0
;                ret

assert_reset:   call    lift_on
                jnc     ar_done
                call    switch_out
                call    puts_nf
                db      ' reset reset ',0
                setb    rele5
                call    wait4it_f
                db      t_wait,0,1,0
                call    puts_nf
                db      ' reset reset ',0
                clr     rele5
                call    board_ok
ar_done:        ret

lift_on:        ;jb      lift,lo_skip1
                mov     c,lift_on1
                cpl     c
                ret
;lo_skip1:       mov     c,lift_on2
;                cpl     c
;                ret

is_board_ok:    ;jb      lift,ibo_skip1
                mov     c,board_dead1
                cpl     c
                ret
;ibo_skip1:      mov     c,board_dead2
;                cpl     c
;                ret

board_ok:       ;jb      lift,bo_skip1
                clr     board_dead1
                mov     reply_cnt1,#6   ;po4etpokusov OK,OK,OK
                ret
;bo_skip1:       clr     board_dead2
;                mov     reply_cnt2,#3
;                ret

no_reply:       ;jb      lift,nr_skip1
                jb      board_dead1,nr_ret
                djnz    reply_cnt1,nr_ret
                setb    board_dead1
                ret
;nr_skip1:       jb      board_dead2,nr_ret
;                djnz    reply_cnt2,nr_ret
;                setb    board_dead2
nr_ret:         ret

board_bad:      ;jb      lift,bb_skip1
                setb    board_dead1
                ret
;bb_skip1:       setb    board_dead2
;                ret

get_def_name:   ;jb      lift,gdn_skip1
                mov     dptr,#def_name1
                ret
;gdn_skip1:      mov     dptr,#def_name2
;                ret

get_name_str:   ;jb      lift,gns_skip1
                mov     a,#name_str1
                ret
;gns_skip1:      mov     a,#name_str2
;                ret

insert_one:     ;jnb     lift,io_ret
                ;mov     a,#'1'
                ;call    put_chr
io_ret:         ret
