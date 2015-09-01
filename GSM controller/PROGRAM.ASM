; version 2.0

$nopaging
$nomod51

$include(at89c55w.asm)
$include(equates.asm)

testing         equ     0
debug           equ     0       ; eventually turn this off

tmr0_period     equ     768*10  ; 768=1ms 2304=3ms 3072=4ms 1200=1/640s
                                ; 2400=1/320s 1152=1.5ms (@ f=9.216 mhz)
tmr_per_sec     equ     100     ; system timer/second ratio
srl_period      equ     30      ; 30=9600
wd_max          equ     255     ; # of timer0 ints before sw wd reset

                using   0
                cseg at reset
                jmp     os_init
                org     exti0
                reti
                org     timer0
                jmp     timer0_int
                org     exti1
                reti
                org     timer1
;                jmp     timer1_int
                org     serp0
                jmp     serial_int
                org     t2ovflw
                reti

$include(memory.asm)
$include(os.asm)
$include(timing.asm)
$include(outputs.asm)
$include(serial.asm)
$include(tier1.asm)
$include(routines.asm)
$include(tier2.asm)
$include(main.asm)

left_of_data_seg        equ     brick_ceiling-brick_floor+1
top_of_code_seg         equ     $
left_of_code_seg        equ     5000h-top_of_code_seg

end
