; version 4.x

t_write         equ     0

th_output:      dw      output_setup
                db      id_output,0,30

output_setup:   clr     a
                mov     wr_brd_reg1,a
                mov     wr_brd_reg2,a
                mov     wr_brd_reg3,a
                mov     wr_brd_reg4,a
                mov     wr_brd_reg5,a
                mov     wr_brd_reg6,a
                mov     wr_brd_reg7,a
                mov     polohovka,a

                call    write_brd_regs1
                call    write_brd_regs2
                
                clr     pol_writing
                clr     can0_change1
                clr     can0_change2
                clr     can0_change3

output_main_lp: call    do_them
                call    can0_poll
                jnb     can0_change2,oml_skip1
                clr     can0_change2
                call    write_brd_regs1
                call    write_brd_regs2
oml_skip1:      mov     a,polohovka
                jz      oml_skip2
                cjne    a,#1,oml_skip1_1
                ; sucik
                call    sucik_write_data
                sjmp    oml_skip2
oml_skip1_1:    cjne    a,#2,oml_skip1_2
                ; lcom
                call    lcom_write_data
                sjmp    oml_skip2
oml_skip1_2:    cjne    a,#3,oml_skip2
                ; banel
                call    lcom_write_data_banel
                
oml_skip2:      mov     a,#t_write
                call    tmr_zro
                jnc     oml_skip3
                call    tmr_int_f
                db      t_write,0,3,0
                setb    can0_change1
oml_skip3:      jmp     output_main_lp
