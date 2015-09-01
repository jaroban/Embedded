; version 2.0

lf                      equ     10              ; line feed
cr                      equ     13              ; carriage return
esc                     equ     27              ; escape
ctrl_z                  equ     26              ; control-z

no_of_timers            equ     10

t_switch                equ     0
t_wait                  equ     1
t_cool                  equ     2
t_blink                 equ     3
t_speak                 equ     4
t_error1                equ     5
t_error2                equ     6
t_no_call               equ     7
t_debug                 equ     8
t_low_v                 equ     9

mask_gsm                equ     11111011b
mask_out1               equ     11110111b
;mask_out2               equ     11101111b

st_disabled             equ     0
st_ok                   equ     1
st_dead                 equ     2
st_dialling             equ     3
