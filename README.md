# tinyvga
This program will allow an ATtiny84 or ATtiny85 microcontroller to generate VGA-compatible timing signals at any of the currently supported resolutions listed below.
The only external support circuitry which is required is a clock source with a frequency that depends on the desired resolution. 

| Horizontal | Vertical | Refresh Rate | Required Clock Frequency                          |
| ---------- | -------- | ------------ | ------------------------------------------------- |
| 640        | 480      | 60           | 25.175 MHz, 12.5875 MHz, or 6.29375 MHz (default) |
| 800        | 600      | 60           | 40 MHz, 20 MHz, or 10 MHz (default)               |
| 1024       | 768      | 60           | 65 MHz, 32.5 MHz, or 16.25 MHz (default)          |
| 1280       | 1024     | 60           | 108 MHz, 27 MHz, or 13.5 MHz (default)            |

The specific frequency which is expected by each resolution's signal generator can be selected at compile time by defining certain preprocessor symbols; the frequency marked 
as "(default)" is the one which is used if this repository is compiled without modifications. In all cases, the clock input is prescaled such that the microcontroller's
system clock is 1/8 of the resolution's standard pixel clock.

Note that the datasheets are unclear about the maximum frequency which can be fed into the prescaler. For that reason, it's recommended that you stick to the default frequency
values, all of which fall within the maximum limit specified for the ATtiny84 and ATtiny85's system clocks at 5 volts (which is 20 MHz).

Due to a lack of pins, the ATtiny85 can only output a single resolution. By default, this is 640x480@60, but you can change this by altering the value of 
the `DEFAULT_RESOLUTION_HANDLER` symbol in `devices.h`. The ATtiny84, however, can output any of the supported resolutions. The PB6 and PB7 pins are configured as
inputs which are read at startup. Depending on the values of these pins, a different resolution is selected, as per the table below.

| PB6 | PB7 | Resolution   |
| --- | --- | ------------ |
| 0   | 0   | 640x480@60   |
| 0   | 1   | 800x600@60   |
| 1   | 0   | 1024x768@60  |
| 1   | 1   | 1280x1024@60 |

You can therefore change the resolution of the generated signals by changing the values of PB6 and PB7 and resetting the microcontroller, but remember that you'll also need
external circuitry to switch to the appropriate clock frequency while the device is still in reset.

While running, this program generates the timing signals listed below and presents them on the specified pins; note that the ATtiny85 does not provide 
the `!ACTIVE` signal due to a lack of GPIO pins.

| Signal  | ATtiny84 Pin | ATtiny85 Pin | Description                                   |
| ------- | ------------ | ------------ | --------------------------------------------- |
|  HBLANK | PA0          | PB0          | Low during horizontal blanking interval.      |
|  HSYNC  | PA1          | PB1          | Low during horizontal sync pulse.             |
|  VBLANK | PA2          | PB2          | Low during vertical blanking interval.        |
|  VSYNC  | PA3          | PB4          | Low during vertical sync pulse.               |
|  ACTIVE | PA4          | PB5*         | High during the visible region of the signal. |
| !ACTIVE | PA5          | -            | Low during the visible region of the signal.  |

\* PB5 on the ATtiny85 is normally the `!RESET` pin, so this is only available if you disable `!RESET` via the `RSTDISBL` fuse.
