spec_ver                        equ     0
kruzkovy_motor                  equ     0
debug_vstupov                   equ     0
auto_vytah                      equ     0
auto_vytah_special              equ     0
default_language                equ     0       ; 0=sk 1=cz 2=polski 3=eng 4=rus
double_speed                    equ     1       ; 2x 9.216 mhz
polska_lista                    equ     0       ; a5 v jazde maze volby
a3_reverzuje                    equ     1       ; (rucne vonkajsie) 0 = len zastavi    1 = reverzuje
vynechat_bcd_kod                equ     0       ; 1 = vynechat,   0 = nevynechat
ktory_bcd_kod                   equ     1101b   ;
revizna_resetuje                equ     1       ; 0 = experimentalne / neotestovane    1 = ok
pocet_zaseknuti                 equ     10      ; kolko krat zostane zalepena volba kym zomrie
jednopovelove_dvere             equ     0       ; zatvaranie = posledne z (zatvaranie, otvaranie)1-jednopovelove
vonkajsia_volba_opravi_dvere        equ     0   ; 0 = normalne
cas_na_rele_baterka                 equ     3   ; cas medzi rele fazy a rele baterka pri nudzovom dojazde
maximalny_pocet_kabinovych_volieb   equ     0   ; 0 = vypnute
magnety_pri_hornom_dolnom           equ     1   ; 0 = chybaju magnety,   1 = su magnety (normalne)
su_dvere_c                      equ     0       ; dvere c na 3 poschodi
na_jednom_poschodi_dve_volby    equ     1       ; +2 poschodia -> volby pre dvere a / dvere b na nejakom poschodi
na_ktorom_poschodi_dve_volby    equ     0       ; na ktorom poschodi su tieto extra volby (0 = najnizsie)
prednostne_zdochnutie           equ     0       ; prednostne privolanie zdochne vytah
dr_state_debug                  equ     0       ; vypis pre jara: 1 = debug enter menu 1, 0 = vypnute
bratislava_dolny                equ     0       ; bratislava dolny snimac
eurovea                         equ     0       ; nj, rj, a2 zapinaju rele 10
zapisuj_pretazenie              equ     0       ; zapisuje pretazenie ako chybu
bez_volby_stop                  equ     0       ; trvalo musi drzat volbu aby isiel
dojazd_do_najblizsej            equ     1       ; 0 = dole, 1 = hore (iba ak dojazd do konkretnej stanice = 0)
ziadne_kabinove_bez_10          equ     0       ; 0 = normalne, 1 = ziadne kabinove bez 10%
gong_kym_a3                     equ     0       ; 0 = normalne, 1 = gonga po zastaveni a pri otvorenych dverach (a3)
snimac_c_nevyhodnoti            equ     0       ; 0 = normalne, 1 = chyba snimac c sa vobec nevyhodnocuje
snimac_c_reset_po_10_min        equ     0       ; 0 = normalne, 1 = 10 minut po chybe snimac c sa doska resetne
pocet_otoceni                   equ     0       ; 0 = pocita pocet jazd, 1 = pocita pocet otoceni smeru vytahu
jedna_volba_v_nezavislej        equ     1       ; 0 = neobmedzene volby, 1 = len jedna volba v nezavislej
obnovuje_volby                  equ     0       ; 0 = neobnovuje volby, 1 = obnovuje volby
dva_kontakty_sachtove_dvere     equ     1       ; 0 = jeden kontakt, 1 = dva kontakty
zrovnavacia_hore                equ     0       ; 0 = zrovnavacia dole, 1 = zrovnavacia hore
hydraulika_a3                   equ     0       ; 0 = normalna kontrola brzdy, 1 = nova hydraulika, RDY/RUN
v_poziarnej_bx_do_nuly          equ     0       ; 0 = ziadne, 1 = b1 ... 8 = b8
cas_medzi_zatvaranim_a_otvaranim equ    30      ; 0 = nie je, viac ako nula: stotiny sekundy, max 255 = 2,55 s
a4_ovlada_svetlo                equ     1       ; 0 = len a3 ovlada svetlo, 1 = a3 aj a4 (pri automatickych dverach)
vyhodnocovat_chybu_sza          equ     1       ; 0 = sza moze trvat donekonecna, 1 = vyhodnocovat chybu sza
maz_volby_neskor                equ     0       ; 0 = volby maze po otvoreni, 1 = volby maze pred zatvaranim
maz_obidve_vonkajsie            equ     0       ; 0 = maze vonkajsiu volbu len v smere, 1 = maze obidve vonkajsie
nudzovy_dojazd_rele_10          equ     1       ; 0 = normalne, 1 = k10 sa zapne pred nudzovym dojazdom
reset_ak_volby_a_nejazdi        equ     1       ; 0 = normalne, 1 = reset ak ma kabinove, nie je 80%, a nejazdi 3 minuty

; normalna smerove hviezda = cez parameter
normalna_hviezda_jazda          equ     30      ; stotiny sekundy v normalnej medzi hviezda trojuholnik a stop v normalnej jazde

revizna_smerove_hviedza         equ     100      ; stotiny sekundy v reviznej stop od vypnutia smerovych do vypnutia hviedza/trojuholnik
revizna_hviedza_jazda           equ     100      ; stotiny sekundy v reviznej stop od vypnutia hviezda/trojuholnik do vypnutia jazda

nudzova_smerove_hviedza         equ     100      ; stotiny sekundy v nudzovej stop od vypnutia smerovych do vypnutia hviedza/trojuholnik
nudzova_hviedza_jazda           equ     100      ; stotiny sekundy v nudzovej stop od vypnutia hviezda/trojuholnik do vypnutia jazda

servisna_smerove_hviedza        equ     100      ; stotiny sekundy v servisnej stop od vypnutia smerovych do vypnutia hviedza/trojuholnik
servisna_hviedza_jazda          equ     100      ; stotiny sekundy v servisnej stop od vypnutia hviezda/trojuholnik do vypnutia jazda
