; version 2.0

get_nrm_mask:   inc     a
                movc    a,@a+pc
                ret
                db      1,2,4,8,10h,20h,40h,80h

get_rvs_mask:   inc     a
                movc    a,@a+pc
                ret
                db      80h,40h,20h,10h,8,4,2,1

clear_data:     clr     a
cd_lp:          mov     @r0,a
                inc     r0
                djnz    r1,cd_lp
                ret

copy_ram:       mov     a,@r1
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,copy_ram
                ret

copy_movc:      clr     a
                movc    a,@a+dptr
                inc     dptr
                mov     @r0,a
                inc     r0
                djnz    r1,copy_movc
                ret

scroll_left:    mov     r0,#layer1+9
                mov     r1,#10
scl_lp:         xch     a,@r0
                dec     r0
                djnz    r1,scl_lp
                ret

scroll_up:      mov     r0,#layer2
                mov     r1,#shift_in
                mov     r2,#5
scu_lp:         clr     c
                mov     a,@r1
                rrc     a
                mov     @r1,a
                mov     a,@r0
                rrc     a
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,scu_lp
                ret

scroll_down:    mov     r0,#layer2
                mov     r1,#shift_in
                mov     r2,#5
scd_lp:         clr     c
                mov     a,@r1
                rlc     a
                mov     @r1,a
                mov     a,@r0
                rlc     a
                mov     @r0,a
                inc     r0
                inc     r1
                djnz    r2,scd_lp
                ret
