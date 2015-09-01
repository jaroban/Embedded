timer_size          equ     3

                    xseg
; three-byte timers
timer_table:

t_check_hv_tr:      ds      timer_size
t_check_nizka:      ds      timer_size
t_smer_blink:       ds      timer_size
t_polohovka:        ds      timer_size
t_kruzkovy:         ds      timer_size
t_check_gong:       ds      timer_size
t_ventilator:       ds      timer_size
t_aus:              ds      timer_size
t_poschodie:        ds      timer_size
t_reset_me:         ds      timer_size
t_check_gong2:      ds      timer_size
t_bepol:            ds      timer_size
t_refresh:          ds      timer_size
t_termistor:        ds      timer_size
t_vaz_80:           ds      timer_size
t_nahodne:          ds      timer_size
t_tlac_otv:         ds      timer_size
t_group:            ds      timer_size
t_location:         ds      timer_size
t_boss:             ds      timer_size
t_a4_a5_delay:      ds      timer_size
t_nd:               ds      timer_size
t_doba_nudz:        ds      timer_size
t_delay_a1:         ds      timer_size
t_delay_a5:         ds      timer_size
t_od_resetu:        ds      timer_size
t_kontrola_brzdy:   ds      timer_size
t_kontrola_npk:     ds      timer_size
t_prednost:         ds      timer_size
t_svetlo:           ds      timer_size
t_parkovanie:       ds      timer_size
t_delay_a4:         ds      timer_size
t_a3_error:         ds      timer_size
t_gonganie:         ds      timer_size
t_keyboard:         ds      timer_size
t_lcd:              ds      timer_size
t_time:             ds      timer_size
t_lcd_on:           ds      timer_size
t_obnovenie_a4:     ds      timer_size
t_z_delay_a4:       ds      timer_size
t_z_menic:          ds      timer_size
t_blikanie:         ds      timer_size
t_zatvaranie_dveri: ds      timer_size
t_start_vytahu:     ds      timer_size
t_flash:            ds      timer_size
t_dorovnavanie:     ds      timer_size
t_nulovanie:        ds      timer_size
t_stykace:          ds      timer_size
t_pohnutia:         ds      timer_size
t_cas_jazdy:        ds      timer_size
t_menic:            ds      timer_size
t_nudzova:          ds      timer_size
t_predotvaranie:    ds      timer_size
t_revizna:          ds      timer_size
t_servisna:         ds      timer_size
t_realtime:         ds      timer_size
t_command:          ds      timer_size
t_door_a_timeout:   ds      timer_size
t_door_b_timeout:   ds      timer_size
t_door_a_delay:     ds      timer_size
t_door_b_delay:     ds      timer_size
t_zotrvacnost_a:    ds      timer_size
t_zotrvacnost_b:    ds      timer_size
t_zrovnavacia:      ds      timer_size
t_moving:           ds      timer_size
t_can_init:         ds      timer_size
t_not_moving:       ds      timer_size
t_locations:        ds      timer_size * 8

no_of_timers        equ     (($ - timer_table) / timer_size)

; one-byte timers
timer_table2:

t_double_click:     ds      no_of_floors * 2        ; 0-31: dbl_dn, 32-63: dbl_up

no_of_timers2       equ     ($ - timer_table2)