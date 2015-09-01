; version 1.0

inc_addr:       mov     a,addr_lo
                add     a,#1
                mov     addr_lo,a
                clr     a
                addc    a,addr_hi
                mov     addr_hi,a
                ret

clear_key:      mov     r2,#8
                mov     a,#0ffh
ck1_lp:         mov     @r0,a
                inc     r0
                djnz    r2,ck1_lp
                ret

copy_key:       mov     r2,#8
ck2_lp:         mov     a,@r0
                mov     @r1,a
                inc     r0
                inc     r1
                djnz    r2,ck2_lp
                ret

compare_keys:   mov     r2,#8
ck3_lp:         mov     a,@r0
                xrl     a,@r1
                jnz     ck3_not_eq
                inc     r0
                inc     r1
                djnz    r2,ck3_lp
                cpl     a
                ret
ck3_not_eq:     clr     a
                ret

; write ff to all memory locations
delete_memory:  mov     r0,#buffer_i2c
                call    clear_key
                mov     r7,#0
                mov     r6,#max_no_of_keys
del_mem_lp:     push    ar6
                push    ar7
                mov     a,r7
                call    write_key
                call    do_them
                pop     ar7
                pop     ar6
                inc     r7
                djnz    r6,del_mem_lp
                ret

; reads a-th key from i2c memory to buffer_i2c
read_key:       mov     b,#8
                mul     ab
                mov     addr_lo,a
                mov     addr_hi,b
                mov     r1,#8
                mov     r0,#buffer_i2c
rk_lp:          call    get_byte
                mov     @r0,a
                inc     r0
                call    inc_addr
                djnz    r1,rk_lp
                ret

; writes key from buffer_i2c to a-th position in i2c memory
write_key:      mov     b,#8
                mul     ab
                mov     addr_lo,a
                mov     addr_hi,b
write_key2:     mov     r1,#8
                mov     r0,#buffer_i2c
wk_lp:          mov     a,@r0
                call    put_byte
                inc     r0
                call    inc_addr
                djnz    r1,wk_lp
                ret

; writes key in buffer_1w to master and i2c memory locations 0-7
add_master:     mov     r0,#buffer_1w
                mov     r1,#master
                call    copy_key
                mov     r0,#buffer_1w
                mov     r1,#buffer_i2c
                call    copy_key
                clr     a
                jmp     write_key

is_master:      mov     r0,#buffer_1w
                mov     r1,#master
                jmp     compare_keys

check_last:     jnb     last_key_ok,cl_no
                mov     r0,#buffer_1w
                mov     r1,#last_key
                jmp     compare_keys
cl_no:          clr     a
                ret

store_last:     setb    last_key_ok
                mov     r0,#buffer_1w
                mov     r1,#last_key
                jmp     copy_key

; checks whether key in buffer_1w is in i2c memory
check_key:      clr     a
                mov     addr_lo,a
                mov     addr_hi,a
ck_lp1:         mov     r0,#buffer_1w
                mov     r1,#8
ck_lp2:         call    get_byte
                xrl     a,@r0
                jnz     ck_not_eq
                call    inc_addr
                inc     r0
                djnz    r1,ck_lp2
                mov     a,#0ffh
                ret
ck_not_eq:      mov     a,addr_lo
                add     a,r1
                mov     addr_lo,a
                clr     a
                addc    a,addr_hi
                mov     addr_hi,a
                mov     a,addr_lo
                cjne    a,#low(max_no_of_keys*8),ck_lp1
                mov     a,addr_hi
                cjne    a,#high(max_no_of_keys*8),ck_lp1
                clr     a
                ret

; adds the key in buffer_1w to i2c memory
add_key:        mov     r7,#1
                mov     r6,#max_no_of_keys-1
ak_lp:          push    ar6
                push    ar7
                mov     a,r7
                call    read_key
                mov     r0,#buffer_i2c
                call    is_crc_ok
                pop     ar7
                pop     ar6
                jz      ak_found
                inc     r7
                djnz    r6,ak_lp
                clr     a
                ret
ak_found:       mov     r0,#buffer_1w
                mov     r1,#buffer_i2c
                call    copy_key
                mov     a,r7
                call    write_key
                mov     a,#0ffh
                ret

; removes the key in buffer_1w from i2c memory
; assumes check_key was called immediately before this
remove_key:     mov     a,addr_lo
                clr     c
                subb    a,#8
                mov     addr_lo,a
                mov     a,addr_hi
                subb    a,#0
                mov     addr_hi,a
                mov     r0,#buffer_i2c
                call    clear_key
                jmp     write_key2
