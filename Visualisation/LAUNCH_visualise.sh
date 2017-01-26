#!/bin/bash
#
#  Created by Ian Munro on 28/11/2016.
#


read -p "Please enter Lateral uncertainty [nm] ? " answer

echo $answer

if [ "$1" = "general" ]
then
one=$(qsub -v LATERAL_RES=$answer $HOME/Visualisation/vis_ARRScript.pbs )
echo "launching processing job"
echo $one
two=$(qsub -W depend=afterok:$one $HOME/Visualisation/vis_MERGEScript.pbs )
echo "launching merge job"
echo $two

else

echo "fogim queue"
one=$(qsub -q pqfogim -v LATERAL_RES=$answer $HOME/Visualisation/vis_ARRScript.pbs )
echo "launching processing job"
echo $one
two=$(qsub -q pqfogim -W depend=afterok:$one $HOME/Visualisation/vis_MERGEScript.pbs )
echo "launching merge job"
echo $two


fi




