#!/bin/bash
#
#  Created by Ian Munro on 22/03/2017.
#

USAGE="Usage: PREVIEW filename <calibration_filename> "


case "$#" in
1)
   ARGS="$WORK":"$1":"$HOME"
   ;;
2)
   ARGS="$WORK":"$1":"$2":"$HOME"
   ;;
*)
   echo $USAGE;
   exit 0
   ;;
esac

echo $ARGS

read -p "Please enter Lateral uncertainty [nm] ? " answer

echo $answer



cd $HOME/Localisation

echo "fogim queue"
QUEUE="pqfogim"

one=$(qsub -q $QUEUE -v SETUP_ARGS=$ARGS $HOME/Localisation/setupScript.pbs)
echo "launching setup job"
echo $one
two=$(qsub -q $QUEUE -W depend=afterok:$one $HOME/Localisation/loc_ARRScript.pbs)
echo "launching Localisation processing job"
echo $two
three=$(qsub -q $QUEUE -W depend=afterok:$two $HOME/Localisation/loc_MERGEScript.pbs )
echo "launching localisation merge job"
echo $three

cd $HOME/Visualisation

four=$(qsub -q $QUEUE -v LATERAL_RES=$answer,POST="SIGMA_FILTER" -W depend=afterok:$three $HOME/Visualisation/vis_Script.pbs )
echo "launching sigma filtering job"
echo $four
five=$(qsub -q $QUEUE -v LATERAL_RES=$answer,POST="DRIFT" -W depend=afterok:$three $HOME/Visualisation/vis_Script.pbs )
echo "launching drift correction job"
echo $five









