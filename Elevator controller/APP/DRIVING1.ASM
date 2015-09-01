; version 4.0

je_tu_volba:    
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     jtv_orig
				mov		a,floor_no
				add		a,#call_table
				mov		r0,a
                mov     a,@r0
				mov		r1,a
				inc		r0
                mov     a,@r0
				orl		a,r1
                anl     a,#7
                ret
jtv_orig:
endif
				mov     a,liftpos
                add     a,#call_table
                mov     r0,a
                mov     a,@r0
                anl     a,#7
                ret

je_tu_volba2:   
if na_jednom_poschodi_dve_volby
                mov     a,liftpos
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     jtv2_orig
				mov		a,floor_no
				add		a,#call_table
				mov		r0,a
                mov     a,@r0
				mov		r1,a
				inc		r0
                mov     a,@r0
				orl		a,r1
                anl     a,#7
                ret
jtv2_orig:
endif
				mov     a,dr_state
                mov     r0,#7
                cjne    a,#dr_dole,jtv2_skip1
                mov     r0,#3
jtv2_skip1:     cjne    a,#dr_hore,jtv2_skip2
                mov     r0,#5
                
jtv2_skip2:     mov     a,liftpos
                add     a,#call_table
                mov     r1,a
                mov     a,@r1
                anl     a,r0
                ret

je_nejaka_volba:
                mov     b,#0
                mov     r0,#call_table
                mov     r1,floor_no
jnv_lp:         mov     a,@r0
                orl     b,a
                inc     r0
                djnz    r1,jnv_lp
                mov     a,b
                anl     a,#7
                ret

je_kabinova_volba:
                mov     b,#0
                mov     r0,#call_table
                mov     r1,floor_no
jkv_lp:         mov     a,@r0
                orl     b,a
                inc     r0
                djnz    r1,jkv_lp
                mov     a,b
                anl     a,#1
                ret

kde_je_kabinova_volba:
                mov     r0,#call_table
                mov     r1,#0
                mov     r2,floor_no
kjkv_lp:        mov     a,@r0
                jb      acc.0,kjkv_ret
                inc     r0
                inc     r1
                djnz    r2,kjkv_lp
                clr     a
                ret
kjkv_ret:       mov     a,r1
                ret

kolko_je_volieb:
                mov     r0,#call_table
                mov     r1,floor_no
                mov     r2,#0
kjv_lp:         mov     a,@r0
                anl     a,#7
                jz      kjv_skip
                inc     r2
kjv_skip:       inc     r0
                djnz    r1,kjv_lp
                mov     a,r2
                ret

kolko_je_kabinovych:
                mov     r0,#call_table
                mov     r1,floor_no
                mov     r2,#0
kjk_lp:         mov     a,@r0
                anl     a,#1
                jz      kjk_skip
                inc     r2
kjk_skip:       inc     r0
                djnz    r1,kjk_lp
                mov     a,r2
                ret

kabinova_nad:   mov     r3,#1
                sjmp    something_up

nejaka_nad:     mov     a,#1
                mov     c,ovazenie_80
                cpl     c
                mov     acc.1,c
                mov     acc.2,c
                mov     r3,a

something_up:   mov     a,liftpos
                mov     r0,a
                mov     a,floor_no
                dec     a
                mov     r2,a
                mov     a,r0
                clr     c
                subb    a,r2
                jnc     su_no
                mov     a,r2
                add     a,#call_table
                mov     r1,a
                mov     b,#0
su_lp:          mov     a,@r1
                orl     b,a
                dec     r1
                dec     r2
                mov     a,r0
                clr     c
                subb    a,r2
                jc      su_lp
                mov     a,b
                anl     a,r3
                ret
su_no:          clr     a
                ret

kabinova_pod:   mov     r3,#1
                sjmp    something_down

nejaka_pod:     mov     a,#1
                mov     c,ovazenie_80
                cpl     c
                mov     acc.1,c
                mov     acc.2,c
                mov     r3,a

something_down: mov     a,liftpos
                mov     r0,a
                jz      sd_no
                clr     a
                mov     r1,#call_table
                mov     r2,a
                mov     b,a
sd_lp:          mov     a,@r1
                orl     b,a
                inc     r1
                inc     r2
                mov     a,r2
                clr     c
                subb    a,r0
                jc      sd_lp
                mov     a,b
                anl     a,r3
                ret
sd_no:          clr     a
                ret

next_up:        mov     a,floor_no
                dec     a
                cjne    a,liftpos,nu_ok1
                mov     a,#0ffh
                ret
nu_ok1:         mov     r0,a
                add     a,#call_table
                mov     r1,a
                mov     b,#0ffh
                mov     a,#00000101b
                mov     c,ovazenie_80
                cpl     c
                mov     acc.2,c
                mov     r2,a
nu_lp1:         mov     a,@r1
                anl     a,r2
                jz      nu_no1
                mov     b,r0
nu_no1:         dec     r0
                dec     r1
                mov     a,liftpos
                clr     c
                subb    a,r0
                jc      nu_lp1
                mov     a,b
                cjne    a,#0ffh,nu_end
                inc     r0
                inc     r1
                mov     a,r2
                clr     acc.0
                rr      a
                mov     r2,a
nu_lp2:         mov     a,@r1
                anl     a,r2
                jz      nu_no2
                mov     b,r0
nu_no2:         inc     r0
                inc     r1
                mov     a,r0
                clr     c
                subb    a,floor_no
                jc      nu_lp2
                mov     a,b
nu_end:         ret

next_down:      mov     a,liftpos
                jnz     nd_ok1
                cpl     a       
                ret
nd_ok1:         clr     a
                mov     r0,a
                mov     r1,#call_table
                mov     b,#0ffh
                mov     a,#00000011b
                mov     c,ovazenie_80
                cpl     c
                mov     acc.1,c
                mov     r2,a
nd_lp1:         mov     a,@r1
                anl     a,r2
                jz      nd_no1
                mov     b,r0
nd_no1:         inc     r0
                inc     r1
                mov     a,r0
                clr     c
                subb    a,liftpos
                jc      nd_lp1
                mov     a,b
                cjne    a,#0ffh,nd_end
                mov     a,r2
                clr     acc.0
                rl      a
                mov     r2,a
nd_lp2:         dec     r0
                dec     r1
                mov     a,@r1
                anl     a,r2
                jz      nd_no2
                mov     b,r0
nd_no2:         mov     a,r0
                jnz     nd_lp2
                mov     a,b
nd_end:         ret

next_one:       mov     r2,floor_no
                mov     r1,#0
                mov     r0,#call_table
no_lp:          mov     a,@r0
                anl     a,#7
                jz      no_skip
                mov     b,r1
no_skip:        inc     r0
                inc     r1
                djnz    r2,no_lp
                mov     a,b
                ret

