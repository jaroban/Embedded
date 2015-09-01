; version 4.0

inc_init:       setb    inc_dir
                setb    inc_toggle
                call    je_inkrement
                jz      ii_ret
                mov     inc_cnt_hi,#1
                mov     inc_cnt_lo,#0
                setb    inc_running
ii_ret:         ret

reset_inc_counter:
                clr     ea
                mov     inc_cnt_hi,#1
                mov     inc_cnt_lo,#0
                setb    ea
                ret

get_inc_data:   rl      a
                add     a,#low(increment_table)
                mov     dpl,a
                clr     a
                addc    a,#high(increment_table)
                mov     dph,a
                movx    a,@dptr
                mov     r4,a
                inc     dptr
                movx    a,@dptr
                mov     r3,a
                ret

put_inc_data:   rl      a
                add     a,#low(increment_table)
                mov     dpl,a
                clr     a
                addc    a,#high(increment_table)
                mov     dph,a
                mov     a,r4
                movx    @dptr,a
                inc     dptr
                mov     a,r3
                movx    @dptr,a
                ret

set_inc_data:   mov     a,liftpos
                call    get_inc_data
                clr     ea
                mov     inc_cnt_lo,r3
                mov     inc_cnt_hi,r4
                setb    ea
                ret

brzdit_vys_hore:
                call    je_inkrement
                jz      bvh_normal
                call    brzdenie_vys
                mov     r5,a
bvh_entry:      mov     a,nextfloor
                call    get_inc_data
                clr     ea
                mov     a,inc_cnt_lo
                add     a,r5
                mov     r0,a
                clr     a
                addc    a,inc_cnt_hi
                mov     r1,a
                clr     c
                mov     a,r3
                subb    a,r0
                mov     a,r4
                subb    a,r1
                setb    ea
                jnc     bvh_no
                ; update liftpos
                mov     liftpos,nextfloor
                mov     a,#0ffh
                ret
bvh_normal:     call    aka_nahrada
                jnz     bvh_yes
                call    je_nad_hornym
                jnz     bvh_yes
                mov     a,liftpos
                inc     a
                clr     c
                subb    a,nextfloor
                jnc     bvh_yes
bvh_no:         clr     a
                ret
bvh_yes:        mov     a,#0ffh
                ret

brzdit_vys_dole:
                call    je_inkrement
                jz      bvd_normal
                call    brzdenie_vys
                mov     r5,a
bvd_entry:      mov     a,nextfloor
                call    get_inc_data
                clr     ea
                mov     a,r3
                add     a,r5
                mov     r0,a
                clr     a
                addc    a,r4
                mov     r1,a
                clr     c
                mov     a,inc_cnt_lo
                subb    a,r0
                mov     a,inc_cnt_hi
                subb    a,r1
                setb    ea
                jnc     bvd_no
                ; update liftpos
                mov     liftpos,nextfloor
                mov     a,#0ffh
                ret
bvd_normal:     
if bratislava_dolny
                mov     a,nextfloor
                jnz     bvd_special
                jmp     je_dolny
bvd_special:
endif
                call    aka_nahrada
                jnz     bvd_yes
                call    je_pod_dolnym
                jnz     bvd_yes
                mov     a,nextfloor
                inc     a
                clr     c
                subb    a,liftpos
                jnc     bvd_yes
bvd_no:         clr     a
                ret
bvd_yes:        mov     a,#0ffh
                ret

brzdit_par_hore:
                call    je_inkrement
                jz      bph_normal
                call    brzdenie_par
                mov     r5,a
                jmp     bvh_entry
bph_normal:     mov     a,liftpos
                clr     c
                subb    a,nextfloor
                jnc     bvh_yes
                clr     a
                ret

brzdit_par_dole:
                call    je_inkrement
                jz      bpd_normal
                call    brzdenie_par
                mov     r5,a
                jmp     bvd_entry
bpd_normal:     mov     a,nextfloor
                clr     c
                subb    a,liftpos
                jnc     bvd_yes
                clr     a
                ret
                
brzdit_niz_hore:
                call    aka_nahrada
                jnz     bnh_yes
                mov     a,liftsub
                cjne    a,#1,bnh_no
bnh_yes:        mov     a,#0ffh
                ret
bnh_no:         clr     a
                ret

brzdit_niz_dole:
                call    aka_nahrada
                jnz     bnd_yes
                mov     a,liftsub
                cjne    a,#1,bnd_no
bnd_yes:        mov     a,#0ffh
                ret
bnd_no:         clr     a
                ret
