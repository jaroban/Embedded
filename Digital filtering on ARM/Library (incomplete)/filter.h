/*
    Digital filter routines header file
    -----------------------------------
    Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
            
    Department of Electronics and Multimedia Communications
                Technical University of Kosice

    Version: 1.01               Last revision: May 23 2006
*/
#ifndef FILTER_H
#define FILTER_H
 
#define INVERSE 0 
#define FORWARD 1

typedef struct
{
    const short *c;     /*  filter coefficients            */
    short *d;           /*  start of delay line            */
    int k;              /*  number of coefficients         */
} fir_state;

typedef struct
{
    int *d;    /* start of delay line             */
    int k;     /* number of biquad sections       */
} iir_state;

typedef struct {
    int r;
    int i;
} Complex; 

typedef struct
{
    Complex *c; /*  FFT of filter coefficients     */
    Complex *r; /*  buffer to store result of FFT  */
    short *d;   /*  trail/history for overlap/add  */
    int k;      /*  size of FFT to use             */
    int n;      /*  FFT N                          */
    int l;      /*  log of FFT N                   */
    int *ft;    /*  address of sin/cos table       */
    int fl;     /*  log of N of table              */
} fir_fft_state;

void fir_init(const short *coeffs, short *delay, int ncoeffs, fir_state *state);
void fir_block(short *inputs, short *outputs, int ndata, fir_state *state);

void iir_init(const int *coeffs, int *delay, int nbiquads, iir_state *state);
void iir_block(short *inputs, short *outputs, int ndata, iir_state *state);

void fir_fft_init(const short *coeffs, Complex *fft_coeffs, Complex *result, \
                  short *trail, int ncoeffs, int fft_N, int log_fft_N, \
                  fir_fft_state *state);
void fir_fft_block(short *inputs, short *outputs, int ndata, \
                   fir_fft_state *state);

void fir_fft_init_opt(const short *coeffs, Complex *fft_coeffs, \
                      Complex *result, short *trail, int ncoeffs, \
                      int fft_N, int log_fft_N, fir_fft_state *state);
void fir_fft_block_opt(short *inputs, short *outputs, int ndata, \
                       fir_fft_state *state);

void fir_fft_init_ext(const short *coeffs, Complex *fft_coeffs, \
                      Complex *result, short *trail, int ncoeffs, \
                      int fft_N, int log_fft_N, int *table, \
                      int table_logn, fir_fft_state *s);
void fir_fft_block_ext(short *inputs, short *outputs, int ndata, \
                       fir_fft_state *s);

#endif
