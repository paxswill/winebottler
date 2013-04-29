#!/bin/sh



##########               Import wineBottlerFunctions                   #########
################################################################################
echo "###BOTTLING### customprefix.sh"
source "$BUNDLERESOURCEPATH/bottler.sh"



##########                         predefines                         ##########
################################################################################
export WINEPREFIX=$BOTTLE



##########                   Installation Script                       #########
################################################################################
winebottlerPrefix

echo "###FINISHED###"
echo "###MAKESUREFINISHDISGETTINGTHRU###"
sleep 1
wait
echo "###MAKESUREFINISHDISGETTINGTHRU###"