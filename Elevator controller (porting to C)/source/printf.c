#include <global.h>

#define PRINT_ZEROES F0
#define EA_SAVED F1
#define UPPERCASE F1

// corrupts b, dptr0, dptr1, psw
// implements: %c, %s, %p, %x, %X, %u
void printf(const __code u8 *f, ...) __reentrant __naked
{
    __asm
                mov     c,ea
                mov     EA_SAVED,c
                clr     ea
                
                pop     acc
                pop     acc
                pop     acc                 ; skip return address
                pop     dpx
                pop     dph
                pop     dpl                 ; dptr0 -> format string

                mov     dpl1,sp
                mov     dph1,esp
                anl     dph1,#3
                mov     dpx1,#0x40          ; dptr1 -> first parameter

                mov     a,#6
                add     a,sp
                mov     sp,a
                clr     a
                addc    a,esp
                mov     esp,a               ; return stack to where it was
                
                mov     c,EA_SAVED
                mov     ea,c

                sjmp    pf_format_entry

pf_ret:         ret
pf_print_it:    push    dpl
                push    dph
                push    dpx
                push    dpl1
                push    dph1
                push    dpx1
pf_print_next:  mov     dpl,a
                acall   _put_char
pf_next_format: pop     dpx1
                pop     dph1
                pop     dpl1
                pop     dpx
                pop     dph
                pop     dpl
pf_format_entry:
                mov     dps,#0
                clr     a
                movc    a,@a+dptr           ; get format char
                inc     dptr
                jz      pf_ret

                cjne    a,#'%,pf_print_it   ;'  %
                clr     a
                movc    a,@a+dptr           ; get format char
                inc     dptr
                jz      pf_ret

                cjne    a,#'%,pf_try_c      ;'  %%
                sjmp    pf_print_it

pf_try_c:       cjne    a,#'c,pf_try_s      ;'  %c
                mov     dps,#DPS_DEC1+1
                movx    a,@dptr             ; get 1 byte
                inc     dptr
                mov     dps,#0
                sjmp    pf_print_it

pf_try_s:       cjne    a,#'s,pf_try_p      ;'  %s
                push    dpl
                push    dph
                push    dpx
                mov     dps,#DPS_DEC1+1
                movx    a,@dptr
                inc     dptr
                mov     b,a
                movx    a,@dptr
                inc     dptr
                mov     dpx,a
                movx    a,@dptr
                inc     dptr
                mov     dph,a
                movx    a,@dptr             ; get 4 bytes
                inc     dptr
                mov     dpl,a
                mov     dps,#0
                push    dpl1
                push    dph1
                push    dpx1

pf_s_lp:        acall   __gptrget
                jz      pf_next_format
                inc     dptr
                push    dpl
                push    dph
                push    dpx
                push    b
                mov     dpl,a
                acall   _put_char
                pop     b
                pop     dpx
                pop     dph
                pop     dpl
                sjmp    pf_s_lp

pf_try_p:       clr     PRINT_ZEROES
                cjne    a,#'p,pf_try_x      ;'  %p
                clr     UPPERCASE           ; as you like it
                push    dpl
                push    dph
                push    dpx
                mov     dps,#DPS_DEC1+1
                movx    a,@dptr
                inc     dptr
                mov     b,a
                movx    a,@dptr
                inc     dptr
                mov     dpx,a
                movx    a,@dptr
                inc     dptr
                mov     dph,a
                movx    a,@dptr             ; get 4 bytes
                inc     dptr
                mov     dpl,a
                mov     dps,#0
                push    dpl1
                push    dph1
                push    dpx1

                mov     a,dpl
                push    acc
                swap    a
                push    acc

                mov     a,dph
                push    acc
                swap    a
                push    acc

                mov     a,dpx
                push    acc
                swap    a
                push    acc

                mov     a,b
                push    acc
                swap    a

                acall   pf_put_hex
                pop     acc
                acall   pf_put_hex
                pop     acc
                acall   pf_put_hex
                pop     acc
pf_p_print_5:   acall   pf_put_hex
                pop     acc
pf_p_print_4:   acall   pf_put_hex
                pop     acc
                acall   pf_put_hex
                pop     acc
                acall   pf_put_hex
                pop     acc
                acall   pf_put_hex

                jb      PRINT_ZEROES,pf_p_done
                mov     a,#'0   ;'
                ajmp    pf_print_next
pf_p_done:      ajmp    pf_next_format

pf_try_x:       cjne    a,#'x,pf_try_X      ;'  %x
                clr     UPPERCASE
                sjmp    pf_x_entry

pf_try_X:       cjne    a,#'X,pf_try_d      ;'  %X
                setb    UPPERCASE
pf_x_entry:     push    dpl
                push    dph
                push    dpx
                mov     dps,#DPS_DEC1+1
                movx    a,@dptr
                inc     dptr
                mov     dph,a
                movx    a,@dptr             ; get 2 bytes
                inc     dptr
                mov     dpl,a
                mov     dps,#0
                push    dpl1
                push    dph1
                push    dpx1

                mov     a,dpl
                push    acc
                swap    a
                push    acc

                mov     a,dph
                push    acc
                swap    a

                sjmp    pf_p_print_4

pf_try_d:       cjne    a,#'u,pf_unknown    ;'  %u
                push    dpl
                push    dph
                push    dpx
                mov     dps,#DPS_DEC1+1
                movx    a,@dptr
                inc     dptr
                mov     dph,a
                movx    a,@dptr             ; get 2 bytes
                inc     dptr
                mov     dpl,a
                mov     dps,#0
                push    dpl1
                push    dph1
                push    dpx1

                mov     c,ea
                mov     EA_SAVED,c
                clr     ea
                
                mov     ma,dpl              ; dividend
                mov     ma,dph
                mov     mb,#100             ; divisor
                mov     mb,#0
pf_div_lp1:     mov     a,mcnt1
                jb      acc.7,pf_div_lp1
                mov     dph,ma              ; quotient
                mov     dpl,ma              ;           dptr = x / 100
                mov     a,mb                ; remainder
                mov     a,mb                ;           a = x % 100

                mov     b,#10
                div     ab                  ;           a = a / 10
                push    b                   ;           b = a % 10
                push    acc

                mov     ma,dpl              ; dividend
                mov     ma,dph
                mov     mb,#100             ; divisor
                mov     mb,#0
pf_div_lp2:     mov     a,mcnt1
                jb      acc.7,pf_div_lp2
                mov     a,mb                ; remainder
                mov     a,mb                ;           a = (x / 100) % 100

                mov     b,#10
                div     ab                  ;           a = a / 10
                push    b                   ;           b = a % 10
                push    acc

                mov     a,ma                ; quotient
                mov     a,ma                ;           x / 10000

                mov     c,EA_SAVED
                mov     ea,c

                ajmp    pf_p_print_5

pf_unknown:     ajmp    pf_format_entry

pf_put_hex:     anl     a,#0x0f
                jb      PRINT_ZEROES,pf_ph_skip1
                jz      pf_ph_ret
                setb    PRINT_ZEROES
pf_ph_skip1:    add     a,#pf_ph_table - pf_ph_pc
                jb      UPPERCASE,pf_ph_skip2
                add     a,#16
pf_ph_skip2:    movc    a,@a+pc
pf_ph_pc:       push    psw
                mov     dpl,a
                acall   _put_char
                pop     psw
pf_ph_ret:      ret
pf_ph_table:    .ascii  "0123456789ABCDEF"
                .ascii  "0123456789abcdef"
    __endasm;
}
