/*
    Routines for Digital Filtering on the ARM
    -----------------------------------------
    Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.01              Last revision: May 24 2006
*/

#include "filter.h"

void s_blk_fir_rhs(short *outputs, short *inputs, const short *coeffs, \
                   int nOutputs, int nCoeffs, int nInputs);

/* init FIR filter state variable                                             */
/* time required: just to zero the delay line                                 */
/* stack used: 4 bytes (local variable i)                                     */
void fir_init(const short *coeffs, short *delay, int ncoeffs, fir_state *state)
{
  int i;

  state->c = coeffs;                                    /* set up pointers    */
  state->d = delay;
  state->k = ncoeffs;

  for(i = 0; i < ncoeffs-1; i++) delay[i] = 0;          /* clear delay line   */
}

/* filter a block of data, # of inputs = # of outputs                         */
/* time required: t ~ (5.1 * ncoeffs * ninputs) / (CPU frequency)             */ 
/*  (time in microseconds, CPU frequency in MHz)                              */
/* stack used: 120 bytes                                                      */
/* code size is ~848 bytes                                                    */
void fir_block(short *inputs, short *outputs, int ndata, fir_state *state)
{
  int c; int i;	short *h;               /* these use up stack, but make the   */
                                        /*  code more readable                */
  c = state->k;                         /* number of coeffs for easy access   */
  h = state->d;                         /* pointer to start of delay line     */
  
  /* since inputs and delays are not contiguous, must filter                  */
  /* in two function calls - 1. for the delay line, 2. for the inputs         */
  if(ndata >= c) {                      /* if more inputs than coefficients   */
    for(i = 0; i < c-1; i++)            /* add data to delay line             */
      h[c-1+i] = inputs[i];
    s_blk_fir_rhs(outputs, h, state->c, c-1, c, (c-1)<<1);
    s_blk_fir_rhs(outputs+c-1, inputs, state->c, ndata-c+1, c, ndata);
    for(i = 0; i < c-1; i++)            /* save data to delay line            */ 
      h[i] = inputs[ndata-c+1+i];
  } else {
  
  /* since there is less input data than there are coefficients, we can do    */
  /* all the filtering in the delay line                                      */
    for(i = 0; i < ndata; i++)          /* add data from inputs               */
      h[c-1+i] = inputs[i];     
    s_blk_fir_rhs(outputs, h, state->c, ndata, c, c-1+ndata);
    for(i = 0; i < c-1; i++)            /* save data to delay line            */
      h[i] = h[i+ndata];
  }
}
