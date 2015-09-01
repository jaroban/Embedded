/*
    Routines for Digital Filtering on the ARM
    -----------------------------------------
    Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.01              Last revision: May 24 2006
*/

#include "filter.h"

void IIR_PowerUp(const int *coeffs, int *coeffsStates, int nBiquads) ;
void IIR(short *outputs, short *inputs, int nInputs, \
         int nBiquads, int *coeffsStates);

/* init IIR filter state variable                                             */
/* stack used: 52 bytes                                                       */
void iir_init(const int *coeffs, int *delay, int nbiquads, iir_state *state)
{
  state->d = delay;
  state->k = nbiquads;

  IIR_PowerUp(coeffs, delay, nbiquads);
}

/* filter a block of data, # of inputs = # of outputs                         */
/* time required: t ~ 41.3 * nbiquads * ninputs / (CPU frequency)             */ 
/*  (time in microseconds, CPU frequency in MHz)                              */
/* stack used: 60 bytes                                                       */
/* code size is ~152 bytes                                                    */
void iir_block(short *inputs, short *outputs, int ndata, iir_state *state)
{
  IIR(outputs, inputs, ndata, state->k, state->d);
}
