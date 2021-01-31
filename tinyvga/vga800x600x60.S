// ===========================================================================
// vga800x600x60.S
// ===========================================================================
#include "devices.h"
#include "vgacommon.S"

// Define this to use an external 20 MHz clock.
// #define USE_20MHZ_CLOCK

// Define this to use an external 10 MHz clock.
#define USE_10MHZ_CLOCK

#define SCANLINES_ACTIVE        600
#define SCANLINES_VFRONTPORCH   1
#define SCANLINES_VSYNC         4
#define SCANLINES_VBACKPORCH    23

.global generate_vga_800x600x60

// ===========================================================================
// vga_hfporch
// Generates the horizontal front porch.
// ===========================================================================
.macro vga_hfporch signal
      vga_out \signal                                   // 2
      nop                                               // 1
      nop                                               // 1
      nop                                               // 1
                                                        // 5 cycles * (8 dots / cycle) = 40 dots
.endm 

// ===========================================================================
// vga_hsync
// Generates the horizontal sync pulse.
// ===========================================================================
.macro vga_hsync signal
      vga_out \signal                                   // 2    
     spin 4                                             // 1 + (4 * 3) = 13
      nop                                               // 1
                                                        // 16 cycles * (8 dots / cycle) = 128 dots
.endm 

// ===========================================================================
// vga_hbporch
// Generates the horizontal back porch.
// ===========================================================================
.macro vga_hbporch signal
      vga_out \signal                                   // 2
     spin 2                                             // 1 + (2 * 3) = 7
      nop                                               // 1
      nop                                               // 1
                                                        // 11 cycles * (8 dots / cycle) = 88 dots
.endm 

// ===========================================================================
// vga_active
// Generates the active portion of the signal.
// ===========================================================================
.macro vga_active signal next_scanline_count, next_label, current_label
      vga_out \signal                                   // 2
      spin 30                                           // 1 + (30 * 3) = 91
      nop                                               // 1
      vga_load_next_scanline \
        \next_scanline_count, \
        \next_label, \
        \current_label                                  // 6
                                                        // 100 cycles * (8 dots / cycle) = 800 dots
.endm

// ===========================================================================
// scanline
// ===========================================================================
.macro scanline hfporch, hsync, hbporch, active, next_scanline_count, next_label, current_label
      vga_hfporch \hfporch
      vga_hsync \hsync
      vga_hbporch \hbporch
      vga_active \active, \next_scanline_count, \next_label, \current_label
.endm

// ===========================================================================
// scanline_active
// Generates a scanline in the active portion of the picture.
// ===========================================================================
scanline_active:
    scanline \
        VGA_ACTIVE_HBLANK, \
        VGA_ACTIVE_HSYNC, \
        VGA_ACTIVE_HBLANK, \
        VGA_ACTIVE, \
        SCANLINES_VFRONTPORCH, scanline_vfrontporch, scanline_active

// ===========================================================================
// scanline_vfrontporch
// Generates a scanline in the vertical front porch portion of the picture.
// ===========================================================================
scanline_vfrontporch:
    scanline \
        VGA_VBLANK_HBLANK, \
        VGA_VBLANK_HSYNC, \
        VGA_VBLANK_HBLANK, \
        VGA_VBLANK, \
        SCANLINES_VSYNC, scanline_vsync, scanline_vfrontporch

// ===========================================================================
// scanline_vsync
// Generates a scanline in the vsync portion of the picture.
// ===========================================================================
scanline_vsync:
    scanline \
        VGA_VSYNC_HBLANK, \
        VGA_VSYNC_HSYNC, \
        VGA_VSYNC_HBLANK, \
        VGA_VSYNC, \
        SCANLINES_VBACKPORCH, scanline_vbackporch, scanline_vsync
    
// ===========================================================================
// scanline_vbackporch
// Generates a scanline in the vertical back porch portion of the picture.
// ===========================================================================
scanline_vbackporch:
    scanline \
        VGA_VBLANK_HBLANK, \
        VGA_VBLANK_HSYNC, \
        VGA_VBLANK_HBLANK, \
        VGA_VBLANK, \
        SCANLINES_ACTIVE, scanline_active, scanline_vbackporch

// ===========================================================================
// generate_vga_800x600x60
// Generates VGA sync pulses for a resolution of 800x600 at 60 Hz.
// Expects an external 40 MHz clock by default, but you can define either 
// USE_10MHZ_CLOCK or USE_20MHZ_CLOCK to use a different external clock speed.
// ===========================================================================
generate_vga_800x600x60:
       vga_ddr_init
       ldi REG_VGA, 0b10000000
       out _SFR_IO_ADDR(CLKPR), REG_VGA
  #if defined(USE_10MHZ_CLOCK)
       ldi REG_VGA, 0b00000001
#elif defined(USE_20MHZ_CLOCK)
       ldi REG_VGA, 0b00000010
#else
       ldi REG_VGA, 0b00000011
#endif
       out _SFR_IO_ADDR(CLKPR), REG_VGA
       ldi REG_SCANLINE_LO, lo8(SCANLINES_ACTIVE);
       ldi REG_SCANLINE_HI, hi8(SCANLINES_ACTIVE);
      rjmp scanline_active