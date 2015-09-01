#define E_DOROVNAVANIE      1       // led 1
#define E_NPK               2       // led 2
#define E_KR                4       // led 3
#define E_DOROVNAVANIE2     8       // led 4
#define E_POSOBENIE_NPK     16 | 15

                                    // ledky:
                                    // 4 3 2 1
#define PO_RESETE           0       // 0000
#define V_STANICI           1       // 0001
#define V_STANICI_LOOP      2       // 0010
#define DOROVNAVANIE        3       // 0011
#define DOROVNAVANIE_WAIT   4       // 0100
#define DOROVNAVANIE_LOOP   5       // 0101
#define DOROVNAVANIE_CHECK  6       // 0110
#define JAZDA               7       // 0111
#define JAZDA_LOOP          8       // 1000
#define MIMO_STANICE        9       // 1001
#define MIMO_STANICE_LOOP   10      // 1010
//#define SPANOK              11      // 1011
//#define SPANOK_LOOP         12      // 1100
#define CHYBA               13      // 1101
#define CHYBA_LOOP          14      // 1110

u8 stav;

void fsm_init()
{
    k1 = 0; 
    k2 = 0; 
    k3 = 1;
    stav = PO_RESETE;
    error = 0;
    t_npk = 1.00 SEKUNDA;
    t_kr  = 2.00 SEKUNDY;
    t_dorovnavanie = 1.00 SEKUNDA;  // used to 
}

void chyba(u8 e)
{
    stav = CHYBA;
    error = e;
}

void decide_where_we_are()
{
    if(dor) { stav = DOROVNAVANIE; }
    else if(jazda && bo) { stav = JAZDA; }
    else if(ab && c) { stav = V_STANICI; }
    else { stav = MIMO_STANICE; }
}

void fsm()
{
    // always
    if(stav != CHYBA_LOOP) { k4 = npk; }
    else                   { k4 = 0; }

    if( (stav == V_STANICI_LOOP) ||
        (stav == JAZDA_LOOP) ||
        (stav == MIMO_STANICE_LOOP))
    {
        if(k2 == npk) { t_npk = 1.00 SEKUNDA; }
        else if(t_npk == 0) { chyba(E_NPK); }
    }
    else t_npk = 1.00 SEKUNDA;

    if(k2 == kr) { t_kr  = 2.00 SEKUNDY; } else if(t_kr == 0) { chyba(E_KR); }
    
    switch(stav)
    {
        case PO_RESETE:
            // citat vstupy az po nejakom case!
            if(t_dorovnavanie == 0)
            {
                // po resete zistit v akom sme stave
                decide_where_we_are();
            }
            else { t_dorovnavanie--; }
            break;
        
        case V_STANICI:
            stav = V_STANICI_LOOP;
            k1 = 0;
            k2 = 0;
            //t_sleep = 30 SEKUND;
            break;
            
        case V_STANICI_LOOP:
            //if(jazda || !bo) { t_sleep = 30 SEKUND; }
            
            if(jazda && bo) { stav = JAZDA; }
            else if(dor) { stav = DOROVNAVANIE; }
            break;

        case DOROVNAVANIE:
            stav = DOROVNAVANIE_WAIT;
            k1 = 1;
            k2 = 0;
            t_dorovnavanie = 2.00 SEKUNDY;
            if(!ab || !c /* || kr */) { chyba(E_DOROVNAVANIE); }
            break;
            
        case DOROVNAVANIE_WAIT:
            if(npk)
            {
                stav = DOROVNAVANIE_LOOP;
                t_dorovnavanie = 15.00 SEKUNDA;
            }
            else if(t_dorovnavanie == 0) { chyba(E_DOROVNAVANIE2); }
            break;
        
        case DOROVNAVANIE_LOOP:
            if(!dor)
            {
                stav = DOROVNAVANIE_CHECK;
                t_dorovnavanie = 2.00 SEKUNDY;
            }
            else if(t_dorovnavanie == 0) { chyba(E_DOROVNAVANIE); }
            else if(!ab || !c) { chyba(E_POSOBENIE_NPK); }
			else if(!npk) { chyba(E_NPK); }
            break;
            
        case DOROVNAVANIE_CHECK:
            k1 = 0;
			if(!ab || !c) { chyba(E_POSOBENIE_NPK); }
            else if(kc) { stav = V_STANICI; }
            else if(t_dorovnavanie == 0) { chyba(E_DOROVNAVANIE); }
            break;
            
        case MIMO_STANICE:
            stav = MIMO_STANICE_LOOP;
            t_delay_k2 = 1.00 SEKUNDY;
            break;

        case MIMO_STANICE_LOOP:
            if(t_delay_k2 == 0) { k2 = 0; }
            if(jazda && bo) { stav = JAZDA; }
            break;

        case JAZDA:
            stav = JAZDA_LOOP;
            k2 = 1;
            break;

        case JAZDA_LOOP:
            // po 2 s musi byt npk == 0
            if(dor) { stav = DOROVNAVANIE; }
            else if(!jazda || !bo)
            {
                if(ab && c)
                {
                    stav = V_STANICI;
                }
                else
                {
                    // mimo stanice
                    stav = MIMO_STANICE;
                }
            }
            break;

        case CHYBA:
            stav = CHYBA_LOOP;
            k1 = 0;
            k2 = 0;
            k3 = 0;
            eeprom_write(0, 0xaa);  // any value other than 0x55
            break;
    
        case CHYBA_LOOP:
            //if(reset) fsm_init();
            break;
            
        default:
            fsm_init();
            break;
    }
}
