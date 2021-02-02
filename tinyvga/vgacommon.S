// ===========================================================================
// vgacommon.S
// ===========================================================================

// ===========================================================================
// spin (1 + [3 * loops] cycles)
// Blocks execution for a specified number of loops. Each loop takes 3 cycles,
// and spin initialization takes an additional cycle.
// ===========================================================================
.macro spin loops
      ldi REG_SPINLOOP, \loops
1:    dec REG_SPINLOOP
     brne 1b
      nop
.endm

// ===========================================================================
// vga_ddr_init
// Initializes the data direction register (DDR) for the VGA output port.
// ===========================================================================
.macro vga_ddr_init
       in REG_VGA, DDR_VGA
      ori REG_VGA, VGA_MASK
      out DDR_VGA, REG_VGA    
.endm

// ===========================================================================
// vga_out (2 cycles)
// Outputs the specified VGA signal value.
// ===========================================================================
.macro vga_out value
      ldi REG_VGA, \value
      out PORT_VGA, REG_VGA
.endm

// ===========================================================================
// vga_load_next_scanline (6 cycles)
// Decrements the scanline counter and jumps to the next scanline handler.
// ===========================================================================
.macro vga_load_next_scanline next_scanline_count, next_label, current_label
     sbiw REG_SCANLINE_LO, 1                            // 2
     brne 1f                                            // 1 (false) / 2 (true)
      ldi REG_SCANLINE_LO, lo8(\next_scanline_count)    // 1 (false)
      ldi REG_SCANLINE_HI, hi8(\next_scanline_count)    // 1 (false)
     rjmp \next_label                                   // 2 (false)
1:    nop                                               // 1 (true)
     rjmp \current_label                                // 2 (true)
                                                        // 7 cycles
.endm