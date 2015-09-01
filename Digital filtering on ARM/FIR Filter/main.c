/*
    Code implementing a FIR filter on the MCB2130 board
    ---------------------------------------------------
    Author: Ban & Varchola     Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.08                Last revision: May 16 2006

    Revision history:
    1.08
        added c_coef
    1.07
        changed from int to short
    1.06
        added INPUT_CHANNEL selection
    1.05
        changed the way samples are output to DAC
        changed FIR coefficients
        changed sampling frequency to 48kHz
    1.04
        reversed inputs, outputs, coefs
    1.03
        added buf_size and ncoefs to generalize sim.ini
    1.02
        added multiple block filterings to test functionality
    1.01
        renamed BUF to BUF_SIZE
        added comments + this header
        removed a warning (assignment in condition - buffer = 1 - buffer)
    1.00
*/
#include <LPC214x.H>                        /* LPC213x definitions            */
#include "filter.h"
#include "kemt_board.h"

#define CPU_CLK 60000000                    /* CPU clock                      */
#define PCLK CPU_CLK                        /* peripherial clock = CPU/VPBDIV */
#define AD9833_CLK 25000000                 /* ref. clock of AD9833 (DDS)     */

#define AUDIO_SAMPLING 48000
#define TIM_TICK (PCLK/AUDIO_SAMPLING)  

#define INPUT_CHANNEL 1                     /* AD0.1, AD0.2, AD0.3            */
#define BUF_SIZE 512                        /* Size of buffers used           */
#define NCOEFS 149                          /* # of FIR filter coefficients   */

int ncoefs = NCOEFS;                        /* for routines in sim.ini        */
int buf_size = BUF_SIZE;

fir_state state;                            /* FIR filter state variable      */
const short coeffs[] = {                    /* FIR filter coefficients        */
  #include "c_1_15.txt"                     /*  in reverse order              */
};
const int c_coef = {
  #include "c_coef.txt"       
};
short history[2*(NCOEFS-1)];                /* FIR delay line requires space  */
                                            /*  for 2x (# of coefs - 1)       */
short inputs0[BUF_SIZE];                    /* first buffer                   */
short outputs0[BUF_SIZE];
volatile int flag0;                         /* flag from interrupt telling    */
                                            /*  main to process this buffer   */
short inputs1[BUF_SIZE];                    /* second buffer                  */
short outputs1[BUF_SIZE];
volatile int flag1;                         /* flag for 2nd buffer            */

int ind;                                    /* buffer counter (0-BUF_SIZE-1)  */
int buffer;                                 /* active buffer (0 or 1)         */
short *in;                                  /* input data wr pointer          */
short *out;                                 /* output data rd pointer         */
short sample;                               /* variable used inside int       */

/* Timer Counter 0 Interrupt executes @ DATA_FREQ Rate                        */
__irq void tc0 (void)  {

  AD0CR &= ~0x01000000;                     /* Stop A/D Conversion            */
  sample = (AD0DR1 & 0xFFC0) - 0x8000;       /* Extract AIN0 Value (1.15)      */
  AD0CR |= 0x01000000;                      /* Start new A/D Conversion       */
 
  *in++ = sample;                           /* store sample from ADC          */
  sample = *out++;                          /* load sample for DAC            */
  
  sample = (sample * c_coef) >> 15;         /* multiply by c_coef             */
                       
  DACR = ((sample + 0x8000) & 0xFFC0) | 0x10000;  /*  write data to DAC       */

  if(!--ind) {                              /* if current buffer is full...   */
    while((buffer && flag1) || (!buffer && flag0)) ;
                              /* main hasn't filtered the other buffer yet!!! */
    ind = BUF_SIZE;                         /* start rd/wr from start of buf. */
    buffer = 1 - buffer;                    /* switch to next buffer          */
    if(buffer) {                            /* if the new buffer is buffer 1  */
      flag0 = 1;                            /* tell main to process buffer 0  */
      in = inputs1;                         /* in -> buffer 1                 */
      out = outputs1;                       /* out -> buffer 1                */
    } else {                                /* if the new buffer is buffer 0  */
      flag1 = 1;                            /* tell main to process buffer 1  */
      in = inputs0;                         /* in -> buffer 0                 */
      out = outputs0;                       /* out -> buffer 0                */
    }
  }

  T0IR = 1;                                 /* Clear interrupt flag           */
  VICVectAddr = 0;                          /* Acknowledge Interrupt          */
}

/* clear the FIR buffers, setup interrupt variables, setup FIR state          */
void init_filtering(void) {
  int i;

  for(i = 0; i < BUF_SIZE; i++) {           /* zero input and output buffers  */
    inputs0[i] = 0; outputs0[i] = 0;
    inputs1[i] = 0; outputs1[i] = 0;
  }

  buffer = 0;                               /* start with buffer 0            */
  ind = BUF_SIZE;
  in = inputs0;
  out = outputs0;
  flag0 = flag1 = 0;                        /* clear flags                    */
  
  fir_init(coeffs, history, NCOEFS, &state); /* set up a FIR filter           */
}

/* init A/D and D/A conversion                                                */
void init_ad_da (void) { 
  PINSEL1 = 0x15080000;                     /* Select DAC (AOUT) & AIN1       */
  AD0CR   = 0x00200400 + (1 << INPUT_CHANNEL); /* ADC1: 10-bit AIN1 @ 3MHz    */ 
  AD0CR  |= 0x01000000;                     /* Start A/D Conversion           */
  DACR    = 0x00008000;                     /* DAC Output set to Middle Point */
}
 
/* Setup the Timer Counter 0 Interrupt                                        */
void init_timer (void) {
  T0MR0 = TIM_TICK - 1;                       
  T0MCR = 3;                                /* Interrupt and Reset on MR0     */
  T0TCR = 1;                                /* Timer0 Enable                  */
  VICVectAddr0 = (unsigned long) tc0;       /* set interrupt vector in 0      */
  VICVectCntl0 = 0x20 | 4;                  /* use it for Timer 0 Interrupt   */
  VICIntEnable = 0x00000010;                /* Enable Timer0 Interrupt        */
}

int main(void) {                        

  init_filtering();
  /* perform test to see if FIR works properly                                */
  /* to output data: click the "save inputs" button here...                   */
  fir_block(inputs0, outputs0, 150, &state);
  fir_block(inputs0 + 150, outputs0 + 150, 50, &state);
  fir_block(inputs0 + 200, outputs0 + 200, 200, &state);
  fir_block(inputs0 + 400, outputs0 + 400, 112, &state);
  /* ... and click the "save outputs" button here                             */

  init_ad_da();                             /* set up A/D and D/A conversion  */
  init_filtering();                         /* initialize some variables      */
  init_timer();                             /* set up timer 0 interrupt       */

  start_pwm(5,500000,PWM_50_50,1,PCLK);  /* start PWM, SW CAP filter 50% duty */
  AD9833_spi0_init(1000000,PCLK);           /* SPI for AD9833                 */
  AD9833_power(OFF);                        /* Power off AD9833               */

  while(1) {                               
    if(flag0) {                                       /* if buffer 0 is full  */
      fir_block(inputs0, outputs0, BUF_SIZE, &state); /* filter it            */
      flag0 = 0;                                      /* and clear the flag   */
    }
    if(flag1) {                                       /* if buffer 1 is full  */
      fir_block(inputs1, outputs1, BUF_SIZE, &state); /* filter it            */
      flag1 = 0;                                      /* and clear the flag   */
    }
  }
}
