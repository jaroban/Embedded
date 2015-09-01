; version 2.0

;polarity_pin
jumper_a                bit     p0.7
jumper_b                bit     p0.6
jumper_c                bit     p0.5

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1
reload_lo:              ds      1
reload_hi:              ds      1

col_ind:                ds      1
mask:                   ds      1
char_hi:                ds      1
char_lo:                ds      1
gong:                   ds      1
scroll_ind:             ds      1
bcd_inputs:             ds      1
data_cnt:               ds      1

clock_cnt:              ds      1
pol_index:              ds      1
shift_cnt:              ds      1
bcd_out:                ds      1
jumpers:                ds      1

                        dseg at 32
bits1:                  ds      1
bits2:                  ds      1
inputs:                 ds      1

layer1:                 ds      10      
layer2:                 ds      5
shift_in:               ds      5

pol_table:              ds      5
pol_table_old:          ds      5

timer_table:            ds      no_of_timers*4

brick_floor             equ     $
brick_ceiling           equ     255

going_up_n              bit     bits1.0
going_dn_n              bit     bits1.1
clock_old               bit     bits1.2
pretazenie              bit     bits1.3
porucha                 bit     bits1.4
show_dir                bit     bits1.5
blink_dir               bit     bits1.6
gong_out                bit     bits1.7

got_serial              bit     bits2.0

data_pin                bit     inputs.0
clock_pin               bit     inputs.1

                        cseg
