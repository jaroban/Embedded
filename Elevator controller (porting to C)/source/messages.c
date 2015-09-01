#include <global.h>

#define MESSAGE_BUFFER_SIZE 250

__data u8 message[8];

static __xdata u8 message_buffer[MESSAGE_BUFFER_SIZE];

void init_messages()
{
    message_buffer[0] = 0;
}

// put any required data in "message" before calling this
void send_message(u8 id, u8 len)
{
    __asm
                mov     r0,dpl
                mov     dps,#0
                mov     dptr,#_message_buffer
                mov     r1,#-MESSAGE_BUFFER_SIZE
                
                ; get next offset
sm_lp1:         movx    a,@dptr
                jz      sm_top
                mov     r2,a
                
                ; advance to next message
                add     a,dpl
                mov     dpl,a
                clr     a
                addc    a,dph
                mov     dph,a
                clr     a
                addc    a,dpx
                mov     dpx,a
                
                ; are we past end of buffer?
                mov     a,r2
                add     a,r1
                mov     r1,a
                jnc     sm_lp1

                ; delete all messages
sm_full:        mov     dptr,#_message_buffer
                mov     r1,#-MESSAGE_BUFFER_SIZE

                ; is there room for message?
sm_top:         mov     a,b1_0
                add     a,#1+1              ; 
                mov     r2,a
                add     a,r1
                mov     r1,a
                
                ;+1? cos terminating zero////////////////////!!!!!!!!!!
                jc      sm_full
                
                ; write offset and id
                mov     a,r2
                movx    @dptr,a
                inc     dptr
                mov     a,r0
                movx    @dptr,a
                inc     dptr
                
                ; copy message data
                mov     a,b1_0
                jz      sm_done
                mov     r0,#_message
sm_lp2:         mov     a,@r0
                movx    @dptr,a
                inc     r0
                inc     dptr
                djnz    r2,sm_lp2
sm_done:        clr     a
                movx    @dptr,a
sm_ret:
    __endasm;
}

bool get_message(u8 id)
{
    __asm
                mov     r0,dpl
                mov     dps,#0
                mov     dptr,#_message_buffer
                sjmp    gm_entry
                
gm_lp1:         inc     dptr
                djnz    r2,gm_lp1
                
gm_entry:       movx    a,@dptr
                jz      gm_no
                
                mov     r2,a
                mov     dpl1,dpl
                mov     dph1,dph
                mov     dpx1,dpx
                
                inc     dptr
                dec     r2
                movx    a,@dptr
                mov     r1,a
                inc     dptr
                dec     r2
                mov     a,r2
                jz      gm_shift
                xch     a,r1
                mov     b,a
                mov     a,psw
                anl     a,#18h
                orl     a,#3
                mov     r0,a
gm_lp2:         movx    a,@dptr
                mov     @r0,a
                inc     dptr
                inc     r0                
                djnz    r1,gm_lp2
                mov     r1,b
gm_shift:       mov     dps,#00100100b
                movx    a,@dptr
                jz      gm_done
gm_next:        mov     r0,a
gm_lp3:         movx    @dptr,a
                inc     dptr
                inc     dptr
                movx    a,@dptr
                djnz    r0,gm_lp3
                jnz     gm_next
gm_done:        movx    @dptr,a
                mov     dps,#0
                mov     dpl,#0xff
                ret
gm_no:          mov     dpl,#0
    __endasm;
}
