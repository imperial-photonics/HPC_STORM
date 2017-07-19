#!/bin/bash
#
#  Created by Ian Munro on 19/07/2017.
#


USAGE="Usage: BATCH_localise filename(inc path) <calibration_filename> <-b> "

function parse {
WORKPATH=$(dirname "${FULLNAME}")
echo $PATH
FNAME=$(basename "${FULLNAME}")
echo $FNAME
}

echo "fogim queue"
QUEUE="pqfogim"


FULLNAME=$1
WORKPATH=""
FNAME=""

NJOBS=8

case "$#" in
1)
parse
ARGS="$WORKPATH":"$FNAME"
;;
2)
  parse
  if [ $2 == "-b" ]
  then 
    NJOBS=1
    ARGS="$WORKPATH":"$FNAME"
  else
    ARGS="$WORKPATH":"$FNAME":"$2"
  fi
;;
3)
  parse
  if [ $3 == "-b" ]
  then 
    NJOBS=1
    ARGS="$WORKPATH":"$FNAME":"$2"
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

echo $ARGS

# set no of jobs
ARGS="$ARGS":"$NJOBS"



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


two=$(qsub -q $QUEUE -W depend=afterok:$one -v SETUP_ARGS=$ARGS,JOBNO=$JNO,LATERAL_RES=$lateral,POST="SIGMA_DRIFT" $HOME/Localisation/loc_MERGEScript.pbs )
echo "launching merge job"
echo $two
three=$(qsub -q $QUEUE -W depend=afterok:$one -v SETUP_ARGS=$ARGS,JOBNO=$JNO $HOME/Localisation/loc_TIDYScript.pbs )
echo "launching tidy job"
echo $three











