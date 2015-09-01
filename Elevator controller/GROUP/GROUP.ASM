; version 4.0

gg_confirm:     mov     a,r4
                add     a,#call_table
                mov     r0,a
                mov     a,r3
                call    get_nrm_mask
                swap    a
                orl     a,@r0
                mov     @r0,a
                jmp     double_click_reset

gg_unconfirm:   mov     a,r4
                add     a,#call_table
                mov     r0,a
                mov     a,r3
                call    get_nrm_cpl_mask
                swap    a
                anl     a,@r0
                mov     @r0,a
                jmp     double_click_reset

gg_del_call:    mov     a,r3
                xrl     a,#g_kabina
                jz      ggdc_skip
                call    g_send_del
ggdc_skip:      jmp     gs_del_call

gg_in_cmp:      mov     a,r3
                xrl     a,#g_kabina
                jz      ggic_ret
                mov     a,r3
                clr     c
                subb    a,#3
                jnc     ggic_ret
                mov     a,r4
                clr     c
                subb    a,floor_no
                jnc     ggic_ret
                mov     a,r3
                call    do_case
                dw      g_dole+c_,moze_dole_combo
                dw      g_hore+c_,moze_hore_combo
                db      0
                jz      ggic_ret
                call    get_cs
                call    do_case
                dw      cs_off+j_,ggic_off
                dw      cs_cmp_me+j_,ggic_cmp_me
                dw      cs_cmp_them+j_,ggic_rst_them
                dw      cs_on_me+j_,ggic_off
                dw      cs_on_them+j_,ggic_off
                db      0
ggic_ret:       ret
ggic_off:       call    set_cmp
                call    g_calculate
                call    cmp_cmp
                jz      ggic_lost
                mov     a,#cs_cmp_me
                call    set_cs
                jmp     g_send_cmp
ggic_lost:      mov     a,#cs_cmp_them
                jmp     set_cs
ggic_cmp_me:    call    cmp_cmp
                jz      ggic_rst_me
ggic_rst_them:  call    gg_unconfirm
                mov     a,#cs_cmp_them
                jmp     set_cs
ggic_rst_me:    mov     a,#cs_cmp_me
                jmp     set_cs

gg_in_del:      mov     a,r3
                jz      ggid_ret
                clr     c
                subb    a,#3
                jnc     ggid_ret
                mov     a,r4
                clr     c
                subb    a,floor_no
                jnc     ggid_ret
                call    get_cs
                xrl     a,#cs_dead
                jz      ggid_ret
                xrl     a,#cs_dead xor cs_on
                jz      ggid_ret
                xrl     a,#cs_on xor cs_stuck
                jz      ggid_ret
                mov     a,#cs_numb
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_dole+j_,del_dole_sft
                dw      g_hore+j_,del_hore_sft
                db      0
ggid_ret:       ret

gg_in_zak:      mov     a,r3
                jz      ggiz_ret
                clr     c
                subb    a,#3
                jnc     ggiz_ret
                mov     a,r4
                clr     c
                subb    a,floor_no
                jnc     ggiz_ret
                call    get_cs
                xrl     a,#cs_dead
                jz      ggiz_ret
                xrl     a,#cs_dead xor cs_on
                jz      ggiz_ret
                xrl     a,#cs_on xor cs_stuck
                jz      ggiz_ret
                ; exception
                call    cislo_v_skupine
                cjne    a,#1,ggiz_ok
                ; i am elevator #1
                call    hlavna_stanica
                jz      ggiz_ok
                dec     a
                cjne    a,ar4,ggiz_ok
                ; in main floor
                ret
ggiz_ok:        mov     a,#cs_just_them
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_dole+j_,del_dole_sft
                dw      g_hore+j_,del_hore_sft
                db      0
ggiz_ret:       ret

gg_in_loc:      mov     dps,#0
                mov     dpx,#0
                mov     a,r3
                anl     a,#7
                add     a,#low(g_locations)
                mov     dpl,a
                clr     a
                addc    a,#high(g_locations)
                mov     dph,a
                mov     a,r4
                movx    @dptr,a
                mov     a,r3
                anl     a,#7
                ; a *= timer_size
                mov     r0,a
                rl      a
                add     a,r0
                add     a,#low(t_locations)
                mov     dpl,a
                clr     a
                addc    a,#high(t_locations)
                mov     dph,a
                mov     r0,#0
                mov     r1,#20
                mov     r2,#0
                jmp     init_timer

gg_in_boss:     setb    im_da_boss
                call    zdielane_vonkajsie
                jz      ggib_ret
                clr     im_da_boss
                call    mux_clock_0
                call    mux_wr_zero
                call    cislo_v_skupine
                anl     a,#7
                add     a,#2
                mov     r0,#0
                mov     r1,a
                mov     r2,#0
                mov     dps,#0
                mov     dptr,#t_boss
                jmp     init_timer
ggib_ret:       ret

gg_poll_calls:  call    moze_hore
                jz      ggpc_dole
                mov     r7,floor_no
                mov     r4,#0
                mov     r3,#g_hore
ggpch_lp:       call    get_cs
                cjne    a,#cs_off,ggpch_skip5
                call    moze_hore_p
                jz      ggpch_skip3
                call    je_double
                jnz     ggpch_skip2
                call    je_hore
                jz      ggpch_skip3
                call    je_blok
                jnz     ggpch_skip4
ggpch_skip1:    call    gg_confirm
                mov     a,#cs_cmp_me
                call    set_cs
                call    g_calculate
                call    set_cmp
                call    g_send_cmp
                sjmp    ggpch_skip3
ggpch_skip2:    call    je_hore
                call    double_click_hore
                jz      ggpch_skip3
                jb      acc.0,ggpch_skip1
ggpch_skip4:    call    add_hore_sft
                mov     a,#cs_just_me
                call    set_cs
                call    g_send_zak
                sjmp    ggpch_skip3
ggpch_skip5:    cjne    a,#cs_on_them,ggpch_skip3
                call    je_double
                jz      ggpch_skip3
                call    je_hore
                call    double_click_hore
                xrl     a,#2
                jz      ggpch_skip4
ggpch_skip3:    inc     r4
                djnz    r7,ggpch_lp

ggpc_dole:      call    moze_dole
                jz      ggpc_kabina
                mov     r7,floor_no
                mov     r4,#0
                mov     r3,#g_dole
ggpcd_lp:       call    get_cs
                cjne    a,#cs_off,ggpcd_skip5
                call    moze_dole_p
                jz      ggpcd_skip3
                call    je_double
                jnz     ggpcd_skip2
                call    je_dole
                jz      ggpcd_skip3
                call    je_blok
                jnz     ggpcd_skip4
ggpcd_skip1:    call    gg_confirm
                mov     a,#cs_cmp_me
                call    set_cs
                call    g_calculate
                call    set_cmp
                call    g_send_cmp
                sjmp    ggpcd_skip3
ggpcd_skip2:    call    je_dole
                call    double_click_dole
                jz      ggpcd_skip3
                jb      acc.0,ggpcd_skip1
ggpcd_skip4:    call    add_dole_sft
                mov     a,#cs_just_me
                call    set_cs
                call    g_send_zak
                sjmp    ggpcd_skip3
ggpcd_skip5:    cjne    a,#cs_on_them,ggpcd_skip3
                call    je_double
                jz      ggpcd_skip3
                call    je_dole
                call    double_click_dole
                xrl     a,#2
                jz      ggpcd_skip4
ggpcd_skip3:    inc     r4
                djnz    r7,ggpcd_lp

ggpc_kabina:    jmp     gspc_kabina

gg_time_out:    mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_cs_timeout
                mov     r4,#0
ggto_lp1:       mov     r3,#0
ggto_lp2:       movx    a,@dptr
                jnz     ggto_skip1
                push    dpl
                push    dph
                call    get_cs
                push    ar3
                push    ar4
                call    do_case
                dw      cs_cmp_me+c_,ggto_cmp_me
                dw      cs_cmp_them+c_,ggto_cmp_them
;                dw      cs_cmp_me+c_,ggto_spec_me
;                dw      cs_cmp_them+c_,ggto_spec_them
                dw      cs_on_me+c_,ggto_again
                dw      cs_on_them+c_,ggto_again
                dw      cs_just_me+c_,ggto_just_me
                dw      cs_just_them+c_,ggto_just_them
                dw      cs_numb+c_,ggto_numb
                dw      cs_stuck+c_,ggto_stuck
                db      0
                pop     ar4
                pop     ar3
                pop     dph
                pop     dpl
ggto_skip1:     inc     dptr
                inc     r3
                mov     a,r3
                cjne    a,#3,ggto_lp2
                inc     r4
                mov     a,r4
                cjne    a,floor_no,ggto_lp1
                ret
if 0
ggto_spec_me:   call    gg_confirm
                mov     a,#cs_just_me
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_dole+j_,add_dole_sft
                dw      g_hore+j_,add_hore_sft
                db      0
                ret

ggto_spec_them: call    gg_unconfirm
                mov     a,#cs_just_them
                jmp     set_cs
endif
ggto_cmp_me:    mov     a,#cs_on_me
                call    set_cs
                mov     a,r3
                call    do_case
                dw      g_dole+j_,add_dole_sft
                dw      g_hore+j_,add_hore_sft
                db      0
                ret

ggto_cmp_them:  call    zdielane_vonkajsie
                jnz     ggto_skip2
                call    gg_unconfirm
ggto_skip2:     mov     a,#cs_on_them
                jmp     set_cs

ggto_again:     mov     a,#cs_cmp_me
                call    set_cs
                call    g_calculate
                call    set_cmp
                jmp     g_send_cmp

ggto_just_me:   call    g_send_zak
                mov     a,#cs_just_me
                jmp     set_cs

ggto_just_them: mov     a,#cs_off
                jmp     set_cs

ggto_numb:      call    g_je_volba
                jmp     g_check_stuck

ggto_stuck:     call    g_je_volba
                jnz     ggto_s_again
                mov     a,#cs_off
                jmp     set_cs
ggto_s_again:   mov     a,#cs_stuck
                jmp     set_cs

gg_main_lp:     call    do_them
                call    do_vnts
                dw      m_del_all+c_,gs_del_all
                dw      m_del_cabin+c_,gs_del_cabin
                dw      m_new_call+c_,gs_new_call
                dw      m_del_call+c_,gg_del_call
                dw      m_del_out+c_,gs_del_out
                dw      m_cmp+c_,gg_in_cmp
                dw      m_del+c_,gg_in_del
                dw      m_zak+c_,gg_in_zak
                dw      m_loc+c_,gg_in_loc
                dw      m_boss+c_,gg_in_boss
                db      0
                jnb     poll_calls,gg_skip1
                clr     poll_calls
                call    gg_poll_calls
gg_skip1:       call    timer_running_reload_f
                dw      t_group
                db      0,0,25
                jnz     gg_skip2
                call    g_dec_timers
                call    gg_time_out
                call    check_loc_timeout
                call    moze_hore
                jz      gg_skip2
                call    moze_dole
                jz      gg_skip2
                call    timer_running_reload_f
                dw      t_location
                db      0,10,0
                jnz     gg_skip2
                call    g_send_loc
gg_skip2:       call    zdielane_vonkajsie
                jz      gg_skip4
                call    moze_hore
                jz      gg_skip3
                call    moze_dole
                jz      gg_skip3
                call    timer_running_reload_f
                dw      t_boss
                db      0,1,0
                jnz     gg_skip4
                setb    im_da_boss
                call    g_send_boss
                sjmp    gg_skip4
gg_skip3:       jnb     im_da_boss,gg_skip3a
                clr     im_da_boss
                call    mux_clock_0
                call    mux_wr_zero
gg_skip3a:      call    cislo_v_skupine
                anl     a,#7
                add     a,#2
                mov     r0,#0
                mov     r1,a
                mov     r2,#0
                mov     dps,#0
                mov     dptr,#t_boss
                call    init_timer
gg_skip4:       jmp     gg_main_lp
