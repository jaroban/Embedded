; version 1.0

vypis_table:    db      '---9-8-7-6-5-4-3-2-1'
                db      ' P 1 2 3 4 5 6 7 8 9'
                db      '10111213141516171819'
                db      '20212223242526272829'
                db      '30313233343536373839'

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
                db      'P',1100111b
                db      0

pol_dig0:       db      7,6,28,29,34,4,5
pol_dig1:       db      13,0,21,22,23,12
pol_dir:        db      20,14,15 ; h,h,d
