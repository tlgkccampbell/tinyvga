// ===========================================================================
// vga640x480x60.S
// ===========================================================================
#include "devices.h"
#include "vgacommon.S"

// Define this to use an external 12.5875 MHz clock.
// #define USE_12MHZ_CLOCK

// Define this to use an external 6.29375 MHz clock.
#define USE_6MHZ_CLOCK

#define SCANLINES_ACTIVE        480
#define SCANLINES_VFRONTPORCH   10
#define SCANLINES_VSYNC         2
#define SCANLINES_VBACKPORCH    33

.global generate_vga_640x480x60

// ===========================================================================
// vga_hfporch
// Generates the horizontal front porch.
// ===========================================================================
.macro vga_hfporch signal
      vga_out \signal                                   // 2
                                                        // 2 cycles * (8 dots / cycle) = 16 dots
.endm 

// ===========================================================================
// vga_hsync
// Generates the horizontal sync pulse.
// ===========================================================================
.macro vga_hsync signal
      vga_out \signal                                   // 2    
     spin 3                                             // 1 + (3 * 3) = 10
                                                        // 12 cycles * (8 dots / cycle) = 96 dots
.endm 

// ===========================================================================
// vga_hbporch
// Generates the horizontal back porch.
// ===========================================================================
.macro vga_hbporch signal
      vga_out \signal                                   // 2
     spin 1                                             // 1 + (1 * 3) = 4
                                                        // 6 cycles * (8 dots / cycle) = 48 dots
.endm 

// ===========================================================================
// vga_active
// Generates the active portion of the signal.
// ===========================================================================
.macro vga_active signal next_scanline_count, next_label, current_label
      vga_out \signal                                   // 2
      spin 23                                           // 1 + (23 * 3) = 70
      nop                                               // 1
      nop                                               // 1
      vga_load_next_scanline \
        \next_scanline_count, \
        \next_label, \
        \current_label                                  // 6
                                                        // 80 cycles * (8 dots / cycle) = 640 dots
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
// generate_vga_640x480x60
// Generates VGA sync pulses for a resolution of 640x480 at 60 Hz.
// Expects an external 25.175 MHz clock by default, but you can define either
// USE_6MHZ_CLOCK or USE_12MHZ_CLOCK to use a different external clock speed.
// ===========================================================================
generate_vga_640x480x60:
       vga_ddr_init
       ldi REG_VGA, 0b10000000
       out _SFR_IO_ADDR(CLKPR), REG_VGA
  #if defined(USE_6MHZ_CLOCK)
       ldi REG_VGA, 0b00000001
#elif defined(USE_12MHZ_CLOCK)
       ldi REG_VGA, 0b00000010
#else
       ldi REG_VGA, 0b00000011
#endif
       out _SFR_IO_ADDR(CLKPR), REG_VGA
       ldi REG_SCANLINE_LO, lo8(SCANLINES_ACTIVE);
       ldi REG_SCANLINE_HI, hi8(SCANLINES_ACTIVE);
      rjmp scanline_active