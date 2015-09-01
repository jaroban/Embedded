; version 4.0

group_init:     mov     dps,#5
                mov     dpx1,#0
                mov     dptr,#g_cs_table
                mov     r0,call_no
                mov     r2,#0
gi_lp1:         mov     r1,#cs_off
                mov     a,r2
                call    je_poschodie_vypnute
                jz      gi_skip1
                mov     r1,#cs_dead
gi_skip1:       mov     dps,#5
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                inc     r2
                djnz    r0,gi_lp1

                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_cs_timeout
                mov     r0,call_no
                mov     a,#255
gi_lp2:         movx    @dptr,a
                inc     dptr
                movx    @dptr,a
                inc     dptr
                movx    @dptr,a
                inc     dptr
                djnz    r0,gi_lp2

                mov     dptr,#g_chk_table
                mov     r0,call_no
                mov     a,#pocet_zaseknuti
gi_lp3:         movx    @dptr,a
                inc     dptr
                movx    @dptr,a
                inc     dptr
                movx    @dptr,a
                inc     dptr
                djnz    r0,gi_lp3

                mov     dptr,#g_dbl_table_d
                mov     r0,call_no
                clr     a
gi_lp4:         movx    @dptr,a
                inc     dptr
                djnz    r0,gi_lp4

                mov     dptr,#g_dbl_table_h
                mov     r0,call_no
                clr     a
gi_lp5:         movx    @dptr,a
                inc     dptr
                djnz    r0,gi_lp5

                mov     dptr,#g_locations
                mov     r0,#8
                mov     a,#0ffh
gi_lp6:         movx    @dptr,a
                inc     dptr
                djnz    r0,gi_lp6

                call    gg_in_boss
                mov     others,#0
                jmp     del_volby

set_cs:         mov     dps,#0
                mov     dpx,#0
                mov     r0,a
                mov     a,r4
                rl      a
                add     a,r4
                add     a,r3
                mov     r1,a
                add     a,#low(g_cs_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_cs_table)
                mov     dph,a
                mov     a,r0
                movx    @dptr,a
                mov     dptr,#g_overflow
                movc    a,@a+dptr
                xch     a,r1
                add     a,#low(g_cs_timeout)
                mov     dpl,a
                clr     a
                addc    a,#high(g_cs_timeout)
                mov     dph,a
                mov     a,r1
                movx    @dptr,a
                ret

get_cs:         mov     dps,#0
                mov     dpx,#0
                mov     a,r4
                rl      a
                add     a,r4
                add     a,r3
                add     a,#low(g_cs_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_cs_table)
                mov     dph,a
                movx    a,@dptr
                ret

set_cmp:        mov     dps,#0
                mov     dpx,#0
                mov     a,r4
                rl      a
                add     a,r3
                dec     a
                rl      a
                add     a,#low(g_cmp_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_cmp_table)
                mov     dph,a
                mov     a,r5
                movx    @dptr,a
                inc     dptr
                mov     a,r6
                movx    @dptr,a
                ret

cmp_cmp:        mov     dps,#0
                mov     dpx,#0
                mov     a,r4
                rl      a
                add     a,r3
                dec     a
                rl      a
                add     a,#low(g_cmp_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_cmp_table)
                mov     dph,a
                movx    a,@dptr
                clr     c
                subb    a,r5
                jc      cc_0
                jnz     cc_1
                inc     dptr
                movx    a,@dptr
                setb    c
                subb    a,r6
                jnc     cc_skip
cc_0:           clr     a
                ret
cc_1:           mov     a,r5
                movx    @dptr,a
                inc     dptr
cc_skip:        mov     a,r6
                movx    @dptr,a
                mov     a,#0ffh
                ret

g_dec_timers:   mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_cs_timeout
                mov     a,call_no
                rl      a
                add     a,call_no
                mov     r0,a
gdt_lp:         movx    a,@dptr
                inc     a
                jz      gdt_skip
                dec     a
                jz      gdt_skip
                dec     a
                movx    @dptr,a
gdt_skip:       inc     dptr
                djnz    r0,gdt_lp
                ret

g_je_volba:     mov     a,r3
                cjne    a,#g_hore,gjv_1
                jmp     je_hore
gjv_1:          cjne    a,#g_dole,gjv_2
                jmp     je_dole
gjv_2:          cjne    a,#g_kabina,gjv_ret
                jmp     je_kabina
gjv_ret:        clr     a
                ret

g_check_stuck:  mov     r0,a
                mov     a,r4
                rl      a
                add     a,r4
                add     a,r3
                add     a,#low(g_chk_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_chk_table)
                mov     dph,a
                mov     a,r0
                jz      gch_inc
                movx    a,@dptr
                djnz    acc,gch_store
                mov     a,#cs_stuck
                jmp     set_cs
gch_inc:        movx    a,@dptr
                inc     a
                xrl     a,#pocet_zaseknuti+1
                jz      gch_ok
                xrl     a,#pocet_zaseknuti+1
gch_store:      movx    @dptr,a
gch_ok:         mov     a,#cs_off
                jmp     set_cs

double_click_reset:
                mov     a,r3
                cjne    a,#g_hore,double_click_reset_dole
double_click_reset_hore:
                mov     dps,#0
                mov     dptr,#g_dbl_table_h
                sjmp    dcr_skip
double_click_reset_dole:
                mov     dps,#0
                mov     dptr,#g_dbl_table_d
dcr_skip:       mov     dpx,#0
                mov     a,r4
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                clr     a
                movx    @dptr,a
                ret
                
double_click_hore:
                mov     r0,a
                mov     dps,#0
                mov     dptr,#g_dbl_table_h
                sjmp    double_click
double_click_dole:
                mov     r0,a
                mov     dps,#0
                mov     dptr,#g_dbl_table_d
double_click:   mov     dpx,#0
                mov     a,r4
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                movx    a,@dptr
                mov     r2,a
                jnz     dc_running
                ; state == 0
                mov     a,r0
                jz      dc_ret_0
                ; input == 1
                mov     a,#1
                movx    @dptr,a
                ; reset timer
                mov     a,r3
                dec     a
                swap    a
                rl      a
                add     a,r4
                add     a,#low(t_double_click)
                mov     dpl,a
                clr     a
                addc    a,#high(t_double_click)
                mov     dph,a
                mov     r2,#tmr_per_sec     ; == 1 second
                call    init_timer2
dc_ret_0:       clr     a
                ret
dc_running:     ; state > 0
                mov     c,acc.0
                mov     a,r0
                jnz     dc_got_1
                cpl     c
dc_got_1:       jc      dc_chk_time
                ; input changed
                inc     r2
                mov     a,r2
                movx    @dptr,a
                
dc_chk_time:    mov     a,r3
                dec     a
                swap    a
                rl      a
                add     a,r4
                push    dpl
                push    dph
                add     a,#low(t_double_click)
                mov     dpl,a
                clr     a
                addc    a,#high(t_double_click)
                mov     dph,a
                call    timer_running2
                pop     dph
                pop     dpl
                jnz     dc_ret_0
                ; timer expired
                clr     a
                movx    @dptr,a
                mov     a,r2
                clr     c
                subb    a,#3
                jc      dc_ret_1
                ; 2x click
                call    cislo_v_skupine
                cjne    a,#1,dc_ret_0
                ; only for elevator #1
                mov     a,#2
                ret
                ; 1x click
dc_ret_1:       mov     a,#1
                ret

check_loc_timeout:
                mov     dps,#00100100b
                mov     dpx,#0
                mov     dpx1,#0
                mov     dptr,#t_locations   ; 0
                mov     dptr,#g_locations   ; 1
                mov     r1,#8
                mov     others,#0
clt_lp1:        mov     dps,#1
                movx    a,@dptr             ; 1
                cpl     a
                jz      clt_skip1
                inc     others
                call    timer_running
                mov     dps,#1
                jnz     clt_skip1
                mov     a,#0ffh
                movx    @dptr,a             ; 1
clt_skip1:      inc     dptr
                mov     dps,#0
                inc     dptr                ; 0
                inc     dptr
                inc     dptr
                djnz    r1,clt_lp1
                ret
