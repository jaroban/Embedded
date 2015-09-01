; version 1.0

get_rvs_mask:   inc     a
                movc    a,@a+pc
                ret
                db      80h,40h,20h,10h,8,4,2,1

output_setup:   clr     pol_writing
                mov     divider,#1
output_main_lp: call    do_them
                call    vypis_poschodie
ifdef seriova_polohovka
                call    vypis_smer
                djnz    divider,out_pol_skip
                mov     divider,#10
                call    pol_write_data
out_pol_skip:
endif
                jmp     output_main_lp

set_pol_clk:    clr     pol_clk
                ret
clr_pol_clk:    setb    pol_clk
                ret
set_pol_data:   clr     pol_data
                ret
clr_pol_data:   setb    pol_data
                ret

pol_write_data: jnb     pol_writing,pwd_try_change
                jbc     pol_clk_hi,pwd_get_data
                setb    pol_clk_hi
                jmp     set_pol_clk

pwd_get_data:   call    clr_pol_clk
                mov     a,pol_index
                jb      acc.7,pwd_0
                jz      pwd_1
                dec     a
                mov     r0,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table_old
                xch     a,r0
                anl     a,#7
                call    get_rvs_mask
                anl     a,@r0
                jnz     pwd_1
pwd_0:          call    clr_pol_data
                sjmp    pwd_inc
pwd_1:          call    set_pol_data
pwd_inc:        inc     pol_index
                mov     a,pol_index
                cjne    a,#36+1,pwd_ret
                clr     pol_writing
                ret

pwd_try_change: mov     r0,#pol_table
                mov     r1,#pol_table_old
                mov     r2,#5
                mov     b,#0
pwd_lp:         mov     a,@r0
                mov     r3,a
                xch     a,@r1
                xrl     a,r3
                orl     b,a
                inc     r0
                inc     r1
                djnz    r2,pwd_lp
                mov     a,b
                jnz     pwd_refresh
                mov     a,#t_polohovka
                call    tmr_zro
                jnc     pwd_ret
                call    tmr_int_f
                db      t_polohovka,0,1,0
pwd_refresh:    setb    pol_writing
                setb    pol_clk_hi
                mov     pol_index,#-40
pwd_ret:        ret

; a=data  r0=cnt  dptr -> table of bit addresses
pol_byte:       mov     r2,a
pb_lp:          clr     a
                movc    a,@a+dptr
                mov     r1,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                xch     a,r1
                anl     a,#7
                call    get_rvs_mask
                xch     a,r2
                rrc     a
                xch     a,r2
                jc      pb_set
                cpl     a
                anl     a,@r1
                sjmp    pb_str
pb_set:         orl     a,@r1
pb_str:         mov     @r1,a
                inc     dptr
                djnz    r0,pb_lp
                ret

; a=data  dptr -> null-term xlat table
xlat_byte:      mov     b,a
                sjmp    xb_entry
xb_lp:          inc     dptr
                inc     dptr
xb_entry:       clr     a
                movc    a,@a+dptr
                jz      xb_ret
                cjne    a,b,xb_lp
                inc     dptr
                clr     a
                movc    a,@a+dptr
xb_ret:         ret

vypis_smer:     mov     a,smer
                xch     a,osmer
                xrl     a,osmer
                jz      vs_ret
                mov     a,smer
                mov     c,acc.0
                rlc     a
                mov     r0,#3
                mov     dptr,#pol_dir
                jmp     pol_byte
vs_ret:         ret

vypis_poschodie:
                mov     a,liftpos
                xch     a,oliftpos
                xrl     a,oliftpos
                jz      vp_ret
ifdef seriova_polohovka
                mov     a,liftpos
                add     a,#10
                clr     c
                rlc     a
                add     a,#low(vypis_table)
                mov     dpl,a
                clr     a
                addc    a,#high(vypis_table)
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                mov     r3,a
                mov     a,#1
                movc    a,@a+dptr
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     r0,#7
                mov     dptr,#pol_dig0
                call    pol_byte
                mov     a,r3
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     r0,#6
                mov     dptr,#pol_dig1
                jmp     pol_byte
else
                mov     a,liftpos
                cjne    a,#-10,vp_ok
                clr     jednotka
                setb    minus
                mov     a,#'-'
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     c,minus
                mov     acc.7,c
                mov     p1,a
                ret
vp_ok:          mov     a,liftpos
                mov     c,acc.7
                mov     minus,c
                jnc     vp_positive
                cpl     a
                inc     a
vp_positive:    mov     r0,a
                clr     c
                subb    a,#10
                cpl     c
                mov     jednotka,c
                mov     a,r0
                mov     b,#10
                div     ab
                mov     a,b
                add     a,#'0'
                mov     dptr,#xlat_table
                call    xlat_byte
                mov     c,minus
                mov     acc.7,c
                mov     p1,a
endif
vp_ret:         ret
