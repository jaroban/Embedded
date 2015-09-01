; version 4.0

g_tm_move       equ     1*64            ; time from one floor to next
g_tm_stop       equ     3*64            ; time spent on floor

g_smer          data    8
g_liftpos       data    9
g_nextfloor     data    10
g_dn            data    11
g_up            data    12

                xseg
g_sim_table:    ds      no_of_floors

                cseg

; r0=origin  r1=destination
gc_add_time:    mov     a,r0
                clr     c
                subb    a,r1
                jnz     gat_skip1
                mov     a,#g_tm_stop
                mov     b,#0
                sjmp    gat_skip3
gat_skip1:      jnc     gat_skip2
                cpl     a
                inc     a
gat_entry:
gat_skip2:      mov     b,#g_tm_move
                mul     ab
gat_skip3:      add     a,r6
                mov     r6,a
                mov     a,b
                addc    a,r5
                mov     r5,a
                clr     a
                addc    a,r7
                mov     r7,a
                ret

g_next_up:      mov     a,floor_no
                dec     a
                mov     r0,a
                setb    c
                subb    a,g_liftpos
                jnc     gnu_ok1
                mov     a,#0ffh
                ret
gnu_ok1:        mov     a,r0
                add     a,#low(g_sim_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_sim_table)
                mov     dph,a
                mov     b,#0ffh
                mov     dps,#01000100b
gnu_lp1:        movx    a,@dptr
                anl     a,#00000101b
                jz      gnu_nix1
                mov     b,r0
gnu_nix1:       dec     r0
                inc     dptr
                mov     a,r0
                cjne    a,g_liftpos,gnu_lp1
                mov     dps,#0
                mov     a,b
                cjne    a,#0ffh,gnu_end
                inc     r0
                inc     dptr
gnu_lp2:        movx    a,@dptr
                anl     a,#00000010b
                jz      gnu_nix2
                mov     b,r0
gnu_nix2:       inc     r0
                inc     dptr
                mov     a,r0
                cjne    a,floor_no,gnu_lp2
                mov     a,b
gnu_end:        ret

g_sim_del_h:    add     a,#low(g_sim_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_sim_table)
                mov     dph,a
                movx    a,@dptr
                anl     a,#11111010b
                movx    @dptr,a
                ret

g_next_down:    mov     a,g_liftpos
                jnz     gnd_ok1
                cpl     a       
                ret
gnd_ok1:        clr     a
                mov     r0,a
                mov     dptr,#g_sim_table
                mov     b,#0ffh
gnd_lp1:        movx    a,@dptr
                anl     a,#00000011b
                jz      gnd_nix1
                mov     b,r0
gnd_nix1:       inc     r0
                inc     dptr
                mov     a,r0
                cjne    a,g_liftpos,gnd_lp1
                mov     a,b
                cjne    a,#0ffh,gnd_end
                mov     dps,#01000100b
gnd_lp2:        dec     r0
                inc     dptr
                movx    a,@dptr
                anl     a,#00000100b
                jz      gnd_nix2
                mov     b,r0
gnd_nix2:       mov     a,r0
                jnz     gnd_lp2
                mov     dps,#0
                mov     a,b
gnd_end:        ret

g_sim_del_d:    add     a,#low(g_sim_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_sim_table)
                mov     dph,a
                movx    a,@dptr
                anl     a,#11111100b
                movx    @dptr,a
                ret

; r7r5r6 = sum
g_sim_ret2:     ret
g_simulate:     ; get existing calls
                mov     r0,#call_table
                mov     r1,floor_no
                mov     dptr,#g_sim_table
                mov     r7,#0
g_sim_lp1:      mov     a,@r0
                anl     a,#7
                movx    @dptr,a
                jz      g_sim_skip0
                inc     r7
g_sim_skip0:    inc     r0
                inc     dptr
                djnz    r1,g_sim_lp1
                push    ar7
                
                ; add investigated call
                mov     a,r4
                add     a,#low(g_sim_table)
                mov     dpl,a
                clr     a
                addc    a,#high(g_sim_table)
                mov     dph,a
                mov     a,r3
                call    get_nrm_mask
                mov     r0,a
                movx    a,@dptr
                orl     a,r0
                movx    @dptr,a

                ; zero result
                clr     a
                mov     r6,a
                mov     r5,a
                mov     r7,a
                
                pop     acc
                jnz     g_sim_got_calls
                ; sem pridem ak nemam ziadne ine volby
                ; exception zo zotrvacnosti:
                ; ak je volba v "mojej" stanici tak ju zoberiem
                mov     a,liftpos
                xrl     a,r4
                jz      g_sim_ret2
                ; aby som sa nepohol kym druhy vytah nema niekolko volieb
                ; cim vacsie cislo tym neskor pojdem
                call    zotrvacnost
                call    gat_entry
                ; volba nie je v mojej stanici takze ideme pocitat

g_sim_got_calls:
                ; inicializacia simulacie
                mov     g_liftpos,liftpos
                mov     g_smer,#0
                
                ; urcenie smeru
                mov     a,dr_state
                xrl     a,#dr_dole
                jz      g_sim_dole
                
                mov     a,dr_state
                xrl     a,#dr_prednost_dole
                jz      g_sim_dole

                mov     a,dr_state
                xrl     a,#dr_hore
                jz      g_sim_hore

                mov     a,dr_state
                xrl     a,#dr_prednost_hore
                jz      g_sim_hore
                
                mov     a,smer
                anl     a,#3
                xrl     a,#hore
                jz      g_sim_hore

                mov     a,smer
                anl     a,#3
                xrl     a,#dole
                jz      g_sim_dole

                jb      rele_hore,g_sim_hore
                jb      rele_dole,g_sim_dole
                
                ; don't know smer

g_sim_hore:     inc     g_smer
g_sim_dole:
                ; ending condition
g_sim_lp2:      mov     a,r4
                xrl     a,g_liftpos
                jnz     g_sim_skip1
                mov     a,r3
                dec     a
                xrl     a,g_smer
                jz      g_sim_ret
                
g_sim_skip1:    mov     a,g_smer
                jnz     g_sim_skip_up
                ; going down
                call    g_next_down
                mov     g_dn,a
                cjne    a,#0ffh,g_sim_dn_ok
                ; down -> up
                mov     g_smer,#1
                call    g_next_up
                inc     a
                jz      g_sim_ret
                jmp     g_sim_lp2
                ; move down
g_sim_dn_ok:    mov     a,g_dn
                call    g_sim_del_d
                mov     a,g_dn
                sjmp    g_sim_go_there
                ; going up
g_sim_skip_up:  call    g_next_up
                mov     g_up,a
                cjne    a,#0ffh,g_sim_up_ok
                ; up -> down
                mov     g_smer,#0
                call    g_next_down
                inc     a
                jz      g_sim_ret
                jmp     g_sim_lp2
                ; move up
g_sim_up_ok:    mov     a,g_up
                call    g_sim_del_h
                mov     a,g_up
                ; actual addition
g_sim_go_there: mov     g_nextfloor,a
                mov     r0,g_liftpos
                mov     r1,a
                call    gc_add_time
                mov     a,g_nextfloor
                mov     g_liftpos,a
                mov     r0,a
                mov     r1,a
                call    gc_add_time
                jmp     g_sim_lp2
g_sim_ret:      ret

; r3=call type  r4=floor
g_calculate:    mov     dps,#0
                mov     dpx,#0
                mov     a,liftpos
                inc     a
                jz      gc_ffff
                jb      ovazenie_80,gc_ffff
                push    ar3
                push    ar4
                push    ar7
                call    g_simulate
                mov     a,r7
                pop     ar7
                pop     ar4
                pop     ar3
                jnz     gc_ffff
                ; make space
                mov     a,r6
                anl     a,#0c0h
                mov     r6,a
                ; add random element
                call    random
                anl     a,#038h
                orl     a,r6
                mov     r6,a
                ; add distinct element
                call    cislo_v_skupine
                anl     a,#7
                orl     a,r6
                mov     r6,a
                ret
gc_ffff:        mov     a,#0ffh
                mov     r5,a
                mov     r6,a
                ret
