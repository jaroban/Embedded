; version 2.0

rele1                   bit     p0.4
rele2                   bit     p0.3
rele3                   bit     p0.2
rele4                   bit     p0.1
rele5                   bit     p0.0

out1                    bit     p0.5
;out2                    bit     p0.6
button1                 bit     p1.0    ; call buttons
;button2                 bit     p1.1
in2                     bit     p1.2
in3                     bit     p1.3
in4                     bit     p1.4
in5                     bit     p1.5
in6                     bit     p1.6
in7                     bit     p1.7
pwr_key                 bit     p2.1
;vdd_ext                 bit     p2.0
low_voltage             bit     p3.7
srl_gsm                 bit     p3.2
srl_out1                bit     p3.3
;srl_out2                bit     p3.4
lift_on1                bit     p3.5
;lift_on2                bit     p3.6

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1

day:                    ds      1
hour:                   ds      1
ohour:                  ds      1
state1:                 ds      1
;state2:                 ds      1
reply_cnt1:             ds      1
;reply_cnt2:             ds      1
gsm_cnt:                ds      1
wait_cnt:               ds      1
signal:                 ds      1
tmp0:                   ds      1
tmp1:                   ds      1
tmp2:                   ds      1
tmp3:                   ds      1
name_str1:              ds      16
bits1:                  ds      1
bits2:                  ds      1
;name_str2:              ds      16
number_str:             ds      16
status_str:             ds      32
fifo0_wr:               ds      1
fifo0_rd:               ds      1
fifo1_valid:            ds      1
mask:                   ds      1
low_v_cnt:              ds      1
dseg_end                equ     $

                        iseg at dseg_end
timer_table:            ds      no_of_timers*4

fifo0_size              equ     50
fifo0:                  ds      fifo0_size
fifo0_end               equ     $

fifo1_size              equ     16
fifo1:                  ds      fifo1_size

brick_floor             equ     $
brick_ceiling           equ     255

get_signal              bit     bits1.0
send_plus               bit     bits1.1
board_dead1             bit     bits1.2
board_dead2             bit     bits1.3
send_reset              bit     bits1.4
send_status             bit     bits1.5
low_voltage_sent        bit     bits1.6
direction               bit     bits1.7

srl_sent_data           bit     bits2.0
send_credit             bit     bits2.1
;lift                    bit     bits2.2
blink                   bit     bits2.3

                        cseg
