; version 4.1

c_mask          equ     00000100b
ba_mask         equ     00000011b
__              equ     00000000b
_a              equ     00000001b
b_              equ     00000010b
ba              equ     00000011b
hd_mask         equ     11000000b
_d              equ     10000000b
h_              equ     01000000b
hd              equ     11000000b

je_horny:       mov     a,snimace
                anl     a,#h_
                ret

je_dolny:       mov     a,snimace
                anl     a,#_d
                ret

je_a_alebo_b:   mov     a,snimace
                anl     a,#ba_mask
                ret

je_c:           mov     a,snimace
                anl     a,#c_mask
                ret

je_len_horny:   mov     a,snimace
                anl     a,#hd_mask
                xrl     a,#h_
                jz      je_x_1
                clr     a
                ret

je_len_dolny:   mov     a,snimace
                anl     a,#hd_mask
                xrl     a,#_d
                jz      je_x_1
                clr     a
                ret
je_x_1:         cpl     a
                ret

je_h_aj_d:      mov     a,snimace
                anl     a,#hd_mask
                xrl     a,#hd
                jz      je_x_1
                clr     a
                ret

je_a:           mov     a,snimace
                anl     a,#_a
                ret

je_b:           mov     a,snimace
                anl     a,#b_
                ret
                
je_len_a:       mov     a,snimace
                anl     a,#ba_mask
                xrl     a,#_a
                jz      je_x_1
                clr     a
                ret

je_len_b:       mov     a,snimace
                anl     a,#ba_mask
                xrl     a,#b_
                jz      je_x_1
                clr     a
                ret

je_a_aj_b:      mov     a,snimace
                anl     a,#ba_mask
                xrl     a,#ba
                jz      je_x_1
                clr     a
                ret

dec_my_liftpos: mov     a,my_liftpos
                jz      dml_ret
                dec     a
iml_ok:         mov     my_liftpos,a
dml_ret:        ret

inc_my_liftpos: mov     a,my_liftpos
                inc     a
                cjne    a,floor_no,iml_ok
                ret

ul_je_len_horny:
                mov     liftsub,#1
                mov     a,floor_no
                dec     a
                mov     my_liftpos,a
                mov     liftpos,a
                ret

ul_je_len_dolny:
                mov     liftsub,#1
                clr     a
                mov     my_liftpos,a
                mov     liftpos,a
                ret

ulx_ret:        ret
update_liftpos: mov     a,liftpos
                inc     a
                jz      ulx_ret
                call    aka_nahrada
                jnz     ul_try_1
                ; nie je nahrada
                mov     a,liftsub
                clr     c
                subb    a,#13
                jc      ul_ok1
                mov     liftsub,#13

ul_ok1:         call    c_vedla_a_b
                jnz     ul_ok2
                ; normalne
                mov     dptr,#ul_table
ul_entry:       mov     a,liftsub
                mov     r0,a
                rl      a
                add     a,r0
                jmp     @a+dptr
                ; c vedla a/b
ul_ok2:         mov     dptr,#ulc_table
                sjmp    ul_entry

ul_try_1:       ; nahrada
                call    je_len_horny
                jnz     ul_je_len_horny
                call    je_len_dolny
                jnz     ul_je_len_dolny

                mov     a,liftsub
                anl     a,#3
                mov     liftsub,a
                
                call    aka_nahrada
                cjne    a,#1,ul_try_2
                ; nahrada 250
                mov     dptr,#uln2_table
                sjmp    ul_entry
ul_try_2:       ; nahrada 100
                mov     dptr,#uln1_table
                sjmp    ul_entry

ul_table:       ljmp    ul_0            ; (b) under stop
                ljmp    ul_1            ; (a+b) stop
                ljmp    ul_2            ; (a) above stop
                ljmp    ul_3            ; (0) gap (short floor)
                ljmp    ul_4            ; (0) gap (long floor)
                ljmp    ul_5            ; (b)
                ljmp    ul_6            ; (0) middle of lower magnet
                ljmp    ul_7            ; (a)
                ljmp    ul_8            ; (0) gap
                ljmp    ul_5            ; (b)
                ljmp    ul_6            ; (0) middle of upper magnet
                ljmp    ul_7            ; (a)
                ljmp    ul_12           ; (0) gap

ul_0:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      __+j_,ul_0_d
                dw      _a+j_,ul_0_s
                dw      ba+j_,ul_0_u
                db      0
ul_0_ret:       ret
ul_0_s:         jb      liftdir,ul_0_u
ul_0_d:         call    dec_my_liftpos
                mov     liftsub,#12
                mov     a,my_liftpos
                call    ake_je_poschodie
                jnz     ul_0_ret
                mov     liftsub,#3
                ret
ul_0_u:         inc     liftsub
                jmp     reset_doba_jazdy

ul_1:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      __+j_,ul_1_s
                dw      _a+j_,ul_1_u
                dw      b_+j_,ul_1_d
                db      0
                call    param_snimac_c
                jz      ul_1_ret
                call    je_c
                jnz     ul_1_ret
                jmp     zdochni_snimac_c
ul_1_ret:       ret
ul_1_s:         jb      liftdir,ul_1_u
ul_1_d:         dec     liftsub
                ret
ul_1_u:         inc     liftsub
                ret

ul_2:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      __+j_,ul_2_u
                dw      b_+j_,ul_2_s
                dw      ba+j_,ul_2_d
                db      0
ul_2_ret:       ret
ul_2_s:         jb      liftdir,ul_2_u
ul_2_d:         dec     liftsub
                jmp     reset_doba_jazdy
ul_2_u:         inc     liftsub
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      ul_2_ret
                inc     liftsub
                ret

ul_3:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      _a+j_,ul_3_d
                dw      b_+j_,ul_3_u
                dw      ba+j_,ul_3_s
                db      0
                call    param_snimac_c
                jz      ul_3_ret
                call    je_c
                jz      ul_3_ret
                jmp     zdochni_snimac_c
ul_3_ret:       ret
ul_3_s:         jb      liftdir,ul_3_u
ul_3_d:         dec     liftsub
                mov     liftpos,my_liftpos
                ret
ul_3_u:         call    inc_my_liftpos
                mov     liftsub,#0
                mov     liftpos,my_liftpos
                ret

ul_4:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      _a+j_,ul_4_d
                dw      b_+j_,ul_4_u
                dw      ba+j_,ul_4_s
                db      0
ul_4_ret:       ret
ul_4_s:         jb      liftdir,ul_4_u
ul_4_d:         mov     liftsub,#2
                ret
ul_4_u:
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                jnz     ul_4_ok
                ; na najnizsom poschodi len jeden magnet
                mov     liftsub,#9
                mov     liftpos,#1
                ret
endif
ul_4_ok:        inc     liftsub
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#2,ul_4_ret
                mov     a,my_liftpos
                inc     a
                mov     liftpos,a
                ret

ul_5:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      __+j_,ul_5_s
                dw      _a+j_,ul_5_s
                dw      ba+j_,ul_5_s
                db      0
ifn magnety_pri_hornom_dolnom
                call    je_len_dolny
                jnz     ul_5_s
                call    je_len_horny
                jnz     ul_5_s
endif
                ret
ul_5_s:         jb      liftdir,ul_5_u
                dec     liftsub
                ret
ul_5_u:         inc     liftsub
                ret

ul_6:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      _a+j_,ul_6_u
                dw      b_+j_,ul_6_d
                dw      ba+j_,ul_6_s
                db      0
ifn magnety_pri_hornom_dolnom
                call    je_len_dolny
                jnz     ul_6_d
                call    je_len_horny
                jnz     ul_6_u
endif                
                ret
ul_6_s:         jb      liftdir,ul_6_u
ul_6_d:         dec     liftsub
                ret
ul_6_u:         inc     liftsub
                ret

ul_7:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      __+j_,ul_7_s
                dw      b_+j_,ul_7_s
                dw      ba+j_,ul_7_s
                db      0
ifn magnety_pri_hornom_dolnom
                call    je_len_dolny
                jnz     ul_7_s
                call    je_len_horny
                jnz     ul_7_s
endif
                ret
ul_7_s:         jb      liftdir,ul_7_u
                dec     liftsub
                ret
ul_7_u:         inc     liftsub
                ret

ul_8:           mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      _a+j_,ul_8_d
                dw      b_+j_,ul_8_u
                dw      ba+j_,ul_8_s
                db      0
ifn magnety_pri_hornom_dolnom
                call    je_len_dolny
                jnz     ul_8_d
                call    je_len_horny
                jnz     ul_8_u
endif                
                call    param_snimac_c
                jz      ul_8_ret
                call    je_c
                jz      ul_8_ret
                jmp     zdochni_snimac_c
ul_8_ret:       ret
ul_8_s:         jb      liftdir,ul_8_u
ul_8_d:         dec     liftsub
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#1,ul_8_ret
                mov     liftpos,my_liftpos
                ret
ul_8_u:         inc     liftsub
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#1,ul_8_ret
                mov     a,my_liftpos
                inc     a
                mov     liftpos,a
                ret

ul_12:          mov     a,snimace
                anl     a,#ba_mask
                call    do_case
                dw      _a+j_,ul_12_d
                dw      b_+j_,ul_12_u
                dw      ba+j_,ul_12_s
                db      0
ul_12_ret:      ret
ul_12_s:        jb      liftdir,ul_12_u
ul_12_d:
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                inc     a
                inc     a
                cjne    a,floor_no,ul_12_ok
                ; na najvyssom poschodi len jeden magnet
                mov     liftsub,#7
                mov     liftpos,my_liftpos
                ret
endif
ul_12_ok:       dec     liftsub
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#2,ul_12_ret
                mov     liftpos,my_liftpos
                ret
ul_12_u:        call    inc_my_liftpos
                mov     liftsub,#0
                ret

ulc_table:      ljmp    ulc_inc         ; (b) under stop
                ljmp    ulc_1           ; (a+b) stop
                ljmp    ulc_dec         ; (a) above stop
                ljmp    ulc_3           ; (0) gap (short floor)
                ljmp    ulc_4           ; (0) gap (long floor)
                ljmp    ulc_dec         ;
                ljmp    ulc_6           ; (c) lower magnet
                ljmp    ulc_inc         ;
                ljmp    ulc_8           ; (0) gap
                ljmp    ulc_dec         ;
                ljmp    ulc_6           ; (c) upper magnet
                ljmp    ulc_inc         ;
                ljmp    ulc_12          ; (0) gap

ulc_dec:        dec     liftsub
                ret

ulc_inc:        inc     liftsub
                ret

ulc_1:          call    je_a_aj_b
                jnz     ulc_1_ret
                jb      liftdir,ulc_1_u
                call    dec_my_liftpos
                mov     liftsub,#12
                mov     a,my_liftpos
                call    ake_je_poschodie
                jnz     ulc_1_ret
                mov     liftsub,#3
                ret
ulc_1_u:        mov     liftsub,#3
                mov     a,my_liftpos
                call    ake_je_poschodie
                jz      ulc_1_ret
                inc     liftsub
ulc_1_ret:      ret

ulc_3:          call    je_a_aj_b
                jz      ulc_3_ret
                jb      liftdir,ulc_3_u
                mov     liftsub,#1
                mov     liftpos,my_liftpos
                jmp     reset_doba_jazdy
ulc_3_u:        call    inc_my_liftpos
                mov     liftsub,#1
                mov     liftpos,my_liftpos
                jmp     reset_doba_jazdy
ulc_3_ret:      ret

ulc_4:          call    je_a_aj_b
                jnz     ulc_4_d                
                call    je_c
                jnz     ulc_4_u
ulc_4_ret:      ret
ulc_4_d:        mov     liftsub,#1
                jmp     reset_doba_jazdy
ulc_4_u:
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                jnz     ulc_4_ok
                ; na najnizsom poschodi len jeden magnet
                mov     liftsub,#10
                mov     liftpos,#1
                ret
endif
ulc_4_ok:       mov     liftsub,#6
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#2,ulc_4_ret
                mov     a,my_liftpos
                inc     a
                mov     liftpos,a
                ret

ulc_6:          call    je_a_aj_b
                jnz     ulc_6_s
ifn magnety_pri_hornom_dolnom
                call    je_len_horny
                jnz     ulc_6_u
                call    je_len_dolny
                jnz     ulc_6_d
endif                
                call    je_c
                jz      ulc_6_s
                ret
ulc_6_s:        jb      liftdir,ulc_6_u
ulc_6_d:        dec     liftsub
                dec     liftsub
                ret
ulc_6_u:        inc     liftsub
                inc     liftsub
                ret

ulc_8:          call    je_a_aj_b
                jnz     ulc_8_s
                call    je_c
                jnz     ulc_8_s
ifn magnety_pri_hornom_dolnom
                call    je_len_horny
                jnz     ulc_8_u
                call    je_len_dolny
                jnz     ulc_8_d
endif
ulc_8_ret:      ret
ulc_8_s:        jb      liftdir,ulc_8_u
ulc_8_d:        mov     liftsub,#6
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#1,ulc_8_ret
                mov     liftpos,my_liftpos
                ret
ulc_8_u:        mov     liftsub,#10
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#1,ulc_8_ret
                mov     a,my_liftpos
                inc     a
                mov     liftpos,a
                ret

ulc_12:         call    je_a_aj_b
                jnz     ulc_12_u
                call    je_c
                jnz     ulc_12_d
ulc_12_ret:     ret
ulc_12_d:
ifn magnety_pri_hornom_dolnom
                mov     a,my_liftpos
                inc     a
                inc     a
                cjne    a,floor_no,ulc_12_ok
                ; na najvyssom poschodi len jeden magnet
                mov     liftsub,#6
                mov     liftpos,my_liftpos
                ret
endif
ulc_12_ok:      mov     liftsub,#10
                mov     a,my_liftpos
                call    ake_je_poschodie
                cjne    a,#2,ulc_12_ret
                mov     liftpos,my_liftpos
                ret
ulc_12_u:       call    inc_my_liftpos
                mov     liftsub,#1
                jmp     reset_doba_jazdy

                ; 250
uln2_table:     ljmp    uln2_0          ; (b) under stop
                ljmp    uln2_1          ; (0) stop
                ljmp    uln2_2          ; (a) above stop
                ljmp    uln2_3          ; (0) gap

uln2_0:         call    je_b
                jnz     uln2_0_ret
                jb      liftdir,uln2_0_u
                call    dec_my_liftpos
                mov     liftsub,#3
uln2_0_ret:     ret
uln2_0_u:       inc     liftsub
                jmp     reset_doba_jazdy

uln2_1:         mov     a,my_liftpos
                jz      uln2_1_b
                inc     a
                cjne    a,floor_no,uln2_1_1
                dec     my_liftpos
uln2_1_b:       mov     liftsub,#3
uln2_1_ret:     ret
uln2_1_1:       call    je_len_a
                jz      uln2_1_t
                inc     liftsub
                ret
uln2_1_t:       call    je_len_b
                jz      uln2_1_ret
                dec     liftsub
                ret

uln2_2:         call    je_a
                jnz     uln2_2_ret
                jb      liftdir,uln2_2_u
                dec     liftsub
                jmp     reset_doba_jazdy
uln2_2_u:       inc     liftsub
uln2_2_ret:     ret

uln2_3:         call    je_len_a
                jz      uln2_3_b
uln2_3_d:       dec     liftsub
                mov     a,my_liftpos
                jnz     uln2_3_ok
                inc     a
                mov     my_liftpos,a
uln2_3_ok:      mov     liftpos,a
                ret
uln2_3_b:       call    je_len_b
                jz      uln2_3_ret
uln2_3_u:       mov     liftsub,#0
                mov     a,my_liftpos
                inc     a
                inc     a
                xrl     a,floor_no
                jz      uln2_3_ret
                inc     my_liftpos
                mov     liftpos,my_liftpos
uln2_3_ret:     ret

                ; 100
uln1_table:     ljmp    uln1_0          ; (?) under stop
                ljmp    uln1_1          ; (a+b) stop
                ljmp    uln1_2          ; (?) above stop
                ljmp    uln1_3          ; (0) gap

uln1_0:         inc     liftsub
                ret
                
uln1_1:         mov     a,my_liftpos
                jz      uln1_1_b
                inc     a
                cjne    a,floor_no,uln1_1_1
                dec     my_liftpos
uln1_1_b:       mov     liftsub,#3
uln1_1_ret:     ret
uln1_1_1:       call    je_a_alebo_b
                jnz     uln1_1_ret
                mov     liftsub,#3
                jb      liftdir,uln1_1_ret
                jmp     dec_my_liftpos

uln1_2:         dec     liftsub
                ret
                
uln1_3:         call    je_a_alebo_b
                jz      uln1_3_ret
                mov     liftsub,#1
                call    reset_doba_jazdy
                jb      liftdir,uln2_3_u
                jmp     uln2_3_d
uln1_3_ret:     ret
