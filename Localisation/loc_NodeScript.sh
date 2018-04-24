#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node
#
#   Expects to be called with one arguement which is a colon seperated list.  This is either
#   ARGS = {input file directory}:{input file name}:{working directory}:{numbero of jobs}:{PBS_array_index}
#   or
#   ARGS = {input file directory}:{input filename}:{calibration filename}:{working directory}:{number of jobs}:{PBS_array_index}

set > $WORK/loc_NodeScript$PBS_ARRAY_INDEX.log
echo $* >> $WORK/loc_NodeScript$PBS_ARRAY_INDEX.log
exit

echo "Start Localization time $(date)"

#  hardwired paths TBD
IJ=/apps/fiji/Fiji.app/ImageJ-linux64

#HOME=/Users/imunro/HPC_STORM
#IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx

ARGS="$1"

ARRARGS=(${ARGS//:/ })
INPATH=${ARRARGS[0]}
FNAME=${ARRARGS[1]}

if [ ${#ARRARGS[@]} == "5" ];then
  NJOBS=${ARRARGS[3]}
else
  CALIB=${ARRARGS[2]}
  NJOBS=${ARRARGS[4]}
fi

# add environment variables to args list
ARGS_FULL="$1":"$TMPDIR"

# if NJOBS == 1 &&  jobs and PBS_ARRAY_INDEX > 1
# then this is a dummy array job so do nothing
if [[ $NJOBS  != 1  ]] || [[  $PBS_ARRAY_INDEX == 1 ]]
then

  ARRFNAME=(${FNAME//.ome/ })
  NAME=${ARRFNAME[0]}


  # split name of temp dir to get pbsjob no
  ARR=(${TMPDIR//./ })
  STR=${ARR[1]}
  ARR=(${STR//[/ })
  JOBNO=${ARR[0]}
  
  
  echo "Jobno = "
  echo $JOBNO


  #create a subdir to hold the outputs from this job

  if [ ! -d $INPATH/$JOBNO ]
  then
    mkdir $INPATH/$JOBNO
  fi

  #if current data file does not exist then copy
  if [ ! -f $TMPDIR"/"$FNAME ]
  then
    rm ${TMPDIR}"/*"
    if [[ $INPATH == "/external"* ]]
    then
      echo "secure copying data file"
      scp -q ${USER}@login-2-internal:${INPATH}/${NAME}*.ome.tif ${TMPDIR}
      # ssh ${USER}@login-2-internal “cd ${INPATH};tar zcf ${NAME}*.ome.tif ” | tar  zxf –
    else
      echo "copying data file"
      cp ${INPATH}/${NAME}*.ome.tif ${TMPDIR}
    fi
  fi
  
  if [ ! -f $TMPDIR"/"$FNAME ]
  then
    echo "Copy failed!"
    exit 0
  fi
    

  if [ ${#ARRARGS[@]} == "6" ]
  then
    if [ ! -f $TMPDIR"/"$CALIB ]
    then
      if [[ $INPATH == "/external"* ]]
      then
        echo "secure copying calibration file"
        scp -q ${USER}@login-2-internal:${INPATH}/${CALIB} ${TMPDIR}
      else
        echo "copying calibration file"
        cp ${INPATH}/${CALIB} ${TMPDIR}
      fi
    fi
  fi

  module load sysconfcpus/0.5

  # run ThunderSTORM
  
  # sysconfcpus -n $NCPUS $IJ --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  sysconfcpus -n 48 fiji --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  # sysconfcpus -n 24 fiji -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  #echo "returned from Macro"


awk -v job_index=$PBS_ARRAY_INDEX -v job_no=$NJOBS 'BEGIN{FS=",";OFS=",";OFMT="%.2f"; getline }{$2=job_no*($2-1)+job_index; print $0}' $TMPDIR/tmp_"$NAME"_slice_$PBS_ARRAY_INDEX.csv  > $WORK/$JOBNO/tmp_"$NAME"_$PBS_ARRAY_INDEX.csv

if [ $PBS_ARRAY_INDEX == 1]
then
    head -1 $TMPDIR/tmp_"$NAME"_slice_1.csv > $WORK/$JOBNO/"$NAME".csv
fi

echo "Finishing Localization time $(date)"

else
  echo "Dummy job returning!"
fi









