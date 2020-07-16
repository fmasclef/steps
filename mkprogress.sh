#!/bin/bash

CIRCLE_OUTER_RADIUS=50
CIRCLE_INNER_RADIUS=40
COLOR_BACKGROUND="#ffffff"
COLOR_INNER_INFO="#1542c3"
COLOR_INNER_WARNING="#c39615"
COLOR_INNER_DANGER="#bb2124"
COLOR_OUTER_INFO="#728ddb"
COLOR_OUTER_WARNING="#dbc072"
COLOR_OUTER_DANGER="#d6797b"
FONT_COLOR="#ffffff"
FONT_FAMILY="Verdana"
FONT_SIZE=25
OUTPUT_PNG=1
PADDING=5
STROKE_WIDTH=5
WRITE_VALUE=1

# startup checks

if [ $# -eq 0 ]; then
    echo "Syntax: $0 <percent>"; exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]] ; then
   echo "error: Not a number" >&2; exit 1
fi
let ANGLE=360*$1/100

if [ -f ".config_progress" ]; then
  echo "Configuration file found, using it"
  . .config_progress
fi

# compute SVG dimensions

let DOT_XY=${CIRCLE_OUTER_RADIUS}*2
let SVG_WIDTH=${DOT_XY}+${PADDING}*2
let SVG_HEIGTH=${DOT_XY}+${PADDING}*2
let CIRCLE_CX=${DOT_XY}/2
let CIRCLE_CY=${DOT_XY}/2

echo "SVG: ${SVG_WIDTH}x${SVG_HEIGTH}, ANGLE: ${ANGLE}°"

# prepare HTML file
INDEX="index.html"
echo "<!DOCTYPE html><html><head><title>Progress report</title></head><body>" > ${INDEX}

# loop thru steps and generate SVG
for level in INFO WARNING DANGER
do
  COLOR_INNER="COLOR_INNER_${level}"
  COLOR_OUTER="COLOR_OUTER_${level}"
  PCENT=0
  echo "<p>" >> ${INDEX}
  for (( step=0; step<=360; step+=${ANGLE} ))
  do
    FILENAME="progress_${level}_${PCENT}.svg"
    echo "generating file ${FILENAME}"
    # SVG wrapper
    echo "<?xml version=\"1.0\" standalone=\"no\"?>" > ${FILENAME}
    echo "<svg version=\"1.1\" width=\"${SVG_WIDTH}\" height=\"${SVG_HEIGTH}\" viewBox=\"0 0 ${SVG_WIDTH} ${SVG_HEIGTH}\" xmlns=\"http://www.w3.org/2000/svg\">" >> ${FILENAME}
    echo "<!-- github.com/fmasclef/steps -->" >> ${FILENAME} 
    echo "<rect width=\"${SVG_WIDTH}\" height=\"${SVG_HEIGTH}\" fill=\"${COLOR_BACKGROUND}\" />" >> ${FILENAME}
    echo "<g transform=\"translate(${PADDING} ${PADDING})\">" >>  ${FILENAME}
    # compute position
    let ARC_START_X=CIRCLE_CX+${CIRCLE_OUTER_RADIUS}
    let ARC_START_Y=CIRCLE_CY
    ARC_STOP_X=$(echo "c(${step}*3.1415927/180)*${CIRCLE_OUTER_RADIUS}+${CIRCLE_CX}" | bc -l)
    ARC_STOP_Y=$(echo "s(${step}*3.1415927/180)*${CIRCLE_OUTER_RADIUS}+${CIRCLE_CY}" | bc -l)
    let ARC_SWEEP=0
    if (( ${step} > 180 )) ; then
      ARC_SWEEP=1
    fi
    # draw the inner circle
    echo "<circle cx=\"${CIRCLE_CX}\" cy=\"${CIRCLE_CY}\" r=\"${CIRCLE_INNER_RADIUS}\" fill=\"${!COLOR_INNER}\" />" >> ${FILENAME}
    # draw the outer progress indicator
    if (( ${step} > 0 && ${step} < 360 )) ; then
      echo "<path d=\"M ${ARC_START_X} ${ARC_START_Y} A ${CIRCLE_OUTER_RADIUS} ${CIRCLE_OUTER_RADIUS} 0 ${ARC_SWEEP} 1 ${ARC_STOP_X} ${ARC_STOP_Y}\" fill=\"none\" stroke=\"${!COLOR_OUTER}\" stroke-width=\"${STROKE_WIDTH}\" />" >> ${FILENAME}
    fi
    if (( ${step} >= 360 )) ; then
      echo "<circle cx=\"${CIRCLE_CX}\" cy=\"${CIRCLE_CY}\" r=\"${CIRCLE_OUTER_RADIUS}\" fill=\"none\" stroke=\"${!COLOR_OUTER}\" stroke-width=\"${STROKE_WIDTH}\" />" >> ${FILENAME}
    fi
    # close SVG group
    echo "</g>" >>  ${FILENAME}
    # add caption
    if (( ${WRITE_VALUE} == 1 )); then
      echo "<text x=\"50%\" y=\"50%\" dominant-baseline=\"central\" text-anchor=\"middle\" style=\"font-family:${FONT_FAMILY}; font-size:${FONT_SIZE}; stroke:${FONT_COLOR}; fill:${FONT_COLOR}\">${PCENT}%</text>" >> ${FILENAME}
    fi
    # close SVG tag
    echo "</svg>" >> ${FILENAME}
    echo "<img src=\"${FILENAME}\" border=0 alt=\"${level} ${PCENT}\"/>" >> ${INDEX}
    let PCENT+=$1
  done
  echo "</p>" >> ${INDEX}
done

# close HTML
echo "<p align=\"center\"><a href=\"https://github.com/fmasclef/steps\" alt=\"Public GitHub\"><code>github.com/fmasclef/steps</code></a></p>" >> ${INDEX}
echo "</body></html>" >> ${INDEX}

# convert to PNG if needed
if (( ${OUTPUT_PNG} == 1 )); then
  echo "Creating PNGs"
  command -v convert >/dev/null 2>&1 || { echo >&2 "I require convert but it's not installed. Aborting."; exit 1; }
  for f in *.svg
  do
    echo "Converting $f to  ${f%.*}.png"
    $(convert ${f} ${f%.*}.png)
  done
fi

echo "Thanks for using."