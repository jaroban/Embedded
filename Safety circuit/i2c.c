// write protect - 0 = writes allowed, 1 = data is protected
// slave address = 000

#define SLAVE_ADDRESS 0xa0

#define ACK 0
#define NO_ACK 1
#define SDA_STUCK 2
#define SCL_STRETCH 3

#define SUCCESS 0
#define XMT_ERROR 1
#define RCV_ERROR 1

__idata u8 i2c_buffer[3];

void i2c_delay()
{
    __asm
        nop
        nop
        nop
        nop
        nop
        nop
        nop
    __endasm;
    reset_watchdog();
}

void i2c_start()
{
    // set idle values
    SDA = 1; 
    SCL = 1; 

    // i2c start
    i2c_delay();
    SDA = 0; 
    i2c_delay();
    SCL = 0; 
    i2c_delay();
}

void i2c_stop()
{
    // set idle values
    SDA = 0; 
    SCL = 0; 
    
    // i2c stop
    i2c_delay();
    SCL = 1; 
    i2c_delay();
    SDA = 1; 
    i2c_delay();
}

/*
    MEMORY RESET: After an interruption in protocol, power loss or system reset, any 2-
    wire part can be reset by following these steps:
    1. Clock up to 9 cycles.
    2. Look for SDA high in each cycle while SCL is high.
    3. Create a start condition.
*/
void i2c_reset()
{
    u8 i;
    SDA = 1;
    for(i = 0; i < 9; i++)
    {
        SCL = 1;
        while(!SCL);
        i2c_delay();
        if(SDA) return;
        SCL = 0;
        i2c_delay();
    }
    SCL = 1;
}

u8 i2c_write(u8 data)
{
    u8 i;
    for(i = 0; i < 8; i++)
    {
        SDA = data & 0x80 ? 1 : 0;
        i2c_delay();
        SCL = 1;
        while(!SCL);
        i2c_delay();
        if((data & 0x80) && !SDA) return SDA_STUCK;
        SCL = 0;
        i2c_delay();
        data <<= 1;
    }
    SDA = 1;
    i2c_delay();
    SCL = 1;
    i2c_delay();
    i = SDA ? NO_ACK : ACK;
    SCL = 0;
    i2c_delay();
    return i;
}

u8 i2c_read(u8 last_bit)
{
    u8 i, data;
    data = 0;
    SDA = 1;
    i2c_delay();
    for(i = 0; i < 8; i++)
    {          
        SCL = 1;
        while(!SCL);
        i2c_delay();
        data = (data << 1) | (SDA ? 1 : 0);
        SCL = 0;
        i2c_delay();
    }
    SDA = last_bit ? 1 : 0;
    i2c_delay();
    SCL = 1; 
    while(!SCL);
    i2c_delay();
    SCL = 0;
    i2c_delay();
    return data;
}

u8 i2c_transmit(u8 length)
{
    u8 i;
    i2c_start();
    if(i2c_write(SLAVE_ADDRESS & 0xfe) != ACK)
    {
        i2c_stop();
        return XMT_ERROR;
    }
    for(i = 0; i < length; i++)
    {
        if(i2c_write(i2c_buffer[i]) != ACK)
        {
            i2c_stop();
            return XMT_ERROR;
        }
    }
    i2c_stop();
    return SUCCESS;
}

u8 i2c_receive(u8 length)
{
    u8 i;
    i2c_start();
    if(i2c_write(SLAVE_ADDRESS | 1) != ACK)
    {
        i2c_stop();
        return RCV_ERROR;
    }
    for(i = 0; i < length; i++)
    {
        i2c_buffer[i] = i2c_read(i < (u8)(length - 1) ? ACK : NO_ACK);
    }
    i2c_stop();
    return SUCCESS;
}

void eeprom_write(u8 address, u8 data)
{
    WP = 0;
    i2c_buffer[0] = address;
    i2c_buffer[1] = data;
    while(i2c_transmit(2) != SUCCESS);
    WP = 1;
}

// current address read
u8 eeprom_read_current()
{
    while(i2c_receive(1) != SUCCESS);
    return i2c_buffer[0];
}

// random read
u8 eeprom_read(u8 address)
{
    while(1)
    {
        // dummy write operation
        i2c_buffer[0] = address;
        if(i2c_transmit(1) == SUCCESS)
        {
            // current address read
            if(i2c_receive(1) == SUCCESS)
            {
                return i2c_buffer[0];
            }
        }
    }
}
