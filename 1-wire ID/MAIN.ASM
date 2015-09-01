; version 1.0

delay:          mov     r4,#0
                mov     r5,a
                mov     r6,#0
                mov     a,#t_delay
                jmp     wait4it

initial_thread: setb    data_bit
                setb    scl_pin
                setb    sda_pin
                setb    wc
                setb    delete
                setb    on_off

                clr     nomem
                clr     state
                clr     last_key_ok
                setb    green_blink
                setb    yellow_blink
                setb    red_blink

                mov     dptr,#output_init
                call    run_it

wait_lp:        call    do_them
                jb      short,wait_lp
                clr     green_blink
                clr     yellow_blink
                clr     red_blink

                call    detect_memory
                jnz     check_for_master
                setb    nomem
                jmp     main_loop

check_for_master:
                clr     a
                call    read_key
                mov     r0,#buffer_i2c
                call    is_crc_ok
                jz      got_no_master
                mov     r0,#buffer_i2c
                mov     r1,#master
                call    copy_key
                jmp     main_loop

got_no_master:  mov     r7,#1
                mov     r6,#max_no_of_keys-1
                mov     r5,#0
any_key_lp:     push    ar5
                push    ar6
                push    ar7
                mov     a,r7
                call    read_key
                call    do_them
                mov     r0,#buffer_i2c
                call    is_crc_ok
                pop     ar7
                pop     ar6
                pop     ar5
                jz      akl_no
                inc     r5
akl_no:         inc     r7
                djnz    r6,any_key_lp

                mov     a,r5
                jz      wait_indef
                setb    yellow_blink
                call    wait_for_key2
                clr     yellow_blink
                jz      wfm_entry2
                sjmp    wfm_entry1
wait_indef:     setb    red_blink
                call    wait_for_key
                clr     red_blink
wfm_entry1:     call    add_master
wfm_entry2:     setb    rled
                setb    yled
                setb    green_blink
                mov     a,#tm_idle
                call    delay

main_loop:      call    do_them
                setb    green_blink
                mov     c,delete
                orl     c,nomem
                jc      m0_skip1
                ;jmp     master_3
m0_skip1:       call    wait_for_key
                jb      nomem,m0_skip2
                call    is_master
                jnz     master_1
                call    check_last
                jnz     m0_skip2
                call    check_key
                jz      main_loop
                call    store_last
m0_skip2:       ;jb      on_off,m0_skip4
if prepinanie
                jbc     state,m0_skip3
                setb    state
                clr     yled
                setb    rout
                mov     a,#tm_idle
                call    delay
                jmp     main_loop
m0_skip3:       setb    yled
                clr     rout
                mov     a,#tm_idle
                call    delay
                jmp     main_loop
else
m0_skip4:       clr     yled
                call    zapni_rele
                jmp     main_loop
endif

master_1:       clr     last_key_ok
                clr     green_blink
                clr     gled
                mov     a,#tm_switch
                call    delay
                mov     r0,#redundancy3
m1_lp0:         call    touch_reset
                jc      m1_skip0
                djnz    r0,m1_lp0
                setb    gled
                jmp     main_loop
m1_skip0:       call    wait_for_key
                call    is_master
                jnz     master_2
m1_lp1:         call    check_last
                jnz     m1_skip2
                call    check_key
                jnz     m1_skip1
                call    add_key
                jnz     m1_skip1
                setb    yled
                sjmp    m1_skip3
m1_skip1:       call    store_last
m1_skip2:       clr     yled
m1_skip3:       call    wait_for_key
                call    is_master
                jz      m1_lp1
                setb    gled
                setb    yled
                setb    green_blink
                mov     a,#tm_idle
                call    delay
                jmp     main_loop

master_2:       clr     last_key_ok
                setb    gled
                clr     rled
                mov     a,#tm_switch
                call    delay
                mov     r0,#redundancy3
m2_lp:          call    touch_reset
                jc      m2_skip0
                djnz    r0,m2_lp
                setb    rled
                jmp     main_loop
m2_skip0:       call    wait_for_key
                call    is_master
                jnz     master_3
                call    check_key
                jz      m2_skip1
                call    remove_key
m2_skip1:       clr     yled
                setb    rled
                mov     a,#tm_idle
                call    delay
                jmp     main_loop

master_3:       clr     yled
                call    delete_memory
                clr     gled
                mov     a,#tm_idle
                call    delay
                setb    rled
                setb    yled
                setb    gled
                mov     a,#tm_idle
                call    delay
                jmp     os_init
