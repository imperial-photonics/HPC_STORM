#!/bin/bash
#
#  Created by Ian Munro on 25/11/2016.
#

##load application modules
module load fiji vnc

#check to see if "my" display is already in use

MY=$(vncserver -list | grep :8)
MY=${MY:0:2}

if [ -n "$MY" ]; then
echo "Unable to start display " $MY
echo "Requested display is already in use!"

else

vncserver :8

MY=$(vncserver -list | grep :8)
MY=${MY:0:2}

echo "Started display "$MY
echo "Please connect to port 5908 "

read -p "Shut down display now? " answer

vncserver -kill $MY

rm core.*
rm .vnc/*.log


fi


