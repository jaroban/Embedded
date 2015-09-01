; version 4.1

inc_toggle              bit     p1.0
inc_dir                 bit     p1.1
lcd_rs                  bit     p1.2            ; lcd register select
lcd_rw                  bit     p1.3            ; lcd r/w
c_snimac                bit     p1.4
lcd_light               bit     p1.5
termistor_n             bit     p1.6
lcd_en                  bit     p1.7            ; lcd enable
a_snimac_n              bit     p3.2
b_snimac_n              bit     p3.3
sda_pin                 bit     p3.4            ; i2c serial data line 
scl_pin                 bit     p3.5            ; i2c serial clock line

                        dseg at 10h
rd_brd_reg1:            ds      1               ; 0 i must be in sequence
rd_brd_reg2:            ds      1               ; 1 i (gaa_a101_216)
rd_brd_reg3:            ds      1               ; 2 i
rd_brd_reg4:            ds      1               ; 3 i
wr_brd_reg1:            ds      1               ; 0 o must be in sequence
wr_brd_reg2:            ds      1               ; 1 o (trans_write)
wr_brd_reg3:            ds      1               ; 2 o
wr_brd_reg4:            ds      1               ; 3 o

wr_trans_reg:           ds      1               ; 4 o
rd_24v_reg2:            ds      1               ; 7 i
ac_index1:              ds      1
ac_index2:              ds      1
ac_index3:              ds      1
ac_cnt:                 ds      1
ac_maj:                 ds      1
floor_no:               ds      1

ac_rd                   data    24h             ; 5 i
a1                      bit     ac_rd.0
a2                      bit     ac_rd.1
a3                      bit     ac_rd.2
a4                      bit     ac_rd.3
a5                      bit     ac_rd.7

wr_rele_reg1            data    25h             ; 5 o
rele_hore               bit     wr_rele_reg1.0
rele_dole               bit     wr_rele_reg1.1
rele_vysoka_rychlost    bit     wr_rele_reg1.2
rele_4                  bit     wr_rele_reg1.3
rele_otvaranie_dveri_a  bit     wr_rele_reg1.4
rele_zatvaranie_dveri_a bit     wr_rele_reg1.5

wr_rele_reg2            data    26h             ; 6 o
rele_7                  bit     wr_rele_reg2.0
rele_svetlo             bit     wr_rele_reg2.1
rele_9                  bit     wr_rele_reg2.2
rele_10                 bit     wr_rele_reg2.3
rele_11                 bit     wr_rele_reg2.4
rele_12                 bit     wr_rele_reg2.5
if kruzkovy_motor
rele_otvaranie_dveri_b  bit     rele_otvaranie_dveri_a
rele_zatvaranie_dveri_b bit     rele_zatvaranie_dveri_a
rele_kruzkovy_1         bit     wr_rele_reg2.4
rele_kruzkovy_2         bit     wr_rele_reg2.5
else
rele_otvaranie_dveri_b  bit     wr_rele_reg2.4
rele_zatvaranie_dveri_b bit     wr_rele_reg2.5
endif

rd_24v_reg1             data    27h             ; 6 i
nudzova_jazda           bit     rd_24v_reg1.0
nvazenie_80             bit     rd_24v_reg1.0
revizna_jazda           bit     rd_24v_reg1.1
hore24                  bit     rd_24v_reg1.2
dole24                  bit     rd_24v_reg1.3
kontrola_mpd            bit     rd_24v_reg1.4
nvazenie_10             bit     rd_24v_reg1.4
kontrola_stykacov       bit     rd_24v_reg1.5

                        bseg at 64
dont_refresh_time:      dbit    1
zakaz_vonkajsie0:       dbit    1
zakaz_vonkajsie:        dbit    1
zakaz_pohon:            dbit    1
poradie_faz:            dbit    1
ovazenie_10:            dbit    1
ovazenie_80:            dbit    1
ovazenie_110:           dbit    1
liftdir:                dbit    1
oliftdir:               dbit    1
poll_calls:             dbit    1
can0_change1:           dbit    1
can0_change2:           dbit    1
can0_change3:           dbit    1
uz_je_revizna:          dbit    1
uz_je_nudzova:          dbit    1
uz_je_zakapanie:        dbit    1
blokuj_volby:           dbit    1
uz_mame_volbu:          dbit    1
uz_mame_vonkajsiu_volbu: dbit    1
checkuj_pohnutie:       dbit    1   ; thread local
bola_strata_a4:         dbit    1
mozes_dorovnavat:       dbit    1
dorovnava_sa:           dbit    1
chceme_ist_parkovat:    dbit    1
chceme_vypnut_svetlo:   dbit    1
je_posledna_jazda:      dbit    1
je_prednostna_jazda:    dbit    1
je_nezavisla_jazda:     dbit    1
je_ranny_program:       dbit    1
je_obed_program:        dbit    1
je_predotvaranie:       dbit    1
key_pressed:            dbit    1
lcd_is_on:              dbit    1
mux_new_k:              dbit    1
mux_new_d1:             dbit    1
mux_new_d2:             dbit    1
mux_new_h:              dbit    1
mux_all_32:             dbit    1
serial_debug:           dbit    1
can_debug:              dbit    1
inc_otoggle:            dbit    1
inc_running:            dbit    1
je_nahravacia:          dbit    1
brd_change1:            dbit    1
pjf2_opened:            dbit    1
scrolling:              dbit    1
im_da_boss:             dbit    1
nezapinaj_fazy:         dbit    1
su_vobec_dvere_a:       dbit    1
su_vobec_dvere_b:       dbit    1
pretazenie:             dbit    1
zakapanie:              dbit    1

                        dseg at 30h
rd_can_reg5:            ds      1
rd_can_reg6:            ds      1
wr_can_reg5:            ds      1
wr_can_reg6:            ds      1
wr_can_reg7:            ds      1
snimace:                ds      1
dr_state:               ds      1
liftpos:                ds      1
oliftpos:               ds      1
nextfloor:              ds      1
my_liftpos:             ds      1
liftsub:                ds      1
smer:                   ds      1
osmer:                  ds      1
smer_hrd:               ds      1
term_state:             ds      1
kb_state:               ds      1
kb_data:                ds      1
sj_data:                ds      1
liftstate:              ds      1
blink_reg1:             ds      1
blink_reg2:             ds      1
blink_reg3:             ds      1
blink_reg4:             ds      1
blink_old:              ds      1
c_preruseni_sza:        ds      1
mux_state:              ds      1
mux_timer:              ds      1
mux_mask1:              ds      1
mux_mask3:              ds      1
others:                 ds      1
inc_cnt_lo:             ds      1
inc_cnt_hi:             ds      1
check_hv_tr:            ds      1
language:               ds      1
porucha:                ds      1
error_no:               ds      1
supervisor:             ds      1
lcom_data:              ds      1
vent_state:             ds      1
gsm_state:              ds      1
pol_div:                ds      1
cnt_pohnutie:           ds      1
rev_old:                ds      1
je_poziarna_jazda:      ds      1
call_no:                ds      1
nahodne_volby:          ds      1
owr_rele_reg1:          ds      1
owr_rele_reg2:          ds      1
owr_trans_reg:          ds      1
timer0_events:          ds      1
lcom_shift1:            ds      1
lcom_shift2:            ds      1
tlac_otv_state:         ds      1
if gong_kym_a3
gong_stopped_state:     ds      1
endif
if na_jednom_poschodi_dve_volby
mozu_dvere_ab:          ds      1
endif
if auto_vytah
au_free_open:           ds      1
au_free_wall:           ds      1
endif
if jednopovelove_dvere
rele_zat:               ds      1
endif
if spec_ver
krap:                   ds      1
endif
if 0
vaz_80_state:           ds      1
endif

                        iseg at 80h
i2c_xmt_buffer:         ds      3
i2c_rcv_buffer:         ds      1
i2c_time:               ds      7
pj_table:               ds      6
ac_table:               ds      20
snimace_table:          ds      2
mjrt_bffr:              ds      10
call_table:             ds      no_of_floors
wr_kabina:              ds      4    
rd_kabina:              ds      4    
wr_dole:                ds      4
rd_dole:                ds      4
wr_hore:                ds      4
rd_hore:                ds      4
test_data:              ds      5
bola_zapnuta_jazda:     ds      1
bepol_target:           ds      1
bepol_current:          ds      1
bepol_zero:             ds      1
pol_table:              ds      5
lcom_output:            ds      2
banel_output:           ds      2


no_of_threads           equ     20

st_input_size           equ     55
st_output_size          equ     55
st_serial_size          equ     55
st_group_size           equ     85
st_commander_size       equ     65
st_safety_size          equ     55
st_servisna_jazda_size  equ     55
st_can_size             equ     50
st_follower_size        equ     55
st_door_act_size        equ     55
st_door_a_size          equ     50
st_door_b_size          equ     50
st_normalna_size        equ     55
st_dorovnavanie_size    equ     50
st_nudzova_size         equ     50
st_revizna_size         equ     55
st_go_up_down_size      equ     55
st_predotvaranie_size   equ     55

                        xseg at 0f000h
st_input:               ds      st_input_size
st_output:              ds      st_output_size
st_serial:              ds      st_serial_size
st_group:               ds      st_group_size
st_commander:           ds      st_commander_size
st_safety:              ds      st_safety_size
st_servisna_jazda:      ds      st_servisna_jazda_size
st_can:                 ds      st_can_size
st_follower:            ds      st_follower_size
st_door_act:            ds      st_door_act_size
st_door_a:              ds      st_door_a_size
st_door_b:              ds      st_door_b_size
st_normalna:            ds      st_normalna_size
st_dorovnavanie:        ds      st_dorovnavanie_size
st_nudzova:             ds      st_nudzova_size
st_revizna:             ds      st_revizna_size
st_go_up_down:          ds      st_go_up_down_size
st_predotvaranie:       ds      st_predotvaranie_size
top_of_stack_seg        equ     $

enum_table_size         equ     p_last_param+1
num_table_size          equ     no_of_nums
time_table_size         equ     3*no_of_times
floor_table_size        equ     no_of_floors
vypis_table_size        equ     no_of_floors+1
hodiny_table_size       equ     4*no_of_hodiny
increment_table_size    equ     2*no_of_floors
gsm_table_size          equ     16*no_of_gsms

enum_table:             ds      enum_table_size
num_table:              ds      num_table_size
time_table:             ds      time_table_size
floor_table:            ds      floor_table_size
vypis_table:            ds      vypis_table_size
hodiny_table:           ds      hodiny_table_size
increment_table:        ds      increment_table_size
gsm_table:              ds      gsm_table_size
lcd_table:              ds      34*2
mjrt_spolu:             ds      35   
mjrt_kabina:            ds      20   
mjrt_dole:              ds      20
mjrt_hore:              ds      20
call_save:              ds      no_of_floors
hodiny_values:          ds      no_of_hodiny
error_table:            ds      no_of_errors
reset_me:               ds      1
prednostna_dest:        ds      1
poziarna_dest:          ds      1
rd_kabina_o:            ds      4
check_gong2:            ds      1
kb_expected:            ds      1
kb_die_soon:            ds      1
pol_table_old:          ds      5
lcom_output_old:        ds      2
banel_output_old:       ds      2
jazda_skoncila:         ds      1

                        cseg
