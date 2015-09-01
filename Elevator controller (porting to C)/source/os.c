#include <global.h>

// STACK_PER_THREAD * MAX_THREADS <= 1024!
#define MAX_THREADS 10
#define STACK_PER_THREAD (1024 / MAX_THREADS)

#define TH_ID_UNUSED 0
#define TH_ID_SOMETHING 1

//#define RESET_STACK __critical { SP16 = STACK_PER_THREAD * thread_index - 1; }

static __idata u8 thread_id[MAX_THREADS];
static __idata u16 thread_stack[MAX_THREADS];
static __xdata u8 thread_dest[MAX_THREADS];
static volatile __data u8 thread_index;
volatile __data u8 thread_watchdog;

void os_init()
{
    thread_index = 0;
    set_memory_i(thread_id, MAX_THREADS, TH_ID_UNUSED);
}

void set_id(u8 id)
{
    thread_id[thread_index] = id;
}

u8 get_id()
{
    return thread_id[thread_index];
}

void write_to(u8 dest)
{
    thread_dest[thread_index] = dest;
}

u8 get_dest()
{
    return thread_dest[thread_index];
}

// returns stack inside routine (on new thread's stack)
static u16 copy_stack(u8 dest)
{
    __asm
                mov     a,dpl
                mov     b,#STACK_PER_THREAD
                mul     ab
                mov     dpl,a           ; new stack base
                mov     dph,b
                mov     dpx,#0x40
                
                mov     a,_thread_index
                mov     b,#STACK_PER_THREAD
                mul     ab
                mov     dpl1,a          ; old stack base
                mov     dph1,b
                mov     dpx1,#0x40
                
                mov     a,sp            
                clr     c
                subb    a,dpl1
                mov     r0,a            ; old stack - old stack base

                mov     dps,#DPS_TOGGLE+1
cp_st_xx_lp:    movx    a,@dptr
                movx    @dptr,a
                inc     dptr
                inc     dptr
                djnz    r0,cp_st_xx_lp
                
                movx    a,@dptr         ; stack is *full* ascending
                movx    @dptr,a
                
                mov     dps,#0          ; return value in dpl, dph
    __endasm;
}

u8 fork()
{
    u8 i;
    u16 stack;

    for(i = 0; i < MAX_THREADS; i++)
    {
        if(thread_id[i] == TH_ID_UNUSED) break;
    }

    if(i == MAX_THREADS)
    {
        // thread table is full
        write_to(SERIAL);
        printf("\r\ncouldn't fork from thread %c", (u8)thread_id[thread_index]);
        halt();
    }
    
    //write_to(SERIAL_DIRECT);
    //printf("forking from %u to %u\n", thread_index, i);
    
    stack = copy_stack(i);
    
    // <- new thread starts here...
    
    if(i == thread_index) return /*child*/ 1;

    thread_stack[i] = stack;    // ...because of this line
    
    thread_id[i] = TH_ID_SOMETHING;
    
    return /*parent*/ 0;
}

void wait()
{
    thread_watchdog = 0;

    thread_stack[thread_index] = SP16;

    do
    {
        thread_index++; 
        if(thread_index == MAX_THREADS) thread_index = 0;
    }
    while(thread_id[thread_index] == TH_ID_UNUSED);
    
    EA = 0;
    SP16 = thread_stack[thread_index];
    EA = 1;
}

void kill_me()
{
    set_id(TH_ID_UNUSED);
    wait();
}

void kill(u8 id)
{
    __idata u8 *p; u8 i;
    
    p = thread_id; i = MAX_THREADS;
    
    do { if(*p == id) *p = TH_ID_UNUSED; p++; } while(--i);
    
    wait();
}
