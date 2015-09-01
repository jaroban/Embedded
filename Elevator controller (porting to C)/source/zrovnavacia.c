#include <global.h>
/*
bool zj_termistor_safety()
{
    if(IN_TERMISTOR)
    {
        dx_zastav_dvere();
        blokuj_volby = 1;
        vymaz_volby();
        pridaj_chybu(E_TERMISTOR);
        zapis_chybu(E_TERMISTOR);
        smer = BOTH_BLINK;
        while(IN_TERMISTOR) wait();
        smer = DOLE;
        zrus_chybu(E_TERMISTOR);
        blokuj_volby = 0;
        return TRUE;
    }
    return 0;
}

void zrovnavacia_jazda()
{
    // init
    
    
    // rucne dvere, vazenie 10% -> cakat na kabinovu volbu
    while((AKE_DVERE2 == RUCNE) && VAZENIE_10 && !je_kabinova_volba()) wait();
    
    // ...
    
    if((AKA_NAHRADA != 0) && je_len_dolny())


}
*/