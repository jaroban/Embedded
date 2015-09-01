; version 4.0

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
                db      11111b
                db      11111b
                db      11111b
                db      11111b
                db      11111b
                db      00000b
                db      00000b

num_range:      db      2,no_of_floors
                db      0,255
                db      0,no_of_floors
                db      0,no_of_floors
                db      0,255

                db      0,7
                db      0,no_of_floors
                db      0,100
                db      0,100
                db      0,255

                db      0,255
                db      1,5
                db      1,5
                db      0,255
                db      0,no_of_floors
                
                db      0,no_of_floors
                db      0,no_of_floors
                db      0,no_of_floors
                db      0,no_of_floors

no_vypis_special        equ     4+9+8
no_vypis_strings        equ     no_vypis_special+9+40

vypis_str_table:
                db      '  --ZJ P'              ; 0-3
                db      ' AA1 B EE1 GG1 F N'    ; 4-12
                db      'SASSS1 R P H??RV'      ; 13-20
                db      '-9-8-7-6-5-4-3-2-1'    ; 21-29
                db      ' 0 1 2 3 4 5 6 7 8 9'  ; 30-39
                db      '10111213141516171819'  ; 40-49
                db      '20212223242526272829'  ; 50-59
                db      '30313233343536373839'  ; 60-69

lcom_table:     db      40,56,49,54
                db      41,42,43,44,45,46,47,48,49
                db      50,51,52,53,54,55,56,62
                db      29,28,27,26,25,24,23,22,21
                db       0, 1, 2, 3, 4, 5, 6, 7, 8, 9
                db      10,11,12,13,14,15,16,17,18,19

bepol_table:    db      17,16,17,22
                db      17,17,17,17,17,17,17,17,17
                db      17,17,18,17,17,17,17,17
                db       1, 3, 5, 7, 9,11,13,15,19
                db      23,24,25,26,27,28,29,30,31,32
                db      33,34,35,36,37,38,39,40,41,42
                db      43,44,45,46,47,48,49,50,51,52
                db      53,54,55,56,57,58,59,60,61,62
                
xlat_table:     db      '0',1111110b
                db      '1',0110000b
                db      '2',1101101b
                db      '3',1111001b
                db      '4',0110011b
                db      '5',1011011b
                db      '6',1011111b
                db      '7',1110010b
                db      '8',1111111b
                db      '9',1111011b
                db      ' ',0000000b
                db      '-',0000001b
                db      'Z',1101101b
                db      'J',0111100b
                db      'P',1100111b
                db      'A',1110111b
                db      'B',0011111b
                db      'E',1001111b
                db      'G',1011110b
                db      'F',1000111b
                db      'S',1011011b
                db      'R',0000101b
                db      'H',0110111b
                db      '?',1100101b
                db      'V',0011100b
                db      0

pol_dig0:       db      7,6,28,29,34,4,5
pol_dig1:       db      13,0,21,22,23,12
pol_dir1:       db      20,14,15 ; h,h,d

pol_ascii0:     db      8,9,10,11,16,17,18,19
pol_ascii1:     db      24,25,26,27,30,31,32,33

pol_pretazenie  equ     1
pol_porucha     equ     2
pol_gong        equ     3

default_enums:  db      0,0,0,0,0,1,2,0,0,1     ; 0-9           (moznosti)
                db      0,1,0,0,0,0,0,0,0,0     ; 10-19
                db      0,0                     ; 20-21
                db      default_language        ; 22
                db            0,0,2,2,0,0,0     ; 23-29
                db      0,0,0,0,0,0,0,0,0,0     ; 30-39
                db      0,0,0,0,0,0,0,0,0,0     ; 40-49
                db      3,0,0,0,0,0,0,0,0,0     ; 50-59
                db      0,0,0,0,0,0,0,0,0,0     ; 60-69
                db      0,0,0,0,0,0,0,0,0,0     ; 70-79
                db      0,0,0,0,0,0,0,0,0,0     ; 80-89
                db      0,0,0,0,0,0,0,0,0,0     ; 90-99
                db      0,0,0,0,0,0,0,0,0,0     ; 100-109
                db      0,0,0,0,0,0,0,0,0,0     ; 110-119

default_nums:   db      6,4,0,0,0               ; 0-4           (cisla)
                db      1,0,0,0,0               ; 5-9
                db      0,1,1,0,0               ; 10-14
                db      0,0,0,0,0               ; 15-19

default_times:  db      0,4,0                   ; 0             (casy)
                db      0,3,0                   ; 1
                db      0,10,0                  ; 2
                db      0,10,0                  ; 3
                db      0,0,0                   ; 4
                db      0,30,0                  ; 5
                db      0,0,0                   ; 6
                db      0,10,0                  ; 7
                db      0,0,0                   ; 8
                db      0,3,0                   ; 9
                db      0,0,0                   ; 10
                db      0,0,0                   ; 11
                db      0,0,0                   ; 12
                db      0,0,0                   ; 13
                db      0,0,0                   ; 14

default_vypisy: db      1                       ; (vypisy)
                db      31,32,33,34,35,36,37,38
                db      39,40,41,42,43,44,45,46
                db      47,48,49,50,51,52,53,54
                db      55,56,57,58,59,60,61,62
