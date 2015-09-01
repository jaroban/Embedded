; version 4.0

get_nrm_mask:   inc     a
                movc    a,@a+pc
                ret
                db      1,2,4,8,10h,20h,40h,80h

get_nrm_cpl_mask:
                inc     a
                movc    a,@a+pc
                ret
                db      0feh,0fdh,0fbh,0f7h,0efh,0dfh,0bfh,7fh

get_nrm_cpl_mask2:
                inc     a
                movc    a,@a+pc
                ret
                db      0fch,0f9h,0f3h,0e7h,0cfh,09fh,03fh

get_lo_mask_16: inc     a
                movc    a,@a+pc
                ret
                db      0,1,3,7,15,31,63,127
                db      255,255,255,255,255,255,255,255,255

get_hi_mask_16: inc     a
                movc    a,@a+pc
                ret
                db      0,0,0,0,0,0,0,0,0
                db      1,3,7,15,31,63,127,255

get_dole_mask_16:
                inc     a
                movc    a,@a+pc
                ret
                db      0,0,0,0,0,0,0,0,0
                db      8,24,0,0,0,0,0,0

get_hore_mask_16:
                inc     a
                movc    a,@a+pc
                ret
                db      0,0,0,0,0,0,0,0,0
                db      64,192,0,0,0,0,0,0

if 0
get_nrm_cpl_mask4:
                inc     a
                movc    a,@a+pc
                ret
                db      0f0h,0e1h,0c3h,87h,0fh
endif

get_rvs_mask:   inc     a
                movc    a,@a+pc
                ret
                db      80h,40h,20h,10h,8,4,2,1

get_rvs_cpl_mask:
                inc     a
                movc    a,@a+pc
                ret
                db      7fh,0bfh,0dfh,0efh,0f7h,0fbh,0fdh,0feh

hex_asc:        anl     a,#0fh
                jnb     acc.3,hex_asc_noadj
                jb      acc.2,hex_asc_adj
                jnb     acc.1,hex_asc_noadj
hex_asc_adj:    add     a,#'a'-'0'-10
hex_asc_noadj:  add     a,#'0'
                ret

asc_hex:        clr     c
                subb    a,#'0'
                jc      asc_hex_no
                subb    a,#'9'-'0'+1
                jc      asc_hex_10
                subb    a,#'A'-'9'-1
                jc      asc_hex_no
                subb    a,#'F'-'A'+1
                jc      asc_hex_16
                subb    a,#'a'-'F'-1
                jc      asc_hex_no
                subb    a,#'f'-'a'+1
                jnc     asc_hex_ret
asc_hex_16:     add     a,#16
                setb    c
                ret
asc_hex_10:     add     a,#10
                setb    c
asc_hex_ret:    ret
asc_hex_no:     clr     c
                ret

add_a_to_dptr:  add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                ret

add_3a_to_dptr: mov     b,a
                rl      a
                add     a,b
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                ret

add_4a_to_dptr: rl      a
                rl      a
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                ret

add_16a_to_dptr:
                swap    a
                mov     b,a
                anl     a,#0f0h
                add     a,dpl
                mov     dpl,a
                mov     a,b
                anl     a,#0fh
                addc    a,dph
                mov     dph,a
                ret

inc_mod_b:      inc     a
                cjne    a,b,inc_skip
                clr     a   
inc_skip:       ret

dec_mod_b:      jnz     dec_skip
                mov     a,b
dec_skip:       dec     a
                ret

hex_bcd:        mov     b,#10
                div     ab
                swap    a
                add     a,b
                ret

bcd_hex:        mov     b,a
                anl     a,#0f0h
                rr      a
                rr      a
                push    acc
                rr      a
                xch     a,b
                clr     c
                subb    a,b
                pop     b
                clr     c
                subb    a,b
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

; a=data  dptr -> null-term table
find_byte:      mov     b,a
                mov     r0,#0
fb_lp:          mov     a,r0
                inc     r0
                movc    a,@a+dptr
                jz      fb_ret
                cjne    a,b,fb_lp
                mov     a,r0
fb_ret:         ret

adj_r0_r1:      mov     r2,a
                clr     c
                subb    a,r0
                jc      adjrr_lo
                mov     a,r1
                clr     c
                subb    a,r2
                jc      adjrr_hi
                mov     a,r2
                ret
adjrr_hi:       mov     a,r1
                ret
adjrr_lo:       mov     a,r0
                ret

inc_r0_r1:      xch     a,r1
                setb    c
                subb    a,r1
                jc      incrr_lo
                mov     a,r1
                inc     a
                ret
incrr_lo:       mov     a,r0
                ret

dec_r0_r1:      xch     a,r0
                clr     c
                subb    a,r0
                jnc     decrr_lo
                mov     a,r0
                dec     a
                ret
decrr_lo:       mov     a,r1
                ret
