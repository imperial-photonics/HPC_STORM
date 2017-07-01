#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node

echo "Start time $(date)"

#  hardwired paths TBD
IJ=/apps/fiji/Fiji.app/ImageJ-linux64

#HOME=/Users/imunro/HPC_STORM
#IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx


#create our own TMP DIRECTORY inc users name
TMPSTORM="/var/tmp/STORM_temp"$USER



# add environment variables to args list
ARGS_FULL="$1":"$TMPSTORM"

#echo $ARGS_FULL


# if tmp directory already exists
if [ ! -d $TMPSTORM ]
then
mkdir $TMPSTORM
fi

ARRARGS=(${ARGS_FULL//:/ })
FNAME=${ARRARGS[1]}
echo "FNAME = "
echo $FNAME

#if current data file does not exist then copy
if [ ! -f $TMPSTORM"/"$FNAME ]
then
rm $TMPSTORM"/*"
cp $WORK"/"$FNAME $TMPSTORM"/"$FNAME
fi


module load sysconfcpus/0.5


# run ThunderSTORM
sysconfcpus -n $NCPUS $IJ --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL

#echo "returned from Macro"


mv $TMPSTORM/tmp_* $WORK/Localisation

#rm -rf $TMPSTORM









