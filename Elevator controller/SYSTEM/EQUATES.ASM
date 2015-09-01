; version 4.1

n                       equ     13
ctrl_z                  equ     26
language_separator      equ     '|'
no_of_languages         equ     5
if auto_vytah
  no_of_enums           equ     99+9
else
  no_of_enums           equ     99
endif
no_of_nums              equ     18
no_of_times             equ     13
no_of_floors            equ     32
no_of_hodiny            equ     4
no_of_gsms              equ     7

id_input                equ     'i'
id_can                  equ     'a'
id_serial               equ     's'
id_follower             equ     'f'
id_commander            equ     'c'
id_output               equ     'o'
id_group                equ     'g'
id_safety               equ     'Y'
id_revizna              equ     'R'
id_nudzova              equ     'N'
id_servisna             equ     'S'
id_zrovnavacia          equ     'Z'
id_normalna             equ     'M'
id_go_up                equ     'U'
id_go_down              equ     'D'
id_stopped              equ     'T'
id_dorovnavanie         equ     'E'
id_predotvaranie        equ     'P'
id_door_a               equ     'A'
id_door_b               equ     'B'

t_otvorenych_dveri      equ     0
t_cod_po_reverze        equ     1
t_otvarania_dveri       equ     2
t_zatvarania_dveri      equ     3
t_odchod_do_parku       equ     4
t_doba_jazdy            equ     5
t_oneskorenie_ab        equ     6
t_vypni_svetlo          equ     7
t_zapni_hv_tr           equ     8
t_doba_prednosti        equ     9
t_vypni_jazda           equ     10
t_cas_kruz_1            equ     11
t_cas_kruz_2            equ     12

e_strata_a1             equ     1
e_strata_a2             equ     2
e_strata_a3             equ     3
e_strata_a4             equ     4
e_wd_reset              equ     5
e_doba_jazdy            equ     6
e_chyba_start           equ     7
e_pocet_zatvarani       equ     8
e_svetelna_zavora       equ     9
e_vela_reverzov         equ     10
e_sachtove_dvere        equ     11
e_hs_ds                 equ     12
e_hs                    equ     13
e_ds                    equ     14
e_porucha_stykacov      equ     15
e_termistor             equ     16
e_porucha_mpd           equ     17
e_doba_dorovnavania     equ     18
e_snimac_c              equ     19
e_poradie_faz           equ     20
e_pocet_jazd            equ     21
e_porucha_modulu_c      equ     22
e_por_reset             equ     23
e_nudzovy_dojazd        equ     24
e_os_reset              equ     25
e_osc_reset             equ     26
e_strata_a5             equ     27
e_blokovanie_dveri      equ     28
e_strata_24v            equ     29
e_pretazenie            equ     30
e_porucha_menica        equ     31
e_revizna_jazda         equ     32
e_bezpecnost_menica     equ     33
e_kontrola_menica       equ     34
if hydraulika_a3
e_porucha_rdy           equ     35
e_porucha_run           equ     36
else
e_kontrola_brzdy1       equ     35
e_kontrola_brzdy2       equ     36
endif
e_modul_npk             equ     37
no_of_errors            equ     37

e_prek_doba_otv         equ     1
e_prek_doba_zat         equ     2

d_nie_su                equ     0
d_otvaraju_sa           equ     1
d_cakaju                equ     2
d_zatvaraju_sa          equ     3
d_svetelna_zavora       equ     4

s_zrov_jazda            equ     0
s_jazda_hore            equ     1
s_jazda_dole            equ     2
s_prednost              equ     3
s_pretazenie            equ     4
s_dvere                 equ     5

dr_nic                  equ     0
dr_prednost             equ     1
dr_niekde               equ     2
dr_dole                 equ     3
dr_hore                 equ     4
dr_prednost_dole        equ     5
dr_prednost_hore        equ     6
dr_parkujeme            equ     7
dr_do_poziarnej         equ     8
dr_do_najnizsej         equ     9
dr_r_nic                equ     10
dr_r_dole               equ     11
dr_r_hore               equ     12
dr_r_spat               equ     13
dr_o_nic                equ     14
dr_o_dole               equ     15
dr_o_spat               equ     16
dr_j_prednost           equ     17
dr_j_niekde             equ     18
dr_pp_chod              equ     19
dr_pp_cakaj             equ     20
dr_pp_vykonaj           equ     21

na_nic                  equ     0
na_prednost             equ     1
na_jazda                equ     2

none                    equ     0
hore                    equ     1
dole                    equ     2
both                    equ     3
alt_blink               equ     4
hore_blink              equ     5
dole_blink              equ     6
both_blink              equ     7

p_riadenie              equ     0
p_nahrada               equ     1
p_skupina_typ           equ     2
p_skupina_spojenie      equ     3
p_dvere_a               equ     4
p_pohon                 equ     5
p_revizna_rychlost1     equ     6
p_poradie_faz           equ     7
p_bezpecny_priestor     equ     8
p_cas_pohnutia          equ     9
p_inkrementalny         equ     10
p_termistor             equ     11
p_dorovnavanie          equ     12
p_predotvaranie         equ     13
p_statie_s_o_d_a        equ     14
p_modul_c               equ     15
p_nudzovy_dojazd        equ     16
p_inverzia_a_b          equ     17
p_inverzia_h_d          equ     18
p_c_vedla_a_b           equ     19
p_blikanie              equ     20
p_je_nudzovy_dojazd     equ     21
p_jazyk                 equ     22      ; -1
p_revizna_rychlost2     equ     23
p_rele_baterka          equ     24
p_volby_kabina          equ     25
p_volby_dole            equ     26
p_volby_hore            equ     27
p_koniec_o_d            equ     28
p_koniec_z_d_a          equ     29
p_koniec_z_d_b          equ     30
p_svetelna_zavora_a     equ     31
p_svetelna_zavora_b     equ     32
p_tlacitko_z_d          equ     33
p_poziarna_jazda        equ     34
p_vazenie_10            equ     35
p_vazenie_80            equ     36
p_vazenie_110           equ     37
p_revizna_vysoka        equ     38
p_ranny_program         equ     39
p_obednajsi_program     equ     40
p_prednostne_p          equ     41
p_nezavisla_jazda       equ     42
p_tlacitko_o_d          equ     43
p_zdielane_vonkajsie    equ     44
p_ohrievanie            equ     45
p_porucha               equ     46
p_a3_maze_volby         equ     47
p_rele_jazda            equ     48
p_rele_hv_tr            equ     49
p_rele_nizka            equ     50
p_rele_stredna          equ     51
;p_gsm_in                equ     52
;p_gsm_out               equ     53
p_vypis                 equ     54
p_vent_in               equ     55
p_typ_bcd               equ     56
p_smerove_sipky         equ     57
p_multiplex             equ     58
p_pretazenie            equ     59
p_inverzia_nudzova      equ     60
p_gong                  equ     61
p_gong_kedy             equ     62
p_seriovy_typ           equ     63
p_seriovy_0             equ     64
p_seriovy_1             equ     65
;p_bcd_0                 equ     66      ; must be in sequence
;p_bcd_1                 equ     67      ; (vypis_poschodie)
;p_bcd_2                 equ     68
;p_bcd_3                 equ     69
p_1zn_0                 equ     70      ; must be in sequence
p_1zn_1                 equ     71      ; (vypis_poschodie)
p_1zn_2                 equ     72
p_1zn_3                 equ     73
p_1zn_4                 equ     74
p_1zn_5                 equ     75
p_1zn_6                 equ     76
p_1zn_7                 equ     77
p_vent_out1             equ     78
p_vent_out2             equ     79
p_bcd_0                 equ     80      ; must be in sequence
p_bcd_1                 equ     81      ; (vypis_poschodie)
p_bcd_2                 equ     82
p_bcd_3                 equ     83
p_bcd_4                 equ     84
p_ozivenie              equ     85
p_copy_in               equ     86
p_copy_out              equ     87
p_kontrola_24v          equ     88
p_grayov_kod            equ     89
if auto_vytah
p_au_in_a               equ     90
p_au_in_b               equ     91
p_au_out_a_go           equ     92
p_au_out_a_stop         equ     93
p_au_out_a_back         equ     94
p_au_out_b_go           equ     95
p_au_out_b_stop         equ     96
p_au_out_b_back         equ     97
p_au_out_free           equ     98
endif
p_dvere_b               equ     99
p_statie_s_o_d_b        equ     100
p_porucha_menica        equ     101
p_reset_menica          equ     102
p_bezpecnost_menica     equ     103
p_typ_menica            equ     104
p_poziarna_jazda2       equ     105
p_prednostne_p2         equ     106
p_prednostne_p3         equ     107
p_kontrola_npk          equ     108
p_kontrola_menica       equ     109
p_ozivenie2             equ     110
if hydraulika_a3
p_hydraulika_rdy        equ     111
p_hydraulika_run        equ     112
else
p_kontrola_brzdy1       equ     111
p_kontrola_brzdy2       equ     112
endif
p_seriovy_typ_rdk       equ     113
p_ozivenie_out          equ     114

p_last_param            equ     114
