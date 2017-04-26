#!/bin/bash
#
#  Created by Ian Munro on 28/11/2016.
#


read -p "Please enter Lateral uncertainty [nm] ? " answer

echo $answer



if [ "$1" = "general" ]
then
one=$(qsub -v LATERAL_RES=$answer,POST="FILTER" $HOME/Visualisation/vis_Script.pbs )
echo "launching processing job"
echo $one
two=$(qsub -v LATERAL_RES=$answer,POST="DRIFT" $HOME/Visualisation/vis_Script.pbs )
echo "launching drift correction processing job"
echo $two


else

echo "fogim queue"
QUEUE="pqfogim"

one=$(qsub -q $QUEUE -v LATERAL_RES=$answer,POST="SIGMA_FILTER" $HOME/Visualisation/vis_Script.pbs )
echo "launching sigma filtering processing job"
echo $one
two=$(qsub -q $QUEUE -v LATERAL_RES=$answer,POST="DRIFT" $HOME/Visualisation/vis_Script.pbs )
echo "launching drift correction processing job"
echo $two

fi




