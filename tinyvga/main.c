// ===========================================================================
// main.c
// ===========================================================================
#include <avr/io.h>
#include "devices.h"

extern void generate_vga_640x480x60();
extern void generate_vga_800x600x60();
extern void generate_vga_1024x768x60();
extern void generate_vga_1280x1024x60();

int main(void)
{
    device_init();

#if defined(SUPPORTS_RESOLUTION_SELECT) 

     DDR_SELECT &= ~SELECT_MASK;

    uint8_t selection = 0;
    if ((PIN_SELECT & (1 << SELECT_BIT_1)) != 0) { selection |= 0b00000010; }
    if ((PIN_SELECT & (1 << SELECT_BIT_0)) != 0) { selection |= 0b00000001; }

    switch (selection) {
        case 1: 
            generate_vga_800x600x60();
            break;
            
        case 2:
            generate_vga_1024x768x60();
            break;
            
        case 3:
            generate_vga_1280x1024x60();
            break;

        default:
            generate_vga_640x480x60(); 
            break;
    }    

#else

    DEFAULT_RESOLUTION_HANDLER();

#endif
}

