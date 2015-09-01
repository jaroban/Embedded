; version 1.0

timer1_int:     clr     ea
                push    psw
                push    acc
                push    ar0
                push    ar1
                anl     psw,#11100111b
oui_again:      mov     a,p1
                cpl     a
                mov     r1,a
                mov     a,ac_index1
                clr     c
                subb    a,#17
                jnc     oui_skip1
                add     a,#20
oui_skip1:      mov     ac_index1,a
                add     a,#ac_table
                mov     r0,a
                mov     a,r1
                anl     a,#00011100b
                orl     a,@r0
                mov     @r0,a
                mov     a,ac_index2
                clr     c
                subb    a,#17
                jnc     oui_skip2
                add     a,#20
oui_skip2:      mov     ac_index2,a
                add     a,#ac_table
                mov     r0,a
                mov     a,r1
                anl     a,#00101100b
                orl     a,@r0
                mov     @r0,a
                mov     a,ac_index3
                clr     c
                subb    a,#17
                jnc     oui_skip3
                add     a,#20
oui_skip3:      mov     ac_index3,a
                add     a,#ac_table
                mov     r0,a
                mov     a,r1
                anl     a,#01001100b
                orl     a,@r0
                mov     @r0,a
                djnz    ac_cnt,oui_ret
                mov     ac_cnt,#20
                push    ar2
                push    ar3
                clr     a
                mov     r0,#ac_table
                mov     r1,a
                mov     r2,a
                mov     r3,#20
                mov     ac_rd,a
oui_eval_lp1:   mov     a,@r0
                orl     ac_rd,a
                anl     a,#01110000b
                jnz     oui_eval_nz
                inc     r1
oui_eval_nz:    xrl     a,#01110000b
                jnz     oui_eval_nff
                inc     r2
oui_eval_nff:   clr     a
                mov     @r0,a
                inc     r0
                djnz    r3,oui_eval_lp1
                mov     a,#5                    ; min pocet '000' z 20
                setb    c
                subb    a,r1
                jnc     oui_eval_bad
                mov     a,#2                    ; min pocet '111' z 20
                subb    a,r2
oui_eval_bad:   mov     a,ac_maj
                rlc     a
                mov     ac_maj,a
                mov     r0,#0
                mov     r1,#8
oui_eval_lp2:   rlc     a
                xch     a,r0
                addc    a,#0
                xch     a,r0
                djnz    r1,oui_eval_lp2
                mov     a,#4                    ; min pocet '1' z 8
                setb    c
                subb    a,r0
                mov     poradie_faz,c
                pop     ar3
                pop     ar2
oui_ret:        clr     tr1
                mov     a,tl1                   ; 1
                add     a,#low(-tmr1_period+7)  ; 1
                mov     tl1,a                   ; 1
                mov     a,th1                   ; 1
                addc    a,#high(-tmr1_period+7) ; 1
                mov     th1,a                   ; 1
                setb    tr1                     ; 1
                jnc     oui_pop
                jmp     oui_again
oui_pop:        pop     ar1
                pop     ar0
                pop     acc
                pop     psw
                setb    ea
                reti

do_majority5:   mov     b,r0
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
                mov     r1,b
                mov     b,#0
                mov     r2,#5
do_maj5_lp:     mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     b,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp
                mov     a,b
                ret

refresh_inputs: mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
                mov     a,p0
                xrl     a,#11111001b
                mov     c,h_termistor
                mov     acc.2,c
                call    do_majority5
                mov     inputs,a
                ret

refresh_snimace:
                mov     a,#t_snimac
                call    tmr_zro
                jnc     rs_ret
                jb      snimac,rs_1
                jnb     h_snimac,rs_ret
                setb    snimac
                call    tmr_int_f
                db      t_snimac,0,1,0
                ret
rs_1:           jb      h_snimac,rs_ret
                clr     snimac
                call    tmr_int_f
                db      t_snimac,0,1,0
rs_ret:         ret

initial_thread: clr     ea
                mov     ac_index1,#0
                mov     ac_index2,#7
                mov     ac_index3,#13
                mov     ac_cnt,#20
                mov     ac_maj,#0
                mov     ac_rd,#0
                orl     tmod,#10h
                mov     tl1,#low(-tmr1_period)
                mov     th1,#high(-tmr1_period)
                setb    tr1
                setb    et1
                setb    ea

                mov     p0,#0ffh
                mov     p1,#0ffh
                mov     p2,#0ffh

                mov     thread_id,#'i'

                mov     dptr,#output_setup
                call    run_it
                mov     dptr,#safety_setup
                call    run_it

                clr     snimac

input_main_lp:  call    do_them
                call    refresh_snimace
                mov     a,#t_vstupy
                call    tmr_zro
                jnc     iml_skip1
                call    tmr_int_f
                db      t_vstupy,0,0,1
                call    refresh_inputs
iml_skip1:      jmp     input_main_lp
