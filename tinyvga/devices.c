// ===========================================================================
// devices.h
// ===========================================================================
#include "devices.h"

void
device_init_attiny84()
{
     DDRB = 0x00;
    PORTB = 0xFF;
}

void
device_init_attiny85()
{

}

void
device_init()
{
  #if defined(__AVR_ATtiny84__)
    device_init_attiny84(); 
#elif defined(__AVR_ATtiny85__)
    device_init_attiny85();  
#endif
}