; version 4.0

moze_kabina_combo:
                call    moze_kabina
                jz      mkp_ret
moze_kabina_p:  jnb     je_ranny_program,mk_1
                call    hlavna_stanica
                jz      mk_1
                dec     a
                cjne    a,liftpos,mk_1
                xrl     a,r4
mkp_ret:        ret

moze_kabina:    mov     c,blokuj_volby
                orl     c,je_posledna_jazda
                jc      mk_0
                mov     a,je_poziarna_jazda
                xrl     a,#1
                jz      mk_0
                xrl     a,#1 xor 3
                jz      mk_0
if maximalny_pocet_kabinovych_volieb
                call    kolko_je_kabinovych
                clr     c
                subb    a,#maximalny_pocet_kabinovych_volieb+1
                jnc     mk_0
endif
if ziadne_kabinove_bez_10
                call    je_vazenie_10
                jz      mk_skip0
                jnb     ovazenie_10,mk_0
mk_skip0:
endif
if jedna_volba_v_nezavislej
                jnb     je_nezavisla_jazda,mk_skip_1
                jb      uz_mame_volbu,mk_0
mk_skip_1:
endif
                call    ake_riadenie
                jnb     acc.0,mk_skip2
                jb      uz_mame_volbu,mk_0
                sjmp    mk_1
mk_skip2:       call    aka_nahrada
                cjne    a,#2,mk_1
                jnb     a3,mk_0
                jb      uz_mame_volbu,mk_0
mk_1:           mov     a,#0ffh
                ret
mk_0:           clr     a
                ret

moze_dole_combo:
                call    moze_dole
                jz      mdp_ret
moze_dole_p:    call    je_blok
                jz      mdp_1
                call    cislo_v_skupine
                cjne    a,#1,mdp_normal
                ; i am elevator #1
                call    hlavna_stanica
                jz      mdp_normal
                dec     a
                cjne    a,ar4,mdp_normal
                ; call is in main floor -> take it
                sjmp    mdp_1
mdp_normal:     mov     a,others
                jz      mdp_1
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_locations
                mov     r0,#8
mdp_lp:         movx    a,@dptr
                cjne    a,ar4,mdp_next
                ; there is another elevator in said floor
                ; we should return 0, now check the exception
                xrl     a,liftpos
                jz      mdp_1   ; call + other elevator + us in same floor -> take call as no travel is involved
mdp_0:          clr     a
                ret
mdp_next:       inc     dptr
                djnz    r0,mdp_lp
mdp_1:          mov     a,#0ffh
mdp_ret:        ret

moze_dole:      mov     a,je_poziarna_jazda
                jnz     md_0
                jb      blokuj_volby,md_0
                jb      zakaz_vonkajsie,md_0
                jb      zakaz_vonkajsie0,md_0
                jb      je_prednostna_jazda,md_0
                jb      je_ranny_program,md_0
                jb      je_nezavisla_jazda,md_0
                jb      je_posledna_jazda,md_0
                call    ake_riadenie
                jnb     acc.0,md_1
                jb      uz_mame_vonkajsiu_volbu,md_0
md_1:           mov     a,#0ffh
                ret
md_0:           clr     a
                ret

moze_hore_combo:
                call    moze_hore
                jz      mhp_ret
moze_hore_p:    call    je_blok
                jz      mhp_1
                call    cislo_v_skupine
                cjne    a,#1,mhp_normal
                ; i am elevator #1
                call    hlavna_stanica
                jz      mhp_normal
                dec     a
                cjne    a,ar4,mhp_normal
                ; call is in main floor -> take it
                sjmp    mhp_1
mhp_normal:     mov     a,others
                jz      mhp_1
                mov     dps,#0
                mov     dpx,#0
                mov     dptr,#g_locations
                mov     r0,#8
mhp_lp:         movx    a,@dptr
                cjne    a,ar4,mhp_next
                ; there is another elevator in said floor
                ; we should return 0, now check the exception
                xrl     a,liftpos
                jz      mhp_1   ; call + other elevator + us in same floor -> take call as no travel is involved
mhp_0:          clr     a
                ret
mhp_next:       inc     dptr
                djnz    r0,mhp_lp
mhp_1:          mov     a,#0ffh
mhp_ret:        ret

moze_hore:      mov     a,je_poziarna_jazda
                jnz     mh_0
                jb      blokuj_volby,mh_0
                jb      zakaz_vonkajsie,mh_0
                jb      zakaz_vonkajsie0,mh_0
                jb      je_prednostna_jazda,mh_0
                jb      je_obed_program,mh_0
                jb      je_ranny_program,mh_0
                jb      je_nezavisla_jazda,mh_0
                jb      je_posledna_jazda,mh_0
                call    ake_riadenie
                jnb     acc.0,mh_1
                jb      uz_mame_vonkajsiu_volbu,mh_0
mh_1:           mov     a,#0ffh
                ret
mh_0:           clr     a
                ret

del_volby:      clr     uz_mame_volbu
                clr     uz_mame_vonkajsiu_volbu
                clr     a
                mov     r0,#call_table
                mov     r1,call_no
dy_lp1:         mov     @r0,a
                inc     r0
                djnz    r1,dy_lp1
                ret

del_kabinove:   clr     uz_mame_volbu
                mov     r0,#call_table
                mov     r1,call_no
dk_lp1:         mov     a,@r0
                anl     a,#11101110b
                mov     @r0,a
                inc     r0
                djnz    r1,dk_lp1
                ret

del_vonkajsie:  mov     r0,#call_table
                mov     r1,call_no
dvo_lp1:        mov     a,@r0
                anl     a,#10011001b
                mov     @r0,a
                inc     r0
                djnz    r1,dvo_lp1
                ret

add_kabina_sft: mov     a,je_poziarna_jazda
                cjne    a,#2,aks_skip1
                jnb     uz_mame_volbu,aks_skip1
                call    del_kabinove
aks_skip1:      setb    uz_mame_volbu
if na_jednom_poschodi_dve_volby
                mov     a,r4
                clr     c
                subb    a,floor_no
                jc      aks_original
                jz      aks_dvere_a
                orl     mozu_dvere_ab,#2
                sjmp    aks_dvere_drain
aks_dvere_a:    orl     mozu_dvere_ab,#1
aks_dvere_drain:
                mov     r0,#call_table+na_ktorom_poschodi_dve_volby
                mov     a,@r0
                orl     a,#00000001b
                mov     @r0,a
aks_original:
endif
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                orl     a,#00010001b
                mov     @r0,a
                ret

del_kabina_sft: clr     uz_mame_volbu
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                anl     a,#11101110b
                mov     @r0,a
                ret

add_dole_sft:   setb    uz_mame_vonkajsiu_volbu
if na_jednom_poschodi_dve_volby
                mov     a,r4
                clr     c
                subb    a,floor_no
                jc      ads_original
                jz      ads_dvere_a
                orl     mozu_dvere_ab,#2
                sjmp    ads_dvere_drain
ads_dvere_a:    orl     mozu_dvere_ab,#1
ads_dvere_drain:
                mov     r0,#call_table+na_ktorom_poschodi_dve_volby
                mov     a,@r0
                orl     a,#00000010b
                mov     @r0,a
ads_original:
endif
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                orl     a,#00100010b
                mov     @r0,a
                ret

del_dole_sft:   clr     uz_mame_vonkajsiu_volbu ;;;;;; not exact
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                anl     a,#11011101b
                mov     @r0,a
                jmp     double_click_reset_dole

add_hore_sft:   setb    uz_mame_vonkajsiu_volbu
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                orl     a,#01000100b
                mov     @r0,a
                ret

del_hore_sft:   clr     uz_mame_vonkajsiu_volbu ;;;;;; not exact
                mov     a,#call_table
                add     a,r4
                mov     r0,a
                mov     a,@r0
                anl     a,#10111011b
                mov     @r0,a
                jmp     double_click_reset_hore

je_kabina:
if na_jednom_poschodi_dve_volby
                mov     a,r4
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     jk_original
                clr     a
                ret
jk_original:
endif
                mov     a,r4
                swap    a
                rl      a
                anl     a,#3
                add     a,#rd_kabina
                mov     r0,a
                mov     a,r4
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                ret

je_kabina_o:    clr     a
                mov     dps,a
                mov     dpx,a
                
                mov     a,r4
                anl     a,#7
                call    get_nrm_mask
                mov     r0,a
                
                mov     a,r4
                swap    a
                rl      a
                anl     a,#3
                add     a,#low(rd_kabina_o)
                mov     dpl,a
                clr     a
                addc    a,#high(rd_kabina_o)
                mov     dph,a
                movx    a,@dptr
                anl     a,r0
                ret       

je_dole:
if na_jednom_poschodi_dve_volby
                mov     a,r4
                xrl     a,#na_ktorom_poschodi_dve_volby
                jnz     jd_original
                clr     a
                ret
jd_original:
endif
                mov     a,r4
                swap    a
                rl      a
                anl     a,#3
                add     a,#rd_dole
                mov     r0,a
                mov     a,r4
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                ret

je_hore:        mov     a,r4
                swap    a
                rl      a
                anl     a,#3
                add     a,#rd_hore
                mov     r0,a
                mov     a,r4
                anl     a,#7
                call    get_nrm_mask
                anl     a,@r0
                ret
