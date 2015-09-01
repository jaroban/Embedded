; version 1.0

initial_thread: setb    bottom_snimac
                setb    middle_snimac
                setb    top_snimac
                mov     liftpos,#-10
                clr     a
                mov     old_no,a
                mov     oliftpos,a
                mov     osnimace,a
                mov     omm,#1
                mov     smer,#none
                mov     osmer,#both

                mov     dptr,#output_setup
                call    run_it

input_main_lp:  call    do_them
                call    urci_smer
                mov     a,#t_snimace
                call    tmr_zro
                jnc     input_main_lp
                call    tmr_int_f
                db      t_snimace,0,0,1
                call    read_snimace
                call    update_it
                jmp     input_main_lp

urci_smer:      mov     a,liftpos
                xrl     a,#-10
                jz      us_none
                mov     a,#t_smer
                call    tmr_zro
                jnc     us_ret
us_none:        mov     smer,#none
us_ret:         ret

read_snimace:   clr     a
                mov     c,top_snimac
                rlc     a
                mov     c,middle_snimac
                rlc     a
                mov     c,bottom_snimac
                rlc     a
                cpl     a
                anl     a,#7
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
                mov     snimace,#0
                mov     r1,#mjrt_bffr
                mov     r2,#5
do_maj5_lp:     mov     a,@r1
                inc     r1
                orl     a,@r1
                inc     r1
                anl     a,@r1
                inc     r1
                anl     a,@r1
                orl     snimace,a
                dec     r1
                dec     r1
                djnz    r2,do_maj5_lp
                ret

update_it:      mov     a,snimace
                xrl     a,#7
                jz      ui_zero
                mov     a,liftpos
                xrl     a,#-10
                jz      ui_ret
                mov     a,snimace
                xrl     a,#5
                jz      ui_ret
                mov     a,snimace
                xch     a,osnimace
                xrl     a,osnimace
                anl     a,#7
                mov     change,a
                jz      ui_ret
                mov     new_no,#0
                mov     a,old_no
                jz      ui_ret
                mov     r1,a
                mov     r0,#old_table
ui_lp1:         mov     bb,@r0
                inc     r0
                mov     mm,@r0
                inc     r0
                mov     tt,@r0
                inc     r0
                push    ar0
                push    ar1
                call    do_bottom
                pop     ar1
                pop     ar0
                djnz    r1,ui_lp1
                call    purge_new
                call    copy_it
                jmp     calculate_it
ui_zero:        mov     osnimace,snimace
                mov     old_no,#1
                mov     r0,#old_table
                mov     a,#1
                mov     @r0,a
                inc     r0
                mov     @r0,a
                inc     r0
                mov     @r0,a
                mov     liftpos,#0
ui_ret:         ret

do_bottom:      mov     a,change
                jnb     acc.0,do_middle
                inc     bb
                call    do_middle
                dec     bb
                dec     bb
                call    do_middle
                inc     bb
                ret

do_middle:      mov     a,change
                jnb     acc.1,do_top
                inc     mm
                call    do_top
                dec     mm
                dec     mm
                call    do_top
                inc     mm
                ret

do_top:         mov     a,change
                jnb     acc.2,add_new
                inc     tt
                call    add_new
                dec     tt
                dec     tt
                call    add_new
                inc     tt
                ret

add_new:        mov     r0,#new_table
                mov     a,new_no
                jz      an_ok
                mov     r1,a
                xrl     a,#new_size
                jz      an_ret
an_lp:          mov     b,#0
                mov     a,@r0
                xrl     a,bb
                orl     b,a
                inc     r0
                mov     a,@r0
                xrl     a,mm
                orl     b,a
                inc     r0
                mov     a,@r0
                xrl     a,tt
                orl     b,a
                inc     r0
                mov     a,b
                jz      an_ret
                djnz    r1,an_lp
an_ok:          inc     new_no
                mov     @r0,bb
                inc     r0
                mov     @r0,mm
                inc     r0
                mov     @r0,tt
an_ret:         ret

purge_new:      mov     a,new_no
                jz      pn_ret
                mov     r2,a
                rl      a
                add     a,r2
                add     a,#new_table-1
                mov     r0,a
                mov     r1,a
pn_lp:          mov     tt,@r0
                dec     r0
                mov     mm,@r0
                dec     r0
                mov     bb,@r0
                dec     r0
                call    check_it
                jc      pn_ok
                dec     new_no
                inc     r0
                inc     r0
                inc     r0
                mov     a,@r1
                dec     r1
                mov     @r0,a
                dec     r0
                mov     a,@r1
                dec     r1
                mov     @r0,a
                dec     r0
                mov     a,@r1
                dec     r1
                mov     @r0,a
                dec     r0
pn_ok:          djnz    r2,pn_lp
pn_ret:         ret

check_it:       mov     a,mm
                mov     b,bb
                call    a_ge_b
                jnc     ch_ret
                mov     a,tt
                mov     b,mm
                call    a_ge_b
                jnc     ch_ret
                mov     a,bb
                inc     a
                inc     a
                mov     b,tt
                call    a_ge_b
                jnc     ch_ret
                mov     a,bb
                anl     a,tt
                jnb     acc.0,ch_yes
                mov     a,bb
                xrl     a,tt
                jz      ch_yes
                clr     c
                ret
ch_yes:         setb    c
ch_ret:         ret

a_ge_b:         mov     c,b.7
                orl     c,/acc.7
                jnc     ageb_ret
                mov     c,b.7
                anl     c,/acc.7
                jc      ageb_ret
                subb    a,b
                cpl     c
ageb_ret:       ret

copy_it:        mov     a,new_no
                jz      cp_ret
                mov     old_no,a
                mov     r2,a
                setb    c
                subb    a,#old_size
                jnc     cp_bad
                mov     r0,#old_table
                mov     r1,#new_table
cp_lp:          mov     a,@r1
                inc     r1
                mov     @r0,a
                inc     r0
                mov     a,@r1
                inc     r1
                mov     @r0,a
                inc     r0
                mov     a,@r1
                inc     r1
                mov     @r0,a
                inc     r0
                djnz    r2,cp_lp
cp_ret:         ret
cp_bad:         mov     old_no,#0
                mov     liftpos,#-10
                ret

calculate_it:   mov     a,old_no
                cjne    a,#1,cl_ret
                mov     r0,#old_table+1
                mov     a,@r0
                mov     r0,a
                xch     a,omm
                mov     b,a
                xrl     a,omm
                jz      ci_done
                mov     a,r0
                call    a_ge_b
                mov     smer,#hore
                jc      ci_hore
                mov     smer,#dole
ci_hore:        call    tmr_int_f
                db      t_smer,0,5,0
ci_done:        mov     r0,#old_table
                mov     a,@r0
                jb      acc.0,cl_ok
                inc     r0
                mov     a,@r0
                jb      acc.0,cl_ok
                inc     r0
                mov     a,@r0
                jb      acc.0,cl_ok
                ret
cl_ok:          clr     acc.0
                mov     c,acc.7
                rrc     a
                mov     liftpos,a
cl_ret:         ret
