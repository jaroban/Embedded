; version 1.0

display:        call    lcd_init
                call    rst_wd
                call    lcd_setup_f
                call    rst_wd
                call    define_chars

dsp_main_lp:    call    do_them
                call    lcd_refresh
                jmp     dsp_main_lp
