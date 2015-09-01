#include <global.h>
#include <i2c.h>

static __sbit __at 0xb4 i2c_sda;       // p3.4
static __sbit __at 0xb5 i2c_scl;       // p3.5

static __idata u8 i2c_xmt_buf[9];
static __idata u8 i2c_rcv_buf[7];

// application specific
#define DS1629 0x9e
#define DS1629_ACCESS_CONFIG 0xac
#define DS1629_CONFIG 0xc0
#define DS1629_READ_TEMP 0xaa
#define DS1629_ACCESS_CLOCK 0xc0
#define DS1629_ACCESS_SRAM 0x17

__bit i2c_set_time;
__data i8 i2c_temperature;
__xdata u8 i2c_ram_read[32];
__xdata u8 i2c_ram_write[32];
__xdata i2c_time_t i2c_time_read;
__xdata i2c_time_t i2c_time_write;

// timer T_I2C

static void i2c_delay()
{
    __asm
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
    __endasm;
}

static void scl_lo() 
{ 
    i2c_scl = 0; 
    i2c_delay(); 
}

static void scl_hi() 
{ 
    i2c_scl = 1; 
    while(!i2c_scl) wait();
    i2c_delay(); 
}

static void sda_lo() 
{ 
    i2c_sda = 0; 
    i2c_delay(); 
}

static void sda_hi() 
{ 
    i2c_sda = 1;
    while(!i2c_sda) wait();
    i2c_delay();
}

static u8 read_sda() 
{
    __asm
                setb    _i2c_sda
                acall   _i2c_delay
                mov     c,_i2c_sda
                clr     a
                rlc     a
                mov     dpl,a
    __endasm;
}

// assuming scl == 0
static u8 i2c_send_byte(u8 c)
{
    u8 i = 8;

    do
    {
        c = (c << 1) | (c >> 7);
        c & 1 ? sda_hi() : sda_lo();
        scl_hi();
        scl_lo();
    }
    while(--i);
    
    scl_hi();
    c = read_sda();
    scl_lo();
    
    return c;   // 0: ack = ok, 1 = no ack, error
}

// assuming scl == 0
static u8 i2c_receive_byte(u8 acknowledge)
{
    u8 i = 8;
    u8 c = 0;

    do
    {
        scl_hi();
        c = (c << 1) | read_sda();
        scl_lo();
    }
    while(--i);

    acknowledge ? sda_lo() : sda_hi();
    scl_hi();
    scl_lo();
    
    return c;
}

static u8 i2c_comm(u8 address, u8 transmit, u8 receive)
{
    u8 e = 0;
    u8 i;
    __idata u8 *p;

    if(!transmit && !receive) return 0;

    // stop (nothing happens if bus already released)
    scl_hi();
    sda_hi();
    
    // start
    sda_lo();
    scl_lo();
    
    if(transmit)
    {   
        e = i2c_send_byte(address & (~1));
        if(e) goto stop;
        
        i = transmit;
        p = i2c_xmt_buf;
        
        do
        {
            e = i2c_send_byte(*p++);
            if(e) goto stop;
        }
        while(--i);
    }

    if(transmit && receive)
    {
        // repeated start
        sda_hi();
        scl_hi();
        sda_lo();
        scl_lo();
    }
    
    if(receive)
    {
        e = i2c_send_byte(address | 1);
        if(e) goto stop;
        
        i = receive;
        p = i2c_rcv_buf;
        
        while(i--)
        {
            *p++ = i2c_receive_byte(i);
        }
    }

stop:
    // assuming scl == 0
    sda_lo();
    scl_hi();
    sda_hi();
    return e;
}

static u8 i2c_init()
{
    u8 e;
    
    i2c_xmt_buf[0] = DS1629_ACCESS_CONFIG;  // read config
    e = i2c_comm(DS1629, 1, 2);             
    if(e) return e;
    
    if(i2c_rcv_buf[0] == DS1629_CONFIG) return 0;

    i2c_xmt_buf[1] = DS1629_CONFIG;
    
    e = i2c_comm(DS1629, 2, 0);             // write config
    if(e) return e;
    
    wait_for_timer(T_I2C, 0, 0, 5);        // wait 50 ms
}

static void i2c_read_temperature()
{
    // try to read temperature
    i2c_xmt_buf[0] = DS1629_READ_TEMP;
    if(!i2c_comm(DS1629, 1, 1))
    {
        i2c_temperature = i2c_rcv_buf[0];
    }
}

static void i2c_read_time()
{
    // try to read time
    i2c_xmt_buf[0] = DS1629_ACCESS_CLOCK;   // read clock
    i2c_xmt_buf[1] = 0;                     // start at seconds
    if(!i2c_comm(DS1629, 2, 7))
    {
        copy_ix(i2c_rcv_buf, 
                (__xdata u8 *)&i2c_time_read, 
                sizeof(i2c_time_read));
    }
}

static u8 i2c_write_time()
{
    if(i2c_set_time)
    {
        i2c_xmt_buf[0] = DS1629_ACCESS_CLOCK;   // write clock
        i2c_xmt_buf[1] = 0;                     // start at seconds
        copy_xi((__xdata u8 *)&i2c_time_write, i2c_xmt_buf + 2, sizeof(i2c_time_write));
        
        if(!i2c_comm(DS1629, 9, 0))
        {
            i2c_set_time = 0;
        }
    }
}

static u8 i2c_read_sram()
{
    u8 i, e;

    i2c_xmt_buf[0] = DS1629_ACCESS_SRAM;
    
    for(i = 0; i < 32; i++)
    {
        // read sram
        i2c_xmt_buf[1] = i;
        e = i2c_comm(DS1629, 2, 1);
        if(e) return e;
        i2c_ram_read[i] = i2c_rcv_buf[0];
    }

    return 0;
}

static void i2c_write_sram()
{
    u8 i;

    // check changes to sram
    if(diff_xx(i2c_ram_write, i2c_ram_read, 32))
    {
        i2c_xmt_buf[0] = DS1629_ACCESS_SRAM;
        
        for(i = 0; i < 32; i++)
        {
            if(i2c_ram_read[i] != i2c_ram_write[i])
            {
                // write to sram
                i2c_xmt_buf[1] = i;
                i2c_xmt_buf[2] = i2c_ram_write[i];
                if(!i2c_comm(DS1629, 3, 0))
                {
                    // read back value
                    if(!i2c_comm(DS1629, 2, 1))
                    {
                        i2c_ram_read[i] = i2c_rcv_buf[0];
                    }
                }
            }
        }
    }
}

void i2c_thread()
{
    i2c_temperature = 0;
    i2c_set_time = 0;
    
    //write_to(SERIAL_DIRECT);
    //puts("inside i2c thread\r\n");

    while(i2c_init() || i2c_read_sram())
    {
        // wait and retry
        wait_for_timer(T_I2C, 0, 1, 0);
        //puts("retrying i2c init\r\n");
    }
    
    copy_xx(i2c_ram_read, i2c_ram_write, 32);

    while(1)
    {
        wait();
        
        if(!timer_running(T_I2C))
        {
            // every second
            init_timer(T_I2C, 0, 1, 0);

            i2c_read_temperature();

            i2c_read_time();

            //printf("temp = %u\r\n", i2c_temperature);
        }

        // try to write time
        i2c_write_time();

        i2c_write_sram();
    }
}
