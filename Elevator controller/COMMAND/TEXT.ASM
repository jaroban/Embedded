; version 4.1

init_text:      db      '   BANEL  4.3   '
                db      '   2015-01-03   ',0

flash_text1:    db      'Flash type:',0
flash_text2:    db      'Unknown',0
                db      'A29010A',0
                db      'SST39SF010A',0
                
init_text2:     db      'LIFT COMPONENTS '
                db      '     s.r.o.     ',0
                db      '    LIFT BUD    '
                db      'tel.+48608592724',0
                db      'Zaklad Dzwigowy '
                db      'tel.32 233-28-96',0

author_text:    db      '  Autorizovana',n
                db      '      zona|'
                db      '  Autorizovana',n
                db      '      zona|'
                db      ' Menu serwisowe|'
                db      '   Restricted',n
                db      '      area|'
                db      '   Restricted',n
                db      '      area|'
                ;db      '  Autorizovana',n
                ;db      '      zona',0
                db      0

f_z_text1:      db      '     Fazy:|'
                db      '     Faze:|'
                db      '     Fazy:|'
                db      '   AC Phases:|'
                db      ' Fazissorrend:|'
                ;db      '     ',vf,aa,zz,tz,':',0
                db      0

f_z_text2:      db      '  Zle poradie|'
                db      '  Nespravny sled|'
                db      '  Zla kolejnosc|'
                db      '  Wrong order|'
                db      '  Rossz sorrend|'
                ;db      vp,oo,r,ja,dd,oo,kk,' ',ff,aa,zz,' ',nn,ee,tt,0
                db      0

f_z_text3:      db      '    L1 L2 L3',0

status_text:    db      'Zrovn. jazda|'
                db      'Srovn. jizda|'
                db      'Szukam sie|'   ;Wyr. jazda
                db      'Grounding|'
                db      'Kiegyen.jarat|'
                ;db      vv,oo,ss,ss,tt,aa,nn,oo,vv,ii,tt,'.',ee,zz,dd,aa,0
                db      0

                db      'Jazda hore|'
                db      'Jizda nahoru|'
                db      'Jazda gora|'
                db      'Going up|'
                db      'Jarat fel|'
                ;db      ve,zz,dd,aa,' ',vv,vv,ee,r,ch,0
                db      0

                db      'Jazda dole|'
                db      'Jizda dolu|'
                db      'Jazda dol|'
                db      'Going down|'
                db      'Jarat le|'
                ;db      ve,zz,dd,aa,' ',vv,nn,ii,zz,0
                db      0

                db      'Prednost|'
                db      'Prednost|'
                db      'Pierwszenstwo|'
                db      'Waiting|'
                db      'Elsobseg adas|'
                ;db      vp,r,ee,ii,mm,uu,ssc,ee,tt,ss,tt,vv,oo,0
                db      0

                db      'Pretazenie|'
                db      'Pretizeni|'
                db      'Przeciazona|'
                db      'Too heavy|'
                db      'Tulterhelt|'
                ;db      vp,ee,r,ee,gg,r,uu,zz,kk,aa,0
                db      0

if dr_state_debug
dr_state_text:  db      'Nic',0
                db      'Prednost',0
                db      'Niekde',0
                db      'Dole',0
                db      'Hore',0
                db      'Prednost D',0
                db      'Prednost H',0
                db      'Parkujeme',0
                db      'Do hlavnej',0
                db      'Do najnizsej',0
                db      'Ranny nic',0
                db      'Ranny dole',0
                db      'Ranny hore',0
                db      'Ranny spat',0
                db      'Obed nic',0
                db      'Obed dole',0
                db      'Obed spat',0
                db      'Jedn pred',0
                db      'Jedn niekde',0
                db      'PP chod',0
                db      'PP cakaj',0
                db      'PP vykonaj',0
endif

dvere_str_a:    db      0

                db      'Otv.A|'
                db      '<>  A|'
                db      '<>  A|'
                db      'OpenA|'
                db      '<>  A|'
                ;db      vo,tt,kk,'.A',0
                db      0

                db      'Cak.A|'
                db      '< > A|'
                db      '< > A|'
                db      'WaitA|'
                db      '< > A|'
                ;db      vo,zzz,ii,'.A',0
                db      0

                db      'ZatvA|'
                db      '> < A|'
                db      '> < A|'
                db      'ClosA|'
                db      '> < A|'
                ;db      vz,aa,kk,r,'A',0
                db      0

                db      'Sza.A|'
                db      'Sza.A|'
                db      'Fot.A|'
                db      'PhotA|'
                db      'FotoA|'
                ;db      vf,oo,tt,'.A',0
                db      0

dvere_str_b:    db      0

                db      'Otv.B|'
                db      '<>  B|'
                db      '<>  B|'
                db      'OpenB|'
                db      '<>  B|'
                ;db      vo,tt,kk,'.B',0
                db      0

                db      'Cak.B|'
                db      '< > B|'
                db      '< > B|'
                db      'WaitB|'
                db      '< > B|'
                ;db      vo,zzz,ii,'.B',0
                db      0

                db      'ZatvB|'
                db      '> < B|'
                db      '> < B|'
                db      'ClosB|'
                db      '> < B|'
                ;db      vz,aa,kk,r,'B',0
                db      0

                db      'Sza.B|'
                db      'Sza.B|'
                db      'Fot.B|'
                db      'PhotB|'
                db      'FotoB|'
                ;db      vf,oo,tt,'.B',0
                db      0

d_error_str:    db      'DobOtv|'
                db      'DobOtv|'
                db      'Cz.Otw|'
                db      'TimOpn|'
                db      'NyiIdo|'
                ;db      vvv,r,ee,vo,tt,kk,0
                db      0

                db      'DobZat|'
                db      'DobZav|'
                db      'Cz.Zam|'
                db      'TimCls|'
                db      'ZarIdo|'
                ;db      vvv,r,ee,vz,aa,kk,0
                db      0

obed_str:       db      'Obed. program|'
                db      'Obed. program|'
                db      'Przerwa prog.|'
                db      'Evening mode|'
                db      'Deli program|'
                ;db      vvv,ee,ccc,ee,r,nn,ja,ja,' ',pp,r,oo,gg,r,aa,mm,0
                db      0

ran_str:        db      'Ranny program|'
                db      'Ranni program|'
                db      'Poranny prog.|'
                db      'Morning mode|'
                db      'Reggeli prog.|'
                ;db      vu,tt,r,ee,nn,ja,ja,' ',pp,r,oo,gg,r,aa,mm,mm,0
                db      0

poz_str:        db      'Poziarna jaz.|'
                db      'Pozarni jizda|'
                db      'Jazda pozaro.|'
                db      'Fire ride|'
                db      'Tuzvedelmi j.|'
                ;db      vp,oo,zzz,aa,p,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0

nez_str:        db      'Nezavisla jaz|'
                db      'Nezavisla jiz|'
                db      'Niezalezna j.|'
                db      'Independ.ride|'
                db      'Sofor jarat|'
                ;db      vr,uu,ccc,nn,oo,ee,' ',uu,pp,r,aa,vv,ll,'.',0
                db      0

dorov_str:      db      'Dorovnavanie|'
                db      'Dorovnavani|'
                db      'Poziomowanie|'
                db      'Levelling|'
                db      'Korekcio|'
                ;db      vk,oo,r,r,ee,kk,cc,ii,ja,0
                db      0

rev_str:        db      'Revizna jazda|'
                db      'Revizni jizda|'
                db      'Kontrolna jaz|'
                db      'Revision ride|'
                db      'Revizios jar.|'
                ;db      vr,ee,vv,ii,zz,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0

nud_str:        db      'Nudzova jazda|'
                db      'Nouzova jizda|'
                db      'Awaryjna jaz.|'
                db      'Emergen. ride|'
                db      'Veszhelyzet j|'
                ;db      va,vv,aa,r,ii,jj,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0

zc_text:        db      'Strata A1|'
                db      'Ztrata A1|'
                db      'Brak A1|'
                db      'Loss of A1|'
                db      'Fesz.veszt.A1|'
                ;db      vp,oo,tt,ee,r,ja,' A1',0
                db      0

                db      'Strata A2|'
                db      'Ztrata A2|'
                db      'Brak A2|'
                db      'Loss of A2|'
                db      'Fesz.veszt.A2|'
                ;db      vp,oo,tt,ee,r,ja,' A2',0
                db      0

                db      'Strata A3|'
                db      'Ztrata A3|'
                db      'Brak A3|'
                db      'Loss of A3|'
                db      'Fesz.veszt.A3|'
                ;db      vp,oo,tt,ee,r,ja,' A3',0
                db      0

                db      'Strata A4|'
                db      'Ztrata A4|'
                db      'Brak A4|'
                db      'Loss of A4|'
                db      'Fesz.veszt.A4|'
                ;db      vp,oo,tt,ee,r,ja,' A4',0
                db      0

                db      'Watchdog RST',0

                db      'Doba jazdy|'
                db      'Doba jizdy|'
                db      'Czas jazdy|'
                db      'Ride too long|'
                db      'Jarat ido|'
                ;db      vvv,r,ee,mm,ja,' ',ee,zz,dd,tz,0
                db      0

                db      'Chyba start|'
                db      'Chyba start|'
                db      'Czas ruszenia|'
                db      'Start error|'
                db      'Start hiba|'
                ;db      vvv,r,ee,mm,ja,' ',ss,tt,aa,r,tt,0
                db      0

                db      'Prek.PocZat|'
                db      'Prek.PocZav|'
                db      'Prze.LicZam|'
                db      'Much closing|'
                db      'Szam bezarasa|'
                ;db      vp,r,ee,dd,ee,ll,' ',zz,aa,kk,r,tz,vv,aa,nn,ii,0
                db      0

                db      'Svetlena Zav|'
                db      'Svetlena Zav|'
                db      'Fotokomorka|'
                db      'Photod. stuck|'
                db      'Fotobunka|'
                ;db      vf,oo,tt,oo,ee,ll,ee,mm,ee,nn,tt,0
                db      0

                db      '5 x Reverz|'
                db      '5 x Reverz|'
                db      '5 x Rewers|'
                db      'Reversed 5x|'
                db      '5 x Reverz|'
                ;db      '5x ',vvv,oo,zz,vv,r,aa,tt,' ',dd,vv,ee,r,0
                db      0

                db      'Sachtove dv.|'
                db      'Sachetni dv.|'
                db      'Drzwi szybo.|'
                db      'Inside door|'
                db      'Kulso ajto|'
                ;db      vss,aa,ch,tt,oo,vv,tz,ee,' ',dd,vv,ee,r,ii,0
                db      0

                db      'HS+DS',0

                db      'Vypol HS|'
                db      'Vypnul HS|'
                db      'Wyl. HS|'
                db      'Top switch|'
                db      'Kikapcs.felso|'
                ;db      vvv,tz,kk,ll,ju,' HS',0
                db      0

                db      'Vypol DS|'
                db      'Vypnul DS|'
                db      'Wyl. DS|'
                db      'Bottom switch|'
                db      'Kikapcs.also|'
                ;db      vvv,tz,kk,ll,ju,' DS',0
                db      0

                db      'Por. stykac|'
                db      'Chyba stykac|'
                db      'Blad stycznik|'
                db      'Contactor stk|'
                db      'Por. stykac|'
                ;db      vo,tt,kk,aa,zz,' ',kk,oo,nn,tt,aa,kk,tt,0
                db      0

                db      'Termistor|'
                db      'Termistor|'
                db      'Termistor|'
                db      'Thermistor|'
                db      'Termisztor|'
                ;db      vt,ee,r,mm,ii,ss,tt,oo,r,0
                db      0

                db      'Porucha MPD|'
                db      'Porucha MPD|'
                db      'Blad MPD|'
                db      'MPD error|'
                db      'Uzemzavar MPD|'
                ;db      vo,tt,kk,aa,zz,' ',vm,vp,vd,0
                db      0

                db      'Doba dorovn.|'
                db      'Doba dorovn.|'
                db      'Czas poziom.|'
                db      'Level. error|'
                db      'Korekcios ido|'
                ;db      vv,r,ee,mm,ja,' ',kk,oo,r,r,ee,kk,cc,ii,ii,0
                db      0

                db      'Snimac C zly|'
                db      'Chyba snim. C|'
                db      'Czujnik C zly|'
                db      'Sensor C bad|'
                db      'Hibas erzekel|'
                ;db      vo,tt,kk,aa,zz,' ',dd,aa,tt,ccc,ii,kk,' ',vc,0
                db      0

                db      'Poradie faz|'
                db      'Poradi fazy|'
                db      'Kolejnosc faz|'
                db      'Phases order|'
                db      'Fazis|'
                ;db      vp,oo,r,ja,dd,oo,kk,' ',ff,aa,zz,0
                db      0

                db      'Servis|'
                db      'Servis|'
                db      'Serwis|'
                db      'Maintenance|'
                db      'Szerviz|'
                ;db      vk,aa,ll,ii,ccc,ee,ss,tt,vv,oo,' ',ee,zz,dd,0
                db      0

                db      'Modul C Por.|'
                db      'Modul C Por.|'
                db      'Modul C zly.|'
                db      'Module C bad|'
                db      'Uzem. C mod.|'
                ;db      vo,tt,kk,aa,zz,' ',mm,oo,dd,uu,ll,' C',0
                db      0

                db      'Zapnutie|'
                db      'Zapnuti|'
                db      'Wlaczenie|'
                db      'Power on RST|'
                db      'Bekapcsolas|'
                ;db      vvv,kk,ll,ju,ccc,ee,nn,ii,ee,0
                db      0

                db      'Nudz. dojazd|'
                db      'Nouz. dojezd|'
                db      'Awar. dojazd|'
                db      'Battery ride|'
                db      'Bateria menet|'
                ;db      va,vv,aa,r,ii,jj,'.',ch,oo,dd,0
                db      0

                db      'OS RST',0
                db      'Oscil. RST',0

                db      'Strata A5|'
                db      'Ztrata A5|'
                db      'Brak A5|'
                db      'Loss of A5|'
                db      'Fesz.veszt.A4|'
                ;db      vp,oo,tt,ee,r,ja,' A5',0
                db      0

                db      'Blok. dveri|'
                db      'Blok. dveri|'
                db      'Blok. drzwi|'
                db      'Doors blocked|'
                db      'Ajto blokkol.|'
                ;db      'Blok. dveri',0
                db      0

                db      'Strata 24V|'
                db      'Ztrata 24V|'
                db      'Brak 24V|'
                db      'Loss of 24V|'
                db      'Veszteseg 24V|'
                ;db      vp,oo,tt,ee,r,ja,' 24V',0
                db      0

                db      'Pretazenie|'
                db      'Pretizeni|'
                db      'Przeciazenie|'
                db      'Too heavy|'
                db      'Tulterheles|'
                ;db      vvv,ch,oo,dd,' ',pp,ee,r,ee,gg,r,uu,zz,kk,aa,0
                db      0

                db      'Porucha menic',0

                db      'Revizna jazda|'
                db      'Revizni jizda|'
                db      'Kontrolna jaz|'
                db      'Revision ride|'
                db      'Revizios jar.|'
                ;db      vr,ee,vv,ii,zz,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0
                
                db      'Bezp. menica',0
                db      'Ch.kontr.meni',0
if hydraulika_a3
                db      'Porucha RDY',0
                db      'Porucha RUN',0
else
                db      'Kontr.brzdy 1|'
                db      'Kontr.brzdy 1|'
                db      'Hamulec 1|'
                db      'Brake check 1|'
                db      'Brake check 1|'
                db      0
                
                db      'Kontr.brzdy 2|'
                db      'Kontr.brzdy 2|'
                db      'Hamulec 2|'
                db      'Brake check 2|'
                db      'Brake check 2|'
                db      0
endif
                db      'Posobenie NPK|'
                db      'Pusobeni NPK|'
                db      'Blend  NPK|'
                db      'NPK active|'
                db      'Posobenie NPK|'
                db      0

p_v_text:       db      ' Pohon   Volby|'
                db      ' Pohon   Volby|'
                db      ' Naped  Wezwania|'
                db      ' Drive   Calls|'
                db      ' Hajtas Valaszt.|'
                ;db      ' ',vp,r,ii,vv,oo,dd,'  ',vz,aa,pp,r,oo,ss,tz,0
                db      0

n_x_text:       db      'Nahodne|'
                db      'Nahodni|'
                db      'Losowe|'
                db      'Random|'
                db      'Talalomra|'
                ;db      ' ',vp,r,ii,vv,oo,dd,'  ',vz,aa,pp,r,oo,ss,tz,0
                db      0

p_v_bool:       db      'Vyp|Vyp|Wyl|Off|Ki ',0 ;vvv,tz,kk,ll,ju,0
                db      'Zap|Zap|Wl |On |Be ',0 ;vvv,kk,ll,ju,' ',0

p_j_text:       db      '   Pocet jazd|'
                db      '   Pocet jizd|'
                db      'Ilosc jazd windy|'
                db      'Total # of rides|'
                db      '   Menetszam|'
                ;db      ' ',vs,ccc,ee,tt,' ',ee,zz,dd,tz,0
                db      0

lang_text1:     db      '    Language',n
                db      '<-            ->',0

lang_text2:     db      'Slovensky|Cesky|Polski|English|Magyar',0 ;vp,oo,' ',vr,uu,ss,kk,ii,0

level0_text:    db      'Zobraz chyby|'
                db      'Zobraz chyby|'
                db      'Pokaz bledy|'
                db      'Show errors|'
                db      'Uzemzavarokat|'
                ;db      vcc,ii,tt,aa,nn,ii,ee,' ',oo,tt,kk,aa,zz,oo,vv,0
                db      0

                db      'Servisna jazda|'
                db      'Servisni jizda|'
                db      'Jazda serwisowa|'
                db      'Service ride|'
                db      'Szervizjarat|'
                ;db      vk,oo,nn,tt,r,oo,ll,mz,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0

                db      'Test rezim|'
                db      'Test rezim|'
                db      'Menu testowe|'
                db      'Testing menu|'
                db      'Tesztelo uzemmod|'
                ;db      vt,ee,ss,tt,uu,ju,ssc,ii,jj,' ',r,ee,zzz,ii,mm,0
                db      0

                db      'Prikazovy rezim|'
                db      'Prikazovy rezim|'
                db      'Menu polecen|'
                db      'Command menu|'
                db      'Parancs uzemmod|'
                ;db      vs,mm,ee,nn,aa,' ',kk,oo,mm,aa,nn,dd,0
                db      0

                db      'Parametre|'
                db      'Parametry|'
                db      'Parametry|'
                db      'Parameters|'
                db      'Parameterek|'
                ;db      vp,aa,r,aa,mm,ee,tt,ee,r,0
                db      0

                db      'Nahravacia jazda|'
                db      'Nahravaci jizda|'
                db      'Jazda nagrywaj.|'
                db      'Learning ride|'
                db      'Tanito menet|'
                ;db      vp,r,oo,gg,r,aa,mm,ii,r,oo,vv,'.',ee,zz,dd,aa,0
                db      0

n_e_text:       db      'Ziadne chyby|'
                db      'Zadne chyby|'
                db      'Brak bledow|'
                db      'No errors|'
                db      'Nincsenek hibak|'
                ;db      vo,tt,ss,uu,tt,ss,tt,vv,ii,ee,' ',oo,sss,ii,bb,'.',0
                db      0

n_c_text:       db      'Neplatna chyba|'
                db      'Neplatni chyba|'
                db      '------------|'
                db      'Invalid error|'
                db      '------------|'
                ;db      '------------',0
                db      0

s_s_text1:      db      'Smer: |'
                db      'Smer: |'
                db      'Kierunek: |'
                db      'Direct''n: |'
                db      'Irany: |'
                ;db      vn,aa,pp,r,aa,vv,ll,ee,nn,'.:',0
                db      0

s_s_text2:      db      'Hore|Nah.|Gore|Up|Fel',0 ;vv,vv,ee,r,ch,0
                db      'Dole|Dolu|Dol|Down|Le',0 ;vv,nn,ii,zz,0

s_s_text3:      db      'Rychlost:|'
                db      'Rychlost:|'
                db      'Predkosc:|'
                db      'Speed:   |'
                db      'Sebesseg:|'
                ;db      vs,kk,oo,r,oo,ss,tt,mz,':',0
                db      0

s_s_text4:      db      ' Vysoka| Vysoka| Wysoka|  High|  Gyors',0 ;vv,ii,ss,oo,kk,aa,ja,0
                db      'Stredna|Stredni|Srednia|Medium|Kozepes',0 ;vs,r,ee,dd,nn,aa,ja,0
                db      '  Nizka|  Nizka|  Niska|   Low|Alacson',0 ;vn,ii,zz,kk,aa,ja,0
                db      'Revizna|Revizni|Kontrol|Revisn|Revizio',0 ;vr,ee,vv,ii,zz,nn,aa,ja,0

test_text:      db      'Vstupy A1-A21|'
                db      'Vstupy A1-A21|'
                db      'Wejsc A1-A21|'
                db      'Inputs A1-A21|'
                db      'Bemenetek A1-A21|'
                ;db      vv,ch,oo,dd,tz,' A1-A21',0
                db      0

                db      'Vstupy A101-A216|'
                db      'Vstupy A101-A216|'
                db      'Wejsc A101-A216|'
                db      'Inputs A101-A216|'
                db      'Bemene.A101-A216|'
                ;db      vv,ch,oo,dd,tz,' A101-A216',0
                db      0

                db      'Test CAN101-132',0

                db      'Test termistoru|'
                db      'Test termistoru|'
                db      'Test termistora|'
                db      'Thermistor test|'
                db      'Teszt termiszt.|'
                ;db      vt,ee,ss,tt,' ',tt,ee,r,mm,ii,ss,tt,oo,r,0
                db      0

                db      'Test rele|'
                db      'Test rele|'
                db      'Test przekaznik.|'
                db      'Relay test|'
                db      'Teszt relle|'
                ;db      vt,ee,ss,tt,' ',r,ee,ll,ee,0
                db      0

                db      'Vystupy B1-B8|'
                db      'Vystupy B1-B8|'
                db      'Wyjsc B1-B8|'
                db      'Outputs B1-B8|'
                db      'Kimenetek B1-B8|'
                ;db      vv,tz,ch,oo,dd,' B1-B8',0
                db      0

                db      'Vystupy A101-216|'
                db      'Vystupy A101-216|'
                db      'Wyjsc A101-216|'
                db      'Outputs A101-216|'
                db      'Kimenet.A101-216|'
                ;db      vv,tz,ch,oo,dd,' A101-A216',0
                db      0

                db      'Test RS-232|'
                db      'Test RS-232|'
                db      'Test RS-232|'
                db      'RS-232 test|'
                db      'Teszt RS-232|'
                ;db      vt,ee,ss,tt,' RS-232',0
                db      0

                db      'Test CANu|'
                db      'Test CANu|'
                db      'Test CAN|'
                db      'CAN test|'
                db      'Teszt CAN|'
                ;db      vt,ee,ss,tt,' CANu',0
                db      0

                db      'Test polohovky|'
                db      'Test polohovky|'
                db      'Test pietrowskaz|'
                db      'Position display|'
                db      'Helyhatar. teszt|'
                ;db      vt,ee,ss,tt,' ',pp,oo,ll,oo,zzz,ee,nn,ja,0
                db      0

                db      'Test GSM modul|'
                db      'Test GSM modulu|'
                db      'Test modulu GSM|'
                db      'GSM module test|'
                db      'GSM module test|'
                ;db      'Test GSM modulu',0
                db      0

prikaz_text:    db      'Reset pocet jazd|'
                db      'Reset pocet jizd|'
                db      'Reset ilosc jazd|'
                db      'Clr # of rides|'
                db      'Menet nullazas|'
                ;db      vu,ss,tt,aa,nn,oo,vv,kk,aa,' ',nn,uu,ll,ja,0
                db      0

                db      'Precitaj cas|'
                db      'Precti cas|'
                db      'Odczyt czasu|'
                db      'Read time|'
                db      'Ido mutatasa|'
                ;db      vp,ee,r,ee,ccc,ii,tt,'. ',vv,r,ee,mm,ja,0
                db      0

                db      'Nastav cas|'
                db      'Nastav cas|'
                db      'Ustawienie czasu|'
                db      'Set time|'
                db      'Ido beallitas|'
                ;db      vn,aa,ss,tt,r,oo,ii,tt,' ',vv,r,ee,mm,ja,0
                db      0

                db      'Vymaz chyby|'
                db      'Vymaz chyby|'
                db      'Kasowanie bledow|'
                db      'Clear errors|'
                db      'Torol hibat|'
                ;db      vs,bb,r,oo,ss,' ',oo,tt,kk,aa,zz,oo,vv,0
                db      0

                db      'Ozivenie',0

s_t_text:       db      ' HodMinDenMesRok|'
                db      ' HodMinDenMesRok|'
                db      ' GodMinDziMieRok|'
                db      ' Hr MinDayMonYr|'
                db      ' OraMinNapHo Ev|'
                ;db      ' ',vcc,aa,ss,vm,ii,nn,vd,ee,nn,vm,ee,ss,vg,oo,dd,0
                db      0

m_c_text1:      db      'Mazem chyby...|'
                db      'Vymazuji chyby|'
                db      'Kasuje bledy...|'
                db      'Deleting errors|'
                db      'Hibatorles...|'
                ;db      vi,ss,kk,ll,ju,ccc,ee,nn,ii,ee,' ',oo,tt,kk,aa,zz,0
                db      0

m_c_text2:      db      'Chyby su',n,'vymazane|'
                db      'Chyby vymazany|'
                db      'Bledow brak|'
                db      'Errors deleted|'
                db      'Hibak torolve|'
                ;db      vo,tt,kk,aa,zz,tz,' ',ii,ss,kk,ll,ju,ccc,ee,nn,tz,0
                db      0

o_v_text:       db      'Vytah oziveny',0

para_text:      db      'Moznosti|'
                db      'Moznosti|'
                db      'Mozliwosci|'
                db      'Options|'
                db      'Lehetosegek|'
                ;db      vv,oo,zz,mm,oo,zzz,nn,oo,ss,tt,ii,0
                db      0

                db      'Cisla|'
                db      'Cisla|'
                db      'Numery|'
                db      'Numbers|'
                db      'Szamok|'
                ;db      vcc,ii,ss,ll,aa,0
                db      0

                db      'Casy|'
                db      'Casy|'
                db      'Czasy|'
                db      'Times|'
                db      'Idopontok|'
                ;db      vv,r,ee,mm,ja,0
                db      0

                db      'Poschodia|'
                db      'Stanice|'
                db      'Pietra|'
                db      'Floors|'
                db      'Szintek|'
                ;db      vn,aa,bb,oo,r,' ',oe,tt,aa,zzz,ee,jj,0
                db      0

                db      'Vypisy|'
                db      'Indikace|'
                db      'Opisy|'
                db      'Position outputs|'
                db      'Kiirasok|'
                ;db      vv,tz,pp,ii,ss,kk,aa,0
                db      0

                db      'Casove vstupy|'
                db      'Casove vstupy|'
                db      'Czasowe wejscia|'
                db      'Time activated|'
                db      'Ido. bemenetek|'
                ;db      vcc,aa,ss,oo,vv,ii,jj,' ',vv,ch,oo,dd,0
                db      0

                db      'Pocty impulzov|'
                db      'Pocty impulzu|'
                db      'Ilosc impulsow|'
                db      'Floor locations|'
                db      'Impulzusszamok|'
                ;db      vs,ccc,ee,tt,' ',ii,mm,pp,uu,ll,mz,ss,oo,vv,0
                db      0

                db      'GSM cisla|'
                db      'GSM cisla|'
                db      'GSM numery|'
                db      'GSM numbers|'
                db      'GSM szamok|'
                ;db      'GSM cisla',0
                db      0

                db      'Zapis parametrov|'
                db      'Zapis parametru|'
                db      'Zapis parametrow|'
                db      'Store parameters|'
                db      'Paramet. beirasa|'
                ;db      zz,aa,pp,ii,ss,' ',dd,aa,nn,nn,tz,ch,0
                db      0

                db      'Default param.|'
                db      'Default param.|'
                db      'Default param.|'
                db      'Load defaults|'
                db      'Load defaults|'
                ;db      dd,ee,ff,uu,ll,tt,' ',dd,aa,nn,nn,tz,ch,0
                db      0

                db      'Kopia programu|'
                db      'Kopie programu|'
                db      'Kopia programu|'
                db      'Copy program|'
                db      'Program kopiaja|'
                ;db      vk,oo,pp,ii,ja,' ',pp,r,oo,gg,r,aa,mm,mm,0
                db      0

enum_text:      db      p_riadenie
                db      'Riadenie|'
                db      'Typ rizeni|'
                db      'Sterowanie|'
                db      'Control type|'
                db      'Iranyitas|'
                ;db      vu,pp,r,aa,vv,ll,ee,nn,ii,ee,0
                db      0
                dw      enum_riadenie

                db      p_nahrada
                db      'Nahrada|'
                db      'Nahrada|'
                db      'Wimiana|'
                db      'Replacement|'
                db      'Felujitas|'
                ;db      'Nahrada',0
                db      0
                dw      enum_nahrada

                db      p_a3_maze_volby
                db      'A3 maze volby|'
                db      'A3 maze volby|'
                db      'A3 kasuje wezw|'
                db      'A3 deletes calls|'
                db      'A3 torli a vala.|'
                ;db      'A3 maze volby',0
                db      0
                dw      enum_bool

                db      p_skupina_typ
                db      'Skupina|'
                db      'Skupina|'
                db      'Grupa|'
                db      'Group|'
                db      'Csoport|'
                ;db      vg,r,uu,pp,pp,aa,0
                db      0
                dw      enum_skupina

                db      p_skupina_spojenie
                db      'Spojenie skupiny|'
                db      'Propoj. skupiny|'
                db      'Polaczenie gru|'
                db      'Group commun.|'
                db      'Csoport kapcsol.|'
                ;db      vg,r,uu,pp,' ',ss,oo,ee,dd,ii,nn,ee,nn,ii,ee,0
                db      0
                dw      enum_spojenie

                db      p_dvere_a
                db      'Dvere A|'
                db      'Dvere A|'
                db      'Drzwi A|'
                db      'Door type A|'
                db      'Ajtok A|'
                ;db      vd,vv,ee,r,mz,0
                db      0
                dw      enum_dvere

                db      p_dvere_b
                db      'Dvere B|'
                db      'Dvere B|'
                db      'Drzwi B|'
                db      'Door type B|'
                db      'Ajtok B|'
                ;db      vd,vv,ee,r,mz,0
                db      0
                dw      enum_dvere

                db      p_pohon
                db      'Pohon|'
                db      'Pohon|'
                db      'Naped|'
                db      'Drive|'
                db      'Hajtas|'
                ;db      vg,oo,r,uu,ccc,ee,ee,0
                db      0
                dw      enum_pohon

                db      p_revizna_rychlost1
                db      'Revizna j.-rych1|'
                db      'Revizni j.-rych1|'
                db      'Rewizyjna pred.1|'
                db      'Revis.rid.speed1|'
                db      'Rev.menet sebes1|'
                ;db      vs,kk,oo,r,oo,ss,tt,mz,' ',r,ee,vv,'.',ee,zz,'1',0
                db      0
                dw      enum_rychlost

                db      p_revizna_rychlost2
                db      'Revizna j.-rych2|'
                db      'Revizni j.-rych2|'
                db      'Rewizyjna pred.2|'
                db      'Revis.rid.speed2|'
                db      'Rev.menet sebes2|'
                ;db      vs,kk,oo,r,oo,ss,tt,mz,' ',r,ee,vv,'.',ee,zz,'2',0
                db      0
                dw      enum_rychlost

                db      p_poradie_faz
                db      'Poradie faz|'
                db      'Poradi faz|'
                db      'Kontrola zasilan|'
                db      'Phase order|'
                db      'Fazissorrend|'
                ;db      vf,aa,zz,ii,r,oo,vv,kk,aa,0
                db      0
                dw      enum_bool

                db      p_bezpecny_priestor
                db      'Bezpecny priestr|'
                db      'Bezpecny prostor|'
                db      'Bezpieczna przes|'
                db      'Safe space|'
                db      'Biztonsagi ter|'
                ;db      'Bezpecny priestr',0
                db      0
                dw      enum_bool

                db      p_cas_pohnutia
                db      'Cas pohnutia|'
                db      'Cas vyjeti|'
                db      'Czas ruszenia|'
                db      'Time to move|'
                db      'Ido a mozgas|'
                ;db      vo,cc,ee,nn,kk,'.',oo,sss,ii,bb,'.',ss,tt,aa,r,tt,0
                db      0
                dw      enum_bool

                db      p_inkrementalny
                db      'Inkrement. poc.|'
                db      'Inkrement. cit.|'
                db      'ENKODER|'
                db      'Inc. counter|'
                db      'Inkrem.szamolas|'
                ;db      vi,nn,kk,r,ee,mm,ee,nn,tt,' ',ss,ccc,ee,tt,0
                db      0
                dw      enum_bool

                db      p_termistor
                db      'Termistor|'
                db      'Termistor|'
                db      'Termistor|'
                db      'Thermistor|'
                db      'Termisztor|'
                ;db      vt,ee,r,mm,ii,ss,tt,oo,r,0
                db      0
                dw      enum_bool

                db      p_dorovnavanie
                db      'Dorovnavanie|'
                db      'Dorovnavani|'
                db      'Doregulowanie|'
                db      'Levelling|'
                db      'Korekcio|'
                ;db      vk,oo,r,ee,kk,cc,ii,ja,0
                db      0
                dw      enum_bool

                db      p_predotvaranie
                db      'Predotvaranie|'
                db      'Predotvirani|'
                db      'Otv.Drz.Przy doj|'
                db      'Early opening|'
                db      'Elonyitas|'
                ;db      vp,r,ee,dd,vv,aa,r,ii,tt,ee,ll,' ',oo,tt,kk,r,0
                db      0
                dw      enum_bool

                db      p_statie_s_o_d_a
                db      'Statie s ot.dv.A|'
                db      'Stati s otv.dv.A|'
                db      'Postoj z drzw<>A|'
                db      'Door alw. open A|'
                db      'Allas <> ajto A|'
                ;db      vo,ss,tt,aa,nn,oo,vv,kk,aa,va,tt,kk,vd,vv,ee,r,0
                db      0
                dw      enum_statie

                db      p_statie_s_o_d_b
                db      'Statie s ot.dv.B|'
                db      'Stati s otv.dv.B|'
                db      'Postoj z drzw<>B|'
                db      'Door alw. open B|'
                db      'Allas <> ajto B|'
                ;db      vo,ss,tt,aa,nn,oo,vv,kk,aa,va,tt,kk,vd,vv,ee,r,0
                db      0
                dw      enum_statie

                db      p_modul_c
                db      'Modul C|'
                db      'Modul C|'
                db      'Modul C|'
                db      'C module|'
                db      'C modul|'
                ;db      vm,oo,dd,uu,ll,' C',0
                db      0
                dw      enum_a_1

                db      p_c_vedla_a_b
                db      'Snim.C vedla A,B|'
                db      'Snim.C vedla A,B|'
                db      'Czuj.C wedlug AB|'
                db      'Sens.C next2 A,B|'
                db      'C erzek.AB mell.|'
                ;db      'Snim.C vedla A,B',0
                db      0
                dw      enum_bool

                db      p_inverzia_a_b
                db      'Snimace A,B|'
                db      'Snimace A,B|'
                db      'Czujniki A,B|'
                db      'Sensor A,B|'
                db      'Erzkelo A,B|'
                ;db      'Snimace A,B',0
                db      0
                dw      enum_inv_sp

                db      p_inverzia_h_d
                db      'Snimace H,D|'
                db      'Snimace H,D|'
                db      'Czujniki G,D|'
                db      'Top Bottom sensr|'
                db      'Erzkelo F,L|'
                ;db      'Snimace H,D',0
                db      0
                dw      enum_inv_roz

                db      p_inverzia_nudzova
                db      'Nudzova jazda|'
                db      'Nouzova jizda|'
                db      'Wej.jaz.awaryjna|'
                db      'Emergency ride|'
                db      'Veszhely. menet|'
                ;db      'Nudzova jazda',0
                db      0
                dw      enum_inv_sp

                db      p_blikanie
                db      'Blikanie|'
                db      'Blikani|'
                db      'Migotanie|'
                db      'Blinking|'
                db      'Villogas|'
                ;db      vm,ii,gg,aa,nn,ii,ee,0
                db      0
                dw      enum_bool

                db      p_volby_kabina
                db      'Kabinove poziad.|'
                db      'Kabinove volby|'
                db      'Dyspozycje kabi.|'
                db      'Cabin calls|'
                db      'Belso hivogomb|'
                ;db      vk,oo,mm,aa,nn,dd,ii,' ',kk,aa,bb,ii,nn,ii,0
                db      0
                dw      enum_kabina

                db      p_volby_dole
                db      'Vonkajsie dole|'
                db      'Stanicove dolu|'
                db      'Wezwania w dol|'
                db      'Hall calls down|'
                db      'Kulso le|'
                ;db      vk,oo,mm,aa,nn,dd,ii,' ',sss,aa,ch,'.',vv,nn,ii,zz,0
                db      0
                dw      enum_dole

                db      p_volby_hore
                db      'Vonkajsie hore|'
                db      'Stanicove nahoru|'
                db      'Wezwania w gore|'
                db      'Hall calls up|'
                db      'Kulso fel|'
                ;db      vk,oo,mm,aa,nn,dd,'.',sss,aa,ch,'.',vv,vv,ee,r,ch,0
                db      0
                dw      enum_hore

                db      p_koniec_o_d
                db      'Kon. otv. dveri|'
                db      'Kon. otv. dveri|'
                db      'Kon. otw. drzwi|'
                db      'Doors are open|'
                db      'Ajto kinyit|'
                ;db      vk,oo,nn,ee,cc,' ',oo,tt,kk,r,tz,' ',dd,vv,ee,r,0
                db      0
                dw      enum_a_1

                db      p_koniec_z_d_a
                db      'Kon.zat.dveri A|'
                db      'Kon.zav.dveri A|'
                db      'Kon.zam.drzwi A|'
                db      'Door A closed|'
                db      'Ajto bezar A|'
                ;db      vk,oo,nn,ee,cc,' ',zz,aa,kk,'.',dd,vv,ee,r,'.A',0
                db      0
                dw      enum_a_1

                db      p_koniec_z_d_b
                db      'Kon.zat.dveri B|'
                db      'Kon.zav.dveri B|'
                db      'Kon.zam.drzwi B|'
                db      'Door B closed|'
                db      'Ajto bezar B|'
                ;db      vk,oo,nn,ee,cc,' ',zz,aa,kk,'.',dd,vv,ee,r,'.B',0
                db      0
                dw      enum_a_1

                db      p_svetelna_zavora_a
                db      'Svet. zavora A|'
                db      'Svet. zavora A|'
                db      'Fotokomorka A|'
                db      'Photodetector A|'
                db      'Fotoszenzor A|'
                ;db      vf,oo,tt,oo,ee,ll,ee,mm,ee,nn,tt,' A',0
                db      0
                dw      enum_a_1

                db      p_svetelna_zavora_b
                db      'Svet. zavora B|'
                db      'Svet. zavora B|'
                db      'Fotokomorka B|'
                db      'Photodetector B|'
                db      'Fotoszenzor B|'
                ;db      vf,oo,tt,oo,ee,ll,ee,mm,ee,nn,tt,' B',0
                db      0
                dw      enum_a_1

                db      p_tlacitko_z_d
                db      'Tlac. zat. dveri|'
                db      'Tlac. zav. dveri|'
                db      'Przycisk. zamyk.|'
                db      'Close doors bttn|'
                db      'Gomb ajto zar|'
                ;db      vk,nn,oo,pp,kk,aa,vz,aa,kk,r,tz,vv,aa,nn,ii,ja,0
                db      0
                dw      enum_a_1

                db      p_poziarna_jazda
                db      'Poziarna jazda 1|'
                db      'Pozarni jizda 1|'
                db      'Jazda pozarna 1|'
                db      'Fire ride|'
                db      'Tuzvedelmi jarat|'
                ;db      vp,oo,zzz,aa,r,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0
                dw      enum_a_1

                db      p_poziarna_jazda2
                db      'Poziarna jazda 2|'
                db      'Pozarni jizda 2|'
                db      'Jazda pozarna 2|'
                db      'Fire ride 2|'
                db      'Tuzvedelmi jar 2|'
                ;db      vp,oo,zzz,aa,r,nn,aa,ja,' ',ee,zz,dd,aa,0
                db      0
                dw      enum_a_1
                
                db      p_vazenie_10
                db      'Vazenie 10%|'
                db      'Vazeni 10%|'
                db      'Obciazenie 10%|'
                db      '10% weight|'
                db      'Terheles 10%|'
                ;db      vg,r,uu,zz,oo,pp,oo,dd,ee,mm,nn,'. 10%',0
                db      0
                dw      enum_a_1

                db      p_vazenie_80
                db      'Vazenie 80%|'
                db      'Vazeni 80%|'
                db      'Obciazenie 80%|'
                db      '80% weight|'
                db      'Terheles 80%|'
                ;db      vg,r,uu,zz,oo,pp,oo,dd,ee,mm,nn,'. 80%',0
                db      0
                dw      enum_a_1

                db      p_vazenie_110
                db      'Vazenie 110%|'
                db      'Vazeni 110%|'
                db      'Obciazenie 110%|'
                db      '110% weight|'
                db      'Terheles 110%|'
                ;db      vvv,ch,oo,dd,' ',pp,ee,r,ee,gg,r,uu,zz,kk,aa,0
                db      0
                dw      enum_a_1

                db      p_revizna_vysoka
                db      'Vysoka rych. RJ|'
                db      'Vysoka rych. RJ|'
                db      'Duza pred. R.J|'
                db      'Rev.ride hi.spd|'
                db      'Rev.jar.seb.nagy|'
                ;db      'Vysoka rych. RJ',0
                db      0
                dw      enum_a_1

                db      p_ranny_program
                db      'Ranny program|'
                db      'Ranni program|'
                db      'Poranny program|'
                db      'Morning mode|'
                db      'Reggeli program|'
                ;db      vu,tt,r,ee,nn,ja,ja,' ',pp,r,oo,gg,r,aa,mm,mm,0
                db      0
                dw      enum_a_1

                db      p_obednajsi_program
                db      'Obednaj. program|'
                db      'Obedni program|'
                db      'Popoludn.program|'
                db      'Evening mode|'
                db      'Deli program|'
                ;db      vvv,ee,ccc,ee,r,nn,ja,ja,' ',pp,r,oo,gg,r,aa,mm,0
                db      0
                dw      enum_a_1

                db      p_prednostne_p
                db      'Prednos. privol1|'
                db      'Prednos. privol1|'
                db      'Przyvol.prioryt1|'
                db      'Priority call 1|'
                db      'Elsobsegi hivas1|'
                ;db      vp,r,ee,ii,mm,uu,ssc,ee,ss,tt,vv,oo,' ',vv,ii,zz,0
                db      0
                dw      enum_a_1

                db      p_prednostne_p2
                db      'Prednos. privol2|'
                db      'Prednos. privol2|'
                db      'Przyvol.prioryt2|'
                db      'Priority call 2|'
                db      'Elsobsegi hivas2|'
                ;db      vp,r,ee,ii,mm,uu,ssc,ee,ss,tt,vv,oo,' ',vv,ii,zz,0
                db      0
                dw      enum_a_1

                db      p_prednostne_p3
                db      'Prednos. privol3|'
                db      'Prednos. privol3|'
                db      'Przyvol.prioryt3|'
                db      'Priority call 3|'
                db      'Elsobsegi hivas3|'
                ;db      vp,r,ee,ii,mm,uu,ssc,ee,ss,tt,vv,oo,' ',vv,ii,zz,0
                db      0
                dw      enum_a_1

                db      p_kontrola_npk
                db      'Modul NPK|'
                db      'Modul NPK|'
                db      'Modul NPK|'
                db      'Module NPK|'
                db      'Modul NPK|'
                ;db      'Prednostne priv.',0
                db      0
                dw      enum_a_1
                
                db      p_nezavisla_jazda
                db      'Nezavisla jazda|'
                db      'Nezavisla jizda|'
                db      'Jazda niezalezna|'
                db      'Independent ride|'
                db      'Sofor jarat|'
                ;db      vr,uu,ll,ee,vv,oo,jj,' ',ee,zz,dd,aa,0
                db      0
                dw      enum_a_1

                db      p_tlacitko_o_d
                db      'Tlac. otv. dveri|'
                db      'Tlac. otv. dveri|'
                db      'Przyc.otw. drzwi|'
                db      'Opn doors buttn|'
                db      'Gomb ajto nyit|'
                ;db      vk,nn,oo,pp,kk,aa,vo,tt,kk,r,tz,vv,aa,nn,ii,ja,0
                db      0
                dw      enum_a_1
                
                db      p_kontrola_24v
                db     	'Kontrola 24V|'
                db     	'Kontrola 24V|'
                db     	'Sprawdz. 24V|'
                db     	'Kontrola 24V|'
                db     	'Kontrola 24V|'
                ;db     azbuka
				db      0
                dw      enum_a_1

                db      p_ozivenie
                db      'Ozivenie|'
                db      'Ozivenie|'
                db      'Ozywienie|'
                db      'Ozivenie|'
                db      'Ozivenie|'
                ;db     azbuka
                db      0
                dw      enum_a_1

                db      p_ozivenie2
                db      'Ozivenie 2|'
                db      'Ozivenie 2|'
                db      'Ozywienie 2|'
                db      'Ozivenie 2|'
                db      'Ozivenie 2|'
                ;db     azbuka
                db      0
                dw      enum_a_1
                
                db      p_ozivenie_out
                db      'Ozivenie vystup|'
                db      'Ozivenie vystup|'
                db      'Ozywienie wyjsc|'
                db      'Ozivenie vystup|'
                db      'Ozivenie vystup|'
                ;db     azbuka
                db      0
                dw      enum_b_1
                
                db      p_porucha_menica
                db      'Porucha menica|'
                db      'Porucha menica|'
                db      'Brak falownika|'
                db      'Porucha menica|'
                db      'Porucha menica|'
                ;db     azbuka
                db      0
                dw      enum_a_1

                db      p_bezpecnost_menica
                db      'Bezp. menica|'
                db      'Bezp. menica|'
                db      'Bezp. falow.|'
                db      'Bezp. menica|'
                db      'Bezp. menica|'
                ;db     azbuka
                db      0
                dw      enum_a_1

                db      p_typ_menica
                db      'Typ menica|'
                db      'Typ menica|'
                db      'Typ falow.|'
                db      'Typ menica|'
                db      'Typ menica|'
                ;db     azbuka
                db      0
                dw      enum_menic

                db      p_kontrola_menica
                db      'Kontrola menica|'
                db      'Kontrola menica|'
                db      'Sprawdz. falow.|'
                db      'Kontrola menica|'
                db      'Kontrola menica|'
                ;db     azbuka
                db      0
                dw      enum_a_1

if hydraulika_a3
                db      p_hydraulika_rdy
                db      'Hydraulika RDY|'
                db      'Hydraulika RDY|'
                db      'Hydraulika RDY|'
                db      'Hydraulika RDY|'
                db      'Hydraulika RDY|'
                ;db     azbuka
                db      0
                dw      enum_a_1
                
                db      p_hydraulika_run
                db      'Hydraulika RUN|'
                db      'Hydraulika RUN|'
                db      'Hydraulika RUN|'
                db      'Hydraulika RUN|'
                db      'Hydraulika RUN|'
                ;db     azbuka
                db      0
                dw      enum_a_1
else
                db      p_kontrola_brzdy1
                db      'Kontrola brzdy 1|'
                db      'Kontrola brzdy 1|'
                db      'Hamulec 1|'
                db      'Brake check 1|'
                db      'Brake check 1|'
                db      0
                dw      enum_a_1
                
                db      p_kontrola_brzdy2
                db      'Kontrola brzdy 2|'
                db      'Kontrola brzdy 2|'
                db      'Hamulec 2|'
                db      'Brake check 2|'
                db      'Brake check 2|'
                db      0
                dw      enum_a_1
endif
                db      p_vent_in
                db      'Ventilator IN|'
                db      'Ventilator IN|'
                db      'Wentylator IN|'
                db      'Ventilator IN|'
                db      'Ventilator IN|'
                db      0
                dw      enum_a_1

                db      p_vent_out1
                db      'Ventilator OUT 1|'
                db      'Ventilator OUT 1|'
                db      'Wentylator B1-B8|'
                db      'Ventilator OUT 1|'
                db      'Ventilator OUT 1|'
                db      0
                dw      enum_b_1

                db      p_vent_out2
                db      'Ventilator OUT 2|'
                db      'Ventilator OUT 2|'
                db      'Wentylator przek|'
                db      'Ventilator OUT 2|'
                db      'Ventilator OUT 2|'
                db      0	
                dw      enum_r_1

                db      p_copy_in
                db      'Kopia IN',0
                dw      enum_a_1

                db      p_copy_out
                db      'Kopia OUT',0
                dw      enum_r_1

                db      p_vypis
                db      'Vypis',0
                dw      enum_vypis

                db      p_rele_jazda
                db      'Jazda|'
                db      'Jizda|'
                db      'Jazda|'
                db      'Relay ride|'
                db      'Menet|'
                ;db      vr,ee,ll,ee,' ',ee,zz,dd,aa,0
                db      0
                dw      enum_r_1

                db      p_rele_hv_tr
                db      'Hviezda/trojuhol|'
                db      'Hvezda/trojuhel|'
                db      'Gwiazda/trojkat|'
                db      'Star/triangle|'
                db      'Csillag/haromsz.|'
                ;db      vz,vv,ee,zz,dd,aa,'/',tt,r,ee,uu,gg,oo,ll,0
                db      0
                dw      enum_r_2

                db      p_rele_nizka
                db      'Nizka rychlost|'
                db      'Nizka rychlost|'
                db      'Niska predkosc|'
                db      'Low speed|'
                db      'Alacsony sebess.|'
                ;db      vn,ii,zz,kk,aa,ja,' ',ss,kk,oo,r,oo,ss,tt,0
                db      0
                dw      enum_r_1

                db      p_rele_stredna
                db      'Stredna rychlost|'
                db      'Stredni rychlost|'
                db      'Srednia predkosc|'
                db      'Medium speed|'
                db      'Kozepes sebesseg|'
                ;db      vs,r,ee,dd,nn,aa,ja,' ',ss,kk,oo,r,oo,ss,tt,0
                db      0
                dw      enum_r_1

                db      p_je_nudzovy_dojazd
                db      'Nudzovy dojazd|'
                db      'Nudzovy dojezd|'
                db      'Awaryjny dojazd|'
                db      'Battery ride|'
                db      'Bateria menet|'
                ;db      vp,r,ii,nn,uu,dd,ii,tt,ee,ll,mz,'.',dd,vv,ii,zzz,0
                db      0
                dw      enum_bool

                db      p_nudzovy_dojazd
                db      'Rele strata faz|'
                db      'Rele ztraty fazi|'
                db      'Przeka.braku.faz|'
                db      'Relay phase loss|'
                db      'Relle fazishiany|'
                ;db      vr,ee,ll,ee,' ',ff,aa,zz,ii,r,oo,vv,kk,aa,0
                db      0
                dw      enum_b_k

                db      p_rele_baterka
                db      'Rele baterka|'
                db      'Rele baterie|'
                db      'Prekaz.bateria|'
                db      'Relay battery|'
                db      'Relle bateria|'
                ;db      vr,ee,ll,ee,' ',aa,kk,uu,mm,uu,ll,ja,tt,oo,r,aa,0
                db      0
                dw      enum_b_k

                db      p_smerove_sipky
                db      'Smerove sipky|'
                db      'Smerove sipky|'
                db      'Strzalki kierunk|'
                db      'Direction arrows|'
                db      'Iranymut. nyilak|'
                ;db      vs,tt,r,ee,ll,kk,ii,' ',ee,zz,dd,ii,0
                db      0
                dw      enum_b_smer

                db      p_pretazenie
                db      'Pretazenie|'
                db      'Pretizeni|'
                db      'Przeciazenie|'
                db      'Too heavy|'
                db      'Tulterheles|'
                ;db      vvv,ch,oo,dd,' ',pp,ee,r,ee,gg,r,uu,zz,kk,aa,0
                db      0
                dw      enum_b_1

                db      p_porucha
                db      'Porucha|'
                db      'Porucha|'
                db      'Uszkodzenie|'
                db      'Malfunction|'
                db      'Uzemzavar|'
                ;db      vvv,tz,ch,oo,dd,' ',oo,tt,kk,aa,zz,0
                db      0
                dw      enum_b_k

                db      p_reset_menica
                db      'Reset menica|'
                db      'Reset menica|'
                db      'Reset falow.|'
                db      'Reset menica|'
                db      'Reset menica|'
                db      0
                dw      enum_b_k

                db      p_ohrievanie
                db      'Ohrievanie|'
                db      'Ohrev|'
                db      'Ogrzewanie|'
                db      'Heating|'
                db      'Temperalas|'
                ;db      vvv,tz,ch,oo,dd,' ',oo,gg,r,ee,vv,0
                db      0
                dw      enum_b_1

                db      p_gong
                db      'Gong|'
                db      'Gong|'
                db      'Gong|'
                db      'Gong|'
                db      'Gong|'
                ;db      vz,vv,uu,kk,oo,vv,aa,ja,' ',ss,ii,gg,nn,aa,ll,0
                db      0
                dw      enum_b_1

                db      p_gong_kedy
                db      'Gong - kedy|'
                db      'Gong - kdyz|'
                db      'Gong - wlaczenie|'
                db      'Gong - when|'
                db      'Gong - mikor|'
                ;db      vvv,r,ee,mm,ja,' ',zz,vv,uu,kk,'. ',ss,ii,gg,'.',0
                db      0
                dw      enum_gong

                db      p_multiplex
                db      'Multiplexovanie|'
                db      'Multiplexovani|'
                db      'Multipleksowanie|'
                db      'Multiplexing|'
                db      'Multiplex|'
                ;db      vm,uu,ll,tt,ii,pp,ll,ee,kk,ss,0
                db      0
                dw      enum_b_2

                db      p_zdielane_vonkajsie
                db      'Vonk. zdielane|'
                db      'Venk. zdileni|'
                db      'Podzial wezwan|'
                db      'Hall clls shared|'
                db      'Hall clls shared|'
                ;db      'Vonk. zdielane',0
                db      0
                dw      enum_bool

                db      p_seriovy_typ
                db      'Seriovy kod-aky|'
                db      'Seriovy kod-typ|'
                db      'Serial kod-jaki|'
                db      'Serial code type|'
                db      'Seria typus|'
                ;db      vk,oo,dd,' ',ss,ee,r,ii,ii,0
                db      0
                dw      enum_seriovy

                db      p_seriovy_typ_rdk
                db      'Seriovy kod RDK|'
                db      'Seriovy kod RDK|'
                db      'Serial kod RDK|'
                db      'Serial code RDK|'
                db      'Seria typus RDK|'
                ;db      vk,oo,dd,' ',ss,ee,r,ii,ii,0
                db      0
                dw      enum_seriovy
                
                db      p_seriovy_0
                db      'Seriovy CLK|'
                db      'Seriovy CLK|'
                db      'Serial CLK|'
                db      'Serial CLK|'
                db      'Serias CLK|'
                ;db      vs,ee,r,ii,'. CLK',0
                db      0
                dw      enum_b_1

                db      p_seriovy_1
                db      'Seriovy DTA|'
                db      'Seriovy DTA|'
                db      'Serial DTA|'
                db      'Serial DTA|'
                db      'Serias DTA|'
                ;db      vs,ee,r,ii,'. DTA',0
                db      0
                dw      enum_b_1

                db      p_typ_bcd
                db      'Typ BCD kodu|'
                db      'Typ BCD kodu|'
                db      'Option BCD|'
                db      'BCD code type|'
                db      'Kodtipus  BCD|'
                ;db      vt,ii,pp,' BCD ',kk,oo,dd,0
                db      0
                dw      enum_typ_bcd

                db      p_grayov_kod
                db      'Grayov kod|'
                db      'Grayuv kod|'
                db      'Gray kod|'
                db      'Gray''s code|'
                db      'Gray kod|'
                ;db      'Grayov kod',0
                db      0
                dw      enum_bool

                db      p_bcd_0
                db          'BCD A',0
                dw          enum_b_1
                db      p_bcd_1
                db          'BCD B',0
                dw          enum_b_1
                db      p_bcd_2
                db          'BCD C',0
                dw          enum_b_1
                db      p_bcd_3
                db          'BCD D',0
                dw          enum_b_1
                db      p_bcd_4
                db          'BCD E',0
                dw          enum_b_1
                db      p_1zn_0
                db          '1zN 0|1zN 0|1zN 0|1ofN 0|1aN 0',0 ;|1 ',ii,zz,' ',vn,' 0',0
                dw          enum_b_1
                db      p_1zn_1
                db          '1zN 1|1zN 1|1zN 1|1ofN 1|1aN 1',0 ;|1 ',ii,zz,' ',vn,' 1',0
                dw          enum_b_1
                db      p_1zn_2
                db          '1zN 2|1zN 2|1zN 2|1ofN 2|1aN 2',0 ;|1 ',ii,zz,' ',vn,' 2',0
                dw          enum_b_1
                db      p_1zn_3
                db          '1zN 3|1zN 3|1zN 3|1ofN 3|1aN 3',0 ;|1 ',ii,zz,' ',vn,' 3',0
                dw          enum_b_1
                db      p_1zn_4
                db          '1zN 4|1zN 4|1zN 4|1ofN 4|1aN 4',0 ;|1 ',ii,zz,' ',vn,' 4',0
                dw          enum_b_1
                db      p_1zn_5
                db          '1zN 5|1zN 5|1zN 5|1ofN 5|1aN 5',0 ;|1 ',ii,zz,' ',vn,' 5',0
                dw          enum_b_1
                db      p_1zn_6
                db          '1zN 6|1zN 6|1zN 6|1ofN 6|1aN 6',0 ;|1 ',ii,zz,' ',vn,' 6',0
                dw          enum_b_1
                db      p_1zn_7
                db          '1zN 7|1zN 7|1zN 7|1ofN 7|1aN 7',0 ;|1 ',ii,zz,' ',vn,' 7',0
                dw          enum_b_1
if auto_vytah
if auto_vytah_special
                db      p_au_in_a
                db          'SZ pri dverach A',0
                dw          enum_a_1
                db      p_au_in_b
                db          'SZ pri dverach B',0
                dw          enum_a_1
                db      p_au_out_a_go
                db          'Dole zelena',0
                dw          enum_b_1
                db      p_au_out_a_stop
                db          'Dole cervena',0
                dw          enum_b_1
                db      p_au_out_a_back
                db          'Semafor A - spat',0
                dw          enum_b_1
                db      p_au_out_b_go
                db          'Hore zelena',0
                dw          enum_b_1
                db      p_au_out_b_stop
                db          'Hore cervena',0
                dw          enum_b_1
                db      p_au_out_b_back
                db          'Semafor B - spat',0
                dw          enum_b_1
                db      p_au_out_free
                db          'Semafor - Volne',0
                dw          enum_b_1
else
                db      p_au_in_a
                db          'SZ pri dverach A',0
                dw          enum_a_1
                db      p_au_in_b
                db          'SZ pri dverach B',0
                dw          enum_a_1
                db      p_au_out_a_go,
                db          'Semafor A - chod',0
                dw          enum_b_1
                db      p_au_out_a_stop
                db          'Semafor A - stoj',0
                dw          enum_b_1
                db      p_au_out_a_back
                db          'Semafor A - spat',0
                dw          enum_b_1
                db      p_au_out_b_go
                db          'Semafor B - chod',0
                dw          enum_b_1
                db      p_au_out_b_stop
                db          'Semafor B - stoj',0
                dw          enum_b_1
                db      p_au_out_b_back
                db          'Semafor B - spat',0
                dw          enum_b_1
                db      p_au_out_free
                db          'Semafor - Volne',0
                dw          enum_b_1
endif
endif

enum_rozp:      db      ' rozpinaci| rozepinaci| rozl.| active 1| aktiv 1',0 ;| active 1',0
enum_spin:      db      ' spinaci| spinaci| wl.| active 0| aktiv 0',0 ;| active 0',0

enum_riadenie:  db      3
                db      'Simplex',0 ;|',vs,ii,mm,pp,ll,ee,kk,ss,0
                db      'Jednoduche|Jednoduche|Proste|Single call|Egyszeru',0 ;|',vp,r,oo,ss,tt,oo,ee,0
                db      'Simpl. bez dveri',0

enum_nahrada:   db      3
                db      'Nie je',0
                db      '250',0
                db      '100',0

enum_skupina:   db      5
                db      'Nie je|Neni|Nie|None|Semmi',0 
                            ;|',vn,ee,tt,0
                db      'Normalna|Normalni|Normalna|Normal|Normalis',0 
                            ;|',vo,bb,tz,ccc,nn,oo,ee,0
                db      'Blokovanie|Blokovani|Blokowanie|Blocking|Blokolt',0 
                            ;|',vb,ll,oo,kk,ii,r,oo,vv,kk,aa,0
                db      'Dvoj-klik|Dvoj-klik|Podw. klikniecie|Double-click|Kettos klik',0 
                            ;|',vn,aa,zzz,aa,tt,mz,' 2 ',r,aa,zz,aa,0
                db      'Umrtveni',0

enum_spojenie:  db      3
                db      'Nie je|Neni|Nie|None|Semmi',0 
                            ;|',vn,ee,tt,0
                db      'Seriove spojenie|Seriove spojeni|Szeregowe|Serial|Seria kapcsolas',0 
                            ;|',vs,ee,r,ii,jj,'.',ss,oo,ee,dd,ii,nn,ee,nn,ii,ee,0
                db      'CAN-ove spojenie|CAN-ove spojeni|CAN|CAN|CAN kapcsolas',0 
                            ;|',ss,oo,ee,dd,ii,nn,ee,nn,ii,ee,0

enum_dvere:     db      5
                db      'Autom. vodorovne|Autom. vodorovne|Autom. horyzont.|Autom horiz|Autom.vizszintes',0
                            ;|',va,vv,tt,oo,mm,aa,tt,'.',gg,oo,r,ii,zz,oo,nn,tt,0
                db      'Automat. zvisle|Automat. svisle|Autom. wertykal.|Autom vert|Autom.fuggoleges',0
                            ;|',va,vv,tt,oo,mm,aa,tt,'.',vv,ee,r,tt,ii,kk,aa,ll,0
                db      'Kabin. vodorovne|Kabin. vodorovne|Kabin. horyzont.|Cabin horiz|Kabin.vizszintes',0
                            ;|',vk,aa,bb,ii,nn,'. ',gg,oo,r,ii,zz,oo,nn,tt,'.',0
                db      'Kabinove zvisle|Kabinove svisle|Kabin.vertikal.|Cabin vert|Kabin.fuggoleges',0 
                            ;|',vk,aa,bb,ii,nn,'. ',vv,ee,r,tt,ii,kk,aa,ll,'.',0
                db      'Manualne|Rucni|Reczne|Manual|Manualis',0 
                            ;|',vr,uu,ccc,nn,oo,ee,0

enum_pohon:     db      2
                db      'Hydraulicky|Hydraulicky|Hydrauliczny|Hydraulic|Hidraulikus',0 
                            ;|',vg,ii,dd,r,aa,vv,ll,ii,ccc,ee,ss,kk,ii,jj,0
                db      'Trakcny, bubnovy|Trakcni, bubnovy|Trakcyjny|Traction|Acelkotelles',0 
                            ;|',vt,r,oo,ss,0

enum_rychlost:  db      4
                db      'Vysoka|Vysoka|Wysoka|High|Nagy',0 
                            ;|',vvv,tz,ss,oo,kk,aa,ja,0
                db      'Stredna|Stredni|Srednia|Medium|Kozepes',0 
                            ;|',vs,r,ee,dd,nn,aa,ja,0
                db      'Nizka|Nizka|Niska|Low|Alacsony',0 
                            ;|',vn,ii,zz,kk,aa,ja,0
                db      'Revizna|Revizni|Kontrolna|Revision|Revizios',0 
                            ;|',vr,ee,vv,ii,zz,nn,aa,ja,0

enum_statie:    db      3
                db      'Nie|Ne|Nie|No|Nem',0 ;|',vn,ee,tt,0
                db      'Ano|Ano|Tak|Yes|Igen',0 ;|',vd,aa,0
                db      'Vypne svetlo|Vypne svetlo|Wyl. swiatlo|Turns off light|Vilagit. kikapcs',0 ;|Vypne svetlo',0

enum_inv_sp:    db      2
                db      'Spinaci|Spinaci|Wl.|Connect|Connect',0 ;|Spinaci',0
                db      'Rozpinaci|Rozepinaci|Rozl.|Disconnect|Disconnect',0 ;|Rozpinaci',0

enum_inv_roz:   db      2
                db      'Rozpinaci|Rozepinaci|Rozl.|Disconnect|Disconnect',0 ;|Rozpinaci',0
                db      'Spinaci|Spinaci|Wl.|Connect|Connect',0 ;|Spinaci',0

enum_bool:      db      2
                db      'Nie|Ne|Nie|No|Nem',0 ;|',vn,ee,tt,0
                db      'Ano|Ano|Tak|Yes|Igen',0 ;|',vd,aa,0

enum_kabina:    db      5
                db      'Nie su|Nejsou|Nie|None|Semmi',0 ;|',vn,ee,tt,0
                db      'A101-A111',0
                db      'A101-A116',0
                db      'CAN',0
                db      'MUX s dole|MUX s nadol|MUX s dol|MUX w/ down|MUX s dole',0

enum_dole:      db      6
                db      'Nie su|Nejsou|Nie|None|Nem',0 ;|',vn,ee,tt,0
                db      '201-208, 112-114',0
                db      'A201-A216',0
                db      'A101-A216',0
                db      'MUX s kabinou|MUX s kabinou|MUX z kabinow|MUX w/ cabin|MUX s kabinou',0
                db      'MUX s hore|MUX s nahoru|MUX z gore|MUX w/ up|MUX s hore',0

enum_hore:      db      4
                db      'Nie su|Nejsou|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      '209-216, 115-116',0
                db      'A101-A116',0
                db      'MUX s dole|MUX s nadol|MUX z dol|MUX w/ down|MUX s dole',0

enum_a_1:       db      1+16+64+18+4+2
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0

enum_r_1:       db      6
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'Rele 7|Rele 7|Przekaznik 7|Relay 7|Rele 7',0 ;',vr,ee,ll,ee,' 7',0
                db      'Rele 9|Rele 9|Przekaznik 9|Relay 9|Rele 9',0 ;',vr,ee,ll,ee,' 9',0
                db      'Rele 4|Rele 4|Przekaznik 4|Relay 4|Rele 4',0 ;',vr,ee,ll,ee,' 4',0
                db      'Rele 11|Rele 11|Przekaznik 11|Relay 11|Rele 11',0 ;',vr,ee,ll,ee,' 11',0
                db      'Rele 12|Rele 12|Przekaznik 12|Relay 12|Rele 12',0 ;',vr,ee,ll,ee,' 12',0

enum_r_2:       db      5
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'Rele 7|Rele 7|Przekaznik 7|Relay 7|Rele 7',0 ;',vr,ee,ll,ee,' 7',0
                db      'Rele 9|Rele 9|Przekaznik 9|Relay 9|Rele 9',0 ;',vr,ee,ll,ee,' 9',0
                db      'Rele 4|Rele 4|Przekaznik 4|Relay 4|Rele 4',0 ;',vr,ee,ll,ee,' 4',0
                db      'Rele 7/9|Rele 7/9|Przekaznik 7/9|Relay 7/9|Rele 7/9',0 ;',vr,ee,ll,ee,' 7/9',0

enum_b_1:       db      41
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0

enum_b_2:       db      8
                db      'Nie su|Nejsou|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'B1-B2',0
                db      'B2-B3',0
                db      'B3-B4',0
                db      'B4-B5',0
                db      'B5-B6',0
                db      'B6-B7',0
                db      'B7-B8',0

enum_b_smer:    db      9
                db      'Nie su|Nejsou|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'B1-B2',0
                db      'B2-B3',0
                db      'B3-B4',0
                db      'B4-B5',0
                db      'B5-B6',0
                db      'B6-B7',0
                db      'B7-B8',0
                db      'K11-K12',0

enum_b_k:       db      14
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'B1',0
                db      'B2',0
                db      'B3',0
                db      'B4',0
                db      'B5',0
                db      'B6',0
                db      'B7',0
                db      'B8',0
                db      'Rele 7|Rele 7|Przekaznik 7|Relay 7|Rele 7',0 ;',vr,ee,ll,ee,' 7',0
                db      'Rele 9|Rele 9|Przekaznik 9|Relay 9|Rele 9',0 ;',vr,ee,ll,ee,' 9',0
                db      'Rele 4|Rele 4|Przekaznik 4|Relay 4|Rele 4',0 ;',vr,ee,ll,ee,' 4',0
                db      'Rele 11|Rele 11|Przekaznik 11|Relay 11|Rele 11',0 ;',vr,ee,ll,ee,' 11',0
                db      'Rele 12|Rele 12|Przekaznik 12|Relay 12|Rele 12',0 ;',vr,ee,ll,ee,' 12',0

enum_gong:      db      4
                db      'Vyp. vys. rych.|'
                db      'Vyp. vys. rych.|'
                db      'Wyl. wys. pred.|'
                db      'High spd. off|'
                db      'Vyp. vys. rych.|'
                db      0

                db      'Zastavenie|'
                db      'Zastaveni|'
                db      'Zatrzymanie|'
                db      'Stop|'
                db      'Zastavenie|'
                db      0

                db      'Otvorenie dveri|'
                db      'Otevreni dveri|'
                db      'Przy otwar.drzwi|'
                db      'Doors open|'
                db      'Otvorenie dveri|'
                db      0

                db      'Zast. alebo otv.|'
                db      'Zast. nebo otev.|'
                db      'Zatrzym.lub otw.|'
                db      'Stop or open|'
                db      'Zast. alebo otv.|'
                db      0

enum_seriovy:   db      5
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'Sucik',0
                db      'LIFT COMPONENTS',0
                db      'BANEL',0
                db      'BEPOL',0

enum_typ_bcd:   db      16
                db      'ZJ=0000 P=1111',0
                db      'ZJ=1111 P=1110',0
                db      'ZJ=1110 P=1101',0
                db      'ZJ=1101 P=1100',0
                db      'ZJ=1100 P=1011',0
                db      'ZJ=1011 P=1010',0
                db      'ZJ=1010 P=1001',0
                db      'ZJ=1001 P=1000',0

                db      'ZJ=1111 P=0000',0
                db      'ZJ=0000 P=0001',0
                db      'ZJ=0001 P=0010',0
                db      'ZJ=0010 P=0011',0
                db      'ZJ=0011 P=0100',0
                db      'ZJ=0100 P=0101',0
                db      'ZJ=0101 P=0110',0
                db      'ZJ=0110 P=0111',0

enum_vypis:     db      4
                db      'Nie je|Neni|Nie|None|Nem',0 ;',vn,ee,tt,0
                db      'LIFT COMPONENTS',0
                db      'LIFT BUD',0
                db      'ZD PYSKOWICE',0

enum_menic:     db      2
                db      'Ostatne',0
                db      'Yaskawa',0

num_text:       db      'Pocet stanic|'
                db      'Pocet stanic|'
                db      'Ilosc przystank.|'
                db      '# of floors|'
                db      'Megallok szama|'
                ;db      vk,aa,ll,ii,ccc,ee,ss,tt,vv,oo,' ',ee,tt,aa,zzz,0
                db      0

                db      'Pocet prerus. SZ|'
                db      'Pocet prerus. SZ|'
                db      'Ilosc fotokomor.|'
                db      '# of photd. ints|'
                db      'Szam fotoszenzor|'
                ;db      'Pocet prerus. SZ',0
                db      0

                db      'Parkovacia stan.|'
                db      'Parkovaci stan.|'
                db      'Przystan.parkow.|'
                db      'Parking floor|'
                db      'Pihenomegallo|'
                ;db      ve,tt,aa,zzz,' ',pp,aa,r,kk,oo,vv,aa,nn,ja,0
                db      0

                db      'Hlavna stanica|'
                db      'Vychozi stanice|'
                db      'Przystan.glowny|'
                db      'Main floor|'
                db      'Fomegallo|'
                ;db      vg,ll,aa,vv,nn,aa,' ',ee,tt,aa,zzz,0
                db      0

                db      'Pov. pocet jazd|'
                db      'Pov. pocet jizd|'
                db      'Dozw.ilosc jazd|'
                db      'Max # of rides|'
                db      'Megeng.menetszam|'
                ;db      'Pov. pocet jazd',0
                db      0

                db      'Cislo vyt. skup.|'
                db      'Cis vyt ve skup.|'
                db      'Numer v grupie|'
                db      'Number in group|'
                db      'Lift szam|'
                ;db      vn,oo,mm,ee,r,' ',ll,ii,ff,tt,aa,' ',gg,r,uu,pp,0
                db      0

                db      'Prednostne priv.|'
                db      'Prednostni priv.|'
                db      'Przyst.prioryte.|'
                db      'Priority call|'
                db      'Prioritas valasz|'
                ;db      'Prednostne priv.',0
                db      0

                db      'Tep. pre zapnut.|'
                db      'Tep. pre zapnut.|'
                db      'Temp.do zalacze.|'
                db      'On @ temp=|'
                db      'Homersekletet be|'
                ;db      'Tep. pre zapnut.',0
                db      0

                db      'Tep. pre vypnut.|'
                db      'Tep. pre vypnut.|'
                db      'Temp.do wylacze.|'
                db      'Off @ temp=|'
                db      'Homersekletet ki|'
                ;db      'Tep. pre vypnut.',0
                db      0

                db      'Brzdenie Vys-Par|'
                db      'Brzdeni Vys-Par|'
                db      'HamowanieVys-Par|'
                db      'Brake Hi-Par|'
                db      'Fek nagy-param|'
                ;db      'Brzdenie Vys-Par',0
                db      0

                db      'Brzdenie Par-Niz|'
                db      'Brzdeni Par-Niz|'
                db      'HamowaniePar-Niz|'
                db      'Brake Par-Low|'
                db      'Fek param-alacs.|'
                ;db      'Brzdenie Par-Niz',0
                db      0

                db      'Posch. pod DS|'
                db      'Posch. pod DS|'
                db      'Przystane.pod KD|'
                db      'Floors under DS|'
                db      'Floors under DS|'
                ;db      'Posch. pod DS',0
                db      0

                db      'Posch. nad HS|'
                db      'Posch. nad HS|'
                db      'Przystane.nad KG|'
                db      'Floors over HS|'
                db      'Floors over HS|'
                ;db      'Posch. nad HS',0
                db      0

                db      'Zotrvacnost|'
                db      'Zetrvacnost|'
                db      'Bezwladnosc|'
                db      'Inertia|'
                db      'Inertia|'
                ;db      'Inertia',0
                db      0

                db      'Dojazd do|'
                db      'Dojezd do|'
                db      'Dojazd do|'
                db      'Dojazd do|'
                db      'Dojazd do|'
                ;db      'Drive to',0
                db      0

                db      'Hlavna stanica 2|'
                db      'Vychozi stanice2|'
                db      'Przystan.glowny2|'
                db      'Main floor 2|'
                db      'Fomegallo 2|'
                ;db      vg,ll,aa,vv,nn,aa,' ',ee,tt,aa,zzz,0
                db      0
                
                db      'Prednostne priv2|'
                db      'Prednostni priv2|'
                db      'Przywol.prioryt2|'
                db      'Priority call 2|'
                db      'Prioritas valas2|'
                ;db      'Prednostne priv.',0
                db      0
                
                db      'Prednostne priv3|'
                db      'Prednostni priv3|'
                db      'Przywol.prioryt3|'
                db      'Priority call 3|'
                db      'Prioritas valas3|'
                ;db      'Prednostne priv.',0
                db      0
                
time_text:      db      'Cas otvor. dveri|'
                db      'C otevreni dveri|'
                db      'Cz.otwarty.drzwi|'
                db      'Doors are open|'
                db      'Nyit.allapot.ide|'
                ;db      vvv,r,ee,mm,ja,' ',oo,tt,kk,r,tz,tt,ii,ja,0
                db      0

                db      'COD po reverze|'
                db      'COD po reverzu|'
                db      'COD po rewersie|'
                db      'DO aft. reverse|'
                db      'NAI reverz.utan|'
                ;db      'COD po reverze',0
                db      0

                db      'C otvarania dv.|'
                db      'C otevirani dv.|'
                db      'Cz.otwier.drzwi|'
                db      'Doors open|'
                db      'Ajto nyitas.idej|'
                ;db      vvv,r,ee,mm,ja,' ',oo,tt,kk,r,tz,vv,aa,nn,ii,ja,0
                db      0

                db      'C zatvarania dv.|'
                db      'C zavirani dv.|'
                db      'Czas zamyk.drzwi|'
                db      'Doors close|'
                db      'Ajto zarasi idej|'
                ;db      vvv,r,ee,mm,ja,' ',zz,aa,kk,r,ii,vv,aa,nn,ii,ja,0
                db      0

                db      'Odchod do park.|'
                db      'Cas do zapark.|'
                db      'Jazda do park.|'
                db      'Go park after|'
                db      'A parkolo allom.|'
                ;db      'Odchod do park.',0
                db      0

                db      'Doba jazdy|'
                db      'Doba jizdy|'
                db      'Czas jazdy|'
                db      'Longest ride|'
                db      'Menetido|'
                ;db      vvv,r,ee,mm,ja,' ',ee,zz,dd,ii,0
                db      0

                db      'Oneskorenie A+B|'
                db      'Zpozdeni zast.|'
                db      'Opoznienie A+B|'
                db      'A+B stop delay|'
                db      'Kesese A+B|'
                ;db      'Oneskorenie A+B',0
                db      0

                db      'Svetlo|'
                db      'Svetlo|'
                db      'Swiatlo|'
                db      'Turn off light|'
                db      'Vilagitas ideje|'
                ;db      vo,ss,vv,ee,ssc,ee,nn,ii,ee,0
                db      0

                db      'Hviezda/trojuhol|'
                db      'Hvezda/trojuhel|'
                db      'Gwiazda/trojkat|'
                db      'Star/triangle|'
                db      'Csillag/delta|'
                ;db      vz,vv,ee,zz,dd,aa,'/',tt,r,ee,uu,gg,oo,ll,0
                db      0

                db      'Prednost kabiny|'
                db      'Prednost kabiny|'
                db      'Pierszens.kabin|'
                db      'Wait for cabin|'
                db      'Kabin elsobbsege|'
                ;db      vp,r,ee,ii,mm,uu,ssc,ee,tt,ss,tt,vv,oo,0
                db      0

                db      'C vyp. rele jaz.|'
                db      'C vyp. rele jiz.|'
                db      'C wyl. prek.jaz.|'
                db      'Turn off ride r.|'
                db      'Rel.jar.kikapcs.|'
                ;db      'C vyp. rele jaz.',0
                db      0

                db      'Cas kruz. 1',0
                db      'Cas kruz. 2',0

posch_text:     db      ' # VypDveMagRch|'
                db      ' # VypDveMagRch|'
                db      ' # WylDrzMagPrd|'
                db      ' # On?DorMagSpd|'
                db      ' # B/KAjtMagSeb|'
                ;db      ' # ',vvv,tz,kk,vd,vv,ee,vm,aa,gg,vd,aa,ll,0
                db      0

vyp_str:        db      ' - ',0
                db      'Vyp|Vyp|Wyl|Off|Ki',0 ;|',vvv,tz,kk,0

dve_str:        db      ' A ',0
                db      ' B ',0
                db      'A+B',0
                db      '???',0

kra_str:        db      ' 0 ',0
                db      ' 1 ',0
                db      ' 2 ',0
                db      '???',0

rych_str:       db      'Vys|Vys|Wys|Hig|Nag',0 ;|',vvv,tz,ss,0
                db      'Str|Str|Srd|Med|Koz',0 ;|',vs,r,ee,0
                db      'Niz|Niz|Nis|Low|Ala',0 ;|',vn,ii,zz,0
                db      '???',0

vypis_text:     db      '  Posch  Vypis|'
                db      '  Posch  Indik.|'
                db      '  Przyst  Opis|'
                db      '  Floor   Text|'
                db      '  Emelet  Text|'
                ;db      '  ',ve,tt,aa,zzz,'  ',vz,oo,bb,r,aa,zz,0
                db      0

ink_text:       db      'Poschodie|Poschodi|Przystanek|Floor|Emelet',0 ;|',ve,tt,aa,zzz,0

gsm_text1:      db      'Miesto|Misto|Miast|Location|Hely',0 ;|Miesto',0

gsm_text2:      db      'Cislo |Cislo |Numera |Number |Szamot ',0 ;|Cislo ',0

p_z_text1:      db      'Naozaj ulozit',n,'param do FLASH?|'
                db      'Ulozit data',n,'do FLASH?|'
                db      'Zapisac paramet-ry do FLASH?|'
                db      'Really store',n,'params to FLASH?|'
                db      'Really store',n,'params to FLASH?|'
                ;db      vch,oo,ccc,ee,sss,' ',zz,aa,pp,ii,ss,aa,tt,mz,n,dd,oo,' FLASH?',0
                db      0

p_z_text2:      db      'Zapisujem...|Zapis...|Zapis...|Writing...|Irasa...',0 ;|',vp,ii,sss,ee,mm,'...',0

p_z_text3:      db      'Parametre boli',n,'ulozene do FLASH|'
                db      'Data byla',n,'zapsana v FLASH|'
                db      'Parametry zapi-',n,'sane w FLASH|'
                db      'Parameters were',n,'stored in FLASH|'
                db      'Parameters were',n,'stored in FLASH|'
                ;db      vch,aa,r,aa,sss,oo,'-',zz,aa,pp,ii,ss,aa,nn,oo,0
                db      0

p_z_text4:      db      'Chyba pri zapise','parametrov|'
                db      'Chyba pri zapise','parametru|'
                db      'Bled zapisu',n,'parametrow|'
                db      'Error writing',n,'parameters|'
                db      'Error writing',n,'parameters|'
                ;db      'Chyba pri zapise','parametrov',0
                db      0

d_p_text1:      db      'Naozaj nahrat',n,'default param?|'
                db      'Opravdu nahrat',n,'vychozi hodnoty?|'
                db      'Really reset to',n,'default params?|'
                db      'Really reset to',n,'default params?|'
                db      'Really reset to',n,'default params?|'
                ;db      vch,oo,ccc,ee,sss,' ',zz,aa,pp,ii,ss,aa,tt,mz,n,dd,ee,ff,aa,uu,ll,tt,'?',0
                db      0

d_p_text2:      db      'Parametre su',n,'nahrate v RAM|'
                db      'Parametry jsou',n,'ulozeny v RAM|'
                db      'Parametry zosta-ly zapis. w RAM|'
                db      'Parameters are',n,'stored in RAM|'
                db      'Parameters are',n,'stored in RAM|'
                ;db      vp,aa,r,aa,mm,ee,tt,ee,r,n,zz,aa,pp,ii,ss,aa,nn,' ',vv,' RAM',0
                db      0

c_p_text0:      db      'Naozaj kopirovat','program?|'
                db      'Opravdu kopiro- ','vat program?|'
                db      'Skopiowac',n,'program?|'
                db      'Really copy',n,'program?|'
                db      'Really copy',n,'program?|'
                ;db      'Really copy',n,'program?',0
                db      0

c_p_text1:      db      'Zapisujem...|'
                db      'Zapis...|'
                db      'Pismie...|'
                db      'Writing...|'
                db      'Writing...|'
                ;db      vz,aa,pp,ii,ss,tz,vv,aa,ee,mm,'...',0
                db      0

c_p_text2:      db      'Pamate sa lisia|'
                db      'Kopirov. selhalo|'
                db      'Pamieci sa',n,'roznia|'
                db      'Memories are',n,'not identical|'
                db      'Memories are',n,'not identical|'
                ;db      vp,aa,mm,ja,tt,mz,' ',nn,ee,ss,oo,gg,ll,aa,ss,'.',0
                db      0

c_p_text3:      db      'Pamate su zhodne|'
                db      'Kopirovani OK|'
                db      'Pamieci sa',n,'identyczne|'
                db      'Memories are',n,'identical|'
                db      'Memories are',n,'identical|'
                ;db      vp,aa,mm,ja,tt,mz,' ',ss,oo,gg,ll,aa,ss,nn,oo,0
                db      0

t_g_text:       db      'Signal:',0

test_list:      db      'A6',0
                db      'A7',0
                db      'A8',0
                db      'A9',0
                db      'A10',0
                db      'A11',0
                db      'A12',0
                db      'A13',0

                db      'A14',0
                db      'A15',0
                db      'A16',0
                db      'A17',0
                db      'A18',0
                db      'A19',0
                db      'A20',0
                db      'A21',0

                db      'A1',0
                db      'A2',0
                db      'A3',0
                db      'A4',0
                db      'R',0
                db      'S',0
                db      'T',0
                db      'A5',0

                db      'CAN8',0
                db      'CAN7',0
                db      'CAN6',0
                db      'CAN5',0
                db      'CAN4',0
                db      'CAN3',0
                db      'CAN2',0
                db      'CAN1',0

                db      'CAN9',0
                db      'A',0
                db      'B',0
                db      'C',0
                db      'DIR',0
                db      'TOG',0
