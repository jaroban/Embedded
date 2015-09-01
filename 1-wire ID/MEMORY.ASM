; version 1.0

data_bit                bit     p3.0    ; 1 wire input
rout                    bit     p1.2    ; relay output
scl_pin                 bit     p1.0    ; i2c clock
sda_pin                 bit     p1.1    ; i2c data
gled                    bit     p1.5    ; green led
yled                    bit     p1.6    ; yellow led
rled                    bit     p1.7    ; red led
wc                      bit     p3.7    ; write control
delete                  bit     p3.1    ; delete memory
on_off                  bit     p3.5    ; on/off mode

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1

i2c_cnt:                ds      1
i2c_buffer:             ds      2
crc:                    ds      1
slv_adr:                ds      1
addr_lo:                ds      1
addr_hi:                ds      1
buffer_1w:              ds      8
buffer_i2c:             ds      8
bits1:                  ds      1
bits2:                  ds      1
master:                 ds      8
last_key:               ds      8
timer_table:            ds      no_of_timers*4

brick_floor             equ     $
brick_ceiling           equ     127

nomem                   bit     bits1.0
short                   bit     bits1.1
state                   bit     bits1.2
last_key_ok             bit     bits1.3
check_rele              bit     bits1.4
green_blink             bit     bits1.5
yellow_blink            bit     bits1.6
red_blink               bit     bits1.7

i2c_error               bit     bits2.0

                        cseg
