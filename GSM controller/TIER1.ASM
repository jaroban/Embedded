; version 1.0

relays:         mov     c,acc.0
                mov     rele1,c

                mov     c,acc.1
                mov     rele2,c
                
                mov     c,acc.2
                mov     rele5,c
                ret

trace:          
if debug
                anl     a,#1fh
                mov     p0,a
                call    wait4it_f
                db      t_debug,0,1,0
endif
                ret

copy_from_code: clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     @r0,a
                inc     r0
                djnz    r1,copy_from_code
                ret

hex_asc:        anl     a,#0fh
                jnb     acc.3,hex_asc_noadj
                jb      acc.2,hex_asc_adj
                jnb     acc.1,hex_asc_noadj
hex_asc_adj:    add     a,#'a'-'0'-10
hex_asc_noadj:  add     a,#'0'
                ret
                
; a=expected  r0->value
is_match:       cjne    a,#'?',im_skip1
im_yes:         setb    c
                ret
im_skip1:       cjne    a,#'#',im_skip2
                mov     a,@r0
                clr     c
                subb    a,#'0'
                jc      im_no
                subb    a,#10
                ret
im_skip2:       xrl     a,@r0
                jz      im_yes
im_no:          clr     c
                ret

; dptr -> null terminated string, returns r3 = length of string, r0 = fifo1, a = match
check_it:
                ; find length of string
                mov     r3,#0ffh
ci_lp1:         inc     r3
                mov     a,r3
                movc    a,@a+dptr
                jnz     ci_lp1

                ; if length > valid then no match
                mov     a,fifo1_valid
                clr     c
                subb    a,r3
                jc      ci_no

                ; compare
                mov     r0,#fifo1
                mov     a,r3
                mov     r2,a

ci_cmp_lp:      mov     a,r2
                dec     a
                movc    a,@a+dptr
                call    is_match
                jnc     ci_no
                inc     r0
                djnz    r2,ci_cmp_lp

                ; match
                mov     fifo1_valid,#0
                mov     a,#0ffh
                sjmp    ci_ret
ci_no:          clr     a
ci_ret:         mov     r0,#fifo1
                ret

; a=timeout in seconds
do_events:      mov     r4,#0
                mov     r5,a
                mov     tmp0,a
                mov     r6,#0
                mov     a,#t_wait
                call    tmr_int
                pop     dph1
                pop     dpl1
de_lp1:         call    do_them
                call    read_serial
                jc      de_check
                mov     a,#t_wait
                call    tmr_zro
                jnc     de_lp1
                mov     dpl,dpl1
                mov     dph,dph1
de_lp2:         clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     de_lp2
                inc     dptr
                inc     dptr
                clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     de_lp2
                jmp     @a+dptr

de_check:       mov     r4,#0
                mov     r5,tmp0
                mov     r6,#0
                mov     a,#t_wait
                ;call    tmr_int
                mov     dpl,dpl1
                mov     dph,dph1
de_lp3:         call    rst_wd

                ; last entry?
                clr     a
                movc    a,@a+dptr
                jz      de_lp1

                call    check_it
                jnz     de_jump

                mov     a,r3
                add     a,#3    ; skip return address
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                jmp     de_lp3

de_jump:        mov     a,r3
                add     a,#2
                movc    a,@a+dptr
                push    acc
                mov     a,r3
                inc     a
                movc    a,@a+dptr
                push    acc
                ret

; returns c = found
find_nf:        pop     dph
                pop     dpl
                call    check_it
                clr     c
                jz      ffnf_lp
                setb    c
ffnf_lp:        clr     a
                movc    a,@a+dptr
                inc     dptr
                jnz     ffnf_lp
                jmp     @a+dptr

; tmp1=ptr  tmp2=max  tmp3=term
read_string:    call    tmr_int_f
                db      t_wait,0,3,0
rst_lp1:        call    do_them
                call    read_serial
                call    get_chr
                jc      rst_skip1
rst_skip0:      mov     a,#t_wait
                call    tmr_zro
                jnc     rst_lp1
                clr     c
                ret
rst_skip1:      ;push    acc
                ;call    tmr_int_f
                ;db      t_wait,0,5,0
                ;pop     acc
                mov     b,a
                clr     c
                subb    a,#' '
                jnc     rst_skip3
                mov     b,#' '
rst_skip3:      mov     a,b
                cjne    a,tmp3,rst_skip2
                mov     a,#' '
                mov     r0,tmp1
rst_lp2:        mov     @r0,a
                inc     r0
                djnz    tmp2,rst_lp2
                setb    c
                ret
rst_skip2:      mov     r0,tmp1
                mov     @r0,a
                inc     tmp1
                djnz    tmp2,rst_lp1
                setb    c
                ret

; r0=ptr  r1=len
string_has_text:
sie_lp:         mov     a,@r0
                cjne    a,#' ',sie_yes
                inc     r0
                djnz    r1,sie_lp
                clr     c
                ret
sie_yes:        setb    c
                ret
