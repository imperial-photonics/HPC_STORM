#!/bin/bash
#
#  Created by Ian Munro on 01/09/2016.
#

if [ "$1" = "pqfogim" ]
then
echo "fogim queue"
one=$(qsub -q pqfogim ARRVNCScript.pbs)
echo "launching processing job"
echo $one
two=$(qsub -q pqfogim -W depend=afterok:$one MERGEScript.pbs )
echo "launching merge job"
echo $two

else

one=$(qsub ARRVNCScript.pbs )
echo "launching processing job"
echo $one
two=$(qsub -W depend=afterok:$one MERGEScript.pbs)
echo "launching merge job"
echo $two

fi




