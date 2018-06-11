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

echo "fogim queue"
QUEUE="pqfogim"
echo $QUEUE

INPATH=""
FNAME=""

echo "How many HPC nodes do you want to use?"
read -p "Enter number of nodes on the HPC: " NJOBS

echo "How many jobs per do you want to use?"
read -p "Enter number of jobs per node, use fewer for large or 3D datasets: " JPERNODE

export NJOBS
export JPERNODE
export THREED=0

case "$#" in
    1)
        FULLNAME=$1
        ;;
    2)
        if [ $1 == "-b" ]; then
            NJOBS=1
            FULLNAME=$2
        elif [ $2 == "-b" ]; then
            NJOBS=1
            FULLNAME=$1
        else
            THREED=1
            FULLNAME=$1
            export CALIB=$2
        fi
        ;;
    3)
        THREED=1
        NJOBS=1
        if [ $1 == "-b" ]; then
            FULLNAME=$2
            export CALIB=$3
        elif [ $2 == "-b" ]; then
            FULLNAME=$1
            export CALIB=$3
        elif [ $3 == "-b" ]; then
            FULLNAME=$1
            export CALIB=$2
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

## check input data and calibration file, if needed, exist

export INPATH=$(dirname "${FULLNAME}")
export FNAME=$(basename "${FULLNAME}")
if [[ $(hostname -s) == "login-2-internal" ]]; then
    if [ -f ${FULLNAME} ]; then
        echo "File found!"
    else
        echo "Error! File not found!"
        exit 0
    fi
else
    COMMAND="[ -f "${FULLNAME}" ]"
    if ssh ${USER}@login-2-internal ${COMMAND}; then
        echo "File found!"
    else
        echo "Error! File not found!"
        exit 0
    fi
fi
if [ $THREED == 1 ]; then
    if [[ $(hostname -s) == "login-2-internal" ]]; then
        if [ -f ${INPATH}/${CALIB} ]; then
            echo "Calibration file found!"
        else
            echo "Error!  Calibration file not found!"
            exit 0
        fi
    else
        COMMAND="[ -f "${INPATH}"/"${CALIB}" ]"
        if ssh ${USER}@login-2-internal ${COMMAND}; then
            echo "Calibration file found!"
        else
            echo "Error!  Calibration file not found!"
            exit 0
        fi
    fi
fi

ARRFNAME=(${FNAME//.ome/ })
export NAME=${ARRFNAME[0]}

# Look for camera name in the ome-tif metadata which sits at the end of the ome.tif file - needs to be fixed so it can be read in imagej properly!
export CAMERA=`tiffinfo -0 ${FULLNAME} 2> /dev/null | grep Detector |  sed 's/^.*Detector ID="// ; s/".*$//' | tr " " "_"`
# export CAMERA=`tiffinfo -0 ${FULLNAME} 2> /dev/null | grep Detector |  sed 's/^.*Detector ID="// ; s/".*$//' `

#   environment variables $INPATH $FNAME $NJOBS $JPERNODE $THREED $CALIB $NAME $CAMERA now contain the necessary information for the other scripts to work

if [ $NJOBS == "1" ]; then
    one=$(qsub -q $QUEUE -m abe -M ${USER} -V $HOME/Localisation/NodeScript_Multi.pbs)
else
    echo qsub -q $QUEUE -m abe -M ${USER} -V -J 1-$NJOBS $HOME/Localisation/NodeScript_Multi.pbs
    one=$(qsub -q $QUEUE -m abe -M ${USER} -V -J 1-$NJOBS $HOME/Localisation/NodeScript_Multi.pbs)
fi
echo "launching processing job"
echo $one

# split name of first job to get pbsjob no
export JOBNO=`expr "$one" : '\([0-9]*\)'`
echo ${JOBNO}

mkdir ${WORK}/${JOBNO}        # Create a directory in $WORK to take shared temporary output files

#create a subdir to hold the outputs from this job

if [ ! -d ${INPATH}/${JOBNO} ]; then  # This probably doesn't work if the file is in an external directory
mkdir ${INPATH}/${JOBNO}
fi

echo "Please enter Lateral uncertainty for reconstruction [nm] ? "
read -p " enter zero to disable preview images ? " lateral

export LATERAL_RES=$lateral
export POST_PROC="DRIFT"
#   environment variables $JOBNO, $POST_PROC and $LATERAL_RES are exported for use in merge and post processing scripts

two=$(qsub -q $QUEUE -W depend=afterok:$one -V $HOME/Localisation/MergeScript.pbs)

echo "launching merge job"
echo $two
#three=$(qsub -q $QUEUE -W depend=afterok:$two -v SETUP_ARGS=$ARGS,JOBNO=$JNO $HOME/Localisation/loc_TIDYScript.pbs )
#echo "launching tidy job"
#echo $three











