; version 4.1

$nopaging
$nomod51

$include(.\system\ds80c390.asm)

source          equ     200h
destination     equ     0

                cseg at 0
                ljmp    bootstrap

btp_signal:     mov     dps,#4
                mov     dpx,#10h
                mov     dptr,#5
                movx    @dptr,a
                mov     dpx,#0
                ret

btp_check_identity:
                mov     dps,#00100100b
                mov     dptr,#source            ; 0
                mov     dptr,#destination       ; 1
bci_lp:         clr     a
                movc    a,@a+dptr               ; 0
                mov     r5,a
                movx    a,@dptr                 ; 1
                xrl     a,r5
                jnz     bci_diff
                inc     dptr                    ; 0
                inc     dptr                    ; 1
                mov     a,dph
                cjne    a,#80h,bci_lp
                mov     dps,#4
                mov     a,#0ffh
                ret
bci_diff:       mov     dps,#4
                clr     a
                ret

f_reset:        mov     dps,#4
                mov     dptr,#0
                mov     a,#0f0h
                movx    @dptr,a
                ret

f_wait4it:      movx    a,@dptr
                mov     r0,a
fw4i_lp:        movx    a,@dptr
                xch     a,r0
                xrl     a,r0
                jnb     acc.6,fw4i_pass
                jnb     acc.5,fw4i_lp
                movx    a,@dptr
                mov     r0,a
                movx    a,@dptr
                xrl     a,r0
                jnb     acc.6,fw4i_pass
                mov     a,#0f0h
                movx    @dptr,a
                clr     a
                ret
fw4i_pass:      mov     a,#0ffh
                ret

; acc = 00h, 40h, 80h, c0h
f_erase_sector: mov     r7,a
f_erase_lp:     mov     dps,#4
                mov     dptr,#555h
                mov     a,#0aah
                movx    @dptr,a
                mov     dptr,#2aah
                mov     a,#055h
                movx    @dptr,a
                mov     dptr,#555h
                mov     a,#080h
                movx    @dptr,a
                mov     dptr,#555h
                mov     a,#0aah
                movx    @dptr,a
                mov     dptr,#2aah
                mov     a,#055h
                movx    @dptr,a
                mov     dph,r7
                mov     a,#030h
                movx    @dptr,a
                call    f_wait4it
                jz      f_erase_lp
                jmp     f_reset

bootstrap:      mov     ie,#0
                mov     ip,#0
                mov     ta,#0aah
                mov     ta,#055h
                mov     acon,#5
                mov     ta,#0aah
                mov     ta,#055h
                mov     p5cnt,#7
                mov     ta,#0aah
                mov     ta,#055h
                mov     wdcon,#0
                mov     ckcon,#11000001b

                mov     dps,#4
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     sp,a
                mov     esp,a
                anl     psw,#11100111b

                call    btp_check_identity
                jnz     btp_ret_ok

                mov     a,#0fh
                call    btp_signal

                call    f_reset
                mov     a,#00h
                call    f_erase_sector
                mov     a,#40h
                call    f_erase_sector

                mov     a,#7
                call    btp_signal

                mov     dps,#00100100b
                mov     dptr,#source            ; 0
                mov     dptr,#destination       ; 1

btp_main_lp:    mov     dps,#4
                push    dpl
                push    dph
                mov     dptr,#555h
                mov     a,#0aah
                movx    @dptr,a
                mov     dptr,#2aah
                mov     a,#055h
                movx    @dptr,a
                mov     dptr,#555h
                mov     a,#0a0h
                movx    @dptr,a
                pop     dph
                pop     dpl

                mov     dps,#00100100b
                clr     a
                movc    a,@a+dptr               ; 0
                movx    @dptr,a                 ; 1

                mov     dps,#5
                call    f_wait4it
                jz      btp_main_lp

                mov     dps,#00100100b
                inc     dptr
                inc     dptr
                mov     a,dph
                cjne    a,#80h,btp_main_lp
                mov     a,#3
                call    btp_signal
                call    btp_check_identity
                jz      btp_ret_no
btp_ret_ok:     mov     a,#1
btp_ret_no:     call    btp_signal
                call    f_reset
                jmp     $

end
