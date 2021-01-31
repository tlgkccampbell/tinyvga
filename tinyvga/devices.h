// ===========================================================================
// devices.h
// ===========================================================================
#ifndef DEVICES_H_
#define DEVICES_H_

#include <avr/io.h>

#if !__ASSEMBLER__
    void device_init();
#endif

// ===========================================================================
// ATtiny85 defines
// ===========================================================================
#if defined(__AVR_ATtiny85__)

#if __ASSEMBLER__
    #define  DDR_VGA        _SFR_IO_ADDR(DDRB)
    #define PORT_VGA        _SFR_IO_ADDR(PORTB)
#else
    #define  DDR_VGA        DDRB
    #define PORT_VGA        PORTB
#endif

#define VGA_BIT_HBLANK      0
#define VGA_BIT_HSYNC       1
#define VGA_BIT_VBLANK      2
#define VGA_BIT_VSYNC       4
#define VGA_BIT_ACTIVE      5
#define VGA_BIT_ACTIVENOT   3

#define REG_VGA             r16
#define REG_SPINLOOP        r17
#define REG_SCANLINE_LO     r28
#define REG_SCANLINE_HI     r29

#define DEFAULT_RESOLUTION_HANDLER generate_vga_640x480x60

// ===========================================================================
// ATtiny84 defines
// ===========================================================================
#elif defined(__AVR_ATtiny84__)

#if __ASSEMBLER__
    #define  DDR_VGA        _SFR_IO_ADDR(DDRA)
    #define PORT_VGA        _SFR_IO_ADDR(PORTA)
    #define  DDR_SELECT     _SFR_IO_ADDR(DDRB)
    #define PORT_SELECT     _SFR_IO_ADDR(PORTB)
    #define  PIN_SELECT     _SFR_IO_ADDR(PINB)
#else
    #define  DDR_VGA         DDRA
    #define PORT_VGA        PORTA
    #define  DDR_SELECT      DDRA
    #define PORT_SELECT     PORTA
    #define  PIN_SELECT      PINA    
#endif

#define VGA_BIT_HBLANK      0
#define VGA_BIT_HSYNC       1
#define VGA_BIT_VBLANK      2
#define VGA_BIT_VSYNC       3
#define VGA_BIT_ACTIVE      4
#define VGA_BIT_ACTIVENOT   5

#define SELECT_BIT_0        6
#define SELECT_BIT_1        7
#define SELECT_MASK         ((1 << SELECT_BIT_0) | (1 << SELECT_BIT_1))

#define REG_VGA             r16
#define REG_SPINLOOP        r17
#define REG_SCANLINE_LO     r28
#define REG_SCANLINE_HI     r29

#define SUPPORTS_RESOLUTION_SELECT

// ===========================================================================
// Unsupported device
// ===========================================================================
#else
    #error The selected device is not supported.
#endif

// ===========================================================================
// VGA signal values 
// ===========================================================================
#define VGA_ACTIVE          (0b11111111 & ~((1 << VGA_BIT_ACTIVENOT)))
#define VGA_ACTIVE_HBLANK   (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_HBLANK)))
#define VGA_ACTIVE_HSYNC    (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_HBLANK) | (1 << VGA_BIT_HSYNC)))

#define VGA_VBLANK          (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK)))
#define VGA_VBLANK_HBLANK   (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_HBLANK)))
#define VGA_VBLANK_HSYNC    (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_HBLANK) | (1 << VGA_BIT_HSYNC)))

#define VGA_VSYNC           (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_VSYNC)))
#define VGA_VSYNC_HBLANK    (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_VSYNC) | (1 << VGA_BIT_HBLANK)))
#define VGA_VSYNC_HSYNC     (0b11111111 & ~((1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_VSYNC) | (1 << VGA_BIT_HBLANK) | (1 << VGA_BIT_HSYNC)))

#define VGA_MASK            ((1 << VGA_BIT_HBLANK) | (1 << VGA_BIT_HSYNC) | (1 << VGA_BIT_VBLANK) | (1 << VGA_BIT_VSYNC) | (1 << VGA_BIT_ACTIVE) | (1 << VGA_BIT_ACTIVENOT))

#endif /* DEVICES_H_ */