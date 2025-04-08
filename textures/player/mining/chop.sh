#!/bin/bash

# convert -extract 128x128+0+0 character_mining_cycles_raw.png 1.png

HORIZONTAL_FRAMES=$((4 - 1))
DIRECTIONS=$((8 - 1))
FRAME_SIZE=128
SOURCE_FILE="character_mining_cycles_raw.png"
OUTPUT_FRAME_SIZE=$((FRAME_SIZE - 40))
FRAME_SHIFT=20


for Y in $(seq 0 $DIRECTIONS); do

    OFFSET_Y=$(((FRAME_SIZE * $Y) + FRAME_SHIFT))

    OUTPUT_FOLDER=./direction_${Y}

    mkdir -p ${OUTPUT_FOLDER}

    for X in $(seq 0 $HORIZONTAL_FRAMES); do

        OFFSET_X=$(((FRAME_SIZE * $X) + FRAME_SHIFT))

        OUTPUT_NAME="player_mining_direction_${Y}_frame_${X}"

        # echo "$OUTPUT_NAME"
        # echo "$OFFSET_X | $OFFSET_Y"

        convert -extract ${OUTPUT_FRAME_SIZE}x${OUTPUT_FRAME_SIZE}+${OFFSET_X}+${OFFSET_Y} ${SOURCE_FILE} ${OUTPUT_FOLDER}/${OUTPUT_NAME}.png

    done
done