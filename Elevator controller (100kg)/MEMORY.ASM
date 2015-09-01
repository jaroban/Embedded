; version 1.0

h_termistor             bit     p1.0
h_snimac                bit     p0.2

led1                    bit     p1.1
led2                    bit     p2.2
led3                    bit     p2.1
led4                    bit     p2.0

rele_hore               bit     p2.7
rele_dole               bit     p2.6
rele_jazda              bit     p2.5
rele_4                  bit     p2.4
rele_5                  bit     p2.3

                        dseg at 8
wd_cnt:                 ds      1
timer_no:               ds      1
brick_top:              ds      1
brick_next:             ds      1
thread_id:              ds      1
to_kill:                ds      1
ac_index1:              ds      1
ac_index2:              ds      1
ac_index3:              ds      1
ac_cnt:                 ds      1
ac_maj:                 ds      1
ac_table:               ds      20
ac_rd:                  ds      1
inputs:                 ds      1
snimace:                ds      1
bits1:                  ds      1
bits2:                  ds      1
error:                  ds      1
mjrt_bffr:              ds      8
liftpos:                ds      1
nextfloor:              ds      1
oinputs:                ds      1
h_snimace:              ds      1
o_snimace:              ds      1
timer_table:            ds      no_of_timers*4

brick_floor             equ     $
brick_ceiling           equ     127

a1                      bit     ac_rd.2
a2                      bit     ac_rd.3
l1                      bit     ac_rd.4
l2                      bit     ac_rd.5
l3                      bit     ac_rd.6

horny                   bit     inputs.0
dolny                   bit     inputs.1
termistor               bit     inputs.2
stykace                 bit     inputs.3
v1                      bit     inputs.4
v2                      bit     inputs.5
v3                      bit     inputs.6
v4                      bit     inputs.7
zdochnutie              bit     inputs.7

short                   bit     bits1.0
liftdir                 bit     bits1.1
first_time              bit     bits1.2
zrovnavacia             bit     bits1.3
svetlo                  bit     bits1.4
moving                  bit     bits1.5
snimac                  bit     bits1.6
kontrolka               bit     bits1.7

poradie_faz             bit     bits2.0

error_fazy              bit     error.0
error_stykace           bit     error.1
error_doba_jazdy        bit     error.2
error_termistor         bit     error.3

                        cseg
