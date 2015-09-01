#ifndef I2C_H
#define I2C_H

typedef struct
{
    u8 seconds;         // bcd, 0x00-0x59, msb = clock halt bit
    u8 minutes;         // bcd, 0x00-0x59
    u8 hours;           // bcd, bit6 = 0: 0x00-0x23, bit6 = 1: bit5 = am/pm, 0x01-0x12
    u8 day_of_week;     // 1-7
    u8 day;             // bcd, 0x01-0x31
    u8 month;           // bcd, 0x01-0x12
    u8 year;            // bcd, 0x00-0x99
} 
i2c_time_t;

extern __xdata i2c_time_t i2c_time_read;
extern __xdata i2c_time_t i2c_time_write;
extern __xdata u8 i2c_ram_read[32];
extern __xdata u8 i2c_ram_write[32];
extern __data i8 i2c_temperature;

void i2c_thread();

#endif