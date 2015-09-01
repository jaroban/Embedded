; version 4.1

init_volby:     mov     r0,#rd_kabina
                mov     r1,#4
                call    clear_ram
                mov     r0,#rd_dole
                mov     r1,#4
                call    clear_ram
                mov     r0,#rd_hore
                mov     r1,#4
                jmp     clear_ram

in_kabina:      call    param_kabina
                jz      ik_ret
                xrl     a,#3
                jz      ik_ret
                mov     r0,#rd_kabina
                mov     a,rd_brd_reg1
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg2
                mov     @r0,a
ik_ret:         ret

in_dole:        call    param_dole
                jz      id_ret
                cjne    a,#1,id_try_2
                mov     r0,#rd_dole
                mov     a,rd_brd_reg3
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg2
                swap    a
                rl      a
                anl     a,#7
                mov     @r0,a
                ret
id_try_2:       cjne    a,#2,id_try_3
                mov     r0,#rd_dole
                mov     a,rd_brd_reg3
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg4
                mov     @r0,a
                ret
id_try_3:       cjne    a,#3,id_ret
                mov     r0,#rd_dole
                mov     a,rd_brd_reg1
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg2
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg3
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg4
                mov     @r0,a
id_ret:         ret

in_hore:        call    param_hore
                jz      ih_ret
                cjne    a,#1,ih_try_2
                mov     r0,#rd_hore
                mov     a,rd_brd_reg4
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg2
                rl      a
                rl      a
                anl     a,#3
                mov     @r0,a
                ret
ih_try_2:       cjne    a,#2,ih_ret
                mov     r0,#rd_hore
                mov     a,rd_brd_reg1
                mov     @r0,a
                inc     r0
                mov     a,rd_brd_reg2
                mov     @r0,a
ih_ret:         ret
