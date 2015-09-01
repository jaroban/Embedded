; version 4.1

$nopaging
$nomod51
$symbols
$xref

$include(config.asm)
$include(.\system\ds80c390.asm)
$include(.\system\equates.asm)
                                ; @ f=9.216 mhz
tmr0_period     equ     2304 * (double_speed + 1)
                                ; 9216000 * multiplier / (4 * 1000)
                                ; 1 ms
tmr1_period     equ     2281 * (double_speed + 1)
                                ; 9216000 * multiplier / (4 * 1010)
                                ; 1010 baud
tmr_per_sec     equ     100     ; timer0 events per second -> init_timer !
os_wd1          equ     10      ; timer0 events per thread run
os_wd2          equ     250     ; timer0 events before sw wd rst; 0=disabled
srl_period      equ     30      ; 120=2400 30=9600 15=19200 5=57600
no_of_data      equ     255

                using   0
                cseg at reset           ;zaciatok programu
                ljmp    starting_point
                org     exti0
                reti
                org     timer0
                ljmp    timer0_int
                org     exti1
                reti
                org     timer1
                ljmp    timer1_int
                org     serp0
                ljmp    serial_int
if 0
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
$include(.\system\timers.asm)
$include(.\system\timing.asm)
$include(.\system\messages.asm)
$include(.\system\routines.asm)
$include(.\system\serial.asm)
$include(.\system\flash.asm)
$include(.\system\errors.asm)

$include(.\command\data.asm)
$include(.\command\lcd.asm)
$include(.\command\i2c.asm)
$include(.\command\follow.asm)
$include(.\command\command.asm)
$include(.\command\realtime.asm)

$include(.\can\routines.asm)
$include(.\can\can0_app.asm)
$include(.\can\can1_app.asm)
$include(.\can\can.asm)

$include(.\input\routines.asm)
$include(.\input\calls.asm)
$include(.\input\inc.asm)
$include(.\input\mux.asm)
$include(.\input\input.asm)
$include(.\input\moving.asm)

$include(.\output\routines.asm)
$include(.\output\calls.asm)
$include(.\output\output.asm)

$include(.\group\calls.asm)
$include(.\group\routines.asm)
$include(.\group\main.asm)
$include(.\group\simplex.asm)
$include(.\group\simulate.asm)
$include(.\group\group.asm)

$include(.\app\safety.asm)
$include(.\app\revizna.asm)
$include(.\app\nudzova.asm)
$include(.\app\servisna.asm)
$include(.\app\zrovnav.asm)
$include(.\app\driving1.asm)
$include(.\app\driving2.asm)
$include(.\app\driving3.asm)
$include(.\app\moving1.asm)
$include(.\app\moving2.asm)
$include(.\app\moving3.asm)
$include(.\app\moving4.asm)
$include(.\app\door_x.asm)
$include(.\app\door_a.asm)
$include(.\app\door_b.asm)
$include(.\app\dorovnav.asm)
$include(.\app\predotv.asm)
$include(.\app\stopped1.asm)
$include(.\app\stopped2.asm)
$include(.\app\stopped3.asm)
if auto_vytah
  $include(.\app\auto.asm)
endif
$include(.\command\russian.asm)
$include(.\command\text.asm)

                        bseg
top_of_bit_seg          equ     $
left_of_bit_seg         equ     80h-top_of_bit_seg
if top_of_bit_seg > 80h
$error(not enough space in bit segment)
endif
                        dseg
top_of_data_seg         equ     $
left_of_data_seg        equ     80h-top_of_data_seg
if top_of_data_seg > 80h
$error(not enough space in data segment)
endif
                        iseg
top_of_indirect_seg     equ     $
left_of_indirect_seg    equ     100h-top_of_indirect_seg
if top_of_indirect_seg > 100h
$error(not enough space in indirect data segment)
endif

left_of_stack_seg       equ     0f400h-top_of_stack_seg
if top_of_stack_seg > 0f400h
$error(not enough space in stack segment)
endif
                        xseg
top_of_external_seg     equ     $
left_of_external_seg    equ     -top_of_external_seg
if top_of_external_seg < 0f000h
$error(not enough space in external segment)
endif
                        cseg
top_of_code_seg         equ     $
left_of_code_seg        equ     -top_of_code_seg
if top_of_code_seg < 08000h
$error(not enough space in code segment)
endif

end
