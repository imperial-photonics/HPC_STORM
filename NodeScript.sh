#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node

#  NB assume c-style numbering here
ONE=1
PBS_ARRAY_INDEX=$(( $1  ))

#  get arg  list from file
ARGS=$(head -$PBS_ARRAY_INDEX args | tail -1)

#  hardwired paths TBD
HOME=/Users/imunro/HPC_STORM
IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx

# run ThunderSTORM
$IJ --ij2 -macro $HOME/TSTORM_macro.ijm $ARGS


if [ $PBS_ARRAY_INDEX -gt 1 ]
then

  echo "editing result file"

  OIFS="$IFS"
  IFS=':'
  read -a arr <<< "${ARGS}"
  IFS="$OIFS"


  WORK=${arr[0]}
  FILENAME=$WORK"/result"$PBS_ARRAY_INDEX".csv"
  
  FIRST=${arr[1]}

  nframes=$((${arr[2]} - $FIRST +1))

  sed -i -e '1d' "${FILENAME}"

  for NUM in `seq 1 1 $nframes`
  do
    fin=$(printf "%d\n" $NUM)
    REP=$(($NUM + $FIRST -$ONE))
    rep=$(printf "%d\n" $REP)

    sed -i -e  "s/^${fin}\.0,/${rep}\.0,/" "${FILENAME}"

  done


fi



