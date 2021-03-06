; version 1.0

$nopaging

seriova_polohovka       equ     0

$include(equates.asm)
$include(memory.asm)

tmr0_period     equ     24000   ; 768=1ms 2304=3ms 3072=4ms 1200=1/640s
                                ; 2400=1/320s 1152=1.5ms (@ f=9.216 mhz)
tmr_per_sec     equ     32      ; system timer/second ratio
wd_max          equ     32      ; # of timer0 ints before sw wd reset

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

$include(os.asm)
$include(timing.asm)
$include(input.asm)
$include(output.asm)
$include(data.asm)

left_of_data_seg        equ     brick_ceiling-brick_floor+1

top_of_code_seg         equ     $
left_of_code_seg        equ     800h-top_of_code_seg

end
