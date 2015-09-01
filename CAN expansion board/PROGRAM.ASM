; version 4.x

$nopaging
$nomod51

double_speed            equ     1       ; 2x 9.216 mhz

$include(.\system\ds80c390.asm)
$include(.\system\equates.asm)

tmr0_period     equ     7680    ; 768=1ms 2304=3ms 3072=4ms 1200=1/640s
                                ; 2400=1/320s 1152=1.5ms (@ f=9.216 mhz)
tmr_per_sec     equ     100
os_wd1          equ     10      ; timer0 events per thread run
os_wd2          equ     100     ; timer0 events before sw wd rst; 0=disabled
no_of_threads   equ     20
no_of_timers    equ     25      ; max 50
no_of_data      equ     255

                using   0
                cseg at reset
                ljmp    starting_point
                org     exti0
                reti
                org     timer0
                ljmp    timer0_int
if 0
                org     exti1
                reti
                org     timer1
                reti
                org     serp0
                reti
                org     t2ovflw
                reti
                org     serp1
                reti
                org     extint2
                reti
                org     extint3
                reti
                org     extint4
                reti
                org     extint5
                reti
                org     wdint
                reti
endif

$include(.\system\memory.asm)
$include(.\system\os.asm)
$include(.\system\timing.asm)
$include(.\system\messages.asm)
$include(.\system\routines.asm)

$include(.\can\routines.asm)
$include(.\can\can0_app.asm)

$include(.\main\input.asm)
$include(.\main\routines.asm)
$include(.\main\output.asm)

                        bseg
top_of_bit_seg          equ     $
left_of_bit_seg         equ     80h-top_of_bit_seg
                        dseg
top_of_data_seg         equ     $
left_of_data_seg        equ     80h-top_of_data_seg
                        iseg
top_of_indirect_seg     equ     $
left_of_indirect_seg    equ     100h-top_of_indirect_seg
                        xseg
top_of_external_seg     equ     $
left_of_external_seg    equ     -top_of_external_seg
                        cseg
top_of_code_seg         equ     $
left_of_code_seg        equ     8000h-top_of_code_seg

end
