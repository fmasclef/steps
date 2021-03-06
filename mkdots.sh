#!/bin/bash

CIRCLE_RADIUS=8
COLOR_BACKGROUND="#ffffff"
COLOR_INNER_CURRENT="#1542c3"
COLOR_INNER_DONE="#ffffff"
COLOR_INNER_NEXT="#ffffff"
COLOR_OUTER_CURRENT="#1542c3"
COLOR_OUTER_DONE="#1542c3"
COLOR_OUTER_NEXT="#999999"
OUTPUT_PNG=1
PADDING=5
STROKE_WIDTH=1

# startup checks

if [ $# -eq 0 ]; then
    echo "Syntax: $0 <steps>"; exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]] ; then
   echo "error: Not a number" >&2; exit 1
fi

if [ -f ".config_dots" ]; then
  echo "Configuration file found, using it"
  . .config_dots
fi

# compute SVG dimensions

let DOT_XY=(${CIRCLE_RADIUS}+${STROKE_WIDTH})*2+2
let SVG_WIDTH=${DOT_XY}*$1+${PADDING}*2
let SVG_HEIGTH=${DOT_XY}+${PADDING}*2

echo "SVG: ${SVG_WIDTH}x${SVG_HEIGTH}"

# prepare HTML file
INDEX="index.html"
echo "<!DOCTYPE html><html><head><title>Dotline</title></head><body>" > ${INDEX}
echo "<p align=\"center\">" > ${INDEX}

# loop thru steps and generate SVG

for (( step=1; step<=$1; step++ ))
do
  FILENAME="${step}_of_${1}.svg"
  echo "generating file ${FILENAME}"
  # SVG wrapper
  echo "<?xml version=\"1.0\" standalone=\"no\"?>" > ${FILENAME}
  echo "<svg version=\"1.1\" width=\"${SVG_WIDTH}\" height=\"${SVG_HEIGTH}\" viewBox=\"0 0 ${SVG_WIDTH} ${SVG_HEIGTH}\" xmlns=\"http://www.w3.org/2000/svg\">" >> ${FILENAME}
  echo "<!-- github.com/fmasclef/steps -->" >> ${FILENAME} 
  echo "<rect width=\"${SVG_WIDTH}\" height=\"${SVG_HEIGTH}\" fill=\"${COLOR_BACKGROUND}\" />" >> ${FILENAME}
  echo "<g transform=\"translate(${PADDING} ${PADDING})\">" >>  ${FILENAME}
  # loop thru dots
  for (( dot=1; dot<=$1; dot++ ))
  do
    # compute position and colors
    let CIRCLE_CX=(${dot}-1)*${DOT_XY}+${DOT_XY}/2
    let CIRCLE_CY=${DOT_XY}/2
    CIRCLE_INNER=${COLOR_INNER_CURRENT}
    CIRCLE_OUTER=${COLOR_OUTER_CURRENT}
    if (( ${dot} < ${step} )) ; then
      CIRCLE_INNER=${COLOR_INNER_DONE}
      CIRCLE_OUTER=${COLOR_OUTER_DONE}
    fi
    if (( ${dot} > ${step} )) ; then
      CIRCLE_INNER=${COLOR_INNER_NEXT}
      CIRCLE_OUTER=${COLOR_OUTER_NEXT}
    fi
    # draw the dot
    echo "<circle cx=\"${CIRCLE_CX}\" cy=\"${CIRCLE_CY}\" r=\"${CIRCLE_RADIUS}\" fill=\"${CIRCLE_INNER}\" stroke=\"${CIRCLE_OUTER}\" stroke-width=\"${STROKE_WIDTH}\" />" >> ${FILENAME}
  done
  # close SVG tag
  echo "</g>" >>  ${FILENAME}
  echo "</svg>" >> ${FILENAME}
  echo "<img src=\"${FILENAME}\" border=0 alt=\"Step ${dot}\"/><br />" >> ${INDEX}
done

# close HTML
echo "</p>" >> ${INDEX}
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