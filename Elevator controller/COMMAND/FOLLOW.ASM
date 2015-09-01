; version 4.0

th_follower:    dw      follower, st_follower
                db      id_follower, os_bank1, st_follower_size

m_store_time    equ     0
m_pocet_jazd    equ     1
m_write_error   equ     2
m_zakapanie     equ     3

slv_adr         data    8
i2c_cnt         data    9
lcd_pos         data    10

zapis_chybu:    mov     r4,liftpos
                inc     r4
                mov     r3,a
                dec     r3
                mov     r2,#2
                mov     r1,#m_write_error
                mov     r0,#id_follower
                jmp     snd_msg

uloz_pocet_jazd:
                mov     r2,#0
                mov     r1,#m_pocet_jazd
                mov     r0,#id_follower
                jmp     ovr_msg

zapis_zakapanie:
                mov     r2,#0
                mov     r1,#m_zakapanie
                mov     r0,#id_follower
                jmp     ovr_msg
                
; pj_table:
; 0 1 2 : pocet jazd in bcd (msb lsb)
; 3 : checksum (0+1+2)
; 4 5 : used by compare routine

inc_pocet_jazd: mov     r0,#pj_table+2
                mov     r1,#3
                setb    c
ipj_lp1:        mov     a,@r0
                addc    a,#0
                da      a
                mov     @r0,a
                dec     r0
                djnz    r1,ipj_lp1
                mov     r0,#pj_table
                mov     r1,#3
                clr     a
ipj_lp2:        add     a,@r0
                inc     r0
                djnz    r1,ipj_lp2
                mov     @r0,a
                ret

display_pocet_jazd:
                mov     r0,#pj_table
                mov     r1,#3
dpj_lp:         mov     a,@r0
                call    lcd_hex
                inc     r0
                djnz    r1,dpj_lp
                ret

check_pocet_jazd:
                mov     r0,#pj_table
                mov     r1,#3
                clr     a    
cpj_lp:         add     a,@r0 
                inc     r0
                djnz    r1,cpj_lp
                mov     b,@r0
                cjne    a,b,cpj_bad
                mov     a,#1
                ret
cpj_bad:        clr     a
                ret

compare_pocet_jazd:
                call    max_pocet_jazd
                jz      mpj_ret
                mov     b,#10
                div     ab
                mov     r1,a
                mov     a,b                     ; a <= b = zvysok
                swap    a
                mov     r0,#pj_table+5
                mov     @r0,a
                dec     r0
                mov     a,r1                    ; a <= cela cast 
                mov     b,#10
                div     ab
                swap    a
                add     a,b
                mov     @r0,a
                mov     r0,#pj_table
                mov     r1,#pj_table+4
                mov     r2,#2
mpj_lp:         mov     a,@r0
                mov     b,@r1
                cjne    a,b,mpj_noteq
                inc     r0
                inc     r1
                djnz    r2,mpj_lp
mpj_over:       mov     a,#-1
                ret
mpj_noteq:      jnc     mpj_over
                clr     a
mpj_ret:        ret

load_pocet_jazd:
                clr     a
                call    i2c_get_byte
                mov     r0,#pj_table
                mov     @r0,a
                mov     a,#1
                call    i2c_get_byte
                mov     r0,#pj_table+1
                mov     @r0,a
                mov     a,#2
                call    i2c_get_byte
                mov     r0,#pj_table+2
                mov     @r0,a
                mov     a,#3
                call    i2c_get_byte
                mov     r0,#pj_table+3
                mov     @r0,a
                call    check_pocet_jazd
                jz      rst_pj
                ret

load_ozivenie:  call    je_ozivenie2
                jz      loz_no
                mov     a,#4
                call    i2c_get_byte
                jz      loz_no
                setb    zakapanie
                ret
loz_no:         clr     zakapanie
                ret

store_zakapanie:
                mov     a,#4
                mov     b,#0
                jnb     zakapanie,szd_skip1
                mov     b,#0ffh
szd_skip1:      jmp     i2c_put_byte
                
rst_pj:         mov     r0,#pj_table
                mov     r1,#4
                clr     a
rpj_lp:         mov     @r0,a
                inc     r0
                djnz    r1,rpj_lp
                ret

reset_pocet_jazd:
                call    rst_pj
store_pocet_jazd:
                clr     a
                mov     r0,#pj_table
                mov     b,@r0
                call    i2c_put_byte
                mov     a,#1
                mov     r0,#pj_table+1
                mov     b,@r0
                call    i2c_put_byte
                mov     a,#2
                mov     r0,#pj_table+2
                mov     b,@r0
                call    i2c_put_byte
                mov     a,#3
                mov     r0,#pj_table+3
                mov     b,@r0
                jmp     i2c_put_byte

if 0
get_keyboard:   mov     dps,#0
                mov     dpx,#10h
                mov     dptr,#4
                movx    a,@dptr
                mov     dpx,#0
                ret
                call    get_keyboard
                cpl     a
endif

keyboard:       mov     a,kb_data
                anl     a,#31
                jnz     kb_smthng
                mov     kb_state,a
kb_ret:         ret
kb_smthng:      mov     r7,a
                mov     a,kb_state
                jnz     kb_try_1
                call    init_timer_f
                dw      t_keyboard
                db      0,0,50
                inc     kb_state
                sjmp    kb_send
kb_try_1:       clr     c
                subb    a,#5
                jnc     kb_try_2
                call    timer_running_reload_f
                dw      t_keyboard
                db      0,0,50
                jnz     kb_ret
                inc     kb_state
                sjmp    kb_send
kb_try_2:       subb    a,#5
                jnc     kb_try_3
                call    timer_running_reload_f
                dw      t_keyboard
                db      0,0,25
                jnz     kb_ret
                inc     kb_state
                sjmp    kb_send
kb_try_3:       call    timer_running_reload_f
                dw      t_keyboard
                db      0,0,12
                jnz     kb_ret
kb_send:        mov     r1,#5
                mov     a,r7
kb_lp1:         jb      acc.4,kb_ok
                rl      a
                djnz    r1,kb_lp1
                ret
kb_ok:          setb    key_pressed
                mov     r0,#id_commander
                dec     r1
                mov     r2,#0
                jmp     ovr_msg

refresh_time:   clr     a
                call    i2c_get_time
                mov     r0,#i2c_time+5
                mov     @r0,a                           ; second
                mov     a,#1
                call    i2c_get_time
                mov     r0,#i2c_time+1
                mov     @r0,a                           ; minute
                mov     a,#2
                call    i2c_get_time
                mov     r0,#i2c_time
                mov     @r0,a                           ; hour
                mov     a,#4
                call    i2c_get_time
                mov     r0,#i2c_time+2
                mov     @r0,a                           ; date
                mov     a,#5
                call    i2c_get_time
                mov     r0,#i2c_time+3
                mov     @r0,a                           ; month
                mov     a,#6
                call    i2c_get_time
                mov     r0,#i2c_time+4
                mov     @r0,a                           ; year
                call    i2c_get_tmpr
                mov     r0,#i2c_time+6
                mov     @r0,a
                ret

store_time:     clr     a
                mov     r0,#i2c_time+5
                mov     b,@r0
                call    i2c_put_time
                mov     a,#1
                mov     r0,#i2c_time+1
                mov     b,@r0
                call    i2c_put_time
                mov     a,#2
                mov     r0,#i2c_time
                mov     b,@r0
                call    i2c_put_time
                mov     a,#4
                mov     r0,#i2c_time+2
                mov     b,@r0
                call    i2c_put_time
                mov     a,#5
                mov     r0,#i2c_time+3
                mov     b,@r0
                call    i2c_put_time
                mov     a,#6
                mov     r0,#i2c_time+4
                mov     b,@r0
                call    i2c_put_time
                call    init_timer_f
                dw      t_time
                db      0,10,0
                clr     dont_refresh_time
                ret

update_hodiny:  mov     r0,#i2c_time
                mov     a,@r0
                call    bcd_hex
                mov     r1,a                    ; hour
                inc     r0
                mov     a,@r0
                call    bcd_hex
                mov     r2,a                    ; minute
                clr     a
                mov     dpx,a
                mov     dpx1,a
                mov     dps,#00100100b
                mov     dptr,#hodiny_table
                mov     dptr,#hodiny_values
                mov     r0,#no_of_hodiny
uh_oh_lp:       mov     b,#0
                mov     dps,#0                  ; 67 = high
                movx    a,@dptr                 ; 45 = low
                inc     dptr                    ; 12 = current
                mov     r5,a
                setb    c
                subb    a,r2
                movx    a,@dptr
                inc     dptr
                mov     r4,a
                subb    a,r1
                cpl     c
                mov     b.0,c
                movx    a,@dptr
                inc     dptr
                mov     r7,a
                clr     c
                subb    a,r2
                movx    a,@dptr
                inc     dptr
                mov     r6,a
                subb    a,r1
                mov     b.1,c
                mov     a,r7
                clr     c
                subb    a,r5
                mov     a,r6
                subb    a,r4
                mov     b.2,c
                mov     dps,#5
                mov     a,b
                jz      uh_oh_ok
                xrl     a,#5
                jz      uh_oh_ok
                xrl     a,#3
uh_oh_ok:       movx    @dptr,a
                inc     dptr
                djnz    r0,uh_oh_lp
                mov     dps,#0
                ret

follower:       call    i2c_init
                call    load_pocet_jazd
                call    load_ozivenie
                call    lcd_init
                call    define_chars
                call    lcd_setup_f

                mov     kb_state,#0
                clr     dont_refresh_time
                setb    key_pressed

fol_main_lp:    call    do_them
                call    lcd_refresh
                call    keyboard
                jb      dont_refresh_time,fol_skip1
                call    timer_running_reload_f
                dw      t_time
                db      0,10,0
                jnz     fol_skip1
                call    refresh_time
                call    update_hodiny
fol_skip1:      jnb     key_pressed,fol_skip2
                clr     key_pressed
                setb    lcd_is_on
                setb    lcd_light
                call    init_timer_f
                dw      t_lcd_on
                db      2,0,0
                sjmp    fol_skip3
fol_skip2:      jnb     lcd_is_on,fol_skip3
                call    timer_running_f
                dw      t_lcd_on
                jnz     fol_skip3
                clr     lcd_is_on
                clr     lcd_light
fol_skip3:      call    do_vnts
                dw      m_store_time+c_,store_time
                dw      m_pocet_jazd+c_,store_pocet_jazd
                dw      m_write_error+c_,write_error
                dw      m_zakapanie+c_,store_zakapanie
                db      0
                jmp     fol_main_lp
