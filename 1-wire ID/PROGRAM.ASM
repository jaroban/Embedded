; version 1.0

$nopaging
$philips

$include(equates.asm)
$include(memory.asm)

tmr0_period     equ     24000   ; 768=1ms 2304=3ms 3072=4ms 1200=1/640s
                                ; 2400=1/320s 1152=1.5ms (@ f=9.216 mhz)
tmr_per_sec     equ     32      ; system timer/second ratio
wd_max          equ     255     ; # of timer0 ints before sw wd reset

prepinanie      equ     1       ; 0 = prilozenie kluca zopne rele na cas, 1 = prilozenie kluca prepina rele (zapne / vypne)

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

$include(output.asm)
$include(i2c.asm)
$include(1w.asm)
$include(keys.asm)
$include(main.asm)

left_of_data_seg        equ     brick_ceiling-brick_floor+1
left_of_code_seg        equ     800h-$

end
