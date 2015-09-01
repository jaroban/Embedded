; version 2.0

timer2_int:     clr     ea
                push    psw
                push    acc
                push    ar0
                anl     psw,#11100111b
                mov     t2con,#00000100b

                mov     p0,#11100000b
                mov     a,mask
                rr      a
                djnz    col_ind,t2i_ok
                mov     col_ind,#5
                mov     a,#10000b
t2i_ok:         mov     mask,a
   
                jb      show_dir,t2i_dir
                mov     a,col_ind
                add     a,#layer1-1
                mov     r0,a
                mov     a,@r0
                clr     acc.7
                mov     p1,a
                mov     a,r0
                add     a,#5
                mov     r0,a
                mov     a,@r0
                clr     acc.7
                mov     p2,a
                mov     a,mask
                orl     a,#11100000b
                mov     p0,a

                pop     ar0
                pop     acc
                pop     psw
                setb    ea
                reti

t2i_dir:        mov     a,col_ind
                add     a,#layer2-1
                mov     r0,a
                mov     a,@r0
                clr     acc.7
                mov     p1,a
                clr     a
                jb      blink_dir,t2i_skip
                mov     a,col_ind
                add     a,#layer1+5-1
                mov     r0,a
                mov     a,@r0
                clr     acc.7
t2i_skip:       mov     p2,a
                mov     a,mask
                orl     a,#11100000b
                mov     p0,a

                pop     ar0
                pop     acc
                pop     psw
                setb    ea
                reti

init_outputs:   clr     ea

                mov     col_ind,#5
                mov     mask,#10000b

                mov     r0,#layer1
                mov     r1,#10
                call    clear_data

                mov     r0,#layer2
                mov     r1,#5
                call    clear_data

                orl     tmod,#00010000b
                mov     rcap2l,#low(-tmr2_period)
                mov     rcap2h,#high(-tmr2_period)
                setb    tr2
                setb    et1
                setb    et2
                setb    ea
                ret
