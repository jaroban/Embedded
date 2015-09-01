; version 1.0

no_of_timers            equ     3

t_blikanie              equ     0
t_rele                  equ     1
t_delay                 equ     2

redundancy1             equ     7       ; key (and)
redundancy2             equ     16      ; memory (or)
redundancy3             equ     16      ; key (or)
max_no_of_keys          equ     32      ; i2c memory size/key size=256/8=32

tm_switch               equ     5       ; times in seconds
tm_idle                 equ     3
