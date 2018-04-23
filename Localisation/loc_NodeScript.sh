#!/bin/sh

#  NodeScript.sh
#  
#
#  Created by Ian Munro on 4/07/2016.
#  The script that runs on each node

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

  if [ ! -d $WORK/$JOBNO ]
  then
    mkdir $WORK/$JOBNO
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
    if [[ $INPATH == "/external"* ]]
    then
      echo "secure copying data file"
      scp -q ${USER}@login-2-internal:${INPATH}/${NAME}*.ome.tif ${TMPSTORM}
      # ssh ${USER}@login-2-internal “cd ${INPATH};tar zcf ${NAME}*.ome.tif ” | tar  zxf –
    else
      echo "copying data file"
      cp ${INPATH}/${NAME}*.ome.tif ${TMPSTORM}
    fi
  fi
  
  if [ ! -f $TMPSTORM"/"$FNAME ]
  then
    echo "Copy failed!"
    exit 0
  fi
    

  if [ ${#ARRARGS[@]} == "6" ]
  then
    if [ ! -f $TMPSTORM"/"$CALIB ]
    then
      if [[ $INPATH == "/external"* ]]
      then
        echo "secure copying calibration file"
        scp -q ${USER}@login-2-internal:${INPATH}/${CALIB} ${TMPSTORM}
      else
        echo "copying calibration file"
        cp ${INPATH}/${CALIB} ${TMPSTORM}
      fi
    fi
  fi


  module load sysconfcpus/0.5

  # run ThunderSTORM
  
  # sysconfcpus -n $NCPUS $IJ --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  sysconfcpus -n 48 fiji --ij2 -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  # sysconfcpus -n 24 fiji -macro $HOME/Localisation/TSTORM_loc_macro.ijm $ARGS_FULL
  #echo "returned from Macro"


awk -v job_index=$PBS_ARRAY_INDEX -v job_no=$NJOBS 'BEGIN{FS=",";OFS=",";OFMT="%.2f"; getline }{$2=job_no*($2-1)+job_index; print $0}' $WORK/$JOBNO/tmp_"$NAME"_slice_$PBS_ARRAY_INDEX.csv  > $WORK/$JOBNO/tmp_"$NAME"_$PBS_ARRAY_INDEX.csv 

#mv $TMPSTORM/tmp_* $WORK/$JOBNO

echo "Finishing Localization time $(date)"

else
  echo "Dummy job returning!"
fi









