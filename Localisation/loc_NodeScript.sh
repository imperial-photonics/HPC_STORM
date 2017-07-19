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

ARGS="$1"

ARRARGS=(${ARGS//:/ })
WORKPATH=${ARRARGS[0]}
FNAME=${ARRARGS[1]}

if [ ${#ARRARGS[@]} == "4" ];then
NJOBS=${ARRARGS[2]}
else
NJOBS=${ARRARGS[3]}
fi


# if NJOBS == 1 &&  jobs and PBS_ARRAY_INDEX > 1
# then this is a dummy array job so do nothing
if [[ $NJOBS  != 1  ]] || [[  $PBS_ARRAY_INDEX == 1 ]]
then

ARRFNAME=(${FNAME//.ome/ })
NAME=${ARRFNAME[0]}


# split name of temp dir to get pbsjob no
ARR=(${TMPDIR//[/ })
STR=${ARR[0]}
JOBNO="${STR:(-7)}"


#create a subdir to hold the outputs from this job

echo $WORKPATH/$JOBNO

if [ ! -d $WORKPATH/$JOBNO ]
then
mkdir $WORKPATH/$JOBNO
fi

# create our own TMP DIRECTORY for this job
# persistent across all the jobs of the array
TMPSTORMU="/var/tmp/STORM_temp_"$USER
TMPSTORM="/var/tmp/STORM_temp_"$USER"/"$JOBNO


# add environment variables to args list
ARGS_FULL="$1":"$TMPSTORM"

#echo $ARGS_FULL

# if tmp directory does not exist
if [ ! -d $TMPSTORMU ]
then
  mkdir $TMPSTORMU
fi

if [ ! -d $TMPSTORMU ]
then 
  echo  "failed to create user temporary dir!!"
fi


# if tmp directory does not exist
if [ ! -d $TMPSTORM ]
then
  mkdir $TMPSTORM
fi

if [ ! -d $TMPSTORM ]
then 
  echo  "failed to create job temporary dir!!"
fi

#if current data file does not exist then copy
if [ ! -f $TMPSTORM"/"$FNAME ]
then
rm ${TMPSTORM}"/*"
echo "copying"
cp "${WORKPATH}"/"${NAME}"*.ome.tif "${TMPSTORM}"
fi

module load sysconfcpus/0.5

# run ThunderSTORM
sysconfcpus -n $NCPUS $IJ --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL

#echo "returned from Macro"


mv $TMPSTORM/tmp_* $WORKPATH/$JOBNO

else
  echo "Dummy job returning!"
fi









