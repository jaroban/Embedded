; version 1.0

lcd_en                  bit     p1.0
lcd_rw                  bit     p1.1
lcd_rs                  bit     p1.2
snimac_a                bit     p1.4
svetlo                  bit     p1.5
k2                      bit     p1.6
k1                      bit     p1.7
scl_pin                 bit     p3.0
sda_pin                 bit     p3.1
snimac_b                bit     p3.2
wc                      bit     p3.3

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1
lcd_pos:                ds      1
lcd_ind:                ds      1

kb_state:               ds      1
kb_count:               ds      1
buffer_a:               ds      1
buffer_b:               ds      1
osnimace:               ds      1
counted:                ds      2
cmp_ind:                ds      1

edit_ind:               ds      1
prescaler:              ds      1
early_cnt:              ds      1
early_pre:              ds      1

                        dseg at 32
inputs:                 ds      1
snimace:                ds      1
bits:                   ds      1
mjrt_bffr:              ds      8
cmp_table:              ds      16
timer_table:            ds      no_of_timers*4
lcd_table:              ds      lcd_rows+2

                        iseg at 128
lcd_table_old:          ds      lcd_rows+2

brick_floor             equ     $
brick_ceiling           equ     255

k_menu                  bit     acc.0
k_stop                  bit     acc.1
k_start                 bit     acc.2
k_down                  bit     acc.3
k_up                    bit     acc.4

going_up                bit     bits.0
at_least_one            bit     bits.1
cnt_changed             bit     bits.2
cmp_changed             bit     bits.3
zero_sup                bit     bits.4
na_sekundu              bit     bits.5
overflow                bit     bits.6
running                 bit     bits.7

                        cseg
