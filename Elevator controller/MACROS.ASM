
enter_poziarna  macro
                local   ep_skip
if v_poziarnej_bx_do_nuly
                
                mov     a,dra_flags
                anl     a,drb_flags
                jnb     db_opened,ep_skip
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    set_bx
endif
ep_skip:
                endm
                
exit_poziarna   macro
if v_poziarnej_bx_do_nuly
                mov     a,#v_poziarnej_bx_do_nuly - 1
                call    clear_bx
endif
                endm
                