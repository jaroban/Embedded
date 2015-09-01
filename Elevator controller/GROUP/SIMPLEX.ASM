; version 4.0

gs_del_all:     mov     r4,#0
gsda_lp1:       mov     r3,#0
gsda_lp2:       call    get_cs
                xrl     a,#cs_off
                jz      gsda_skip
                xrl     a,#cs_off xor cs_dead
                jz      gsda_skip
                xrl     a,#cs_dead xor cs_stuck
                jz      gsda_skip
                mov     a,#cs_numb
                call    set_cs
gsda_skip:      inc     r3
                mov     a,r3
                cjne    a,#3,gsda_lp2
                inc     r4
                mov     a,r4
                cjne    a,call_no,gsda_lp1
                jmp     del_volby

gs_del_cabin:   mov     r7,call_no
                mov     r4,#0
                mov     r3,#g_kabina
gsdn_lp:        call    get_cs
                xrl     a,#cs_off
                jz      gsdn_skip
                xrl     a,#cs_off xor cs_dead
                jz      gsdn_skip
                xrl     a,#cs_dead xor cs_stuck
                jz      gsdn_skip
                mov     a,#cs_numb
                call    set_cs
gsdn_skip:      inc     r4
                djnz    r7,gsdn_lp
                jmp     del_kabinove

gs_del_out:     mov     r7,call_no
                mov     r4,#0
gsdo_lp:        mov     r3,#g_dole
                call    get_cs
                xrl     a,#cs_off
                jz      gsdo_skip1
                xrl     a,#cs_off xor cs_dead
                jz      gsdo_skip1
                xrl     a,#cs_dead xor cs_stuck
                jz      gsdo_skip1
                mov     a,#cs_numb
                call    set_cs
gsdo_skip1:     mov     r3,#g_hore
                call    get_cs
                xrl     a,#cs_off
                jz      gsdo_skip2
                xrl     a,#cs_off xor cs_dead
                jz      gsdo_skip2
                xrl     a,#cs_dead xor cs_stuck
                jz      gsdo_skip2
                mov     a,#cs_numb
                call    set_cs
gsdo_skip2:     inc     r4
                djnz    r7,gsdo_lp
                jmp     del_vonkajsie

gs_new_call:    mov     a,r3
                clr     c
                subb    a,#3
                jnc     gsnc_ret
                mov     a,r4
                clr     c
                subb    a,call_no
                jnc     gsnc_ret
                call    get_cs
                xrl     a,#cs_dead
                jz      gsnc_ret
                xrl     a,#cs_dead xor cs_stuck
                jz      gsnc_ret
                mov     a,r3
                call    do_case
                dw      g_kabina+c_,moze_kabina_combo
                dw      g_dole+c_,moze_dole_combo
                dw      g_hore+c_,moze_hore_combo
                db      0
                jz      gsnc_ret
                mov     a,#cs_on
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_kabina+j_,add_kabina_sft
                dw      g_dole+j_,add_dole_sft
                dw      g_hore+j_,add_hore_sft
                db      0
gsnc_ret:       ret

gs_del_call:    mov     a,r3
                clr     c
                subb    a,#3
                jnc     gsdc_ret
                mov     a,r4
                clr     c
                subb    a,call_no
                jnc     gsdc_ret
                call    get_cs
                xrl     a,#cs_off
                jz      gsdc_ret
                xrl     a,#cs_off xor cs_dead
                jz      gsdc_ret
                xrl     a,#cs_dead xor cs_stuck
                jz      gsdc_ret
                mov     a,#cs_numb
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_kabina+j_,del_kabina_sft
                dw      g_dole+j_,del_dole_sft
                dw      g_hore+j_,del_hore_sft
                db      0
gsdc_ret:       ret

gs_poll_calls:  call    moze_hore
                jz      gspc_dole
                mov     r7,call_no
                mov     r4,#0
                mov     r3,#g_hore
gspch_lp:       call    get_cs
                cjne    a,#cs_off,gspch_skip
                call    moze_hore_p
                jz      gspch_skip
                call    je_hore
                jz      gspch_skip
                call    add_hore_sft
                mov     a,#cs_on
                call    set_cs
gspch_skip:     inc     r4
                djnz    r7,gspch_lp

gspc_dole:      call    moze_dole
                jz      gspc_kabina
                mov     r7,call_no
                mov     r4,#0
                mov     r3,#g_dole
gspcd_lp:       call    get_cs
                cjne    a,#cs_off,gspcd_skip
                call    moze_dole_p
                jz      gspcd_skip
                call    je_dole
                jz      gspcd_skip
                call    add_dole_sft
                mov     a,#cs_on
                call    set_cs
gspcd_skip:     inc     r4
                djnz    r7,gspcd_lp

gspc_kabina:    call    moze_kabina
                jz      gspc_ret
                mov     r7,call_no
                mov     r4,#0
                mov     r3,#g_kabina
gspck_lp:       call    moze_kabina_p
                jz      gspck_next
                call    get_cs
                cjne    a,#cs_off,gspck_skip1
                call    je_kabina
                jz      gspck_next
                call    add_kabina_sft
                mov     a,#cs_on
                call    set_cs
                sjmp    gspck_gong
gspck_skip1:    cjne    a,#cs_on,gspck_next
                call    je_kabina
                jz      gspck_next
                call    je_kabina_o
                jnz     gspck_next
                ; rising edge on call
gspck_gong:     push    ar3
                push    ar4
                push    ar7
                call    gong_nevidiaci_on
                pop     ar7
                pop     ar4
                pop     ar3
gspck_next:     inc     r4
                djnz    r7,gspck_lp
                
                mov     dps,#0
                mov     dptr,#rd_kabina_o
                mov     r0,#rd_kabina
                mov     r1,#4
gspck_lp2:      mov     a,@r0
                movx    @dptr,a
                inc     r0
                inc     dptr
                djnz    r1,gspck_lp2
gspc_ret:       ret

gs_time_out:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_cs_timeout
                mov     r4,#0
gsto_lp1:       mov     r3,#0
gsto_lp2:       movx    a,@dptr
                jnz     gsto_skip3
                push    dpl
                push    dph
                call    get_cs
                cjne    a,#cs_numb,gsto_skip1
                call    g_je_volba
                call    g_check_stuck
                sjmp    gsto_skip2
gsto_skip1:     cjne    a,#cs_stuck,gsto_skip2
                call    g_je_volba
                jnz     gsto_skip1_1
                mov     a,#cs_off
                call    set_cs
                sjmp    gsto_skip2
gsto_skip1_1:   mov     a,#cs_stuck
                call    set_cs
gsto_skip2:     pop     dph
                pop     dpl
gsto_skip3:     inc     dptr
                inc     r3
                mov     a,r3
                cjne    a,#3,gsto_lp2
                inc     r4
                mov     a,r4
                cjne    a,call_no,gsto_lp1
                ret

gs_main_lp:     call    do_them
                call    do_vnts
                dw      m_del_all+c_,gs_del_all
                dw      m_del_cabin+c_,gs_del_cabin
                dw      m_new_call+c_,gs_new_call
                dw      m_del_call+c_,gs_del_call
                dw      m_del_out+c_,gs_del_out
                dw      m_loc+c_,gg_in_loc
                db      0
                jnb     poll_calls,gs_skip1
                clr     poll_calls
                call    gs_poll_calls
gs_skip1:       call    timer_running_reload_f
                dw      t_group
                db      0,0,25
                jnz     gs_skip2
                call    g_dec_timers
                call    gs_time_out
                call    je_zdochnutie
                jz      gs_skip2
                call    check_loc_timeout
gs_skip2:       jmp     gs_main_lp
