// ===========================================================================
// vga1024x768x60.S
// ===========================================================================
#include "devices.h"
#include "vgacommon.S"

// Define this to use an external 32.5 MHz clock.
// #define USE_32MHZ_CLOCK

// Define this to use an external 16.25 MHz clock.
#define USE_16MHZ_CLOCK

#define SCANLINES_ACTIVE        768
#define SCANLINES_VFRONTPORCH   3
#define SCANLINES_VSYNC         6
#define SCANLINES_VBACKPORCH    29

.global generate_vga_1024x768x60

// ===========================================================================
// vga_hfporch
// Generates the horizontal front porch.
// ===========================================================================
.macro vga_hfporch signal
      vga_out \signal                                   // 2
      nop                                               // 1
                                                        // 3 cycles * (8 dots / cycle) = 24 dots
.endm 

// ===========================================================================
// vga_hsync
// Generates the horizontal sync pulse.
// ===========================================================================
.macro vga_hsync signal
      vga_out \signal                                   // 2    
     spin 4                                             // 1 + (4 * 3) = 13
      nop                                               // 1
      nop                                               // 1
                                                        // 17 cycles * (8 dots / cycle) = 136 dots
.endm 

// ===========================================================================
// vga_hbporch
// Generates the horizontal back porch.
// ===========================================================================
.macro vga_hbporch signal
      vga_out \signal                                   // 2
     spin 5                                             // 1 + (5 * 3) = 16
      nop                                               // 1
      nop                                               // 1
                                                        // 20 cycles * (8 dots / cycle) = 160 dots
.endm 

// ===========================================================================
// vga_active
// Generates the active portion of the signal.
// ===========================================================================
.macro vga_active signal next_scanline_count, next_label, current_label
      vga_out \signal                                   // 2
      spin 39                                           // 1 + (39 * 3) = 118
      nop                                               // 1
      vga_load_next_scanline \
        \next_scanline_count, \
        \next_label, \
        \current_label                                  // 7
                                                        // 128 cycles * (8 dots / cycle) = 1024 dots
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
// generate_vga_1024x768x60
// Generates VGA sync pulses for a resolution of 1024x768 at 60 Hz.
// Expects an external 65 MHz clock by default, but you can define either
// USE_16MHZ_CLOCK or USE_32MHZ_CLOCK to use a different external clock speed.
// ===========================================================================
generate_vga_1024x768x60:
       vga_ddr_init
       ldi REG_VGA, 0b10000000
       out _SFR_IO_ADDR(CLKPR), REG_VGA
  #if defined(USE_16MHZ_CLOCK)
       ldi REG_VGA, 0b00000001
#elif defined(USE_32MHZ_CLOCK)
       ldi REG_VGA, 0b00000010
#else
       ldi REG_VGA, 0b00000011
#endif
       out _SFR_IO_ADDR(CLKPR), REG_VGA
       ldi REG_SCANLINE_LO, lo8(SCANLINES_ACTIVE);
       ldi REG_SCANLINE_HI, hi8(SCANLINES_ACTIVE);
      rjmp scanline_active