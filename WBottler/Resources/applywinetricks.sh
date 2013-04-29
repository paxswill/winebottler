#!/bin/sh



##########               Import wineBottlerFunctions                   #########
################################################################################
echo "###BOTTLING### applywinetricks.sh"
source "$BUNDLERESOURCEPATH/bottler.sh"



##########                         predefines                         ##########
################################################################################
export WINEPREFIX=$BOTTLE



##########                   Installation Script                       #########
################################################################################
winebottlerWinetricks

echo "###FINISHED###"
echo "###MAKESUREFINISHDISGETTINGTHRU###"
sleep 1
wait
echo "###MAKESUREFINISHDISGETTINGTHRU###"