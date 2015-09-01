; version 4.1

                jb      je_ranny_program,no_its_not
is_ranny_top:
                jb      je_obed_program,no_its_not
is_obed_top:
                jb      je_nezavisla_jazda,no_its_not
is_nezavisla_top:
                jb      je_prednostna_jazda,no_its_not
is_prednostna_top:
                mov     a,je_poziarna_jazda
                jnz     no_its_not
is_poziarna_top:
                jb      je_posledna_jazda,no_its_not
is_posledna_top:
                mov     a,#0ffh
                ret
no_its_not:     clr     a
                ret

zapni_svetlo:   clr     rele_svetlo
                ; reg3.d4
                anl     wr_can_reg5,#0efh
                setb    can0_change2
                ret

vypni_svetlo:   setb    rele_svetlo
                ; reg3.d4
                orl     wr_can_reg5,#10h
                setb    can0_change2
                ret

reset_svetlo:   mov     a,#t_vypni_svetlo
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_svetlo
                call    init_timer
                setb    chceme_vypnut_svetlo
                ret

reset_parkovanie:
                mov     a,#t_odchod_do_parku
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_parkovanie
                call    init_timer
                setb    chceme_ist_parkovat
                ret

reset_prednost:
                mov     a,#t_doba_prednosti
                call    get_timer_data
                mov     dps,#0
                mov     dptr,#t_prednost
                jmp     init_timer

if 0
check_emergency1:
                mov     a,dr_state
                cjne    a,#dr_do_najnizsej,ce1_skip1
                mov     a,#0ffh
                ret
ce1_skip1:      cjne    a,#dr_do_poziarnej,ce1_0
                mov     a,#0ffh
                ret
ce1_0:          clr     a
                ret
endif

neotvaraj_dvere:
                mov     a,je_poziarna_jazda
                xrl     a,#2
                jz      nd1_1
                mov     a,dr_state
                cjne    a,#dr_do_poziarnej,nd1_0
                call    poziarna_stanica
                dec     a
                cjne    a,liftpos,nd1_1
nd1_0:          clr     a
                ret
nd1_1:          mov     a,#0ffh
                ret

check_emergency2:
                mov     a,dr_state
                cjne    a,#dr_do_najnizsej,ce2_skip1
                mov     a,liftpos
                jz      ce2_1
                clr     a
                ret
ce2_skip1:      cjne    a,#dr_do_poziarnej,ce2_0
                call    poziarna_stanica
                dec     a
                xrl     a,liftpos
                jz      ce2_1
ce2_0:          clr     a
                ret
ce2_1:          cpl     a
                ret

obed_v_hornej:  jnb     je_obed_program,ovh_0
                mov     a,floor_no
                dec     a
                xrl     a,liftpos
                jnz     ovh_0
                cpl     a
                ret
ovh_0:          clr     a
                ret

ranny_v_hlavnej:
                jnb     je_ranny_program,rvh_0
                call    hlavna_stanica
                dec     a
                xrl     a,liftpos
                jnz     rvh_0
                cpl     a
                ret
rvh_0:          clr     a
                ret

treba_otvorit_dvere:
                call    check_emergency2
                jnz     tod_1
                call    statie_s_otvorenymi_dverami
                jnz     tod_1
                jb      je_nezavisla_jazda,tod_1
                jb      je_prednostna_jazda,tod_1
                call    obed_v_hornej
                jnz     tod_1
                call    ranny_v_hlavnej
                jnz     tod_1
                clr     a
                ret
tod_1:          mov     a,#0ffh
                ret

netreba_otvorit_dvere:
                mov     a,dr_state
                cjne    a,#dr_parkujeme,nod_no
                call    statie_s_otvorenymi_dverami
                jnz     nod_no
                mov     a,#0ffh
                ret
nod_no:         clr     a
                ret

mozem_zatvorit_dvere:
                call    statie_s_otvorenymi_dverami
                jnz     mzd_0
                mov     a,#0ffh
                ret
mzd_0:          clr     a
                ret
