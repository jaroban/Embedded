@echo off
rem /DEFINE:je_poradie_faz
rem /DEFINE:smerove_sipky
asemw program.asm mb100_4.hex  mb100_4.lst  /DEFINE:doba_jazdy:80 /DEFINE:je_poradie_faz
asemw program.asm mb100_3.hex  mb100_3.lst  /DEFINE:doba_jazdy:80 /DEFINE:je_poradie_faz /DEFINE:je_zdochnutie 
asemw program.asm mb100_4s.hex mb100_4s.lst /DEFINE:doba_jazdy:80 /DEFINE:je_poradie_faz /DEFINE:jazda_ked_volba
pause