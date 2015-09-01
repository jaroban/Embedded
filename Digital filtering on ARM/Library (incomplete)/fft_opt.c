/*
    Routines for Digital Filtering on the ARM
    -----------------------------------------
    Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.01              Last revision: May 24 2006
*/

#include "filter.h"

int FFT_OPT(Complex *input, Complex *output, int logN, int direction);
int REALFFT_OPT(int *input, Complex *output, int logN);

int FFT_SC_OPT(Complex *input, Complex *output, int logN, int direction);
int REALFFT_SC_OPT(int *input, Complex *output, int logN);

/* init FIR FFT filter state variable, using optimized REALFFT                */
/* stack used: 60 bytes                                                       */
void fir_fft_init_opt(const short *coeffs, Complex *fft_coeffs, \
                      Complex *result, short *trail, int ncoeffs, \
                      int fft_N, int log_fft_N, fir_fft_state *s)
{
  int i; int *hlp;

  s->c = fft_coeffs;                                    /* set up pointers    */
  s->r = result;
  s->d = trail;
  s->k = ncoeffs;
  s->l = log_fft_N;
  s->n = fft_N;

  for(i = 0; i < ncoeffs-1; i++) trail[i] = 0;          /* clear trail        */

  hlp = (int *) fft_coeffs;
  for(i = 0; i < ncoeffs; i++) hlp[i] = coeffs[i];      /* copy coeffs        */
  for(i = ncoeffs; i < fft_N; i++) hlp[i] = 0;          /* add zero padding   */
  while(REALFFT_OPT(hlp, fft_coeffs, log_fft_N-1)) ;    /* error              */
}

/* filter a block of data, # of inputs = # of outputs                         */
/* time required: t ~ 42.3 * N * log2(N) / (CPU frequency)                    */ 
/*  (time in microseconds, CPU frequency in MHz)                              */
/* stack used: 68 bytes                                                       */
/* code size ~ 2.6k + N/2 bytes                                               */
void fir_fft_block_opt(short *inputs, short *outputs, int ndata, \
                       fir_fft_state *s)
{
  int c; int i;	int j; int n; int h;    /* these use up stack, but make the   */
  short *t; int *hlp;                   /*  code more readable                */
  Complex *acc;
  Complex *mul;  

  t = s->d;                             /* pointer to start of trail          */
  acc = s->r;
  mul = s->c;
  n = s->n;
  h = n >> 1;

  hlp = (int *) acc;
  for(i = 0; i < ndata; i++) hlp[i] = inputs[i]; /* copy input data           */
  for(i = ndata; i < n; i++) hlp[i] = 0;         /* add zero padding          */
                                                 /* perform forward FFT       */ 
  while(REALFFT_SC_OPT(hlp, acc, s->l-1)) ;      /* an error ocurred          */
  
  acc[0].r *= mul[0].r;                          /* multiply FFT coefficients */
  acc[0].i = 0;
  for(i = 1; i < h; i++) {                
    j = n - i;
    acc[j].r = acc[i].r;                         /* spectrum is symmetric     */
    acc[j].i = -acc[i].i;   
    c = acc[i].r;                                
    acc[i].r = (c * mul[i].r - acc[i].i * mul[i].i) >> 14;
    acc[i].i = (c * mul[i].i + acc[i].i * mul[i].r) >> 14;
    acc[j].r = (c * mul[i].r + acc[j].i * mul[i].i) >> 14;
    acc[j].i = (-c * mul[i].i + acc[j].i * mul[i].r) >> 14;
  }
  acc[h].r = (acc[h-1].r + acc[h+1].r) >> 1;
  acc[h].i = 0;   

  while(FFT_OPT(acc, acc, s->l, INVERSE)) ;      /* an error ocurred          */
     
  c = s->k - 1;                                  /* size of trail             */
  for(i = 0; i < ndata; i++) outputs[i] = acc[i].r;
  if(ndata > c) {
    for(i = 0; i < c; i++) {
      outputs[i] += t[i];
      t[i] = acc[ndata + i].r;
    }
  } else {
    for(i = 0; i < ndata; i++) outputs[i] += t[i];
    for(i = 0; i < c - ndata; i++) t[i] = t[ndata + i] + acc[ndata + i].r;
    for(i = 0; i < ndata; i++) t[c - ndata + i] = acc[c + i].r; 
  }
}
