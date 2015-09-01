; version 4.0

g_kabina        equ     0
g_dole          equ     1
g_hore          equ     2

th_group:       dw      group_setup, st_group
                db      id_group, 0, st_group_size

m_del_all       equ     0
m_del_cabin     equ     1
m_new_call      equ     2
m_del_call      equ     3
m_del_out       equ     4

m_cmp           equ     0a1h
m_del           equ     0a2h
m_zak           equ     0a3h
m_loc           equ     0a4h
m_boss          equ     0a5h
m_test          equ     0a6h

cs_dead         equ     0       ; disabled via parameter
cs_off          equ     1       ; off, polling
cs_on           equ     2       ; call assigned to me (no group)
cs_cmp_me       equ     3       ; winning comparison
cs_cmp_them     equ     4       ; losing comparison
cs_on_me        equ     5       ; call assigned to me (group)
cs_on_them      equ     6       ; call assigned to them (group)
cs_just_me      equ     7       ; call assigned exclusively to me
cs_just_them    equ     8       ; call can't be assigned to me
cs_numb         equ     9       ; waiting to settle down
cs_stuck        equ     10      ; stuck in active state

; in 0.25 second intervals
g_overflow:     db      255,255,255,6,6,12,16,40,60,8,240

                xseg
g_cs_table:     ds      3*no_of_floors
g_cs_timeout:   ds      3*no_of_floors
g_cmp_table:    ds      4*no_of_floors
g_chk_table:    ds      3*no_of_floors
g_dbl_table_d:  ds      no_of_floors
g_dbl_table_h:  ds      no_of_floors
g_locations:    ds      8

                cseg
group_setup:    call    group_init
                call    je_zdochnutie
                jnz     g_s_skip
                call    aka_skupina
                jz      g_s_skip
                jmp     gg_main_lp
g_s_skip:       jmp     gs_main_lp

vymaz_volby:    mov     r2,#0
                mov     r1,#m_del_all
                mov     r0,#id_group
                jmp     ovr_msg

vymaz_kabinove: mov     r2,#0
                mov     r1,#m_del_cabin
                mov     r0,#id_group
                jmp     ovr_msg
if 0
vymaz_vonkajsie:
                mov     r2,#0
                mov     r1,#m_del_out
                mov     r0,#id_group
                jmp     ovr_msg
endif

vymaz_kabina:   mov     r4,a
                mov     r3,#g_kabina
                mov     r2,#2
                mov     r1,#m_del_call
                mov     r0,#id_group
                jmp     snd_msg
                
vymaz_dole:     mov     r4,a
                mov     r3,#g_dole
                mov     r2,#2
                mov     r1,#m_del_call
                mov     r0,#id_group
                jmp     snd_msg

vymaz_hore:     mov     r4,a
                mov     r3,#g_hore
                mov     r2,#2
                mov     r1,#m_del_call
                mov     r0,#id_group
                jmp     snd_msg
                
g_send_cmp:     call    ake_spojenie
                jz      gsc_ret
                mov     r2,#4
                mov     r1,#m_cmp
                cjne    a,#1,gsc_can
                mov     r0,#id_serial
                jmp     snd_msg
gsc_can:        mov     r0,#id_can
                jmp     snd_msg
gsc_ret:        ret

g_send_del:     call    ake_spojenie
                jz      gsd_ret
                mov     r2,#2
                mov     r1,#m_del
                cjne    a,#1,gsd_can
                mov     r0,#id_serial
                jmp     snd_msg
gsd_can:        mov     r0,#id_can
                jmp     snd_msg
gsd_ret:        ret

g_send_zak:     call    ake_spojenie
                jz      gsz_ret
                mov     r2,#2
                mov     r1,#m_zak
                cjne    a,#1,gsz_can
                mov     r0,#id_serial
                jmp     snd_msg
gsz_can:        mov     r0,#id_can
                jmp     snd_msg
gsz_ret:        ret

g_send_loc:     call    ake_spojenie
                jz      gsl_ret
                push    acc
                mov     r4,liftpos
                call    cislo_v_skupine
                mov     r3,a
                mov     r2,#2
                mov     r1,#m_loc
                pop     acc
                cjne    a,#1,gsl_can
                mov     r0,#id_serial
                jmp     ovr_msg
gsl_can:        mov     r0,#id_can
                jmp     ovr_msg
gsl_ret:        ret

g_send_boss:    call    ake_spojenie
                jz      gsb_ret
                mov     r2,#0
                mov     r1,#m_boss
                cjne    a,#1,gsb_can
                mov     r0,#id_serial
                jmp     snd_msg
gsb_can:        mov     r0,#id_can
                jmp     snd_msg
gsb_ret:        ret

g_send_test:    mov     r2,#1
                mov     r1,#m_test
                mov     r0,#id_can
                jmp     ovr_msg
