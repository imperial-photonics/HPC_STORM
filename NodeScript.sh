#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node

#  NB assume c-style numbering here
ONE=1
PBS_ARRAY_INDEX=$(( $1 + $ONE ))

#  get arg  list from file
ARGS=$(head -$PBS_ARRAY_INDEX args | tail -1)

#  hardwired paths TBD
HOME=/Users/imunro/HPC_STORM
IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx

#$IJ --ij2 -macro $HOME/TSTORM_macro.ijm $ARGS
if [ $PBS_ARRAY_INDEX > 1 ]
then

DELIMITER_VAL=':'

SPLIT_NOW=$(awk -F$DELIMITER_VAL '{for(i=1;i<=NF;i++){printf "%s\n", $i}}' <<<"${ARGS}")
while read -r line; do
SPLIT+=("$line")
done <<< "$SPLIT_NOW"
for i in "${SPLIT[@]}"; do
echo "$i"
done


fi



