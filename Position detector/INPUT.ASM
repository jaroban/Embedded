; version 1.0

zapni_na_sekundu:
                setb    k1
                clr     k2
                call    tmr_int_f
                db      t_sekunda,0,5,0
                setb    na_sekundu
                ret

is_word_nz:     mov     a,@r0
                jnz     iwnz_ret
                inc     r0
                mov     a,@r0
                dec     r0
iwnz_ret:       ret

reset_counter:  clr     a
                mov     counted,a
                mov     counted+1,a
                mov     prescaler,a
                setb    cnt_changed
                ret

initial_thread: setb    snimac_a
                setb    snimac_b
                setb    k1
                setb    k2
                clr     running
                setb    svetlo
                clr     na_sekundu
                clr     at_least_one
                clr     overflow
                mov     cmp_ind,#0

                mov     p2,#0ffh
                clr     cnt_changed
                setb    going_up

                mov     dptr,#display
                call    run_it

main_main_lp:   call    do_them
                call    read_snimace
                call    change_pos
                mov     a,#t_vstupy
                call    tmr_zro
                jnc     mm_skip1
                call    tmr_int_f
                db      t_vstupy,0,0,1
                call    read_inputs
mm_skip1:       jnb     at_least_one,mm_skip2
                
                jnb     na_sekundu,mm_skip1_5
                mov     a,#t_sekunda
                call    tmr_zro
                jnc     mm_skip2
                clr     na_sekundu
                ; 5 secs after pre
                setb    k2
                
mm_skip1_5:     jnb     overflow,mm_skip2
                clr     overflow
                ; counter done
                setb    k1
                call    reset_counter
                clr     running
                
                mov     r1,cmp_ind
mm_lp1:         mov     a,r1
                inc     a
                anl     a,#7
                mov     r1,a
                rl      a
                add     a,#cmp_table
                mov     r0,a
                call    is_word_nz
                jz      mm_lp1
                mov     cmp_ind,r1
                setb    cmp_changed
mm_skip2:       jmp     main_main_lp

read_inputs:    mov     a,p2
                cpl     a
                mov     r0,#mjrt_bffr
                mov     r1,#mjrt_bffr+5
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
                mov     inputs,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
do_maj5_lp:     mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     inputs,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp
                ret

xlat_majority5: anl     a,#1fh
                inc     a
                movc    a,@a+pc
                ret
                db      0,0,0,0,0,0,0,1
                db      0,0,0,1,0,1,1,1
                db      0,0,0,1,0,1,1,1
                db      0,1,1,1,1,1,1,1

read_snimace:   mov     c,snimac_a
                cpl     c
                mov     a,buffer_a
                rlc     a
                mov     buffer_a,a
                call    xlat_majority5
                mov     c,acc.0
                mov     snimace.0,c
                mov     c,snimac_b
                cpl     c
                mov     a,buffer_b
                rlc     a
                mov     buffer_b,a
                call    xlat_majority5
                mov     c,acc.0
                mov     snimace.1,c
                ret

change_pos:     mov     a,osnimace
                anl     a,#3
                rl      a
                rl      a
                mov     r0,a
                mov     a,snimace
                anl     a,#3
                mov     osnimace,a
                orl     a,r0
                mov     r0,a
                rl      a
                add     a,r0
                mov     dptr,#cp_table
                jmp     @a+dptr

cp_table:       ljmp    cp_ret
                ljmp    cp_up
                ljmp    cp_down
                ljmp    cp_maybe_inc

                ljmp    cp_down
                ljmp    cp_ret
                ljmp    cp_maybe_inc
                ljmp    cp_inc

                ljmp    cp_up
                ljmp    cp_maybe_dec
                ljmp    cp_ret
                ljmp    cp_down

                ljmp    cp_maybe_dec
                ljmp    cp_dec
                ljmp    cp_up
                ljmp    cp_ret

cp_ret:         ret

cp_up:          setb    going_up
                ret

cp_down:        clr     going_up
                ret

cp_maybe_inc:   jb      going_up,cp_inc
                ret

cp_maybe_dec:   jnb     going_up,cp_dec
                ret

cp_dec:         clr     going_up
                mov     a,counted
                jnz     cpd_ok
                mov     a,counted+1
                jnz     cpd_ok
                mov     a,prescaler
                jz      cpd_ret
cpd_ok:         setb    cnt_changed
                mov     a,prescaler
                jz      cpd_skip
                dec     prescaler
                ret
cpd_skip:       mov     prescaler,#no_of_spots-1
                mov     a,#99h
                add     a,counted+1
                da      a
                mov     counted+1,a
                jc      cpd_ret
                mov     a,#99h
                add     a,counted
                da      a
                mov     counted,a
cpd_ret:        ret

cp_inc:         setb    going_up
                setb    cnt_changed

                inc     prescaler
                mov     a,prescaler
                cjne    a,#no_of_spots,cpi_check
                mov     prescaler,#0

                mov     a,#1
                add     a,counted+1
                da      a
                mov     counted+1,a
                clr     a
                addc    a,counted
                da      a
                mov     counted,a

cpi_check:      jnb     at_least_one,cpi_ret

                mov     a,cmp_ind
                anl     a,#7
                rl      a
                add     a,#cmp_table
                mov     r0,a
                call    is_word_nz
                jz      cpi_ret

                mov     a,early_pre
                add     a,prescaler
                clr     c
                subb    a,#no_of_spots
                cpl     c
                mov     a,early_cnt
                addc    a,counted+1
                da      a
                mov     r7,a
                clr     a
                addc    a,counted
                da      a
                mov     r6,a

                inc     r0
                clr     c
                mov     a,r7
                subb    a,@r0
                dec     r0
                mov     a,r6
                subb    a,@r0
                jc      cpi_end
                ; x otacok pred
                jnb     running,cpi_end
                clr     running
                call    zapni_na_sekundu
                
cpi_end:        inc     r0
                clr     c
                mov     a,counted+1
                subb    a,@r0
                dec     r0
                mov     a,counted
                subb    a,@r0
                jc      cpi_ret
                setb    overflow
cpi_ret:        ret
