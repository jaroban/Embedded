
jazyk           equ     2       ; 0 = sk, 1 = pl, 2 = hu

if jazyk eq 0

txt_pretazenie: db      'Pretazenie  ',0
txt_porucha:    db      'Porucha  ',0

elseif jazyk eq 1

txt_pretazenie: db      'Przeciazone  ',0
txt_porucha:    db      'Awaryja  ',0

elseif jazyk eq 2

txt_pretazenie: db      'Tulterhelt  ',0
txt_porucha:    db      'Hiba  ',0

endif
