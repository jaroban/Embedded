; version 4.0

can0            equ     0
can1            equ     16

c_wtoe          equ     1

; can msg center format reg
c_xmt           equ     8
c_meme          equ     2
c_rcv           equ     0

; can control
c_crst          equ     8
c_swint         equ     1

; can msg center
c_msrdy         equ     80h
c_eti           equ     40h
c_eri           equ     20h
c_intrq         equ     10h
c_extrq         equ     8
c_mtrq          equ     4
c_row           equ     2
c_tih           equ     2
c_dtup          equ     1

; can state
c_busoff        equ     80h
c_cece          equ     40h
c_wks           equ     20h
c_rxs           equ     10h
c_txs           equ     8

db0             data    8
db1             data    9
db2             data    10
db3             data    11
db4             data    12
db5             data    13
db6             data    14
db7             data    15

; r0=can+msg center  acc=value of sfr
can_get_sfr:    mov     a,r0
                anl     a,#31
                mov     r0,a
                rl      a
                add     a,r0
                add     a,#low(cgs_table)
                push    acc
                clr     a
                addc    a,#high(cgs_table)
                push    acc
                clr     a
                push    acc
                ret

cgs_table:      db      0,0,34
                db      229,c0m1c,34
                db      229,c0m2c,34
                db      229,c0m3c,34
                db      229,c0m4c,34
                db      229,c0m5c,34
                db      229,c0m6c,34
                db      229,c0m7c,34
                db      229,c0m8c,34
                db      229,c0m9c,34
                db      229,c0m10c,34
                db      229,c0m11c,34
                db      229,c0m12c,34
                db      229,c0m13c,34
                db      229,c0m14c,34
                db      229,c0m15c,34
                db      0,0,34
                db      229,c1m1c,34
                db      229,c1m2c,34
                db      229,c1m3c,34
                db      229,c1m4c,34
                db      229,c1m5c,34
                db      229,c1m6c,34
                db      229,c1m7c,34
                db      229,c1m8c,34
                db      229,c1m9c,34
                db      229,c1m10c,34
                db      229,c1m11c,34
                db      229,c1m12c,34
                db      229,c1m13c,34
                db      229,c1m14c,34
                db      229,c1m15c,34

; r0=can+msg center  acc=value of sfr
can_set_sfr:    push    acc
                mov     a,r0
                anl     a,#31
                mov     r0,a
                rl      a
                add     a,r0
                add     a,#low(css_table)
                push    acc
                clr     a
                addc    a,#high(css_table)
                push    acc
                clr     a
                push    acc
                ret

css_table:      db      208,acc,34
                db      208,c0m1c,34
                db      208,c0m2c,34
                db      208,c0m3c,34
                db      208,c0m4c,34
                db      208,c0m5c,34
                db      208,c0m6c,34
                db      208,c0m7c,34
                db      208,c0m8c,34
                db      208,c0m9c,34
                db      208,c0m10c,34
                db      208,c0m11c,34
                db      208,c0m12c,34
                db      208,c0m13c,34
                db      208,c0m14c,34
                db      208,c0m15c,34
                db      208,acc,34
                db      208,c1m1c,34
                db      208,c1m2c,34
                db      208,c1m3c,34
                db      208,c1m4c,34
                db      208,c1m5c,34
                db      208,c1m6c,34
                db      208,c1m7c,34
                db      208,c1m8c,34
                db      208,c1m9c,34
                db      208,c1m10c,34
                db      208,c1m11c,34
                db      208,c1m12c,34
                db      208,c1m13c,34
                db      208,c1m14c,34
                db      208,c1m15c,34

; r0=can+msg center  r1=offset  dptr1=movx address
can_get_dptr:   mov     dpx1,#0
                mov     a,r0
                mov     c,acc.4
                mov     a,#77h
                rlc     a
                mov     dph1,a
                mov     a,r0
                clr     acc.4
                swap    a
                add     a,r1
                mov     dpl1,a
                ret

; followed by null-terminated list (entries have 6 bytes)
; 1: can+msg center  2-6: data to be written to msg center
can_config_msg: mov     dpx,#0
                pop     acc
                pop     dph
                pop     dpl
ccm_lp1:        mov     dps,#4
                clr     a
                movc    a,@a+dptr
                inc     dptr
                jz      ccm_ret
                mov     r0,a
                clr     a
                call    can_set_sfr
                mov     r1,#2
                call    can_get_dptr
                mov     dps,#00100100b
                mov     r2,#5
ccm_lp2:        clr     a
                movc    a,@a+dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r2,ccm_lp2
                mov     a,#c_msrdy
                call    can_set_sfr
                jmp     ccm_lp1
ccm_ret:        jmp     @a+dptr

; r0=can+msg center
can_send_msg:   mov     a,#c_tih
                call    can_set_sfr
                mov     r1,#2
                call    can_get_dptr
                mov     r1,#3
                mov     r2,#13
                mov     dps,#5
csm_lp:         mov     a,@r1
                movx    @dptr,a
                inc     r1
                inc     dptr
                djnz    r2,csm_lp
                mov     dps,#4
                mov     a,#c_msrdy+c_mtrq+c_dtup
                jmp     can_set_sfr

; r0=can+msg center
can_send_data:  mov     a,#c_tih
                call    can_set_sfr
                mov     r1,#7
                call    can_get_dptr
                mov     r1,#8
                mov     r2,#8
                mov     dps,#5
csd_lp:         mov     a,@r1
                movx    @dptr,a
                inc     r1
                inc     dptr
                djnz    r2,csd_lp
                mov     dps,#4
                mov     a,#c_msrdy+c_mtrq+c_dtup
                jmp     can_set_sfr

if 0
; r0=can+msg center  r2=# of bytes
can_send_rfr_no:
                clr     a
                call    can_set_sfr
                mov     r1,#6
                call    can_get_dptr
                mov     dps,#5
                movx    a,@dptr
                anl     a,#0fh
                xch     a,r2
                swap    a
                orl     a,r2
                movx    @dptr,a
                mov     dps,#4
                mov     a,#c_msrdy+c_mtrq
                jmp     can_set_sfr
endif

; r0=can+msg center
can_send_rfr:   mov     a,#c_msrdy+c_mtrq
                jmp     can_set_sfr

; r0=can+msg center
can_get_msg_wtoe:
                call    can_get_sfr
                anl     a,#c_dtup
                jz      cgmw_ret
cgmw_ok:        mov     a,#c_msrdy
                call    can_set_sfr
                mov     r1,#2
                call    can_get_dptr
                mov     r1,#3
                mov     r2,#13
                mov     dps,#5
cgmw_lp:        movx    a,@dptr
                mov     @r1,a
                inc     dptr
                inc     r1
                djnz    r2,cgmw_lp
                mov     dps,#4
                call    can_get_sfr
                anl     a,#c_dtup
                jnz     cgmw_ok
                cpl     a
cgmw_ret:       ret

; r0=can+msg center
can_get_msg:    call    can_get_sfr
                anl     a,#c_dtup
                jz      cgm_ret
                mov     r1,#2
                call    can_get_dptr
                mov     r1,#3
                mov     r2,#13
                mov     dps,#5
cgm_lp:         movx    a,@dptr
                mov     @r1,a
                inc     dptr
                inc     r1
                djnz    r2,cgm_lp
                mov     dps,#4
                mov     a,#c_msrdy
                call    can_set_sfr
                mov     a,#0ffh
cgm_ret:        ret

; r0=can+msg center
can_is_msg_sent:
                call    can_get_sfr
                anl     a,#c_mtrq
                jnz     cims_no
                cpl     a
                ret
cims_no:        clr     a
                ret
