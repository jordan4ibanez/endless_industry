#!/bin/bash

# convert -extract 128x128+0+0 character_mining_cycles_raw.png 1.png


HORIZONTAL_FRAMES=$((4 - 1))
DIRECTIONS=$((8 - 1))
FRAME_SIZE=128
SOURCE_FILE="character_mining_cycles_raw.png"

for Y in $(seq 0 $DIRECTIONS); do

    OFFSET_Y=$((FRAME_SIZE * $Y))

    for X in $(seq 0 $HORIZONTAL_FRAMES); do

        OFFSET_X=$((FRAME_SIZE * $X))

        OUTPUT_NAME="player_mining_direction_${Y}_frame_${X}"

        echo "$OUTPUT_NAME"


        convert -extract ${FRAME_SIZE}x${FRAME_SIZE}+${OFFSET_X}+${OFFSET_Y} ${SOURCE_FILE} ${OUTPUT_NAME}.png



        
        

        echo "$OFFSET_X | $OFFSET_Y"

    done
done