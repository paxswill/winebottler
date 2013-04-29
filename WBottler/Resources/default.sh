#!/bin/sh



##########               Import wineBottlerFunctions                   #########
################################################################################
echo "###BOTTLING### default.sh"
source "$BUNDLERESOURCEPATH/bottler.sh"



##########               Default Installation Script                   #########
################################################################################
winebottlerApp
wait
[ "$TEMPLATE" == "" ] && {
    winebottlerPrefix
    wait
}

winebottlerWinetricks
wait

winebottlerOverride
wait

winebottlerInstall
wait

winebottlerProxy
wait

echo "###FINISHED###"
echo "###MAKESUREFINISHDISGETTINGTHRU###"
sleep 1
wait
echo "###MAKESUREFINISHDISGETTINGTHRU###"
exit 0