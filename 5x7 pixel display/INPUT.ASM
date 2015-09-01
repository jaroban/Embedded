; version 2.0

read_inputs:    mov     a,p3
                ;jb      polarity_pin,ri_ok
                ;cpl     a
ri_ok:          mov     inputs,a
                mov     a,p0
                cpl     a
                swap    a
                rr      a
                anl     a,#7
                mov     jumpers,a
                ret

detect_clock:   mov     c,clock_pin
                anl     c,/clock_old
                jc      dc_yes
                mov     c,clock_pin
                mov     clock_old,c
                clr     a
                ret
dc_yes:         setb    clock_old
                mov     a,#0ffh
                ret

get_pol_bit:    mov     a,r0
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table_old
                mov     r1,a
                mov     a,r0
                anl     a,#7
                call    get_rvs_mask
                anl     a,@r1
                ret

; r0=cnt  dptr -> table of bit addresses
pol_byte:       mov     r2,#0
pb_lp:          clr     a
                movc    a,@a+dptr
                mov     r1,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table_old
                xch     a,r1
                anl     a,#7
                call    get_rvs_mask
                anl     a,@r1
                clr     c
                jz      pb_shift
                setb    c
pb_shift:       mov     a,r2
                rlc     a
                mov     r2,a
                inc     dptr
                djnz    r0,pb_lp
                ret

process_data:   mov     a,pol_index
                jnz     pd_get_bit
                jnb     data_pin,pd_ret
                inc     pol_index
pd_ret:         clr     a
                ret
pd_get_bit:     dec     a
                mov     r0,a
                swap    a
                rl      a
                anl     a,#1fh
                add     a,#pol_table
                xch     a,r0
                anl     a,#7
                call    get_rvs_mask
                jb      data_pin,pd_set
                cpl     a
                anl     a,@r0
                sjmp    pd_inc
pd_set:         orl     a,@r0
pd_inc:         mov     @r0,a
                inc     pol_index
                mov     a,#36
                cjne    a,pol_index,pd_ret
                mov     pol_index,#0

                mov     r0,#pol_table
                mov     r1,#pol_table_old
                mov     r2,#5
                mov     b,#0
pd_lp1:         mov     a,@r0
                mov     r3,a
                xch     a,@r1
                xrl     a,r3
                orl     b,a
                inc     r0
                inc     r1
                djnz    r2,pd_lp1
                mov     a,b
                jz      pd_ret
                mov     a,#0ffh
                ret

find_char:      mov     r0,a
                mov     dptr,#symbol_table
fc_lp:          clr     a
                movc    a,@a+dptr
                jz      fc_done
                xrl     a,r0
                jz      fc_done
                mov     a,dpl
                add     a,#6
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                jmp     fc_lp
fc_done:        inc     dptr
                ret

do_layer2:      mov     c,going_up_n
                orl     c,going_dn_n
                jc      dl2_try_both
                mov     r0,#layer2
                mov     r1,#5
                call    clear_data
                mov     shift_cnt,#1
                clr     show_dir
                clr     blink_dir
                ret
dl2_try_both:   clr     show_dir
                setb    blink_dir
                mov     a,char_hi
                cjne    a,#' ',dl2_skip
                setb    show_dir
                clr     blink_dir
dl2_skip:       mov     c,going_up_n
                anl     c,going_dn_n
                jnc     dl2_ret
                mov     r0,#layer2
                mov     r1,#5
                mov     dptr,#arrow_both_table
                call    copy_movc
                mov     shift_cnt,#1
dl2_ret:        ret

show_data:      clr     ea
                mov     r0,#2
                mov     dptr,#pol_dir
                call    pol_byte
                rrc     a
                mov     going_up_n,c
                rrc     a
                mov     going_dn_n,c

                mov     r0,#8
                mov     dptr,#pol_ascii0
                call    pol_byte
                mov     char_lo,a
                mov     r0,#8
                mov     dptr,#pol_ascii1
                call    pol_byte
                mov     char_hi,a

                mov     a,char_hi
                cjne    a,#'-',sd_skip0
                mov     a,#'0'
                clr     c
                subb    a,char_lo
                sjmp    sd_drain
sd_skip0:       mov     r0,#0
                cjne    a,#'1',sd_skip1
                mov     r0,#10
sd_skip1:       mov     a,char_lo
                clr     c
                subb    a,#'0'
                add     a,r0
sd_drain:       add     a,jumpers
                dec     a
                mov     bcd_out,a
                call    show_outputs

                mov     r0,#pol_porucha
                call    get_pol_bit
                jz      sd_try_1
                jb      porucha,sd_done
                setb    porucha
                mov     r0,#layer1
                mov     r1,#10
                call    clear_data
                clr     show_dir
                clr     blink_dir
                mov     scroll_ind,#0
                sjmp    sd_done

sd_try_1:       clr     porucha
                mov     r0,#pol_pretazenie
                call    get_pol_bit
                jz      sd_try_2
                jb      pretazenie,sd_done
                setb    pretazenie
                mov     r0,#layer1
                mov     r1,#10
                call    clear_data
                clr     show_dir
                clr     blink_dir
                mov     scroll_ind,#0
                call    show_outputs
                sjmp    sd_done

sd_try_2:       clr     pretazenie
                call    do_layer2
                mov     r0,#pol_gong
                call    get_pol_bit
                jz      sd_try_3
                mov     gong,#1
                call    tmr_int_f
                db      t_gong,0,0,3

sd_try_3:       mov     a,char_lo
                call    find_char
                mov     r0,#layer1+5
                mov     r1,#5
                call    copy_movc
                mov     a,char_hi
                call    find_char
                mov     r0,#layer1
                mov     r1,#5
                call    copy_movc
sd_done:        setb    ea
                ret

show_outputs:   jnb     got_serial,so_ret
                mov     a,bcd_out
                setb    c
                rlc     a
                setb    c
                rlc     a
                mov     c,gong_out
                mov     acc.6,c
                mov     c,pretazenie
                mov     acc.7,c
                mov     p3,a
so_ret:         ret
                
process_bcd:    mov     a,inputs
                cpl     a
                rr      a
                rr      a
                anl     a,#00111111b
                xch     a,bcd_inputs
                xrl     a,bcd_inputs
                jz      pb_ret
                mov     a,#0ffh
pb_ret:         ret

show_bcd:       clr     ea
                mov     a,bcd_inputs
                mov     c,acc.4
                mov     going_dn_n,c
                mov     c,acc.5
                mov     going_up_n,c
                add     a,jumpers
                anl     a,#00001111b
                rl      a
                add     a,#low(number_table)
                mov     dpl,a
                clr     a
                addc    a,#high(number_table)
                mov     dph,a
                clr     a
                movc    a,@a+dptr
                mov     char_hi,a
                mov     a,#1
                movc    a,@a+dptr
                mov     char_lo,a

                call    do_layer2
                mov     a,char_lo
                call    find_char
                mov     r0,#layer1+5
                mov     r1,#5
                call    copy_movc
                mov     a,char_hi
                call    find_char
                mov     r0,#layer1
                mov     r1,#5
                call    copy_movc
                setb    ea
                ret

gong_state:     mov     a,gong
                jz      gs_ret
                cjne    a,#1,gs_skip1
                mov     a,#t_gong
                call    tmr_zro
                jnc     gs_ret
                setb    gong_out
                call    show_outputs
                mov     gong,#2
                call    tmr_int_f
                db      t_gong,0,3,0
                ret
gs_skip1:       mov     a,#t_gong
                call    tmr_zro
                jnc     gs_ret
                clr     gong_out
                call    show_outputs
                mov     gong,#0
gs_ret:         ret

st_again:       mov     scroll_ind,#0
scroll_text:    mov     a,scroll_ind
                mov     b,#6
                div     ab
                movc    a,@a+dptr
                jz      st_again
                call    find_char
                mov     a,b
                cjne    a,#5,st_text
                clr     a
                sjmp    st_space
st_text:        movc    a,@a+dptr
st_space:       clr     ea
                call    scroll_left
                setb    ea
                inc     scroll_ind
                ret

scroll_error:   mov     a,#t_scroll
                call    tmr_zro
                jnc     se_ret
                call    tmr_int_f
                db      t_scroll,0,0,3
                jnb     pretazenie,se_skip1
                mov     dptr,#txt_pretazenie
se_skip1:       jnb     porucha,se_skip2
                mov     dptr,#txt_porucha
se_skip2:       jmp     scroll_text
se_ret:         ret

scroll_direction:
                mov     a,#t_scroll
                call    tmr_zro
                jnc     sdi_ret
                call    tmr_int_f
                db      t_scroll,0,0,6
                jb      going_up_n,sdi_up1
                jnb     going_dn_n,sdi_ret
                clr     ea
                djnz    shift_cnt,sdi_skip1
                mov     shift_cnt,#8
                mov     dptr,#arrow_dn_table
                mov     r0,#shift_in
                mov     r1,#5
                call    copy_movc
sdi_skip1:      call    scroll_down
                setb    ea
                ret
sdi_up1:        jb      going_dn_n,sdi_ret
                clr     ea
                djnz    shift_cnt,sdi_skip2
                mov     shift_cnt,#8
                mov     dptr,#arrow_up_table
                mov     r0,#shift_in
                mov     r1,#5
                call    copy_movc
sdi_skip2:      call    scroll_up
                setb    ea
sdi_ret:        ret

blink_direction:
                jnb     blink_dir,bd_ret
                mov     a,#t_blink
                call    tmr_zro
                jnc     bd_ret
                call    tmr_int_f
                db      t_blink,0,2,0
                cpl     show_dir
bd_ret:         ret

initial_thread: mov     p0,#11100000b
                mov     p3,#0ffh
                clr     going_up_n
                clr     going_dn_n
                clr     clock_old
                clr     pretazenie
                clr     porucha
                clr     show_dir
                clr     blink_dir
                clr     gong_out
                clr     got_serial
                clr     a
                mov     data_cnt,a
                mov     clock_cnt,a
                mov     pol_index,a
                mov     gong,a
                mov     shift_cnt,a
                mov     bcd_inputs,#0aah
                call    init_outputs

input_main_lp:  call    rst_wd
                call    read_inputs
                call    detect_clock
                jz      iml_skip2
                call    process_data
                jz      iml_skip2
                setb    got_serial
                call    show_data
iml_skip2:      mov     c,pretazenie
                orl     c,porucha
                jnc     iml_skip3
                call    scroll_error
                sjmp    iml_skip4
iml_skip3:      call    scroll_direction
                call    blink_direction
iml_skip4:      call    gong_state
                jb      got_serial,iml_skip5
                call    process_bcd
                jz      iml_skip5
                call    show_bcd
iml_skip5:      jmp     input_main_lp
