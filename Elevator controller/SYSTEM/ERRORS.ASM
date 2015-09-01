; version 4.0

aka_je_chyba:   mov     dps,#0
                mov     dpx,#0
                mov     a,error_no
                jz      ajc_ret
                add     a,#low(error_table-1)
                mov     dpl,a
                clr     a
                addc    a,#high(error_table-1)
                mov     dph,a
                movx    a,@dptr
ajc_ret:        ret

vazna_chyba_table:
                db      e_strata_a1
                db      e_strata_a2
                db      e_strata_a3
                db      e_strata_a4
                db      e_hs_ds
                db      e_doba_jazdy
                db      e_poradie_faz
                db      e_porucha_mpd
                db      e_doba_dorovnavania
                db      e_snimac_c
                db      e_porucha_modulu_c
                db      e_porucha_stykacov
if hydraulika_a3
                db      e_porucha_rdy
                db      e_porucha_run
else
                db      e_kontrola_brzdy1
                db      e_kontrola_brzdy2
endif
                db      e_modul_npk
                db      0

pridaj_chybu:   push    acc
                mov     r0,a
                jz      prch_ret
                clr     c
                subb    a,#no_of_errors+1
                jnc     prch_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#vazna_chyba_table
                mov     a,r0
                push    ar0
                call    find_byte
                jz      prch_skip
                call    zapni_poruchu
prch_skip:      pop     ar0
                mov     dptr,#error_table
                mov     a,error_no
                jz      prch_ok
                mov     r1,a
prch_lp:        movx    a,@dptr
                xrl     a,r0
                jz      prch_ret
                inc     dptr
                djnz    r1,prch_lp
prch_ok:        mov     a,r0
                movx    @dptr,a
                mov     a,error_no
                xrl     a,#no_of_errors
                jz      prch_ret
                inc     error_no
prch_ret:       pop     acc
                ret

zrus_chybu:     mov     r0,a
                jz      zrch_ret
                clr     c
                subb    a,#no_of_errors+1
                jnc     zrch_ret
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#vazna_chyba_table
                mov     a,r0
                push    ar0
                call    find_byte
                jz      zrch_skip
                call    vypni_poruchu
zrch_skip:      pop     ar0
                mov     a,error_no
                jz      zrch_ret
                mov     r1,a
                call    aka_je_chyba
                mov     r2,a
                mov     dptr,#error_table
zrch_lp:        movx    a,@dptr
                xrl     a,r0
                jz      zrch_ok
                inc     dptr
                djnz    r1,zrch_lp
                ret
zrch_ok:        dec     error_no
                mov     a,r2
                movx    @dptr,a
zrch_ret:       ret
