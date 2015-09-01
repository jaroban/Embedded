; version 1.0

char_table:     db      11111b
                db      10001b
                db      10001b
                db      10001b
                db      10001b
                db      10001b
                db      11111b
                db      00000b
; 1
                db      00100b
                db      00100b
                db      00100b
                db      00100b
                db      10101b
                db      01110b
                db      00100b
                db      00000b
; 2
                db      00100b
                db      01110b
                db      10101b
                db      00100b
                db      00100b
                db      00100b
                db      00100b
                db      00000b
; 3
                db      00100b
                db      01110b
                db      10101b
                db      00100b
                db      10101b
                db      01110b
                db      00100b
                db      00000b
; 4
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
; 5
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
; 6
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
; 7
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b
                db      00000b

init_text:      db      '   SUNTEC 1.3',n
                db      '   2007-03-31',0

cas_prip_txt:   db      'Cas na pripravu:',0
cas_chlad_txt:  db      'Cas chlazeni:',0
cas_zmena_txt:  db      'Casy se meni o:',0
chr_zona_txt:   db      'Chranena zona',0
zad_heslo_txt:  db      'Zadejte heslo:',0
nesp_heslo_txt: db      'Nespravne heslo',0
cas_celk_txt:   db      'Celkovy cas 1:',0
vym_cas_txt:    db      'Vymazat celkovy',n
                db      '      cas 1',0
mazem_cas_txt:  db      'Mazem celkovy',n
                db      '    cas 1',0
cas_celk_txt:   db      'Celkovy cas 2:',0
vym_cas_txt:    db      'Vymazat celkovy',n
                db      '      cas 2',0
mazem_cas_txt:  db      'Mazem celkovy',n
                db      '    cas 2',0
zmena_hesla_txt:
                db      'Zmena hesla',0
nove_heslo_txt: db      'Nove heslo:',0
navrat_txt:     db      '   Navrat do',n
                db      ' hlavniho menu',0

mm_text:        db      'Prip Opal  Chlad',0
                db      'Priprava        ',0
                db      '   Opalovani    ',0
                db      '       Chlazeni ',0

mm_blank:       db      '                ',0

delta_text:     db      '   1 sekundu  ',0
                db      '   10 sekund  ',0
                db      '   30 sekund  ',0
                db      '   1 minutu   ',0
                db      '    5 minut   ',0

delta_table:    db      0,1
                db      0,10
                db      0,30
                db      1,0
                db      5,0
