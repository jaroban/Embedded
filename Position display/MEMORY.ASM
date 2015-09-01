; version 1.0

old_size                equ     2
new_size                equ     8

bottom_snimac           bit     p3.0
middle_snimac           bit     p3.1
top_snimac              bit     p3.2
pol_clk                 bit     p1.5
pol_data                bit     p1.6
jednotka                bit     p3.7

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1
snimace:                ds      1
osnimace:               ds      1
change:                 ds      1
bb:                     ds      1
mm:                     ds      1
tt:                     ds      1
old_no:                 ds      1
new_no:                 ds      1
liftpos:                ds      1
oliftpos:               ds      1
smer:                   ds      1
osmer:                  ds      1
omm:                    ds      1
pol_index:              ds      1
pol_table:              ds      5
pol_table_old:          ds      5
bits:                   ds      1
divider:                ds      1
mjrt_bffr:              ds      8
old_table:              ds      3*old_size
new_table:              ds      3*new_size
timer_table:            ds      no_of_timers*4

brick_floor             equ     $
brick_ceiling           equ     127

pol_writing             bit     bits.0
pol_clk_hi              bit     bits.1
minus                   bit     bits.2

                        cseg
