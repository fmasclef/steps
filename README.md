# Steps indicator

This shell script creates a series of visual SVG indicators you could use to show progress on slides.

# Usage

This is pure shell and should run on most Linux or macOS. Invoke from command line to generate your very own indicators.

    ./mkdots.sh <steps>

Let's say you need a 8 steps indicator, run `./mkdots.sh 8`. This will generate the following SVG files :

![Step 1](sample/1_of_8.svg)<br/>
![Step 2](sample/2_of_8.svg)<br/>
![Step 3](sample/3_of_8.svg)<br/>
![Step 4](sample/4_of_8.svg)<br/>
![Step 5](sample/5_of_8.svg)<br/>
![Step 6](sample/6_of_8.svg)<br/>
![Step 7](sample/7_of_8.svg)<br/>
![Step 8](sample/8_of_8.svg)<br/>

# Configuration

Some options can be tweaked to suit your mood. You should edit `.config` to override default settings.

    CIRCLE_RADIUS=8                  # guess what?
    COLOR_BACKGROUND="#ffffff"       # avoid transparent SVG
    COLOR_INNER_CURRENT="#1542c3"    # current step color
    COLOR_INNER_DONE="#ffffff"       # past steps color
    COLOR_INNER_NEXT="#ffffff"       # upcoming steps color
    COLOR_OUTER_CURRENT="#1542c3"    # current step color
    COLOR_OUTER_DONE="#1542c3"       # past steps color
    COLOR_OUTER_NEXT="#999999"       # upcoming steps color
    OUTPUT_PNG=1                     # produce PNG as well
    PADDING=5                        # outermost padding
    STROKE_WIDTH=1                   # speaks for itself

Beware of the `OUTPUT_PNG` option. It relies on `convert`. This script checks for `convert` prior trying to use it. So don't expect PNGs if `convert` is not available to you.

# Dependencies

Well, there's basically no dependency. Anyway, as stated above, `ImageMagick` is required for generating PNGs. You might install it using any package manager.