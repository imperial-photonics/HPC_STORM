#!/bin/bash
#
#  Created by Ian Munro on 01/09/2016.
#


one=$(qsub ARRVNCScript.pbs)
echo "launching processing job"
echo $one
two=$(qsub -W depend=afterok:$one MERGEScript.pbs)
echo "launching merge job"
echo $two



