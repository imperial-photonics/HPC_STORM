#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node

echo "Start time $(date)"

PBS_ARRAY_INDEX=$(( $1 ))


#  hardwired paths TBD
HOME=/home/imunro
IJ=/apps/fiji/Fiji.app/ImageJ-linux64

#HOME=/Users/imunro/HPC_STORM
#IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx

ARGSFILE=$HOME"/args"


#  get arg  list from file
ARGS=$(head -$PBS_ARRAY_INDEX $ARGSFILE | tail -1)



echo "running TSTORM macro!"
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
  

  sed -i -e '1d' "${FILENAME}"


fi

echo "End time $(date)"

