; version 2.0

$nopaging
$nomod51

$include(at89c55w.asm)
$include(equates.asm)

tmr0_period     equ     24000   ; 768=1ms 2304=3ms 3072=4ms 1200=1/640s
                                ; 2400=1/320s 1152=1.5ms (@ f=9.216 mhz)
tmr_per_sec     equ     32      ; system timer/second ratio
wd_max          equ     255     ; # of timer0 ints before sw wd reset
flicker         equ     5*40    ; 5*30 ; how many times a second?
tmr2_period     equ     3840    ; 5120 ; frequency/(12*flicker)
;divide_this     equ     1920    ; 3413 ; tmr2_period*100/flicker

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
                reti
                org     serp0
                reti
                org     t2ovflw
                jmp     timer2_int

$include(memory.asm)
$include(os.asm)
$include(timing.asm)
$include(routines.asm)

$include(output.asm)
$include(input.asm)
$include(config.asm)
$include(data.asm)

left_of_data_seg        equ     brick_ceiling-brick_floor+1

top_of_code_seg         equ     $
left_of_code_seg        equ     5000h-top_of_code_seg

end
