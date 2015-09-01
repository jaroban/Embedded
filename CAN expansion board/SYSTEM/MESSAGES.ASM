; version 3.0

is_thread_on:   mov     dptr,#thread_table
                mov     a,thread_no
                jz      ito_no
                mov     b,a
ito_lp:         movx    a,@dptr
                xrl     a,r0
                jz      ito_yes
                mov     a,dpl
                add     a,#7
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                djnz    b,ito_lp
                clr     a
ito_no:         ret
ito_yes:        cpl     a
                ret

; r0=thread id  r1=message id
; r2=number of data bytes
; r3-r7=data bytes
snd_msg:        clr     ea
                mov     dps,#4
                mov     dpx,#0
                call    is_thread_on
                jz      sm_ret
                mov     dptr,#data_table
                mov     b,#-no_of_data
sm_lp1:         movx    a,@dptr
                jz      sm_top
                xch     a,b
                add     a,b
                jc      sm_full
                xch     a,b
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                jmp     sm_lp1
sm_full:        mov     dptr,#data_table
                mov     b,#-no_of_data
sm_top:         mov     a,r2
                add     a,#3
                xch     a,b
                add     a,b
                jc      sm_full
                xch     a,b
                movx    @dptr,a
                inc     dptr
                mov     a,r0
                movx    @dptr,a
                inc     dptr
                mov     a,r1
                movx    @dptr,a
                inc     dptr
                mov     a,r2
                jz      sm_done
                mov     a,psw
                anl     a,#18h
                orl     a,#3
                mov     r0,a
sm_lp2:         mov     a,@r0
                movx    @dptr,a
                inc     r0                
                inc     dptr
                djnz    r2,sm_lp2
                clr     a
sm_done:        movx    @dptr,a
sm_ret:         setb    ea
                ret

; r0=thread id  r1=message id
; r2=number of data bytes
; r3-r7=data bytes
ovr_msg:        clr     ea
                mov     dps,#4
                mov     dpx,#0
                call    is_thread_on
                jz      om_ret2
                mov     dptr,#data_table
                mov     b,#-no_of_data
                mov     a,r2
                push    acc
                sjmp    om_entry
om_full:        mov     dptr,#data_table
                mov     b,#-no_of_data
om_top:         pop     acc
                mov     r2,a
                jmp     sm_top
om_lp1:         inc     dptr
                djnz    r2,om_lp1
om_entry:       movx    a,@dptr
                jz      om_top
                xch     a,b
                add     a,b
                jc      om_full
                xch     a,b
                dec     a
                mov     r2,a
                inc     dptr
                movx    a,@dptr
                xrl     a,r0
                jnz     om_lp1
                inc     dptr
                dec     r2
                movx    a,@dptr
                xrl     a,r1
                jnz     om_lp1
                dec     r2
                mov     a,r2
                jz      om_ret1
                inc     dptr
                mov     a,psw
                anl     a,#18h
                orl     a,#3
                mov     r0,a
om_lp2:         mov     a,@r0
                movx    @dptr,a
                inc     r0                
                inc     dptr
                djnz    r2,om_lp2
om_ret1:        pop     acc
om_ret2:        setb    ea
                ret

; c=message was received
; r1=message id
; r2=number of data bytes
; r3-r7=data bytes
get_msg:        clr     ea
                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dptr,#data_table
                sjmp    gm_entry
gm_lp1:         inc     dptr
                djnz    r2,gm_lp1
gm_entry:       movx    a,@dptr
                jz      gm_ret
                mov     r2,a
                mov     dpl1,dpl
                mov     dph1,dph
                inc     dptr
                dec     r2
                movx    a,@dptr
                cjne    a,thread_id,gm_lp1
                inc     dptr
                dec     r2
                movx    a,@dptr
                mov     r1,a
                inc     dptr
                dec     r2
                mov     a,r2
                jz      gm_shift
                xch     a,r1
                mov     b,a
                mov     a,psw
                anl     a,#18h
                orl     a,#3
                mov     r0,a
gm_lp2:         movx    a,@dptr
                mov     @r0,a
                inc     dptr
                inc     r0                
                djnz    r1,gm_lp2
                mov     r1,b
gm_shift:       mov     dps,#00100100b
                movx    a,@dptr
                jz      gm_done
gm_next:        mov     r0,a
gm_lp3:         movx    @dptr,a
                inc     dptr
                inc     dptr
                movx    a,@dptr
                djnz    r0,gm_lp3
                jnz     gm_next
gm_done:        movx    @dptr,a
                mov     dps,#4
                setb    c
                setb    ea
                ret
gm_ret:         clr     c
                setb    ea
                ret

if 0
; a=message id
; c=message was received
; r2=number of data bytes
; r3-r7=data bytes
get_spc:        clr     ea
                mov     b,a
                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dptr,#data_table
                sjmp    gs_entry
gs_lp1:         inc     dptr
                djnz    r2,gs_lp1
gs_entry:       movx    a,@dptr
                jz      gs_ret
                mov     r2,a
                mov     dpl1,dpl
                mov     dph1,dph
                inc     dptr
                dec     r2
                movx    a,@dptr
                cjne    a,thread_id,gs_lp1
                inc     dptr
                dec     r2
                movx    a,@dptr
                cjne    a,b,gs_lp1
                inc     dptr
                dec     r2
                mov     a,r2
                jz      gs_shift
                mov     r1,a
                mov     a,psw
                anl     a,#18h
                orl     a,#3
                mov     r0,a
gs_lp2:         movx    a,@dptr
                mov     @r0,a
                inc     dptr
                inc     r0                
                djnz    r1,gs_lp2
gs_shift:       mov     dps,#00100100b
                movx    a,@dptr
                jz      gs_done
gs_next:        mov     r0,a
gs_lp3:         movx    @dptr,a
                inc     dptr
                inc     dptr
                movx    a,@dptr
                djnz    r0,gs_lp3
                jnz     gs_next
gs_done:        movx    @dptr,a
                mov     dps,#4
                setb    c
                setb    ea
                ret
gs_ret:         clr     c
                setb    ea
                ret
endif

do_vnts:        call    get_msg
                pop     acc
                pop     dph
                pop     dpl
                jnc     dv_lp3
dv_lp1:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      dv_ret
                mov     b,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                xrl     a,r1
                jz      dv_found
                inc     dptr
                inc     dptr
                jmp     dv_lp1
dv_found:       mov     a,b
                xrl     a,#high(r_)
                jz      dv_do_ret
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph1,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl1,a
                mov     a,b
                xrl     a,#high(j_)
                jz      dv_do_jmp
dv_lp2:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      dv_do_call
                inc     dptr
                inc     dptr
                inc     dptr
                jmp     dv_lp2
dv_lp3:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      dv_ret
                inc     dptr
                inc     dptr
                inc     dptr
                jmp     dv_lp3
dv_ret:         jmp     @a+dptr
dv_do_call:     push    dpl
                push    dph
                push    acc
dv_do_jmp:      push    dpl1
                push    dph1
                push    acc
dv_do_ret:      ret

do_case:        mov     r1,a
                mov     dps,#4
                mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
dc_lp1:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      dc_ret
                mov     r0,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                xrl     a,r1
                jz      dc_found
                inc     dptr
                inc     dptr
                jmp     dc_lp1
dc_found:       mov     a,r0
                xrl     a,#high(r_)
                jz      dc_do_ret
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dph1,a
                clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     dpl1,a
                mov     a,r0
                xrl     a,#high(j_)
                jz      dc_do_jmp
dc_lp2:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      dc_do_call
                inc     dptr
                inc     dptr
                inc     dptr
                jmp     dc_lp2
dc_ret:         jmp     @a+dptr
dc_do_call:     push    dpl
                push    dph
                push    acc
dc_do_jmp:      push    dpl1
                push    dph1
                push    acc
dc_do_ret:      ret
