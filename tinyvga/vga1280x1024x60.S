// ===========================================================================
// vga1280x1024x60.S
// ===========================================================================
#include "devices.h"
#include "vgacommon.S"

// Define this to use an external 27 MHz clock.
// #define USE_27MHZ_CLOCK

// Define this to use an external 13.5 MHz clock.
#define USE_13MHZ_CLOCK

#define SCANLINES_ACTIVE        1024
#define SCANLINES_VFRONTPORCH   1
#define SCANLINES_VSYNC         3
#define SCANLINES_VBACKPORCH    38

.global generate_vga_1280x1024x60

// ===========================================================================
// vga_hfporch
// Generates the horizontal front porch.
// ===========================================================================
.macro vga_hfporch signal
      vga_out \signal                                   // 2
     spin 1                                             // 1 + (1 * 3) = 4
                                                        // 6 cycles * (8 dots / cycle) = 48 dots
.endm 

// ===========================================================================
// vga_hsync
// Generates the horizontal sync pulse.
// ===========================================================================
.macro vga_hsync signal
      vga_out \signal                                   // 2    
     spin 4                                             // 1 + (3 * 3) = 10
      nop                                               // 1
      nop                                               // 1
                                                        // 14 cycles * (8 dots / cycle) = 112 dots
.endm 

// ===========================================================================
// vga_hbporch
// Generates the horizontal back porch.
// ===========================================================================
.macro vga_hbporch signal
      vga_out \signal                                   // 2
     spin 9                                             // 1 + (9 * 3) = 28
      nop                                               // 1
                                                        // 31 cycles * (8 dots / cycle) = 248 dots
.endm 

// ===========================================================================
// vga_active
// Generates the active portion of the signal.
// ===========================================================================
.macro vga_active signal next_scanline_count, next_label, current_label
      vga_out \signal                                   // 2
      spin 50                                           // 1 + (50 * 3) = 151
      nop                                               // 1
      vga_load_next_scanline \
        \next_scanline_count, \
        \next_label, \
        \current_label                                  // 6
                                                        // 160 cycles * (8 dots / cycle) = 1280 dots
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
// generate_vga_1280x1024x60
// Generates VGA sync pulses for a resolution of 1280x1024 at 60 Hz.
// Expects an external 108 MHz clock by default, but you can define either
// USE_13MHZ_CLOCK or USE_27MHZ_CLOCK to use a different external clock speed.
// ===========================================================================
generate_vga_1280x1024x60:
       vga_ddr_init
       ldi REG_VGA, 0b10000000
       out _SFR_IO_ADDR(CLKPR), REG_VGA
  #if defined(USE_13MHZ_CLOCK)
       ldi REG_VGA, 0b00000000
#elif defined(USE_27MHZ_CLOCK)
       ldi REG_VGA, 0b00000001
#else
       ldi REG_VGA, 0b00000011
#endif
       out _SFR_IO_ADDR(CLKPR), REG_VGA
       ldi REG_SCANLINE_LO, lo8(SCANLINES_ACTIVE);
       ldi REG_SCANLINE_HI, hi8(SCANLINES_ACTIVE);
      rjmp scanline_active