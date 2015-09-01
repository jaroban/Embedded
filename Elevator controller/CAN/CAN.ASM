; version 4.1

th_can:         dw      can_setup, st_can
                db      id_can, 0, st_can_size

th_can_test:    dw      can_both, st_can
                db      id_can, 0, st_can_size

je_treba_can0:  jmp     je_kabina_po_cane

je_treba_can1:  jmp     je_skupina_po_cane

can_setup:      clr     can_debug
                call    je_treba_can0
                jz      cs_try_can1
                call    je_treba_can1
                jz      can_only_0
                sjmp    can_both
cs_try_can1:    call    je_treba_can1
                jnz     can_only_1
                jmp     kill_me

can_only_0:     call    can0_setup

                call    init_timer_f
                dw      t_can_init
                db      0,3,0
c0_lp1:         call    do_them
                call    can0_write
                call    timer_running_f
                dw      t_can_init
                jnz     c0_lp1
                
c0_lp2:         call    do_them
                call    can0_poll
                call    can0_write
                jmp     c0_lp2

can_only_1:     call    can1_setup

                call    init_timer_f
                dw      t_can_init
                db      0,3,0
c1_lp1:         call    do_them
                call    can1_write
                call    timer_running_f
                dw      t_can_init
                jnz     c1_lp1

c1_lp2:         call    do_them
                call    can1_poll
                call    can1_write
                jmp     c1_lp2

can_both:       clr     can_debug
                call    can0_setup
                call    can1_setup
                
                call    init_timer_f
                dw      t_can_init
                db      0,3,0
cb_lp1:         call    do_them
                call    can0_write
                call    can1_write
                call    timer_running_f
                dw      t_can_init
                jnz     cb_lp1

cb_lp2:         call    do_them
                call    can0_poll
                call    can0_write
                call    can1_poll
                call    can1_write
                jmp     cb_lp2
