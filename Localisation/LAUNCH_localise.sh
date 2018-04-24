#!/bin/bash
#
#   Created by Ian Munro on 19/07/2017.
#   Modified by Mark Neil on 23/04/2018.
#
#   Checks that required files are present and then submits localisation jobs to the PBS queuing system
#   followed by a single merge and postprocessing job
#
#   Expects arguments of a full path to a data set to be processesd and optionally a callibration file if
#   3D localisation is to take place.  Adding a callibration file therefore triggers 3D localisation.
#   An optional arguement of -b in position 1 forces only a single job to run.


USAGE="Usage: LAUNCH_localise [-b] filename(inc path) [calibration_file(name only - must be in same directory] <-b> "

function parse {
  export INPATH=$(dirname "${FULLNAME}")
  export FNAME=$(basename "${FULLNAME}")
  if [[ $(hostname -s) == "login-2-internal" ]]
  then
    if [ -f ${FULLNAME} ]
    then
      echo "File found!"
    else
      echo "Error! File not found!"
      exit 0
    fi
  else
    COMMAND="[ -f "${FULLNAME}" ]"
    if ssh ${USER}@login-2-internal ${COMMAND}
    then
      echo "File found!"
    else
      echo "Error! File not found!"
      exit 0
    fi
  fi
}


echo "fogim queue"
QUEUE="pqfogim"


FULLNAME=$1
INPATH=""
FNAME=""

echo "How many HPC nodes do you wand to use?"
read -p "Enter number of nodes on the HPC: " NJOBS

THREED=0

case "$#" in
1)
parse
ARGS="$INPATH":"$FNAME"
;;
2)
  parse
  if [ $2 == "-b" ]
  then 
    NJOBS=1
    ARGS="$INPATH":"$FNAME"
  else
    THREED=1
    ARGS="$INPATH":"$FNAME":"$2"
  fi
;;
3)
  parse
  if [ $3 == "-b" ]
  then 
    THREED=1
    NJOBS=1
    ARGS="$INPATH":"$FNAME":"$2"
  else
    echo $USAGE;
    exit 0
  fi
;;
*)
echo $USAGE;
exit 0
;;
esac

## check calibration file , if needed, exists
if [ $THREED == 1 ]
then
  if [[ $(hostname -s) == "login-2-internal" ]]
  then
    if [ -f ${INPATH}/${2} ]
    then
      echo "Calibration file found!"
    else
      echo "Error!  Calibration file not found!"
      exit 0
    fi
  else
    COMMAND="[ -f "${INPATH}"/"${2}" ]"
    if ssh ${USER}@login-2-internal ${COMMAND}
    then
      echo "Calibration file found!"
    else
      echo "Error!  Calibration file not found!"
      exit 0
    fi
  fi
fi



# set  work directory and no of jobs
ARGS="$ARGS":"$WORK":"$NJOBS"

#   $ARGS now contains the arguements to pass to the localisation script as a colon separated list.  THese are either
#   ARGS = {input file directory}:{input file name}:{working directory}:{numbero of jobs}
#   or
#   ARGS = {input file directory}:{input filename}:{calibration filename}:{working directory}:{number of jobs}
#   where does $THREED go?

if [ $NJOBS == "1" ]
then
  one=$(qsub -q $QUEUE -v SETUP_ARGS=$ARGS $HOME/Localisation/loc_ARRScriptSingle.pbs)
else
  one=$(qsub -q $QUEUE -v SETUP_ARGS=$ARGS $HOME/Localisation/loc_ARRScript.pbs)
fi
echo "launching processing job"
echo $one

# split name of first job to get pbsjob no
ARR=(${one//[/ })
JNO=${ARR[0]}

echo "Please enter Lateral uncertainty [nm] ? "
read -p " enter zero to disable preview images ? " lateral

two=$(qsub -q $QUEUE -W depend=afterok:$one -v SETUP_ARGS=$ARGS,JOBNO=$JNO,LATERAL_RES=$lateral,POST="DRIFT" $HOME/Localisation/loc_MERGEScript.pbs)

echo "launching merge job"
echo $two
#three=$(qsub -q $QUEUE -W depend=afterok:$two -v SETUP_ARGS=$ARGS,JOBNO=$JNO $HOME/Localisation/loc_TIDYScript.pbs )
#echo "launching tidy job"
#echo $three











