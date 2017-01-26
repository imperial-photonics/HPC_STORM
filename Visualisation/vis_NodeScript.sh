#!/bin/sh
#  vis_NodeScript.pbs
#  

#  Created by Ian Munro on 23/01/2017.
#  Visualisation script that runs on each node.

PBS_ARRAY_INDEX=$(( $1 ))

echo "ncpus on node = "
echo $NCPUS

#  hardwired paths TBD
IJ=/apps/fiji/Fiji.app/ImageJ-linux64

# HOME=/Users/imunro/HPC_STORM
# IJ=/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx


ARGSFILE=$HOME"/args"

#  get arg  list from config file
ARGS=$(head -1 $ARGSFILE | tail -1)

# add environment variables to args list
ARGS_FULL="$ARGS":"$HOME":"$LATERAL_RES":"$PBS_ARRAY_INDEX"

echo $ARGS_FULL

##load application module
module load fiji vnc

module load sysconfcpus/0.5

echo "running TSTORM macro!"
# run ThunderSTORM
sysconfcpus -n $NCPUS $IJ --ij2 -macro $HOME/Visualisation/TSTORM_vis_macro.ijm $ARGS_FULL

echo "End time $(date)"


