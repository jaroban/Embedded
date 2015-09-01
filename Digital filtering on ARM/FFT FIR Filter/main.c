/*
    Code implementing a FIR FFT filter on the MCB2130 board
    -------------------------------------------------------
    Author: Ban & Varchola     Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.02                Last revision: May 23 2006

    Revision history:
    1.02
        fixed some issues in assembler
    1.01
        cleaned up code
    1.00
*/
#include <LPC214x.H>                        /* LPC213x definitions            */
#include "filter.h"
#include "kemt_board.h"

#define NULL ((void *) 0)
#define CPU_CLK 60000000                    /* CPU clock                      */
#define PCLK CPU_CLK                        /* peripherial clock = CPU/VPBDIV */
#define AD9833_CLK 25000000                 /* ref. clock of AD9833 (DDS)     */

#define AUDIO_SAMPLING 48000
#define TIM_TICK (PCLK/AUDIO_SAMPLING)  

#define INPUT_CHANNEL 1                     /* AD0.1, AD0.2, AD0.3            */
#define MEM_TOP 0x40008000                  /* top of RAM                     */
#define NCOEFS 149                          /* # of FIR filter coefficients   */
#define FFT_N 1024                          /* FFT_N > 2*NCOEFS!              */
#define LOG_FFT_N 10                        /* base 2 log of above value      */
#define FFT_N_2 (FFT_N/2)                   /* FFT_N / 2                      */
#define BUF_SIZE (FFT_N-NCOEFS+1)           /* Size of buffers used           */

int buf_size = BUF_SIZE;                    /* for routines in sim.ini        */

fir_fft_state state;                        /* FFT FIR filter state variable  */
const short coeffs[NCOEFS] = {              /* FIR filter coefficients        */
  #include "c_1_15.txt"                 
};
Complex *coefs_fft;                         /* FFT of FIR coeffs              */
Complex *result_fft;                        /* required to store FFT result   */ 
short trail[NCOEFS-1];                      /* overlap - add buffer           */

short buffer0[BUF_SIZE];                    /* first buffer                   */
volatile int flag0;                         /* flag from interrupt telling    */
                                            /*  main to process this buffer   */                                      
short buffer1[BUF_SIZE];                    /* second buffer                  */
volatile int flag1;                         /* flag for 2nd buffer            */

int ind;                                    /* buffer counter (0-BUF_SIZE-1)  */
int buffer;                                 /* active buffer (0 or 1)         */
short *ptr;                                 /* input data wr pointer          */
short sample;                               /* variable used inside int       */

/* Timer Counter 0 Interrupt executes @ DATA_FREQ Rate                        */
__irq void tc0 (void)  {

  sample = *ptr;                            /* load sample for DAC            */
                                         
  DACR = ((sample + 0x8000) & 0xFFC0) | 0x10000; /*  write data to DAC        */                     

  AD0CR &= ~0x01000000;                     /* Stop A/D Conversion            */
  sample = (AD0DR1 & 0xFFC0) - 0x8000;       /* Extract AIN0 Value             */
  AD0CR |= 0x01000000;                      /* Start new A/D Conversion       */
 
  *ptr++ = sample;                          /* store sample from ADC          */

  if(!--ind) {                              /* if current buffer is full...   */
    while((buffer && flag1) || (!buffer && flag0)) ;
                              /* main hasn't filtered the other buffer yet!!! */
    ind = BUF_SIZE;                         /* start rd/wr from start of buf. */
    buffer = 1 - buffer;                    /* switch to next buffer          */
    if(buffer) {                            /* if the new buffer is buffer 1  */
      flag0 = 1;                            /* tell main to process buffer 0  */
      ptr = buffer1;                        /* in -> buffer 1                 */
    } else {                                /* if the new buffer is buffer 0  */
      flag1 = 1;                            /* tell main to process buffer 1  */
      ptr = buffer0;                        /* out -> buffer 0                */
    }
  }

  T0IR = 1;                                 /* Clear interrupt flag           */
  VICVectAddr = 0;                          /* Acknowledge Interrupt          */
}

/* clear the FIR buffers, setup interrupt variables, setup FIR state          */
void init_filtering(void) {
  int i;

  for(i = 0; i < BUF_SIZE; i++) {           /* zero input and output buffers  */
    buffer0[i] = 0; buffer1[i] = 0;
  }

  buffer = 0;                               /* start with buffer 0            */
  ind = BUF_SIZE;
  ptr = buffer0;
  flag0 = flag1 = 0;                        /* clear flags                    */
  
  fir_fft_init(coeffs, coefs_fft, result_fft, trail, NCOEFS, FFT_N, \
               LOG_FFT_N, &state);          /* set up a FIR FFT filter        */
}

/* init A/D and D/A conversion                                                */
void init_ad_da (void) { 
  PINSEL1 = 0x15080000;                     /* Select DAC (AOUT) & AIN1, 2, 3 */
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

void init_mempool(void *pool, unsigned int size);
void *malloc(unsigned int size);
int *get_stack_top(void);

int main(void) {                        
  
  init_mempool(get_stack_top(), MEM_TOP - (int) get_stack_top());
  coefs_fft = malloc(FFT_N_2 * sizeof(Complex));
  result_fft = malloc(FFT_N * sizeof(Complex));
  while((coefs_fft == NULL) || (result_fft == NULL)) ; /* error allocating    */

  init_filtering();
  /* perform test to see if FIR FFT works properly                            */
  /* to output data: click the "save inputs" button here                      */
  fir_fft_block(buffer0, buffer0, BUF_SIZE, &state);
  fir_fft_block(buffer1, buffer1, BUF_SIZE, &state);
  /* ... and click the "save outputs" button here                             */

  init_ad_da();                             /* set up A/D and D/A conversion  */
  init_filtering();                         /* initialize some variables      */
  init_timer();                             /* set up timer 0 interrupt       */

  start_pwm(5,500000,PWM_50_50,1,PCLK);  /* start PWM, SW CAP filter 50% duty */

  while(1) {                               
    if(flag0) {                                       /* if buffer 0 is full  */
      fir_fft_block(buffer0, buffer0, BUF_SIZE, &state); /* filter it         */
      flag0 = 0;                                      /* and clear the flag   */
    }
    if(flag1) {                                       /* if buffer 1 is full  */
      fir_fft_block(buffer1, buffer1, BUF_SIZE, &state); /* filter it         */
      flag1 = 0;                                      /* and clear the flag   */
    }   
  }
}
