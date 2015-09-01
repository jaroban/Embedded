; version 1.0

if auto_vytah_special

aus_volby:      mov     r3,#0
                mov     r0,#call_table
                mov     a,@r0
                anl     a,#7
                jz      ausv_skip1
                inc     r3
ausv_skip1:     mov     r0,#call_table+1
                mov     a,@r0
                anl     a,#7
                jz      ausv_skip2
                inc     r3
                inc     r3
ausv_skip2:     mov     a,r3
                ret

au_special:     call    timer_running_reload_f
                dw      t_aus
                db      0,1,0
                jnz     aus_skip0
                inc     au_free_open
aus_skip0:

                jnb     ovazenie_10,aus_no_stops
                mov     a,#1010b
au_drain:       mov     r7,a
                anl     a,#1
                mov     r0,#p_au_out_a_go
                call    trans_write
                mov     a,r7
                anl     a,#2
                mov     r0,#p_au_out_a_stop
                call    trans_write
                mov     a,r7
                anl     a,#4
                mov     r0,#p_au_out_b_go
                call    trans_write
                mov     a,r7
                anl     a,#8
                mov     r0,#p_au_out_b_stop
                jmp     trans_write
                
aus_no_stops:   mov     a,liftpos
                jnz     aus_first
                call    aus_volby
                cjne    a,#2,aus_skip1
                mov     a,au_free_open
                mov     c,acc.0
                mov     a,#1010b
                mov     acc.2,c
                jmp     au_drain
aus_skip1:      mov     a,#1001b
                jmp     au_drain
aus_first:      call    aus_volby
                cjne    a,#1,aus_skip2
                mov     a,au_free_open
                mov     c,acc.0
                mov     a,#1010b
                mov     acc.0,c
                jmp     au_drain
aus_skip2:      mov     a,#0110b
                jmp     au_drain
else
au_update_in:   mov     a,#p_svetelna_zavora_a
                call    get_a14_a21
                mov     r2,a
                mov     a,#p_au_in_a
                call    get_a14_a21
                mov     r3,a
                mov     a,#p_vazenie_10
                call    get_a14_a21
                mov     r4,a
                mov     a,#p_au_in_b
                call    get_a14_a21
                mov     r5,a
                mov     a,#p_svetelna_zavora_b
                call    get_a14_a21
                mov     r6,a

                mov     au_free_open,#0
                mov     r0,#2
                mov     r1,#5
aui_lp1:        mov     a,@r0
                jnz     aui_skip1
                inc     au_free_open
                inc     r0
                djnz    r1,aui_lp1

aui_skip1:      mov     au_free_wall,#0
                mov     r0,#6
                mov     r1,#5
aui_lp2:        mov     a,@r0
                jnz     aui_skip2
                inc     au_free_wall
                dec     r0
                djnz    r1,aui_lp2

aui_skip2:      mov     a,my_liftpos
                call    su_dvere_a
                jz      aui_skip3
                mov     a,au_free_open
                xch     a,au_free_wall
                mov     au_free_open,a
aui_skip3:      ret

au_out_outside: mov     a,au_free_open
                cjne    a,#5,aoo_stop
                mov     a,dra_flags
                orl     a,drb_flags
                anl     a,#dm_opening+dm_waiting+dm_closing
                jnz     aoo_stop
                call    je_nejaka_volba
                jz      aoo_free
                mov     a,nextfloor
                cjne    a,#2,aoo_stop
aoo_free:       mov     a,#0ffh
                sjmp    aoo_out
aoo_stop:       clr     a
aoo_out:        mov     r0,#p_au_out_free
                jmp     trans_write

au_out_open:    mov     a,au_free_open
                xrl     a,#5
                jz      aoop_nothing
                mov     a,dra_flags
                anl     a,drb_flags
                jb      db_closed,aoop_stop
                mov     r7,#1
                sjmp    aoop_drain
aoop_nothing:   mov     r7,#0
                sjmp    aoop_drain
aoop_stop:      mov     r7,#2
                jnb     rele_svetlo,aoop_drain
                mov     r7,#0
aoop_drain:     mov     a,my_liftpos
                call    su_dvere_a
                jnz     au_out_dvere_a
                sjmp    au_out_dvere_b

au_out_wall:    mov     a,au_free_wall
                xrl     a,#5
                jz      aoow_nothing
                mov     a,dra_flags
                anl     a,drb_flags
                jb      db_closed,aoow_stop
                mov     a,au_free_open
                clr     c
                subb    a,#2
                jc      aoow_back
                mov     a,au_free_wall
                jz      aoow_go
                dec     a
                jz      aoow_go
                xrl     a,#4
                jz      aoow_go
aoow_stop:      mov     r7,#2
                jnb     rele_svetlo,aoow_drain
aoow_nothing:   mov     r7,#0
                sjmp    aoow_drain
aoow_go:        mov     r7,#1
                sjmp    aoow_drain
aoow_back:      mov     r7,#4
aoow_drain:     mov     a,my_liftpos
                call    su_dvere_b
                jnz     au_out_dvere_a
                sjmp    au_out_dvere_b

au_out_dvere_a: mov     a,r7
                anl     a,#1
                mov     r0,#p_au_out_a_go
                call    trans_write
                mov     a,r7
                anl     a,#2
                mov     r0,#p_au_out_a_stop
                call    trans_write
                mov     a,r7
                anl     a,#4
                mov     r0,#p_au_out_a_back
                jmp     trans_write

au_out_dvere_b: mov     a,r7
                anl     a,#1
                mov     r0,#p_au_out_b_go
                call    trans_write
                mov     a,r7
                anl     a,#2
                mov     r0,#p_au_out_b_stop
                call    trans_write
                mov     a,r7
                anl     a,#4
                mov     r0,#p_au_out_b_back
                jmp     trans_write
endif
