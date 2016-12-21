#!/bin/bash
#
#  Created by Ian Munro on 01/09/2016.
#

if [ "$1" = "general" ]
then

one=$(qsub $HOME/Localisation/loc_ARRScript.pbs )
echo "launching processing job"
echo $one
two=$(qsub -W depend=afterok:$one $HOME/Localisation/loc_MERGEScript.pbs )
echo "launching merge job"
echo $two

else

echo "fogim queue"
one=$(qsub -q pqfogim $HOME/Localisation/loc_ARRScript.pbs)
echo "launching processing job"
echo $one
two=$(qsub -q pqfogim -W depend=afterok:$one $HOME/Localisation/loc_MERGEScript.pbs )
echo "launching merge job"
echo $two

fi




