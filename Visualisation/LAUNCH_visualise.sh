#!/bin/bash
#
#  Created by Ian Munro on 28/11/2016.
#


read -p "Please enter Lateral uncertainty [nm] ? " answer

echo $answer

if [ "$1" = "general" ]
then
one=$(qsub -v LATERAL_RES=$answer $HOME/Vis2/vis_Script.pbs )
echo "launching processing job"
echo $one


else

echo "fogim queue"
one=$(qsub -q pqfogim -v LATERAL_RES=$answer $HOME/Vis2/vis_Script.pbs )
echo "launching processing job"
echo $one


fi




